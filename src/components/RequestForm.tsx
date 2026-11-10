"use client";

import { useState } from "react";
import { useFormState, useFormStatus } from "react-dom";
import { submitRequest } from "@/app/actions";
import type { Allowance, TicketType } from "@/lib/types";
import { MERIT_TYPES, allowanceOptions, qtyOptions } from "@/lib/format";

const pts = (n: number) => `${Math.round(n).toLocaleString("en-US")} pts`;

function Submit({ disabled }: { disabled: boolean }) {
  const { pending } = useFormStatus();
  return <button className="btn" type="submit" disabled={disabled || pending} style={{ width: "100%", justifyContent: "center" }}>{pending ? "Sending…" : "Submit request"}</button>;
}

export default function RequestForm({ types, available, max, unit, schools, step = 2, donated }: { types: TicketType[]; available: number; max: number | null; unit: string; schools: string[]; step?: number; donated?: Allowance }) {
  const first = types.find((t) => t.qty - t.approved > 0) || types[0];
  const [tid, setTid] = useState(first?.id || "");
  const [qty, setQty] = useState("");
  const [state, action] = useFormState(submitRequest, null);
  const t = types.find((x) => x.id === tid);
  const left = t ? t.qty - t.approved : 0;
  const seats = t?.seats || 1;
  const opts = donated ? allowanceOptions(donated.remaining, seats, left, max) : qtyOptions(left, max, step);
  const q = opts.includes(parseInt(qty, 10)) ? parseInt(qty, 10) : 0;
  const schoolList = schools.length ? schools : ["District-wide"];
  const cost = t && !donated ? q * t.points : 0;
  const tix = (o: number) => `${o * seats} ticket${o * seats === 1 ? "" : "s"}`;
  let problem = "";
  if (q > 0 && t && donated) {
    if (q * seats > donated.remaining) problem = `Your district has ${donated.remaining} donated tickets left.`;
  } else if (q > 0 && t) {
    if (q > left) problem = `Only ${left} ${t.name} left.`;
    else if (max && q > max) problem = `The most you can request here is ${max}.`;
    else if (cost > available) problem = `This costs ${pts(cost)} and you have ${pts(available)} available.`;
  }
  return (
    <form action={action} style={{ display: "flex", flexDirection: "column", gap: 14 }}>
      <input type="hidden" name="type_id" value={tid} />
      <div className="f"><label htmlFor="rt">{unit === "cards" ? "Gift card" : "Ticket type"}</label>
        <select id="rt" value={tid} onChange={(e) => { setTid(e.target.value); setQty(""); }}>
          {types.map((x) => { const l = x.qty - x.approved; return <option key={x.id} value={x.id} disabled={l <= 0}>{x.name}{donated ? "" : ` · ${x.points} pts`}{l <= 0 ? " (sold out)" : ` · ${l} left`}</option>; })}
        </select></div>
      <div className="f"><label htmlFor="rq">How many {unit}</label>
        <select id="rq" name="qty" value={q ? String(q) : ""} onChange={(e) => setQty(e.target.value)} required>
          <option value="" disabled>{opts.length ? "Choose an amount" : donated && donated.remaining < seats ? "No donated tickets left" : "None left"}</option>
          {donated ? opts.map((o) => <option key={o} value={o}>{tix(o)}{seats > 1 ? ` (${o} award${o === 1 ? "" : "s"})` : ""}</option>)
          : opts.map((o) => { const short = t ? o * t.points > available : false;
            return <option key={o} value={o} disabled={short}>{o} · {pts(t ? o * t.points : 0)}{short ? " (not enough points)" : ""}</option>; })}
        </select></div>
      <fieldset className="f" style={{ border: 0, padding: 0, margin: 0, display: "flex", flexDirection: "column", gap: 10 }}>
        <legend className="lab" style={{ padding: 0, marginBottom: 6, fontWeight: 700 }}>Merit awarded for</legend>
        <div className="f"><label htmlFor="rs">School</label>
          <select id="rs" name="school" defaultValue={schoolList.length === 1 ? schoolList[0] : ""} required>
            {schoolList.length > 1 && <option value="" disabled>Choose a school</option>}
            {schoolList.map((x) => <option key={x}>{x}</option>)}
          </select>
          {!schools.length && <span className="hint">ClassTix hasn&apos;t added your schools yet. Ask hello@classtix.org to add them.</span>}</div>
        <div className="f"><label htmlFor="rm">Merit type</label>
          <select id="rm" name="merit" defaultValue="" required>
            <option value="" disabled>Choose a merit type</option>
            {MERIT_TYPES.map((x) => <option key={x}>{x}</option>)}
          </select></div>
      </fieldset>
      {donated ? <div className="calc">
        <span>Donated tickets left</span><b>{donated.remaining} of {donated.tickets}</b>
        <span>This request</span><b className="tot">{q ? tix(q) : "0 tickets"}</b>
        <span>Left after request</span><b>{Math.max(donated.remaining - q * seats, 0)}</b>
        <span>Points</span><b>None used</b>
      </div> : <div className="calc">
        <span>Total</span><b className="tot">{pts(cost)}</b>
        <span>Available now</span><b>{pts(available)}</b>
        <span>Available after request</span><b className={available - cost < 0 ? "neg" : ""}>{pts(available - cost)}</b>
      </div>}
      {problem && <p className="err">{problem}</p>}
      {state?.error && <p className="msg-err" role="alert">{state.error}</p>}
      <Submit disabled={!t || q < 1 || !!problem} />
      <p className="sub" style={{ margin: 0 }}>{donated
        ? <>{donated.note || `Donated ${donated.partner} tickets`}. No points are used. Pending and approved requests count toward your {donated.tickets}; if ClassTix rejects one or you cancel, those tickets come back.</>
        : "Points are held as soon as you submit. If ClassTix rejects it or you cancel, they come back."}</p>
    </form>
  );
}
