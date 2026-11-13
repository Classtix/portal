import Link from "next/link";
import { notFound } from "next/navigation";
import { districtContext } from "@/lib/district";
import { Head, CatPill } from "@/components/ui";
import RequestForm from "@/components/RequestForm";
import { num, fDate, fmtTime, evState, evWhen, remaining, sortTypes, allowedFor, isFree } from "@/lib/format";
import type { EventRow } from "@/lib/types";

export const metadata = { title: "Event" };

export default async function DistrictEvent({ params }: { params: { id: string } }) {
  const { supabase, district, available, allowances } = await districtContext();
  if (!district) return null;
  const { data } = await supabase.from("events").select("*, ticket_types(*)").eq("id", params.id).maybeSingle();
  if (!data) notFound();
  const e = sortTypes(data as EventRow);
  const s = evState(e);
  const isCard = /^(giftcard|restaurantcard)-/.test(e.series || "");
  const free = isFree(e);
  const unit = isCard ? "cards" : e.cat === "families" ? (e.series === "families-camp" ? "students" : "families") : e.cat === "retail" ? "awards" : "tickets";
  const plain = unit === "cards" || e.cat === "families";
  const donated = allowances.find((a) => a.partner.toLowerCase() === (e.partner || "").toLowerCase());
  const allowed = free || allowedFor(allowances, e.partner);
  const back = e.cat === "families" ? ["/district/families", "Families · Access ASU"] : e.cat === "retail" ? ["/district/retail", "Restaurant & Retail"] : e.cat === "arts" ? ["/district/arts", "Arts & Culture"] : ["/district/calendar", "Music & Sports Calendar"];
  return (
    <>
      <div><Link className="link" href={back[0]}>← Back to {back[1]}</Link></div>
      <Head eyebrow={<><CatPill c={e.cat} /> {e.partner}</>} title={e.title} sub={e.cat === "families" ? (e.series === "families-camp" ? "July · all grades · free" : "Free for award winners' families") : `${evWhen(e)}${e.venue ? " · " + e.venue : ""}`} />
      <div className="grid3">
        <section className="panel">
          <h2>About</h2>
          <p style={{ margin: "0 0 14px", maxWidth: "62ch" }}>{e.description || <span className="sub">No description yet.</span>}</p>
          <dl className="dl">
            {e.dated ? <><dt>Date</dt><dd>{fDate(e.date)}{e.time ? ` · ${fmtTime(e.time)}` : ""}</dd><dt>Request by</dt><dd>{fDate(e.deadline)}</dd></> : <><dt>Date</dt><dd>{e.series === "families-camp" ? "July" : "Anytime"}</dd></>}
            <dt>Per request</dt><dd>{e.max_per_request ? `Up to ${num(e.max_per_request)}` : "No limit"}</dd>
          </dl>
          <div className="tbl-wrap" style={{ marginTop: 16 }}><table>
            <thead><tr><th>Type</th>{!plain && <th className="n">Seats each</th>}<th className="n">Points each</th><th className="n">Remaining</th></tr></thead>
            <tbody>{e.ticket_types.map((t) => <tr key={t.id}><td><b>{t.name}</b></td>{!plain && <td className="n">{num(t.seats)}</td>}<td className="n">{t.points ? num(t.points) : "Free"}</td><td className="n">{num(remaining(t))} / {num(t.qty)}</td></tr>)}</tbody>
          </table></div>
        </section>
        <section className="panel">
          <h2>{e.cat === "families" ? (unit === "students" ? "Request camp spots" : "Request access") : `Request ${unit}`}</h2>
          {!allowed ? <p className="banner">Right now your district can request {allowances.map((a) => a.partner).join(", ")} only. You can still browse everything else; ask ClassTix if you&apos;d like other rewards opened up.</p>
            : s !== "Open" ? <p className="banner">{s === "Sold out" ? "This listing is sold out." : s === "Closed" ? "The request deadline has passed." : "This listing isn't open for requests."}</p>
            : <RequestForm types={e.ticket_types} available={available} max={e.max_per_request} unit={unit} schools={district.schools || []} step={e.cat === "retail" || e.cat === "families" ? 1 : 2} donated={free ? undefined : donated} free={free ? e.partner || "the sponsor" : undefined} />}
        </section>
      </div>
    </>
  );
}
