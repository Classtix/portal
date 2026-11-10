import Shell from "@/components/Shell";
import { requireSponsor } from "@/lib/session";

export default async function SponsorLayout({ children }: { children: React.ReactNode }) {
  const { profile } = await requireSponsor();
  return (
    <Shell me={profile} nav={[
      { href: "/sponsor", label: "Your Impact", exact: true },
      { href: "/sponsor/calendar", label: "Music & Sports Calendar" },
      { href: "/sponsor/retail", label: "Restaurant & Retail" },
      { href: "/sponsor/arts", label: "Arts & Culture" },
    ]}>{children}</Shell>
  );
}
