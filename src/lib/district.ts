import "server-only";
import { requireDistrict } from "./session";
import type { District, Settings } from "./types";

/** The signed-in district, its balance and the program month. */
export async function districtContext() {
  const me = await requireDistrict();
  const did = me.profile.district_id!;
  const [{ data: d }, { data: avail }, { data: held }, { data: s }] = await Promise.all([
    me.supabase.from("districts").select("*").eq("id", did).maybeSingle(),
    me.supabase.rpc("available", { p_district: did }),
    me.supabase.rpc("held", { p_district: did }),
    me.supabase.from("settings").select("*").single(),
  ]);
  return { ...me, district: d as District | null, available: (avail as number) ?? 0, held: (held as number) ?? 0, settings: s as Settings };
}
