import type { EventRow, TicketType } from "./types";

export const CATS: Record<string, string> = {
  sports: "Sports", music: "Music", arts: "Arts & Culture", retail: "Restaurant & Retail", other: "Other",
};
export const RATE_LABEL = "$2 per student";
/** Monthly points for a district: $2 per student, all of it as points at $2 each — 1 point per student. */
export const monthlyFor = (students: number) => Math.max(0, Math.round(students));
export const REJECT_REASONS = ["Not enough tickets left", "Request exceeds a fair share for this event", "Request deadline passed"];

const TZ = "America/Phoenix";
export const num = (n: number | null | undefined) => Math.round(Number(n) || 0).toLocaleString("en-US");
export const pts = (n: number | null | undefined) => `${num(n)} pts`;
export const p2 = (n: number) => String(n).padStart(2, "0");

/** Today's date in Phoenix as YYYY-MM-DD. */
export function today(): string {
  const parts = new Intl.DateTimeFormat("en-CA", { timeZone: TZ, year: "numeric", month: "2-digit", day: "2-digit" }).format(new Date());
  return parts; // en-CA formats as YYYY-MM-DD
}
export const thisMonth = () => today().slice(0, 7);
const noon = (iso: string) => new Date(iso + "T12:00:00");
export const fDate = (iso: string | null | undefined) =>
  iso ? noon(iso).toLocaleDateString("en-US", { weekday: "short", month: "short", day: "numeric" }) : "";
export const fShort = (ts: string | null | undefined) =>
  ts ? new Date(ts).toLocaleDateString("en-US", { month: "short", day: "numeric", timeZone: TZ }) : "—";
export const fDT = (ts: string | null | undefined) =>
  ts ? new Date(ts).toLocaleString("en-US", { month: "short", day: "numeric", hour: "numeric", minute: "2-digit", timeZone: TZ }) : "—";
export function mLabel(k: string) {
  const [y, m] = k.split("-").map(Number);
  return new Date(y, m - 1, 1).toLocaleDateString("en-US", { month: "long", year: "numeric" });
}
export function mNext(k: string) { const [y, m] = k.split("-").map(Number); return m === 12 ? `${y + 1}-01` : `${y}-${p2(m + 1)}`; }
export function mPrev(k: string) { const [y, m] = k.split("-").map(Number); return m === 1 ? `${y - 1}-12` : `${y}-${p2(m - 1)}`; }
export function fmtTime(t: string) {
  if (!t) return "";
  const [h, m] = t.split(":").map(Number);
  if (Number.isNaN(h)) return t;
  return `${h % 12 || 12}${m ? ":" + p2(m) : ""} ${h < 12 ? "AM" : "PM"}`;
}
export const remaining = (t: TicketType) => Math.max(0, t.qty - t.approved);
export const evRemaining = (e: EventRow) => e.ticket_types.reduce((s, t) => s + remaining(t), 0);
export const evQty = (e: EventRow) => e.ticket_types.reduce((s, t) => s + t.qty, 0);
export const evMin = (e: EventRow) => (e.ticket_types.length ? Math.min(...e.ticket_types.map((t) => t.points)) : 0);
export const evWhen = (e: EventRow) =>
  e.dated ? `${fDate(e.date)}${e.time ? " · " + fmtTime(e.time) : ""}` : "Anytime · no event date";
export function evState(e: EventRow): "Open" | "Closed" | "Sold out" | EventRow["status"] {
  if (e.status !== "Published") return e.status;
  if (e.dated && e.deadline && e.deadline < today()) return "Closed";
  if (evRemaining(e) <= 0) return "Sold out";
  return "Open";
}
export const sortTypes = (e: EventRow) => ({ ...e, ticket_types: [...(e.ticket_types || [])].sort((a, b) => a.sort - b.sort) });
