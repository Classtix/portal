"use client";

import { useState } from "react";
import { useFormState, useFormStatus } from "react-dom";
import { submitRequest } from "@/app/actions";
import type { TicketType } from "@/lib/types";

const pts = (n: number) => `${Math.round(n).toLocaleString("en-US")} pts`;

function Submit({ disabled }: { disabled: boolean }) {
  const { pending } = useFormStatus();
  return <button className="btn" type="submit" disabled={disabled || pending} style={{ width: "100%", justifyContent: "center" }}>{pending ? "Sending…" : "Submit request"}</button>;
}

export default function RequestForm({ types, available, max, unit }: { types: TicketType[]; available: number; max: number | null; unit: string }) {
  const first = types.find((t) => t.qty - t.approved > 0) || types[0];
  const [tid, setTid] = useState(first?.id || "");
  const [qty, setQty] = useState("");
  const [state, action] = useFormState(submitRequest, null);
  const t = types.find((x) => x.id === tid);
  const left = t ? t.qty - t.approved : 0;
  const q = parseInt(qty, 10) || 0;
  const cost = t ? q * t.points : 0;
  let problem = "";
  if (q > 0 && t) {
    if (q > left) problem = `Only ${left} ${t.name} left.`;
    else if (max && q > max) problem = `The most you can request here is ${max}.`;
    else if (cost > available) problem = `This costs ${pts(cost)} and you have ${pts(available)} available.`;
  }
  return (
    <form action={action} style={{ display: "flex", flexDirection: "column", gap: 14 }}>
      <input type="hidden" name="type_id" value={tid} />
      <div className="f"><label htmlFor="rt">{unit === "cards" ? "Gift card" : "Ticket type"}</label>
        <select id="rt" value={tid} onChange={(e) => setTid(e.target.value)}>
          {types.map((x) => { const l = x.qty - x.approved; return <option key={x.id} value={x.id} disabled={l <= 0}>{x.name} · {x.points} pts{l <= 0 ? " (sold out)" : ` · ${l} left`}</option>; })}
        </select></div>
      <div className="f"><label htmlFor="rq">How many {unit}</label>
        <input id="rq" name="qty" type="number" min={1} max={Math.min(left, max || left)} value={qty} onChange={(e) => setQty(e.target.value)} placeholder="e.g. 10" required /></div>
      <div className="f"><label htmlFor="rn">Note for ClassTix</label>
        <textarea id="rn" name="note" maxLength={300} placeholder="Attendance winners, Lincoln Elementary" />
        <span className="hint">Use school and award names. Please don&apos;t include student names.</span></div>
      <div className="calc">
        <span>Total</span><b className="tot">{pts(cost)}</b>
        <span>Available now</span><b>{pts(available)}</b>
        <span>Available after request</span><b className={available - cost < 0 ? "neg" : ""}>{pts(available - cost)}</b>
      </div>
      {problem && <p className="err">{problem}</p>}
      {state?.error && <p className="msg-err" role="alert">{state.error}</p>}
      <Submit disabled={!t || q < 1 || !!problem} />
      <p className="sub" style={{ margin: 0 }}>Points are held as soon as you submit. If ClassTix rejects it or you cancel, they come back.</p>
    </form>
  );
}
