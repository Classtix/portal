import Link from "next/link";
import type { Allowance } from "@/lib/types";

/** Shown to districts with donated tickets: what they can request, and how many are left. */
export default function AllowanceNotice({ allowances, link = true }: { allowances: Allowance[]; link?: boolean }) {
  if (!allowances.length) return null;
  return (
    <div className="banner" role="status">
      {allowances.map((a) => (
        <div key={a.partner}>
          <b>{a.remaining} of {a.tickets} donated {a.partner} tickets left</b>{a.note ? ` · ${a.note}` : ""}. Request them in pairs for any {a.partner} game; no points are used.
          {link && a.partner.toLowerCase() === "asu athletics" && <> <Link className="link" href="/district/calendar?g=asu">See ASU games</Link></>}
        </div>))}
      <div className="sub" style={{ marginTop: 4 }}>Right now your district can request {allowances.map((a) => a.partner).join(", ")} and free rewards only. Other rewards are shown so you can see what&apos;s available.</div>
    </div>
  );
}
