import "server-only";
import { redirect } from "next/navigation";
import { createClient } from "./supabase/server";
import type { Profile } from "./types";

/** The signed-in person's profile, or a redirect to sign-in. */
export async function getMe(): Promise<{ profile: Profile; supabase: ReturnType<typeof createClient> }> {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect("/login");
  const { data: profile } = await supabase.from("profiles").select("*").eq("id", user.id).maybeSingle();
  if (!profile || profile.status === "Deactivated") redirect("/login?e=access");
  return { profile: profile as Profile, supabase };
}

export async function requireAdmin() {
  const me = await getMe();
  if (me.profile.role !== "admin") redirect("/district");
  return me;
}

export async function requireDistrict() {
  const me = await getMe();
  if (me.profile.role !== "district") redirect("/admin");
  return me;
}
