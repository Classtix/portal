import { Empty } from "./ui";
import { num, fShort } from "@/lib/format";
import type { LedgerRow } from "@/lib/types";

/** Points history, newest first, with a running balance. Pass rows oldest-first. */
export default function LedgerTable({ rows, limit }: { rows: LedgerRow[]; limit?: number }) {
  let bal = 0;
  const all = rows.map((l) => ({ ...l, bal: (bal += l.amount) })).reverse();
  const shown = limit ? all.slice(0, limit) : all;
  if (!shown.length) return <Empty title="No points activity yet">Allocations, holds and adjustments appear here.</Empty>;
  return (
    <>
      <div className="tbl-wrap"><table>
        <thead><tr><th>Date</th><th>Entry</th><th>Ref</th><th className="n">Points</th><th className="n">Balance</th></tr></thead>
        <tbody>{shown.map((l) => (
          <tr key={l.id}><td>{fShort(l.at)}</td><td>{l.entry}</td><td className="sub">{l.ref || "—"}</td>
            <td className={`n ${l.amount > 0 ? "pos" : l.amount < 0 ? "neg" : "zero"}`}>{l.amount > 0 ? "+" : ""}{num(l.amount)}</td>
            <td className="n">{num(l.bal)}</td></tr>))}</tbody>
      </table></div>
      {limit && all.length > limit ? <p className="sub">Showing the latest {limit} of {all.length} entries.</p> : null}
    </>
  );
}
