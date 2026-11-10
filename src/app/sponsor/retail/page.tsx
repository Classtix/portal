import { requireSponsor } from "@/lib/session";
import { Head } from "@/components/ui";
import CategoryList from "@/components/CategoryList";
import { sortTypes } from "@/lib/format";
import type { EventRow } from "@/lib/types";

export const metadata = { title: "Restaurant & Retail" };
const PRICES = "$25 = 13 pts · $50 = 25 pts · $100 = 50 pts · $250 = 125 pts";

export default async function SponsorRetail() {
  const { supabase, profile } = await requireSponsor();
  const { data } = await supabase.from("events").select("*, ticket_types(*)").eq("status", "Published").eq("cat", "retail");
  const all = ((data || []) as EventRow[]).map(sortTypes);
  const isCard = (e: EventRow) => (e.series || "").startsWith("giftcard-");
  return (
    <>
      <Head eyebrow={`${profile.partner} · Sponsor`} title="Restaurant & Retail" sub="Gift cards districts can request any time. Browsing only." />
      <CategoryList hrefFor={(id) => `/sponsor/events/${id}`} groups={[
        { title: "Gift cards", sub: PRICES, items: all.filter(isCard) },
        { title: "Restaurants", sub: PRICES, items: all.filter((e) => !isCard(e)) },
      ]} />
    </>
  );
}
