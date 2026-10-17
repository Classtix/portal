import Link from "next/link";
import { districtContext } from "@/lib/district";
import { Head, CatPill, Empty } from "@/components/ui";
import { CATS, num, pts, fDate, mLabel, mNext, mPrev, p2, thisMonth, today, evMin, evRemaining, evState, evWhen, sortTypes } from "@/lib/format";
import type { EventRow } from "@/lib/types";

export const metadata = { title: "Event calendar" };

function Stub({ e }: { e: EventRow }) {
  const s = evState(e); const closed = s !== "Open";
  return (
    <Link className={`tk ${closed ? "closed" : ""}`} href={`/district/events/${e.id}`} style={{ textDecoration: "none" }}>
      <div className="a"><CatPill c={e.cat} /><h3>{e.title}</h3>
        <div className="m">{evWhen(e)}{e.venue ? ` · ${e.venue}` : ""}</div>
        <div className="m">{closed ? <span className="flag">{s}</span> : <>{num(evRemaining(e))} left{e.dated && e.deadline ? ` · request by ${fDate(e.deadline)}` : ""}</>}</div></div>
      <div className="b"><span>from</span><strong>{num(evMin(e))}</strong><span>pts each</span></div>
    </Link>
  );
}

export default async function Calendar({ searchParams }: { searchParams: { m?: string; view?: string; cat?: string } }) {
  const { supabase, district, available } = await districtContext();
  if (!district) return null;
  const view = searchParams.view === "list" ? "list" : "month";
  const k = /^\d{4}-\d{2}$/.test(searchParams.m || "") ? searchParams.m! : thisMonth();
  const cat = searchParams.cat && CATS[searchParams.cat] ? searchParams.cat : "all";
  const { data } = await supabase.from("events").select("*, ticket_types(*)").eq("status", "Published").order("date", { ascending: true, nullsFirst: false });
  const all = ((data || []) as EventRow[]).map(sortTypes);
  const cats = [...new Set(all.map((e) => e.cat))];
  const vis = all.filter((e) => cat === "all" || e.cat === cat);
  const undated = vis.filter((e) => !e.dated);
  const href = (p: Record<string, string>) => { const u = new URLSearchParams({ view, m: k, cat, ...p }); return `/district/calendar?${u}`; };
  const t = today();

  let body: React.ReactNode;
  if (view === "month") {
    const [y, m] = k.split("-").map(Number);
    const first = new Date(y, m - 1, 1); const start = new Date(first); start.setDate(1 - first.getDay());
    const cells: React.ReactNode[] = [];
    for (let i = 0; i < 42; i++) {
      const dd = new Date(start); dd.setDate(start.getDate() + i);
      const iso = `${dd.getFullYear()}-${p2(dd.getMonth() + 1)}-${p2(dd.getDate())}`;
      const out = dd.getMonth() !== m - 1;
      if (i >= 35 && out && dd.getDay() === 0) break;
      const evs = vis.filter((e) => e.dated && e.date === iso);
      cells.push(
        <div key={iso} className={`d ${out ? "out" : ""} ${iso === t ? "today" : ""} ${evs.length ? "" : "none"}`}>
          <span className="dn"><span className="dshort">{dd.getDate()}</span><span className="dlong">{fDate(iso)}</span></span>
          {evs.map((e) => { const s = evState(e); return (
            <Link key={e.id} className={`ce ${s !== "Open" ? "x" : ""}`} href={`/district/events/${e.id}`} style={{ textDecoration: "none" }}>
              <b>{e.title}</b><span className="dl">{s === "Open" ? `${num(evRemaining(e))} left · from ${num(evMin(e))} pts` : s}</span>
            </Link>); })}
        </div>);
    }
    const any = vis.some((e) => e.dated && e.date?.slice(0, 7) === k);
    body = <>
      <div className="row">
        <Link className="btn sec sm" href={href({ m: mPrev(k) })} aria-label="Previous month">‹</Link>
        <h2 style={{ fontSize: 22, minWidth: 180, textAlign: "center" }}>{mLabel(k)}</h2>
        <Link className="btn sec sm" href={href({ m: mNext(k) })} aria-label="Next month">›</Link>
        {k !== thisMonth() && <Link className="link" href={href({ m: thisMonth() })}>This month</Link>}
      </div>
      <div className="cal">{["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"].map((x) => <div key={x} className="dh">{x}</div>)}{cells}</div>
      {!any && <p className="sub">No dated events in {mLabel(k)}{cat !== "all" ? " for this category" : ""}.</p>}
    </>;
  } else {
    const dated = vis.filter((e) => e.dated && (e.date || "") >= t);
    body = <section><div className="ph"><h2 style={{ fontSize: 19 }}>Upcoming events</h2></div>
      {dated.length ? <div className="stubs">{dated.map((e) => <Stub key={e.id} e={e} />)}</div> : <Empty title="No upcoming dated events">Check back soon, or browse the anytime rewards below.</Empty>}</section>;
  }
  return (
    <>
      <Head eyebrow={district.name} title="Event calendar" sub={<>You have <b>{pts(available)}</b> available. Pick an event to see seats, point costs and the request deadline.</>} />
      <div className="row">
        <div className="chips">
          <Link className="chip" aria-current={cat === "all" ? "true" : undefined} href={href({ cat: "all" })}>All</Link>
          {cats.map((c) => <Link key={c} className="chip" aria-current={cat === c ? "true" : undefined} href={href({ cat: c })}>{CATS[c] || c}</Link>)}
        </div>
        <span className="spacer" />
        <div className="chips">
          <Link className="chip" aria-current={view === "month" ? "true" : undefined} href={href({ view: "month" })}>Month</Link>
          <Link className="chip" aria-current={view === "list" ? "true" : undefined} href={href({ view: "list" })}>List</Link>
        </div>
      </div>
      {body}
      {undated.length > 0 && <section><div className="ph"><h2 style={{ fontSize: 19 }}>Anytime rewards</h2><span className="sub">Passes and visits without a set date</span></div>
        <div className="stubs">{undated.map((e) => <Stub key={e.id} e={e} />)}</div></section>}
    </>
  );
}
