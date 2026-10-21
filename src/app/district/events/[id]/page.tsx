import Link from "next/link";
import { notFound } from "next/navigation";
import { districtContext } from "@/lib/district";
import { Head, CatPill } from "@/components/ui";
import RequestForm from "@/components/RequestForm";
import { num, fDate, fmtTime, evState, evWhen, remaining, sortTypes } from "@/lib/format";
import type { EventRow } from "@/lib/types";

export const metadata = { title: "Event" };

export default async function DistrictEvent({ params }: { params: { id: string } }) {
  const { supabase, district, available } = await districtContext();
  if (!district) return null;
  const { data } = await supabase.from("events").select("*, ticket_types(*)").eq("id", params.id).maybeSingle();
  if (!data) notFound();
  const e = sortTypes(data as EventRow);
  const s = evState(e);
  const isCard = (e.series || "").startsWith("giftcard-");
  const unit = isCard ? "cards" : e.cat === "retail" ? "awards" : "tickets";
  const back = e.cat === "retail" ? ["/district/retail", "Restaurant & Retail"] : e.cat === "arts" ? ["/district/arts", "Arts & Culture"] : ["/district/calendar", "calendar"];
  return (
    <>
      <div><Link className="link" href={back[0]}>← Back to {back[1]}</Link></div>
      <Head eyebrow={<><CatPill c={e.cat} /> {e.partner}</>} title={e.title} sub={`${evWhen(e)}${e.venue ? " · " + e.venue : ""}`} />
      <div className="grid3">
        <section className="panel">
          <h2>About</h2>
          <p style={{ margin: "0 0 14px", maxWidth: "62ch" }}>{e.description || <span className="sub">No description yet.</span>}</p>
          <dl className="dl">
            {e.dated ? <><dt>Date</dt><dd>{fDate(e.date)}{e.time ? ` · ${fmtTime(e.time)}` : ""}</dd><dt>Request by</dt><dd>{fDate(e.deadline)}</dd></> : <><dt>Date</dt><dd>Anytime</dd></>}
            <dt>Per request</dt><dd>{e.max_per_request ? `Up to ${num(e.max_per_request)}` : "No limit"}</dd>
          </dl>
          <div className="tbl-wrap" style={{ marginTop: 16 }}><table>
            <thead><tr><th>Type</th>{unit !== "cards" && <th className="n">Seats each</th>}<th className="n">Points each</th><th className="n">Remaining</th></tr></thead>
            <tbody>{e.ticket_types.map((t) => <tr key={t.id}><td><b>{t.name}</b></td>{unit !== "cards" && <td className="n">{num(t.seats)}</td>}<td className="n">{num(t.points)}</td><td className="n">{num(remaining(t))} / {num(t.qty)}</td></tr>)}</tbody>
          </table></div>
        </section>
        <section className="panel">
          <h2>Request {unit}</h2>
          {s !== "Open" ? <p className="banner">{s === "Sold out" ? "This listing is sold out." : s === "Closed" ? "The request deadline has passed." : "This listing isn't open for requests."}</p>
            : <RequestForm types={e.ticket_types} available={available} max={e.max_per_request} unit={unit} schools={district.schools || []} />}
        </section>
      </div>
    </>
  );
}
