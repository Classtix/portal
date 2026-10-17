import Link from "next/link";
import { CatPill, Empty } from "./ui";
import { CATS, num, fDate, mLabel, mNext, mPrev, p2, thisMonth, today, evMin, evRemaining, evState, evWhen } from "@/lib/format";
import type { EventRow } from "@/lib/types";

/**
 * Month and list calendar shared by the district and admin sides.
 * `basePath` is the page's own URL (for filter links); `hrefFor` is where an event opens.
 * `admin` shows draft listings and a status label on each event.
 */
export default function CalendarView({ events, k, view, cat, basePath, hrefFor, admin }: {
  events: EventRow[]; k: string; view: "month" | "list"; cat: string; basePath: string;
  hrefFor: (id: string) => string; admin?: boolean;
}) {
  const cats = [...new Set(events.map((e) => e.cat))];
  const vis = events.filter((e) => cat === "all" || e.cat === cat);
  const undated = vis.filter((e) => !e.dated);
  const href = (p: Record<string, string>) => `${basePath}?${new URLSearchParams({ view, m: k, cat, ...p })}`;
  const t = today();
  const label = (e: EventRow) => {
    const s = evState(e);
    if (s === "Draft") return "Draft · hidden from districts";
    return s === "Open" ? `${num(evRemaining(e))} left · from ${num(evMin(e))} pts` : s;
  };

  const Stub = ({ e }: { e: EventRow }) => {
    const s = evState(e); const closed = s !== "Open";
    return (
      <Link className={`tk ${closed ? "closed" : ""}`} href={hrefFor(e.id)} style={{ textDecoration: "none" }}>
        <div className="a"><CatPill c={e.cat} /><h3>{e.title}</h3>
          <div className="m">{evWhen(e)}{e.venue ? ` · ${e.venue}` : ""}</div>
          <div className="m">{closed ? <span className="flag">{s === "Draft" ? "Draft" : s}</span> : <>{num(evRemaining(e))} left{e.dated && e.deadline ? ` · request by ${fDate(e.deadline)}` : ""}</>}</div></div>
        <div className="b"><span>from</span><strong>{num(evMin(e))}</strong><span>pts each</span></div>
      </Link>
    );
  };

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
          {evs.map((e) => (
            <Link key={e.id} title={`${e.title} · ${label(e)}`} className={`ce ${evState(e) !== "Open" ? "x" : ""}`} href={hrefFor(e.id)} style={{ textDecoration: "none" }}>
              <b>{e.title}</b><span className="dl">{label(e)}</span>
            </Link>))}
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
      {dated.length ? <div className="stubs">{dated.map((e) => <Stub key={e.id} e={e} />)}</div>
        : <Empty title="No upcoming dated events">{admin ? "Add one under Events & items." : "Check back soon, or browse the anytime rewards below."}</Empty>}</section>;
  }
  return (
    <>
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

/** Reads the calendar's month, view and category from the page's search params. */
export function calendarParams(sp: { m?: string; view?: string; cat?: string }) {
  return {
    view: (sp.view === "list" ? "list" : "month") as "month" | "list",
    k: /^\d{4}-\d{2}$/.test(sp.m || "") ? sp.m! : thisMonth(),
    cat: sp.cat && CATS[sp.cat] ? sp.cat : "all",
  };
}
