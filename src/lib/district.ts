import "server-only";
import { requireDistrict } from "./session";
import type { Allowance, District, Settings } from "./types";

/** The signed-in district, its balance, the program month and any donated-ticket allowances. */
export async function districtContext() {
  const me = await requireDistrict();
  const did = me.profile.district_id!;
  const [{ data: d }, { data: avail }, { data: held }, { data: s }, { data: al }] = await Promise.all([
    me.supabase.from("districts").select("*").eq("id", did).maybeSingle(),
    me.supabase.rpc("available", { p_district: did }),
    me.supabase.rpc("held", { p_district: did }),
    me.supabase.from("settings").select("*").single(),
    me.supabase.rpc("district_allowance_status"),
  ]);
  return { ...me, district: d as District | null, available: (avail as number) ?? 0, held: (held as number) ?? 0, settings: s as Settings,
    allowances: ((al as Allowance[] | null) || []) };
}
