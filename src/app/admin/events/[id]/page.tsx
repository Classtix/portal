import Link from "next/link";
import { notFound } from "next/navigation";
import { requireAdmin } from "@/lib/session";
import { Head, Pill } from "@/components/ui";
import EventForm from "@/components/EventForm";
import ActionForm from "@/components/ActionForm";
import Pop from "@/components/Pop";
import { setEventStatus, cancelEvent } from "@/app/actions";
import { num, sortTypes } from "@/lib/format";
import type { EventRow } from "@/lib/types";

export const metadata = { title: "Edit listing" };

export default async function EditEvent({ params }: { params: { id: string } }) {
  const { supabase } = await requireAdmin();
  const { data } = await supabase.from("events").select("*, ticket_types(*)").eq("id", params.id).maybeSingle();
  if (!data) notFound();
  const e = sortTypes(data as EventRow);
  const { data: reqs } = await supabase.from("requests").select("status").eq("event_id", e.id);
  const c = (s: string) => (reqs || []).filter((r) => r.status === s).length;
  const approved = e.ticket_types.reduce((s, t) => s + t.approved, 0);
  const closed = e.status === "Cancelled" || e.status === "Archived";
  return (
    <>
      <Head eyebrow={<>Edit listing · <Pill s={e.status} ev={e.status === "Cancelled"} /></>} title={e.title}
        sub={`${num(approved)} tickets approved · ${c("Pending")} pending · ${c("Fulfilled")} fulfilled`}
        right={<>
          <Link className="btn sec" href={`/admin/requests?status=All&event=${e.id}`}>See requests</Link>
          <Link className="btn sec" href={`/admin/events/new?from=${e.id}`}>Duplicate</Link>
          <Link className="btn sec" href="/admin/events">Back to list</Link>
        </>} />
      <EventForm event={e} />
      <section className="panel">
        <h2>Status</h2>
        <div className="row" style={{ alignItems: "flex-start" }}>
          {e.status === "Archived" && <ActionForm action={setEventStatus} hidden={{ id: e.id, status: "Draft" }} submit="Restore as draft" buttonClass="btn sec" />}
          {!closed && <ActionForm action={setEventStatus} hidden={{ id: e.id, status: "Archived" }} submit="Archive" buttonClass="btn sec" />}
          {!closed && <Pop label="Cancel event" className="btn danger">
            <p style={{ margin: 0 }}>{c("Pending")} pending requests are rejected and {c("Approved")} approved, not-yet-sent requests are cancelled. Their points go back and each district is emailed.
              {c("Fulfilled") ? ` ${c("Fulfilled")} fulfilled requests already have tickets; follow up with those districts directly.` : ""}</p>
            <ActionForm action={cancelEvent} hidden={{ id: e.id }} submit="Yes, cancel this event" buttonClass="btn danger" pendingLabel="Cancelling…" />
          </Pop>}
          {closed && e.status === "Cancelled" && <p className="sub" style={{ margin: 0 }}>Cancelled events stay on record for reporting.</p>}
        </div>
      </section>
    </>
  );
}
