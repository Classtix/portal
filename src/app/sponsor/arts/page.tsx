import { requireSponsor } from "@/lib/session";
import { Head } from "@/components/ui";
import CategoryList from "@/components/CategoryList";
import { sortTypes } from "@/lib/format";
import type { EventRow } from "@/lib/types";

export const metadata = { title: "Arts & Culture" };

export default async function SponsorArts() {
  const { supabase, profile } = await requireSponsor();
  const { data } = await supabase.from("events").select("*, ticket_types(*)").eq("status", "Published").eq("cat", "arts");
  const all = ((data || []) as EventRow[]).map(sortTypes);
  return (
    <>
      <Head eyebrow={`${profile.partner} · Sponsor`} title="Arts & Culture" sub="Museums, performances and family visits districts can request. Browsing only." />
      <CategoryList hrefFor={(id) => `/sponsor/events/${id}`} groups={[
        { title: "Upcoming performances", items: all.filter((e) => e.dated) },
        { title: "Visit any time", sub: "Museums, gardens and family passes", items: all.filter((e) => !e.dated) },
      ]} />
    </>
  );
}
