import Link from "next/link";
import { requireAdmin } from "@/lib/session";
import { Head, Pill, Empty } from "@/components/ui";
import ActionForm from "@/components/ActionForm";
import Pop from "@/components/Pop";
import { approveRequest, rejectRequest, fulfilRequest, saveInternalNote } from "@/app/actions";
import { num, pts, fDate, fDT, evWhen, remaining, sortTypes, REJECT_REASONS } from "@/lib/format";
import type { District, EventRow, RequestRow } from "@/lib/types";

export const metadata = { title: "Requests" };
const STATUSES = ["Pending", "Approved", "Fulfilled", "Rejected", "Cancelled", "All"];

export default async function AdminRequests({ searchParams }: { searchParams: { status?: string; district?: string; event?: string; id?: string; ok?: string } }) {
  const { supabase } = await requireAdmin();
  const status = STATUSES.includes(searchParams.status || "") ? searchParams.status! : searchParams.id ? "All" : "Pending";
  let q = supabase.from("requests").select("*").order("created_at", { ascending: status !== "Pending" ? false : true }).limit(300);
  if (status !== "All") q = q.eq("status", status);
  if (searchParams.district) q = q.eq("district_id", searchParams.district);
  if (searchParams.event) q = q.eq("event_id", searchParams.event);
  const [{ data: reqs }, { data: districts }, { data: counts }] = await Promise.all([
    q, supabase.from("districts").select("*").order("name"),
    supabase.from("requests").select("status").in("status", ["Pending", "Approved"]),
  ]);
  const R = (reqs || []) as RequestRow[];
  const D = (districts || []) as District[];
  const evIds = [...new Set(R.map((r) => r.event_id).concat(searchParams.event ? [searchParams.event] : []))];
  const { data: evs } = evIds.length ? await supabase.from("events").select("*, ticket_types(*)").in("id", evIds) : { data: [] };
  const E = new Map(((evs || []) as EventRow[]).map((e) => [e.id, sortTypes(e)]));
  if (status === "Pending") R.sort((a, b) => (E.get(a.event_id)?.date || "9999").localeCompare(E.get(b.event_id)?.date || "9999") || a.created_at.localeCompare(b.created_at));
  const selId = searchParams.id || R[0]?.id;
  let sel = R.find((r) => r.id === selId) || null;
  if (!sel && searchParams.id) {
    const { data } = await supabase.from("requests").select("*").eq("id", searchParams.id).maybeSingle();
    sel = data as RequestRow | null;
    if (sel && !E.has(sel.event_id)) {
      const { data: e } = await supabase.from("events").select("*, ticket_types(*)").eq("id", sel.event_id).maybeSingle();
      if (e) E.set(e.id, sortTypes(e as EventRow));
    }
  }
  const cnt = (s: string) => (counts || []).filter((c) => c.status === s).length;
  const href = (p: Record<string, string | undefined>) => {
    const u = new URLSearchParams();
    const m = { status, district: searchParams.district, event: searchParams.event, ...p };
    Object.entries(m).forEach(([k, v]) => v && u.set(k, v));
    return `/admin/requests?${u.toString()}`;
  };
  const label = (r: RequestRow) => { const e = E.get(r.event_id); const t = e?.ticket_types.find((x) => x.id === r.type_id); return `${e?.title || "Listing"}${t ? " · " + t.name : ""}`; };
  return (
    <>
      <Head eyebrow="ClassTix Admin" title="Requests" sub="Sorted by event date while pending. Approving updates inventory and the district's points right away." />
      <div className="row">
        <div className="chips">{STATUSES.map((s) => (
          <Link key={s} className="chip" aria-current={status === s ? "true" : undefined} href={href({ status: s, id: undefined })}>
            {s}{(s === "Pending" || s === "Approved") && cnt(s) ? ` · ${cnt(s)}` : ""}
          </Link>))}</div>
        <span className="spacer" />
        <form className="row" action="/admin/requests">
          <input type="hidden" name="status" value={status} />
          <select className="sel" name="district" defaultValue={searchParams.district || ""} aria-label="District">
            <option value="">All districts</option>{D.map((d) => <option key={d.id} value={d.id}>{d.name}</option>)}
          </select>
          <button className="btn sec sm" type="submit">Filter</button>
          {(searchParams.district || searchParams.event) && <Link className="link" href={`/admin/requests?status=${status}`}>Clear</Link>}
        </form>
      </div>
      <div className="grid3">
        <section className="panel">
          {R.length ? <div className="list">{R.map((r) => (
            <Link key={r.id} href={href({ id: r.id })} className={`item click ${r.id === sel?.id ? "on" : ""}`} style={{ color: "inherit", textDecoration: "none" }}>
              <div style={{ minWidth: 0 }}>
                <div className="t">{D.find((d) => d.id === r.district_id)?.name || "District"}</div>
                <div className="m">{label(r)}</div>
                <div className="m">{num(r.status === "Pending" ? r.qty : r.approved_qty || r.qty)} tickets · {E.get(r.event_id)?.dated ? fDate(E.get(r.event_id)!.date) : "Anytime"} · {r.code}</div>
              </div>
              <Pill s={r.status} />
            </Link>))}</div>
            : <Empty title={status === "Pending" ? "No pending requests" : "Nothing matches these filters"}>Requests appear here as districts submit them.</Empty>}
        </section>
        <section className="panel" id="detail">
          {searchParams.ok && sel?.id === searchParams.id && <p className="msg-ok" style={{ marginBottom: 14 }}>{searchParams.ok}</p>}
          {sel ? <Detail back={status} r={sel} e={E.get(sel.event_id) || null} d={D.find((d) => d.id === sel!.district_id) || null} /> : <p className="sub">Choose a request to review it.</p>}
        </section>
      </div>
    </>
  );
}

async function Detail({ r, e, d, back }: { r: RequestRow; e: EventRow | null; d: District | null; back: string }) {
  const { supabase } = await requireAdmin();
  const [{ data: avail }, { data: held }, { data: note }] = await Promise.all([
    supabase.rpc("available", { p_district: r.district_id }),
    supabase.rpc("held", { p_district: r.district_id }),
    supabase.from("request_notes").select("note").eq("request_id", r.id).maybeSingle(),
  ]);
  const t = e?.ticket_types.find((x) => x.id === r.type_id);
  const left = t ? remaining(t) : 0;
  const over = r.status === "Pending" && r.qty > left;
  return (
    <div className="detail">
      <div className="ph"><h2>{r.code}</h2><Pill s={r.status} /></div>
      <dl className="dl">
        <dt>District</dt><dd>{d?.name || "—"}</dd>
        <dt>Balance</dt><dd>{pts(avail as number)} available · {pts(held as number)} on hold</dd>
        <dt>Listing</dt><dd>{e?.title || "Removed"}{e && <div className="sub">{evWhen(e)}{e.venue ? " · " + e.venue : ""}</div>}</dd>
        <dt>Type</dt><dd>{t?.name || "—"} · {pts(r.points_each)} each</dd>
        <dt>Requested</dt><dd>{num(r.qty)} · {pts(r.qty * r.points_each)}</dd>
        {(r.status === "Approved" || r.status === "Fulfilled") && <><dt>Approved</dt><dd>{num(r.approved_qty)} · {pts(r.approved_qty * r.points_each)}</dd></>}
        <dt>Remaining</dt><dd>{t ? `${num(left)} of ${num(t.qty)} left` : "—"}</dd>
        <dt>Submitted</dt><dd>{fDT(r.created_at)}</dd>
        {r.decided_at && <><dt>Decided</dt><dd>{fDT(r.decided_at)}</dd></>}
        {r.fulfilled_at && <><dt>Fulfilled</dt><dd>{fDT(r.fulfilled_at)}</dd></>}
        {r.reason && <><dt>Reason</dt><dd>{r.reason}</dd></>}
        <dt>District note</dt><dd>{r.note || <span className="sub">No note</span>}</dd>
      </dl>
      {over && <p className="note">Only {num(left)} left. Approve part of this request or reject it.</p>}
      {r.status === "Pending" && (
        <div className="row" style={{ alignItems: "flex-start" }}>
          <ActionForm action={approveRequest} hidden={{ id: r.id, back }} submit={`Approve ${num(r.qty)}`} pendingLabel="Approving…" disabled={over || !left} />
          {r.qty > 1 && left > 0 && <Pop label="Approve part">
            <ActionForm action={approveRequest} hidden={{ id: r.id, back }} submit="Approve these" pendingLabel="Approving…">
              <div className="f"><label htmlFor="pq">Tickets to approve (1–{Math.min(r.qty - 1, left)})</label>
                <input id="pq" name="qty" type="number" min={1} max={Math.min(r.qty - 1, left)} required /></div>
              <p className="sub" style={{ margin: 0 }}>Unused points go back to the district.</p>
            </ActionForm>
          </Pop>}
          <Pop label="Reject" className="btn danger sm">
            <ActionForm action={rejectRequest} hidden={{ id: r.id, back }} submit="Reject request" buttonClass="btn danger" pendingLabel="Rejecting…">
              <div className="f"><label htmlFor="rr">Reason the district will see</label>
                <select id="rr" name="reason" required defaultValue="">
                  <option value="" disabled>Choose a reason</option>{REJECT_REASONS.map((x) => <option key={x}>{x}</option>)}<option>Other</option>
                </select></div>
              <div className="f"><label htmlFor="ro">If Other, write it here</label><input id="ro" name="other" type="text" maxLength={160} /></div>
            </ActionForm>
          </Pop>
        </div>
      )}
      {r.status === "Approved" && <ActionForm action={fulfilRequest} hidden={{ id: r.id, back }} submit="Mark fulfilled" buttonClass="btn blue" pendingLabel="Saving…" />}
      <ActionForm action={saveInternalNote} hidden={{ id: r.id }} submit="Save note" buttonClass="btn sec sm">
        <div className="f"><label htmlFor="inote">Internal note <span className="sub">(only ClassTix sees this)</span></label>
          <textarea id="inote" name="note" defaultValue={note?.note || ""} placeholder="Tickets sent via Ticketmaster transfer" /></div>
      </ActionForm>
    </div>
  );
}
