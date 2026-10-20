import { requireAdmin } from "@/lib/session";
import { Head, Empty, Pill } from "@/components/ui";
import ActionForm from "@/components/ActionForm";
import { updateProgram, scheduleRetail, runResetNow } from "@/app/actions";
import { fDate, fDT, mLabel, mNext, num, pts, thisMonth, today, evRemaining, evQty, sortTypes } from "@/lib/format";
import type { District, EventRow, Settings } from "@/lib/types";

export const metadata = { title: "Program settings" };

export default async function ProgramSettings() {
  const { supabase } = await requireAdmin();
  const [{ data: s }, { data: districts }, { data: drops }] = await Promise.all([
    supabase.from("settings").select("*").single(),
    supabase.from("districts").select("*").eq("status", "Active"),
    supabase.from("events").select("*, ticket_types(*)").eq("series", "retail").gte("date", today()).order("date").limit(6),
  ]);
  const st = s as Settings;
  const act = (districts || []) as District[];
  const due = mNext(st.current_month) <= thisMonth();
  const denoms = [...st.retail.denoms, ...Array(Math.max(0, 4 - st.retail.denoms.length)).fill({ label: "", points: "", qty: "" })].slice(0, 4);
  return (
    <>
      <Head eyebrow="ClassTix Admin" title="Program settings" sub="The monthly cycle, points rules, retail gift card drops and exports." />
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
        <h2>Points rules and retail gift card drops</h2>
        <ActionForm action={updateProgram} submit="Save settings">
          <div className="form">
            <div className="f full"><span className="lab">At each reset, a district&apos;s unused points</span>
              <div className="chips">
                <label className="check"><input type="radio" name="rollover" value="0" defaultChecked={!st.rollover} /> Expire</label>
                <label className="check"><input type="radio" name="rollover" value="1" defaultChecked={st.rollover} /> Roll over</label>
              </div></div>
            <div className="f"><label htmlFor="days">Drop days each month</label><input id="days" name="days" type="text" defaultValue={st.retail.days.join(", ")} /><span className="hint">Days 1–28, separated by commas.</span></div>
            <div className="f"><label htmlFor="retailers">Retailers (one per line)</label><textarea id="retailers" name="retailers" rows={7} defaultValue={st.retail.retailers.join("\n")} /></div>
            <div className="f full"><span className="lab">Card values</span>
              <div className="types">{denoms.map((d, i) => (
                <div className="trow" key={i} style={{ gridTemplateColumns: "repeat(3,minmax(0,1fr))" }}>
                  <div className="f"><label htmlFor={`d${i}l`}>Value</label><input id={`d${i}l`} name={`d${i}_label`} type="text" defaultValue={d.label} placeholder="$25" /></div>
                  <div className="f"><label htmlFor={`d${i}p`}>Points</label><input id={`d${i}p`} name={`d${i}_points`} type="number" min={1} defaultValue={d.points} /></div>
                  <div className="f"><label htmlFor={`d${i}q`}>Cards per retailer, per drop</label><input id={`d${i}q`} name={`d${i}_qty`} type="number" min={1} defaultValue={d.qty} /></div>
                </div>))}</div>
              <span className="hint">Leave a value blank to remove it. Changes apply to drops scheduled from now on.</span></div>
          </div>
        </ActionForm>
        <div className="ph" style={{ marginTop: 22 }}><h2>Upcoming drops</h2>
          <ActionForm action={scheduleRetail} hidden={{ month: thisMonth(), next: mNext(thisMonth()) }} submit={`Schedule through ${mLabel(mNext(thisMonth()))}`} buttonClass="btn sec sm" inlineMsg />
        </div>
        {(drops || []).length ? <div className="list">{((drops || []) as EventRow[]).map(sortTypes).map((e) => (
          <a key={e.id} className="item click" style={{ color: "inherit", textDecoration: "none" }} href={`/admin/events/${e.id}`}>
            <div><div className="t">{fDate(e.date)}</div><div className="m">{num(evRemaining(e))} of {num(evQty(e))} cards left · request by {fDate(e.deadline)}</div></div>
            <Pill s={e.status} /></a>))}</div> : <Empty title="No upcoming drops">The daily job schedules them; you can also use the button above.</Empty>}
      </section>
    </>
  );
}
