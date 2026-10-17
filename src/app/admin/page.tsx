import Link from "next/link";
import { requireAdmin } from "@/lib/session";
import { Head, Kpi, Pill, Empty } from "@/components/ui";
import { num, pts, fShort, fDate, mLabel, today, evRemaining, evQty, sortTypes } from "@/lib/format";
import type { District, EventRow, RequestRow, Settings } from "@/lib/types";

export const metadata = { title: "Dashboard" };

export default async function AdminDash() {
  const { supabase } = await requireAdmin();
  const t = today();
  const lim = new Date(new Date(t + "T12:00:00").getTime() + 45 * 864e5).toISOString().slice(0, 10);
  const [{ data: settings }, { data: reqs }, { data: districts }, { data: events }] = await Promise.all([
    supabase.from("settings").select("*").single(),
    supabase.from("requests").select("*").in("status", ["Pending", "Approved", "Fulfilled"]),
    supabase.from("districts").select("*").order("name"),
    supabase.from("events").select("*, ticket_types(*)").eq("status", "Published").eq("dated", true).gte("date", t).lte("date", lim).order("date").limit(8),
  ]);
  const k = (settings as Settings).current_month;
  const R = (reqs || []) as RequestRow[];
  const D = (districts || []) as District[];
  const evName = new Map<string, string>();
  const evIds = [...new Set(R.filter((r) => r.status === "Pending").map((r) => r.event_id))];
  if (evIds.length) {
    const { data } = await supabase.from("events").select("id,title").in("id", evIds);
    (data || []).forEach((e) => evName.set(e.id, e.title));
  }
  const pend = R.filter((r) => r.status === "Pending").sort((a, b) => a.created_at.localeCompare(b.created_at));
  const live = R.filter((r) => (r.status === "Approved" || r.status === "Fulfilled") && r.decided_at?.slice(0, 7) === k);
  const byD = D.filter((d) => d.status === "Active").map((d) => ({ d, n: live.filter((r) => r.district_id === d.id).reduce((s, r) => s + r.approved_qty, 0) })).sort((a, b) => b.n - a.n);
  const max = Math.max(1, ...byD.map((x) => x.n));
  const upcoming = ((events || []) as EventRow[]).map(sortTypes);
  const dname = (id: string) => D.find((d) => d.id === id)?.name || "";
  return (
    <>
      <Head eyebrow={`ClassTix Admin · ${mLabel(k)}`} title="Today at ClassTix" sub="Requests waiting on you, what's coming up, and where tickets went this month."
        right={<Link className="btn" href="/admin/requests">Open request queue</Link>} />
      <div className="kpis">
        <Kpi label="Pending requests" value={num(pend.length)} small={pend.length ? `Oldest from ${fShort(pend[0].created_at)}` : "Queue is clear"} hot={pend.length > 0} />
        <Kpi label="Approved, not yet sent" value={num(R.filter((r) => r.status === "Approved").length)} small="Mark fulfilled once tickets go out" />
        <Kpi label="Tickets approved" value={num(live.reduce((s, r) => s + r.approved_qty, 0))} small={`in ${mLabel(k)}`} />
        <Kpi label="Active districts" value={num(byD.length)} small={`${num(D.length - byD.length)} inactive`} />
      </div>
      <div className="grid3">
        <section className="panel">
          <div className="ph"><h2>Waiting for a decision</h2><Link className="link" href="/admin/requests">See all</Link></div>
          {pend.length ? <div className="list">{pend.slice(0, 6).map((r) => (
            <Link key={r.id} className="item click" style={{ color: "inherit", textDecoration: "none" }} href={`/admin/requests?id=${r.id}`}>
              <div><div className="t">{evName.get(r.event_id) || "Listing"}</div><div className="m">{dname(r.district_id)} · {num(r.qty)} tickets · {pts(r.qty * r.points_each)} · {r.code}</div></div>
              <Pill s="Pending" />
            </Link>))}</div> : <Empty title="No requests waiting">New district requests land here and in the Requests tab.</Empty>}
        </section>
        <section className="panel">
          <h2>Tickets approved by district</h2>
          {byD.length ? <div className="list">{byD.map((x) => (
            <div key={x.d.id} className="item"><div style={{ minWidth: 0 }}><div className="t">{x.d.name}</div>
              <div style={{ height: 8, borderRadius: 99, background: "var(--stub)", marginTop: 6, overflow: "hidden" }}><i style={{ display: "block", height: "100%", width: `${(x.n / max) * 100}%`, background: "var(--blue)", borderRadius: 99 }} /></div></div>
              <b className="num">{num(x.n)}</b></div>))}</div> : <Empty title="No districts yet"><Link href="/admin/districts">Add one under Districts.</Link></Empty>}
        </section>
      </div>
      <section className="panel">
        <div className="ph"><h2>Coming up in the next 45 days</h2><Link className="link" href="/admin/events">Manage events</Link></div>
        {upcoming.length ? <div className="tbl-wrap"><table><thead><tr><th>Event</th><th>Date</th><th className="n">Remaining</th></tr></thead><tbody>
          {upcoming.map((e) => <tr key={e.id}><td><Link href={`/admin/events/${e.id}`}><b>{e.title}</b></Link><div className="sub">{e.venue}</div></td><td>{fDate(e.date)}</td><td className="n">{num(evRemaining(e))} / {num(evQty(e))}</td></tr>)}
        </tbody></table></div> : <Empty title="Nothing dated in the next 45 days">Add an event with a date and it shows here.</Empty>}
      </section>
    </>
  );
}
