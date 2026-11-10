import Link from "next/link";
import { requireSponsor } from "@/lib/session";
import { Head, Kpi, Empty } from "@/components/ui";
import { num, fDate, today } from "@/lib/format";

export const metadata = { title: "Your Impact" };

type Row = {
  event_id: string; title: string; date: string | null; dated: boolean; venue: string; status: string; seats: number;
  requests: number; requested: number; approved: number; fulfilled: number; districts: string[]; schools: number; merits: Record<string, number>;
};

export default async function SponsorImpact() {
  const { supabase, profile } = await requireSponsor();
  const { data } = await supabase.rpc("sponsor_impact");
  const rows = (data || []) as Row[];
  const t = today();
  const awards = rows.reduce((s, r) => s + r.approved, 0);
  const tickets = rows.reduce((s, r) => s + r.approved * (r.seats || 1), 0);
  const districts = [...new Set(rows.flatMap((r) => r.districts))].sort();
  const merits: Record<string, number> = {};
  rows.forEach((r) => Object.entries(r.merits || {}).forEach(([k, v]) => { merits[k] = (merits[k] || 0) + v; }));
  const meritList = Object.entries(merits).sort((a, b) => b[1] - a[1]);
  const upcoming = rows.filter((r) => r.status === "Published" && (!r.dated || (r.date || "") >= t))
    .sort((a, b) => (b.requests > 0 ? 1 : 0) - (a.requests > 0 ? 1 : 0));
  const past = rows.filter((r) => r.requests > 0 && !upcoming.includes(r));

  const table = (list: Row[]) => (
    <div className="tbl-wrap"><table>
      <thead><tr><th>Listing</th><th className="n">Requested</th><th className="n">Awarded</th><th className="n">Sent</th><th>Districts</th><th className="n">Schools</th></tr></thead>
      <tbody>{list.map((r) => (
        <tr key={r.event_id}>
          <td><Link href={`/sponsor/events/${r.event_id}`}><b>{r.title}</b></Link><div className="sub">{r.dated ? fDate(r.date) : "Any time"}{r.venue ? ` · ${r.venue}` : ""}</div></td>
          <td className="n">{num(r.requested)}</td><td className="n">{num(r.approved)}</td><td className="n">{num(r.fulfilled)}</td>
          <td>{r.districts.length ? r.districts.join(", ") : <span className="sub">None yet</span>}</td>
          <td className="n">{num(r.schools)}</td>
        </tr>))}</tbody>
    </table></div>
  );

  return (
    <>
      <Head eyebrow={`${profile.partner} · Sponsor`} title="Your Impact"
        sub={<>How districts are using the rewards {profile.partner} provides. Awards are approved requests; each award is the number of seats shown on the listing. No student names are collected.</>} />
      <div className="kpis">
        <Kpi label="Awards approved" value={num(awards)} />
        <Kpi label="Tickets to students & families" value={num(tickets)} />
        <Kpi label="Districts reached" value={num(districts.length)} small={districts.join(" · ") || undefined} />
        <Kpi label="Listings open now" value={num(upcoming.length)} />
      </div>
      <section className="panel">
        <div className="ph"><h2>Earned for</h2><span className="sub">Merit types districts gave for your awards</span></div>
        {meritList.length ? <div className="chips">{meritList.map(([k, v]) => <span key={k} className="chip">{k}: {num(v)}</span>)}</div>
          : <p className="sub" style={{ margin: 0 }}>Nothing approved yet.</p>}
      </section>
      <section className="panel">
        <div className="ph"><h2>Open listings</h2><span className="sub">Ones with requests are listed first</span></div>
        {upcoming.length ? table(upcoming) : <Empty title="No upcoming listings">ClassTix adds your games and items as they&apos;re scheduled.</Empty>}
      </section>
      {past.length > 0 && <section className="panel"><div className="ph"><h2>Past and closed</h2></div>{table(past)}</section>}
    </>
  );
}
