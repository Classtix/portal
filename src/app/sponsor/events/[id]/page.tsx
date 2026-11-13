import Link from "next/link";
import { notFound } from "next/navigation";
import { requireSponsor } from "@/lib/session";
import { Head, CatPill } from "@/components/ui";
import { num, fDate, fmtTime, evWhen, remaining, sortTypes, partnerOf } from "@/lib/format";
import type { EventRow } from "@/lib/types";

export const metadata = { title: "Listing" };

export default async function SponsorEvent({ params }: { params: { id: string } }) {
  const { supabase, profile } = await requireSponsor();
  const { data } = await supabase.from("events").select("*, ticket_types(*)").eq("id", params.id).maybeSingle();
  if (!data) notFound();
  const e = sortTypes(data as EventRow);
  const mine = partnerOf(profile.partner || "", e.partner);
  const back = e.cat === "families" ? ["/sponsor/families", "Families · Access ASU"] : e.cat === "retail" ? ["/sponsor/retail", "Restaurant & Retail"] : e.cat === "arts" ? ["/sponsor/arts", "Arts & Culture"] : ["/sponsor/calendar", "Music & Sports Calendar"];
  return (
    <>
      <div><Link className="link" href={back[0]}>← Back to {back[1]}</Link></div>
      <Head eyebrow={<><CatPill c={e.cat} /> {e.partner}</>} title={e.title} sub={e.cat === "families" ? (e.series === "families-camp" ? "July · all grades · free" : "Free for award winners' families") : `${evWhen(e)}${e.venue ? " · " + e.venue : ""}`} />
      <section className="panel">
        {mine && <p className="msg-ok" style={{ marginBottom: 14 }}>This is one of your listings. <Link className="link" href="/sponsor">See its impact</Link>.</p>}
        <p style={{ margin: "0 0 14px", maxWidth: "62ch" }}>{e.description || <span className="sub">No description yet.</span>}</p>
        <dl className="dl">
          {e.dated ? <><dt>Date</dt><dd>{fDate(e.date)}{e.time ? ` · ${fmtTime(e.time)}` : ""}</dd><dt>Districts request by</dt><dd>{fDate(e.deadline)}</dd></> : <><dt>Date</dt><dd>{e.series === "families-camp" ? "July" : "Any time"}</dd></>}
        </dl>
        <div className="tbl-wrap" style={{ marginTop: 16 }}><table>
          <thead><tr><th>Type</th><th className="n">Seats each</th><th className="n">Points each</th><th className="n">Remaining</th></tr></thead>
          <tbody>{e.ticket_types.map((t) => <tr key={t.id}><td><b>{t.name}</b></td><td className="n">{num(t.seats)}</td><td className="n">{t.points ? num(t.points) : "Free"}</td><td className="n">{num(remaining(t))} / {num(t.qty)}</td></tr>)}</tbody>
        </table></div>
        <p className="sub" style={{ margin: "14px 0 0" }}>Districts request rewards from their own portal. As a sponsor you can browse but not request.</p>
      </section>
    </>
  );
}
