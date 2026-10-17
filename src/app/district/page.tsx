import Link from "next/link";
import { districtContext } from "@/lib/district";
import { Head, Kpi, Pill, Empty } from "@/components/ui";
import { num, pts, fDate, fShort, mLabel, today, TIERS } from "@/lib/format";
import type { RequestRow } from "@/lib/types";

export const metadata = { title: "Dashboard" };

export default async function DistrictDash() {
  const { supabase, district: d, available, held, settings } = await districtContext();
  if (!d) return null;
  const k = settings.current_month;
  const { data } = await supabase.from("requests").select("*, events(title, date, dated)").order("created_at", { ascending: false }).limit(200);
  const R = (data || []) as (RequestRow & { events: { title: string; date: string | null; dated: boolean } | null })[];
  const live = R.filter((r) => r.status === "Approved" || r.status === "Fulfilled");
  const spent = live.filter((r) => r.decided_at?.slice(0, 7) === k).reduce((s, r) => s + r.approved_qty * r.points_each, 0);
  const upcoming = live.filter((r) => r.events?.dated && (r.events.date || "") >= today()).sort((a, b) => (a.events!.date || "").localeCompare(b.events!.date || "")).slice(0, 5);
  return (
    <>
      <Head eyebrow={`${d.name} · ${mLabel(k)}`} title="Your rewards this month" sub="Request tickets and gift cards with your monthly points. ClassTix reviews each request and sends them."
        right={<Link className="btn" href="/district/calendar">Browse events</Link>} />
      <div className="kpis">
        <Kpi label="Available" value={pts(available)} small="ready to spend" hot />
        <Kpi label="On hold" value={pts(held)} small={`${R.filter((r) => r.status === "Pending").length} pending requests`} />
        <Kpi label="Spent this month" value={pts(spent)} small="approved requests" />
        <Kpi label="Monthly allocation" value={pts(d.monthly)} small={`${TIERS[d.tier]} tier`} />
      </div>
      <div className="grid2">
        <section className="panel"><h2>Upcoming approved events</h2>
          {upcoming.length ? <div className="list">{upcoming.map((r) => (
            <div className="item" key={r.id}><div><div className="t">{r.events!.title}</div><div className="m">{fDate(r.events!.date)} · {num(r.approved_qty)} tickets · {r.code}</div></div><Pill s={r.status} /></div>))}</div>
            : <Empty title="Nothing approved yet">Approved events show here with their dates.</Empty>}
        </section>
        <section className="panel"><div className="ph"><h2>Recent requests</h2><Link className="link" href="/district/requests">See all</Link></div>
          {R.length ? <div className="list">{R.slice(0, 5).map((r) => (
            <div className="item" key={r.id}><div><div className="t">{r.events?.title}</div><div className="m">{num(r.qty)} · {pts(r.qty * r.points_each)} · {fShort(r.created_at)}</div></div><Pill s={r.status} /></div>))}</div>
            : <Empty title="No requests yet"><Link href="/district/calendar">Open the event calendar</Link> to request tickets.</Empty>}
        </section>
      </div>
    </>
  );
}
