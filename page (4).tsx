import Link from "next/link";
import { requireAdmin } from "@/lib/session";
import { Head, Pill, CatPill, Empty } from "@/components/ui";
import { num, fDate, evRemaining, evQty, evState, sortTypes } from "@/lib/format";
import type { EventRow } from "@/lib/types";

export const metadata = { title: "Events & items" };
const FILTERS: [string, string][] = [["live", "Published & drafts"], ["Published", "Published"], ["Draft", "Drafts"], ["retail", "Retail drops"], ["Cancelled", "Cancelled"], ["Archived", "Archived"], ["all", "All"]];

export default async function AdminEvents({ searchParams }: { searchParams: { f?: string; saved?: string } }) {
  const { supabase } = await requireAdmin();
  const f = FILTERS.some(([k]) => k === searchParams.f) ? searchParams.f! : "live";
  let q = supabase.from("events").select("*, ticket_types(*)").order("date", { ascending: true, nullsFirst: false }).order("title").limit(500);
  if (f === "live") q = q.in("status", ["Published", "Draft"]);
  else if (f === "retail") q = q.eq("series", "retail");
  else if (f !== "all") q = q.eq("status", f);
  const { data } = await q;
  const list = ((data || []) as EventRow[]).map(sortTypes);
  return (
    <>
      <Head eyebrow="ClassTix Admin" title="Events & items"
        sub="Dated events show on the district calendar. Undated items, like museum passes, show in the list view."
        right={<Link className="btn" href="/admin/events/new">New event or item</Link>} />
      {searchParams.saved && <p className="msg-ok">Saved. Districts see published listings right away.</p>}
      <div className="chips">{FILTERS.map(([k, l]) => <Link key={k} className="chip" aria-current={f === k ? "true" : undefined} href={`/admin/events?f=${k}`}>{l}</Link>)}</div>
      <section className="panel">
        {list.length ? <div className="tbl-wrap"><table>
          <thead><tr><th>Listing</th><th>When</th><th>Status</th><th className="n">Approved</th><th className="n">Remaining</th><th className="n">Points</th></tr></thead>
          <tbody>{list.map((e) => {
            const st = evState(e); const p = e.ticket_types.map((t) => t.points);
            const approved = e.ticket_types.reduce((s, t) => s + t.approved, 0);
            return (
              <tr key={e.id}>
                <td><Link href={`/admin/events/${e.id}`}><b>{e.title}</b></Link><div className="sub"><CatPill c={e.cat} /> {e.partner}</div></td>
                <td>{e.dated ? fDate(e.date) : <span className="sub">Anytime</span>}</td>
                <td><Pill s={e.status} ev={e.status === "Cancelled"} />{e.status === "Published" && st !== "Open" ? <> <span className="pill">{st}</span></> : null}</td>
                <td className="n">{num(approved)}</td>
                <td className="n">{num(evRemaining(e))} / {num(evQty(e))}</td>
                <td className="n">{p.length ? (Math.min(...p) === Math.max(...p) ? num(p[0]) : `${num(Math.min(...p))}–${num(Math.max(...p))}`) : "—"}</td>
              </tr>);
          })}</tbody></table></div>
          : <Empty title="No listings here">Choose New event or item to add the first one.</Empty>}
      </section>
    </>
  );
}
