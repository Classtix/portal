import { districtContext } from "@/lib/district";
import { Head } from "@/components/ui";
import CategoryList from "@/components/CategoryList";
import { pts, sortTypes } from "@/lib/format";
import type { EventRow } from "@/lib/types";

export const metadata = { title: "Restaurant & Retail" };
const PRICES = "$25 = 13 pts · $50 = 25 pts · $100 = 50 pts · $250 = 125 pts";

export default async function Retail() {
  const { supabase, district, available } = await districtContext();
  if (!district) return null;
  const { data } = await supabase.from("events").select("*, ticket_types(*)").eq("status", "Published").eq("cat", "retail");
  const all = ((data || []) as EventRow[]).map(sortTypes);
  const isCard = (e: EventRow) => (e.series || "").startsWith("giftcard-");
  return (
    <>
      <Head eyebrow={district.name} title="Restaurant & Retail" sub={<>Gift cards and restaurant rewards, available any time. You have <b>{pts(available)}</b> available.</>} />
      <CategoryList hrefFor={(id) => `/district/events/${id}`} groups={[
        { title: "Gift cards", sub: PRICES, items: all.filter(isCard) },
        { title: "Restaurants", sub: PRICES, items: all.filter((e) => !isCard(e)) },
      ]} />
    </>
  );
}
