import { districtContext } from "@/lib/district";
import { Head } from "@/components/ui";
import CategoryList from "@/components/CategoryList";
import { sortTypes } from "@/lib/format";
import type { EventRow } from "@/lib/types";

export const metadata = { title: "Families · Access ASU" };

export default async function Families() {
  const { supabase, district } = await districtContext();
  if (!district) return null;
  const { data } = await supabase.from("events").select("*, ticket_types(*)").eq("status", "Published").eq("cat", "families");
  const all = ((data || []) as EventRow[]).map(sortTypes);
  return (
    <>
      <Head eyebrow={district.name} title="Families · Access ASU"
        sub="Free programs from the Access ASU network for your award winners and their families. They cost no points. Request one per student or family; once ClassTix approves it, the sign-up link appears in My Tickets." />
      <CategoryList hrefFor={(id) => `/district/events/${id}`} groups={[
        { title: "Summer camp", sub: "July · all grades · one spot per student", items: all.filter((e) => e.series === "families-camp") },
        { title: "For parents & families", sub: "ASU Family Hub, newsletter, college prep and WeGrad", items: all.filter((e) => e.series !== "families-camp") },
      ]} />
    </>
  );
}
