import Link from "next/link";
import { CatPill } from "./ui";
import { num, fDate, evMin, evRemaining, evState, evWhen, isFree } from "@/lib/format";
import type { EventRow } from "@/lib/types";

/** A ticket-stub card for one listing: title, when and where, what's left, and the starting point cost. */
export default function RewardCard({ e, href, accent }: { e: EventRow; href: string; accent?: string }) {
  const s = evState(e); const closed = s !== "Open";
  return (
    <Link className={`tk ${closed ? "closed" : ""}`} href={href} style={{ textDecoration: "none" }}>
      <div className="a" style={accent ? { borderLeftColor: accent } : undefined}><CatPill c={e.cat} /><h3>{e.title}</h3>
        <div className="m">{e.dated ? evWhen(e) : e.partner || "Available any time"}{e.dated && e.venue ? ` · ${e.venue}` : ""}</div>
        <div className="m">{closed ? <span className="flag">{s}</span> : <>{isFree(e) && evRemaining(e) >= 100 ? "Available" : `${num(evRemaining(e))} left`}{e.dated && e.deadline ? ` · request by ${fDate(e.deadline)}` : ""}</>}</div></div>
      {isFree(e) ? <div className="b"><span>no points</span><strong>Free</strong><span>{e.partner ? `from ${e.partner}` : ""}</span></div>
        : <div className="b"><span>from</span><strong>{num(evMin(e))}</strong><span>pts each</span></div>}
    </Link>
  );
}
