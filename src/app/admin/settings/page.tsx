import { requireAdmin } from "@/lib/session";
import { Head, Empty, Pill } from "@/components/ui";
import ActionForm from "@/components/ActionForm";
import { updateProgram, runResetNow } from "@/app/actions";
import { fDate, fDT, mLabel, mNext, num, pts, thisMonth, today, evRemaining, evQty, sortTypes } from "@/lib/format";
import type { District, EventRow, Settings } from "@/lib/types";

export const metadata = { title: "Program settings" };

export default async function ProgramSettings() {
  const { supabase } = await requireAdmin();
  const [{ data: s }, { data: districts }] = await Promise.all([
    supabase.from("settings").select("*").single(),
    supabase.from("districts").select("*").eq("status", "Active"),
  ]);
  const st = s as Settings;
  const act = (districts || []) as District[];
  const due = mNext(st.current_month) <= thisMonth();
  return (
    <>
      <Head eyebrow="ClassTix Admin" title="Program settings" sub="The monthly cycle, points rules and exports." />
      <div className="grid2">
        <section className="panel">
          <h2>Monthly reset</h2>
          <dl className="dl">
            <dt>Current month</dt><dd>{mLabel(st.current_month)}</dd>
            <dt>Last reset</dt><dd>{st.last_reset_at ? fDT(st.last_reset_at) : "Not run yet"}</dd>
            <dt>Next reset</dt><dd>{fDate(mNext(st.current_month) + "-01")}, automatically</dd>
            <dt>Next allocation</dt><dd>{pts(act.reduce((a, d) => a + d.monthly, 0))} across {num(act.length)} active district{act.length === 1 ? "" : "s"}</dd>
            <dt>Unused points</dt><dd>{st.rollover ? "Roll over to next month" : "Expire at reset"}</dd>
          </dl>
          <p className="sub" style={{ margin: "14px 0" }}>On the 1st, unused points expire (or roll over), each district is credited and its admins are emailed. Pending requests keep their held points; if one is rejected later, the points return to the new month.</p>
          {due && <ActionForm action={runResetNow} submit={`Start ${mLabel(mNext(st.current_month))} now`} pendingLabel="Running…" />}
        </section>
        <section className="panel">
          <h2>Export</h2>
          <p className="sub" style={{ margin: "0 0 12px" }}>CSV files for funders, district reports, or your own records.</p>
          <div className="row">
            <a className="btn sec" href="/admin/export/requests">Requests CSV</a>
            <a className="btn sec" href="/admin/export/ledger">Points ledger CSV</a>
            <a className="btn sec" href="/admin/export/events">Events CSV</a>
          </div>
        </section>
      </div>
      <section className="panel">
        <h2>Points rules</h2>
        <ActionForm action={updateProgram} submit="Save settings">
          <div className="f"><span className="lab">At each reset, a district&apos;s unused points</span>
            <div className="chips">
              <label className="check"><input type="radio" name="rollover" value="0" defaultChecked={!st.rollover} /> Expire</label>
              <label className="check"><input type="radio" name="rollover" value="1" defaultChecked={st.rollover} /> Roll over</label>
            </div></div>
        </ActionForm>
      </section>
    </>
  );
}
