import Shell from "@/components/Shell";
import { requireSponsor } from "@/lib/session";

export default async function SponsorLayout({ children }: { children: React.ReactNode }) {
  const { profile, supabase } = await requireSponsor();
  const { count: fam } = await supabase.from("events").select("id", { count: "exact", head: true }).eq("cat", "families").eq("status", "Published");
  return (
    <Shell me={profile} nav={[
      { href: "/sponsor", label: "Your Impact", exact: true },
      { href: "/sponsor/calendar", label: "Music & Sports Calendar" },
      { href: "/sponsor/retail", label: "Restaurant & Retail" },
      { href: "/sponsor/arts", label: "Arts & Culture" },
      ...(fam ? [{ href: "/sponsor/families", label: "Families · Access ASU" }] : []),
    ]}>{children}</Shell>
  );
}
