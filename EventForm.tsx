"use client";

import { useState } from "react";
import { useFormState, useFormStatus } from "react-dom";
import { saveEvent } from "@/app/actions";
import { CATS } from "@/lib/format";
import type { EventRow } from "@/lib/types";

type T = { id?: string; name: string; qty: string; points: string; seats: string; approved: number };

function Save({ label }: { label: string }) {
  const { pending } = useFormStatus();
  return <button className="btn" type="submit" disabled={pending}>{pending ? "Saving…" : label}</button>;
}

export default function EventForm({ event, copy }: { event?: EventRow | null; copy?: boolean }) {
  const ex = copy ? null : event || null;
  const [f, setF] = useState(() => ({
    title: event?.title ?? "", cat: event?.cat ?? "sports", partner: event?.partner ?? "", description: event?.description ?? "",
    dated: event?.dated ?? true, date: copy ? "" : event?.date ?? "", time: event?.time ?? "", venue: event?.venue ?? "",
    deadline: copy ? "" : event?.deadline ?? "", max_per_request: event?.max_per_request ? String(event.max_per_request) : "",
    status: copy ? "Draft" : event?.status === "Draft" ? "Draft" : "Published",
  }));
  const [types, setTypes] = useState<T[]>(() =>
    event?.ticket_types?.length
      ? event.ticket_types.map((t) => ({ id: copy ? undefined : t.id, name: t.name, qty: String(t.qty), points: String(t.points), seats: String(t.seats), approved: copy ? 0 : t.approved }))
      : [{ name: "General admission", qty: "", points: "", seats: "2", approved: 0 }]);
  const [state, action] = useFormState(saveEvent, null);
  const set = (k: keyof typeof f) => (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => setF({ ...f, [k]: e.target.value });
  const setT = (i: number, k: keyof T) => (e: React.ChangeEvent<HTMLInputElement>) => setTypes(types.map((t, j) => (j === i ? { ...t, [k]: e.target.value } : t)));
  const payload = JSON.stringify({
    id: ex?.id ?? "", ...f, status: ex && (ex.status === "Cancelled" || ex.status === "Archived") ? ex.status : f.status,
    types: types.map((t) => ({ id: t.id ?? "", name: t.name, qty: Number(t.qty), points: Number(t.points), seats: Number(t.seats) || 1 })),
  });
  return (
    <form action={action} className="panel">
      <input type="hidden" name="payload" value={payload} />
      <div className="form">
        <div className="f full"><label htmlFor="title">Title</label><input type="text" id="title" value={f.title} onChange={set("title")} maxLength={90} required placeholder="Phoenix Suns home game" /></div>
        <div className="f"><label htmlFor="cat">Category</label><select id="cat" value={f.cat} onChange={set("cat")}>{Object.entries(CATS).map(([k, l]) => <option key={k} value={k}>{l}</option>)}</select></div>
        <div className="f"><label htmlFor="partner">Partner</label><input type="text" id="partner" value={f.partner} onChange={set("partner")} maxLength={60} placeholder="Phoenix Suns" /></div>
        <div className="f full"><label htmlFor="desc">Description</label><textarea id="desc" value={f.description} onChange={set("description")} maxLength={600} placeholder="What students and families get, and anything to know before going." /></div>
        <div className="f full"><span className="lab">Listing type</span><div className="chips">
          <button type="button" className="chip" aria-pressed={f.dated} onClick={() => setF({ ...f, dated: true })}>Dated event</button>
          <button type="button" className="chip" aria-pressed={!f.dated} onClick={() => setF({ ...f, dated: false })}>Undated item (gift card, pass)</button>
        </div></div>
        {f.dated && <>
          <div className="f"><label htmlFor="date">Event date</label><input type="date" id="date" value={f.date} onChange={set("date")} required /></div>
          <div className="f"><label htmlFor="time">Start time</label><input type="time" id="time" value={f.time} onChange={set("time")} /></div>
          <div className="f"><label htmlFor="venue">Venue</label><input type="text" id="venue" value={f.venue} onChange={set("venue")} maxLength={80} placeholder="Footprint Center, Phoenix" /></div>
          <div className="f"><label htmlFor="deadline">Request deadline</label><input type="date" id="deadline" value={f.deadline} onChange={set("deadline")} max={f.date || undefined} /><span className="hint">Districts can&apos;t request after this date. Blank means the event date.</span></div>
        </>}
        <div className="f"><label htmlFor="max">Max tickets per request</label><input type="number" id="max" min={1} value={f.max_per_request} onChange={set("max_per_request")} placeholder="No limit" /></div>
        {!(ex && (ex.status === "Cancelled" || ex.status === "Archived")) &&
          <div className="f"><label htmlFor="status">Status</label><select id="status" value={f.status} onChange={set("status")}><option>Published</option><option>Draft</option></select><span className="hint">Drafts are hidden from districts.</span></div>}
        <div className="f full"><span className="lab">Ticket or item types</span>
          <div className="types">{types.map((t, i) => (
            <div className="trow" key={i}>
              <div className="f"><label htmlFor={`tn${i}`}>Type name</label><input type="text" id={`tn${i}`} value={t.name} onChange={setT(i, "name")} maxLength={60} placeholder="Upper level" required /></div>
              <div className="f"><label htmlFor={`tq${i}`}>Quantity</label><input type="number" id={`tq${i}`} min={Math.max(1, t.approved)} value={t.qty} onChange={setT(i, "qty")} required />{t.approved ? <span className="hint">{t.approved} approved</span> : null}</div>
              <div className="f"><label htmlFor={`tp${i}`}>Points each</label><input type="number" id={`tp${i}`} min={1} value={t.points} onChange={setT(i, "points")} required /></div>
              <div className="f"><label htmlFor={`ts${i}`}>Seats each</label><input type="number" id={`ts${i}`} min={1} value={t.seats} onChange={setT(i, "seats")} /></div>
              <button type="button" className="btn sec sm" disabled={types.length < 2 || t.approved > 0} onClick={() => setTypes(types.filter((_, j) => j !== i))}>Remove</button>
            </div>))}
          </div>
          <div><button type="button" className="link" onClick={() => setTypes([...types, { name: "", qty: "", points: "", seats: "2", approved: 0 }])}>Add another type</button></div>
        </div>
      </div>
      {state?.error && <p className="msg-err" role="alert" style={{ marginTop: 14 }}>{state.error}</p>}
      <div className="row" style={{ marginTop: 18 }}><Save label={ex ? "Save changes" : "Save listing"} /></div>
    </form>
  );
}
