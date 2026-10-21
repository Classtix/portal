import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { CATS, today } from "@/lib/format";

const cell = (v: unknown) => { const s = String(v ?? ""); return /[",\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s; };
const csv = (rows: unknown[][]) => rows.map((r) => r.map(cell).join(",")).join("\n");

export async function GET(_: Request, { params }: { params: { kind: string } }) {
  const supabase = createClient();
  const { data: isAdmin } = await supabase.rpc("is_admin");
  if (!isAdmin) return NextResponse.json({ error: "Only ClassTix admins can export." }, { status: 403 });
  const [{ data: districts }, { data: events }] = await Promise.all([
    supabase.from("districts").select("id,name"), supabase.from("events").select("*, ticket_types(*)"),
  ]);
  const dn = new Map((districts || []).map((d) => [d.id, d.name]));
  const ev = new Map((events || []).map((e) => [e.id, e]));
  let rows: unknown[][];
  if (params.kind === "requests") {
    const { data } = await supabase.from("requests").select("*").order("created_at");
    rows = [["Code", "District", "Listing", "Event date", "Type", "Requested", "Approved", "Points each", "Points used", "Status", "Reason", "School", "Merit type", "Submitted", "Decided", "Fulfilled"]];
    (data || []).forEach((r) => {
      const e = ev.get(r.event_id); const t = e?.ticket_types.find((x: { id: string }) => x.id === r.type_id);
      const live = r.status === "Approved" || r.status === "Fulfilled";
      rows.push([r.code, dn.get(r.district_id), e?.title, e?.date, t?.name, r.qty, live ? r.approved_qty : 0, r.points_each, live ? r.approved_qty * r.points_each : 0, r.status, r.reason, r.school, r.merit || r.note, r.created_at, r.decided_at, r.fulfilled_at]);
    });
  } else if (params.kind === "ledger") {
    const { data } = await supabase.from("ledger").select("*").order("at").order("id");
    rows = [["Date", "District", "Entry", "Ref", "Points"], ...(data || []).map((l) => [l.at, dn.get(l.district_id), l.entry, l.ref, l.amount])];
  } else if (params.kind === "events") {
    rows = [["Title", "Category", "Partner", "Status", "Date", "Deadline", "Venue", "Type", "Quantity", "Approved", "Remaining", "Points each"]];
    (events || []).forEach((e) => e.ticket_types.forEach((t: { name: string; qty: number; approved: number; points: number }) =>
      rows.push([e.title, CATS[e.cat] || e.cat, e.partner, e.status, e.date, e.deadline, e.venue, t.name, t.qty, t.approved, t.qty - t.approved, t.points])));
  } else return NextResponse.json({ error: "Unknown export." }, { status: 404 });
  return new NextResponse(csv(rows), {
    headers: { "Content-Type": "text/csv; charset=utf-8", "Content-Disposition": `attachment; filename="classtix-${params.kind}-${today()}.csv"` },
  });
}
