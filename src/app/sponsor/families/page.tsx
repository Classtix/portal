import { requireSponsor } from "@/lib/session";
import { Head } from "@/components/ui";
import CategoryList from "@/components/CategoryList";
import { sortTypes } from "@/lib/format";
import type { EventRow } from "@/lib/types";

export const metadata = { title: "Families · Access ASU" };

export default async function SponsorFamilies() {
  const { supabase, profile } = await requireSponsor();
  const { data } = await supabase.from("events").select("*, ticket_types(*)").eq("status", "Published").eq("cat", "families");
  const all = ((data || []) as EventRow[]).map(sortTypes);
  return (
    <>
      <Head eyebrow={`${profile.partner} · Sponsor`} title="Families · Access ASU" sub="Free Access ASU programs districts can request for award winners' families. Browsing only." />
      <CategoryList hrefFor={(id) => `/sponsor/events/${id}`} groups={[
        { title: "Summer camp", items: all.filter((e) => e.series === "families-camp") },
        { title: "For parents & families", items: all.filter((e) => e.series !== "families-camp") },
      ]} />
    </>
  );
}
