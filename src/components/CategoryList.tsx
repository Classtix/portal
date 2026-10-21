import RewardCard from "./RewardCard";
import { Empty } from "./ui";
import { today } from "@/lib/format";
import type { EventRow } from "@/lib/types";

/** Listings of one category, in titled groups. Dated listings are upcoming only, soonest first. */
export default function CategoryList({ groups, hrefFor }: {
  groups: { title: string; sub?: string; items: EventRow[] }[]; hrefFor: (id: string) => string;
}) {
  const t = today();
  const shown = groups.map((g) => ({
    ...g,
    items: g.items.filter((e) => !e.dated || (e.date || "") >= t)
      .sort((a, b) => (a.dated && b.dated ? (a.date || "").localeCompare(b.date || "") : a.title.localeCompare(b.title))),
  })).filter((g) => g.items.length);
  if (!shown.length) return <Empty title="Nothing here yet">ClassTix adds new rewards regularly. Check back soon.</Empty>;
  return <>{shown.map((g) => (
    <section key={g.title}>
      <div className="ph"><h2 style={{ fontSize: 19 }}>{g.title}</h2>{g.sub && <span className="sub">{g.sub}</span>}</div>
      <div className="stubs">{g.items.map((e) => <RewardCard key={e.id} e={e} href={hrefFor(e.id)} />)}</div>
    </section>))}</>;
}
