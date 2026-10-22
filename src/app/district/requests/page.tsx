import Link from "next/link";
import { districtContext } from "@/lib/district";
import { Head, Pill, Empty } from "@/components/ui";
import ActionForm from "@/components/ActionForm";
import Pop from "@/components/Pop";
import { cancelRequest } from "@/app/actions";
import { num, pts, fDate, fShort } from "@/lib/format";
import type { RequestRow } from "@/lib/types";

export const metadata = { title: "My Requests" };
const ST = ["all", "Pending", "Approved", "Fulfilled", "Rejected", "Cancelled"];

export default async function MyRequests({ searchParams }: { searchParams: { status?: string; sent?: string } }) {
  const { supabase, district } = await districtContext();
  if (!district) return null;
  const st = ST.includes(searchParams.status || "") ? searchParams.status! : "all";
  let q = supabase.from("requests").select("*, events(title, date, dated), ticket_types(name)").order("created_at", { ascending: false }).limit(300);
  if (st !== "all") q = q.eq("status", st);
  const { data } = await q;
  const R = (data || []) as (RequestRow & { events: { title: string; date: string | null; dated: boolean } | null; ticket_types: { name: string } | null })[];
  return (
    <>
      <Head eyebrow={district.name} title="My Requests" sub="Track every request from submitted to tickets sent." />
      {searchParams.sent && <p className="msg-ok">Request {searchParams.sent} sent. Its points are on hold until ClassTix reviews it.</p>}
      <div className="chips">{ST.map((s) => <Link key={s} className="chip" aria-current={st === s ? "true" : undefined} href={`/district/requests?status=${s}`}>{s === "all" ? "All" : s}</Link>)}</div>
      <section className="panel">
        {R.length ? <div className="tbl-wrap"><table>
          <thead><tr><th>Request</th><th>Event date</th><th className="n">Qty</th><th className="n">Points</th><th>Status</th><th></th></tr></thead>
          <tbody>{R.map((r) => {
            const live = r.status === "Approved" || r.status === "Fulfilled"; const q = live ? r.approved_qty : r.qty;
            return (
              <tr key={r.id}>
                <td><b>{r.events?.title}</b>{r.ticket_types ? <> · {r.ticket_types.name}</> : null}
                  <div className="sub">{r.code} · sent {fShort(r.created_at)}{r.note ? ` · ${r.note}` : ""}</div>
                  {r.reason && <div className="sub">Reason: {r.reason}</div>}
                  {live && r.approved_qty < r.qty && <div className="sub">{num(r.approved_qty)} of {num(r.qty)} approved</div>}</td>
                <td>{r.events?.dated ? fDate(r.events.date) : "Anytime"}</td>
                <td className="n">{num(q)}</td><td className="n">{pts(q * r.points_each)}</td>
                <td><Pill s={r.status} /></td>
                <td>{r.status === "Pending" && <Pop label="Cancel">
                  <p style={{ margin: 0 }}>Cancel {r.code}? Your {pts(r.qty * r.points_each)} come back right away.</p>
                  <ActionForm action={cancelRequest} hidden={{ id: r.id }} submit="Cancel request" buttonClass="btn danger sm" />
                </Pop>}</td>
              </tr>);
          })}</tbody></table></div>
          : <Empty title="No requests here"><Link href="/district/calendar">Open the Music &amp; Sports Events Calendar</Link> to request tickets.</Empty>}
      </section>
    </>
  );
}
