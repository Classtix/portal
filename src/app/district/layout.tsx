import Shell from "@/components/Shell";
import { requireDistrict } from "@/lib/session";

export default async function DistrictLayout({ children }: { children: React.ReactNode }) {
  const { profile, supabase } = await requireDistrict();
  const { data: d } = await supabase.from("districts").select("name").eq("id", profile.district_id!).maybeSingle();
  return (
    <Shell me={profile} districtName={d?.name} nav={[
      { href: "/district", label: "Dashboard", exact: true },
      { href: "/district/calendar", label: "Event Calendar" },
      { href: "/district/retail", label: "Restaurant & Retail" },
      { href: "/district/arts", label: "Arts & Culture" },
      { href: "/district/requests", label: "My Requests" },
      { href: "/district/tickets", label: "My Tickets" },
      { href: "/district/points", label: "Points History" },
    ]}>
      {d ? children : <p className="banner">Your district isn&apos;t active right now, so requests are paused. Contact ClassTix at hello@classtix.org.</p>}
    </Shell>
  );
}
