import Link from "next/link";
import { districtContext } from "@/lib/district";
import { Head, Empty, CatPill } from "@/components/ui";
import { num, fDate, fmtTime, fSize, today } from "@/lib/format";
import type { Delivery, RequestRow } from "@/lib/types";

export const metadata = { title: "My Tickets" };

type Row = RequestRow & {
  events: { title: string; date: string | null; dated: boolean; time: string | null; venue: string; cat: string; series: string | null } | null;
  ticket_types: { name: string } | null;
  deliveries: Delivery[];
};
const KINDS = [["all", "All"], ["tickets", "Tickets"], ["cards", "Gift cards"]] as const;
const isCard = (r: Row) => /^(giftcard-|retail)/.test(r.events?.series || "");

export default async function MyTickets({ searchParams }: { searchParams: { kind?: string } }) {
  const { supabase, district } = await districtContext();
  if (!district) return null;
  const kind = KINDS.some(([k]) => k === searchParams.kind) ? searchParams.kind! : "all";
  const { data } = await supabase.from("requests")
    .select("*, events(title, date, dated, time, venue, cat, series), ticket_types(name), deliveries(*)")
    .in("status", ["Approved", "Fulfilled"]).order("created_at", { ascending: false }).limit(500);
  const t = today();
  const all = ((data || []) as Row[]).filter((r) => kind === "all" || (kind === "cards") === isCard(r));
  const past = (r: Row) => !!(r.events?.dated && r.events.date && r.events.date < t);
  const byDate = (a: Row, b: Row) => (a.events?.date || "9999").localeCompare(b.events?.date || "9999");
  const ready = all.filter((r) => r.deliveries.length && !past(r)).sort(byDate);
  const waiting = all.filter((r) => !r.deliveries.length && !past(r)).sort(byDate);
  const old = all.filter(past).sort((a, b) => byDate(b, a));

  return (
    <>
      <Head eyebrow={district.name} title="My Tickets"
        sub="Tickets and gift cards for your approved requests. Download them here once ClassTix attaches them." />
      <div className="chips">{KINDS.map(([k, l]) => <Link key={k} className="chip" aria-current={kind === k ? "true" : undefined} href={`/district/tickets?kind=${k}`}>{l}</Link>)}</div>
      {!all.length ? <section className="panel"><Empty title="No tickets yet">When ClassTix approves a request, it shows up here. <Link className="link" href="/district/calendar">Browse the calendar</Link>.</Empty></section> : <>
        <Group title="Ready to download" rows={ready} empty="Nothing ready yet." />
        {waiting.length > 0 && <Group title="Being prepared" sub="Approved. ClassTix will attach the tickets or gift cards here and email you." rows={waiting} />}
        {old.length > 0 && <Group title="Past events" rows={old} />}
      </>}
    </>
  );
}

function Group({ title, sub, rows, empty }: { title: string; sub?: string; rows: Row[]; empty?: string }) {
  return (
    <section className="panel">
      <div className="ph"><h2>{title}</h2>{sub && <span className="sub">{sub}</span>}</div>
      {rows.length ? <div className="list">{rows.map((r) => {
        const e = r.events;
        return (
          <div className="item" key={r.id} style={{ gridTemplateColumns: "minmax(0,1fr)", alignItems: "start" }}>
            <div className="row" style={{ gap: 8, alignItems: "baseline" }}>
              {e && <CatPill c={e.cat} />}
              <b style={{ fontSize: 16 }}>{e?.title || "Listing removed"}</b>
            </div>
            <div className="m sub">
              {[e?.dated ? `${fDate(e.date)}${e.time ? " · " + fmtTime(e.time) : ""}` : "Any time", e?.venue, `${num(r.approved_qty)} × ${r.ticket_types?.name || "item"}`, r.merit ? `${r.merit}, ${r.school}` : "", r.code].filter(Boolean).join(" · ")}
            </div>
            {r.deliveries.length > 0 && <div className="row" style={{ gap: 8, marginTop: 6, flexWrap: "wrap" }}>
              {r.deliveries.map((d) => (
                <a key={d.id} className={d.kind === "file" ? "btn sm" : "btn sec sm"} href={`/district/tickets/download/${d.id}`}
                  target={d.kind === "link" ? "_blank" : undefined} rel="noreferrer"
                  title={d.kind === "file" ? `${d.file_name}${d.size ? ` (${fSize(d.size)})` : ""}` : d.url || ""}>
                  {d.kind === "file" ? "Download" : "Open link"}{d.label ? `: ${d.label}` : d.kind === "file" && d.file_name ? `: ${d.file_name}` : ""}
                </a>))}
            </div>}
          </div>);
      })}</div> : <p className="sub" style={{ margin: 0 }}>{empty}</p>}
    </section>
  );
}
