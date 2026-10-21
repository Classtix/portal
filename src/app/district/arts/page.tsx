import { districtContext } from "@/lib/district";
import { Head } from "@/components/ui";
import CategoryList from "@/components/CategoryList";
import { pts, sortTypes } from "@/lib/format";
import type { EventRow } from "@/lib/types";

export const metadata = { title: "Arts & Culture" };

export default async function Arts() {
  const { supabase, district, available } = await districtContext();
  if (!district) return null;
  const { data } = await supabase.from("events").select("*, ticket_types(*)").eq("status", "Published").eq("cat", "arts");
  const all = ((data || []) as EventRow[]).map(sortTypes);
  return (
    <>
      <Head eyebrow={district.name} title="Arts & Culture" sub={<>Museums, performances and family visits. You have <b>{pts(available)}</b> available.</>} />
      <CategoryList hrefFor={(id) => `/district/events/${id}`} groups={[
        { title: "Upcoming performances", items: all.filter((e) => e.dated) },
        { title: "Visit any time", sub: "Museums, gardens and family passes", items: all.filter((e) => !e.dated) },
      ]} />
    </>
  );
}
