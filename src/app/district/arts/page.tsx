import { districtContext } from "@/lib/district";
import AllowanceNotice from "@/components/AllowanceNotice";
import { Head } from "@/components/ui";
import CategoryList from "@/components/CategoryList";
import { pts, sortTypes } from "@/lib/format";
import type { EventRow } from "@/lib/types";

export const metadata = { title: "Arts & Culture" };

export default async function Arts() {
  const { supabase, district, available, allowances } = await districtContext();
  if (!district) return null;
  const { data } = await supabase.from("events").select("*, ticket_types(*)").eq("status", "Published").eq("cat", "arts");
  const all = ((data || []) as EventRow[]).map(sortTypes);
  return (
    <>
      <Head eyebrow={district.name} title="Arts & Culture" sub={<>Museums, performances and family visits. You have <b>{pts(available)}</b> available.</>} />
      <AllowanceNotice allowances={allowances} />
      <CategoryList hrefFor={(id) => `/district/events/${id}`} groups={[
        { title: "Upcoming performances", items: all.filter((e) => e.dated) },
        { title: "Visit any time", sub: "Museums, gardens and family passes", items: all.filter((e) => !e.dated) },
      ]} />
    </>
  );
}
