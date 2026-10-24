import Shell from "@/components/Shell";
import { requireAdmin } from "@/lib/session";

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const { profile, supabase } = await requireAdmin();
  const [{ count }, { count: asm }] = await Promise.all([
    supabase.from("requests").select("id", { count: "exact", head: true }).eq("status", "Pending"),
    supabase.from("assembly_requests").select("id", { count: "exact", head: true }).eq("status", "Requested"),
  ]);
  return (
    <Shell me={profile} nav={[
      { href: "/admin", label: "Dashboard", exact: true },
      { href: "/admin/requests", label: "Requests", count: count || 0 },
      { href: "/admin/assemblies", label: "Assemblies", count: asm || 0 },
      { href: "/admin/calendar", label: "Calendar" },
      { href: "/admin/events", label: "Events & items" },
      { href: "/admin/districts", label: "Districts" },
      { href: "/admin/users", label: "Users" },
      { href: "/admin/email", label: "Email log" },
      { href: "/admin/settings", label: "Program settings" },
    ]}>{children}</Shell>
  );
}
