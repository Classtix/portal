import Link from "next/link";
import { requireAdmin } from "@/lib/session";
import { Head, Pill, Empty } from "@/components/ui";
import ActionForm from "@/components/ActionForm";
import Pop from "@/components/Pop";
import { decideAssembly, saveSpeaker } from "@/app/actions";
import { fDate, fDT, fmtClock, today } from "@/lib/format";
import type { AssemblyRequest, Speaker } from "@/lib/types";

export const metadata = { title: "Assemblies" };
const TABS = ["Requested", "Upcoming", "Past", "All"];

export default async function AdminAssemblies({ searchParams }: { searchParams: { s?: string } }) {
  const { supabase } = await requireAdmin();
  const tab = TABS.includes(searchParams.s || "") ? searchParams.s! : "Requested";
  const [{ data: rq }, { data: sp }, { data: ds }] = await Promise.all([
    supabase.from("assembly_requests").select("*").order("date").order("start_time").limit(500),
    supabase.from("speakers").select("*").order("sort"),
    supabase.from("districts").select("id, name"),
  ]);
  const all = (rq || []) as AssemblyRequest[];
  const speakers = (sp || []) as Speaker[];
  const dn = new Map((ds || []).map((d) => [d.id, d.name]));
  const sn = (id: string) => speakers.find((x) => x.id === id)?.name || "Speaker";
  const t = today();
  const list = all.filter((r) =>
    tab === "Requested" ? r.status === "Requested"
      : tab === "Upcoming" ? r.status === "Confirmed" && r.date >= t
        : tab === "Past" ? r.date < t : true);
  const count = (x: string) => all.filter((r) => x === "Requested" ? r.status === "Requested" : x === "Upcoming" ? r.status === "Confirmed" && r.date >= t : x === "Past" ? r.date < t : true).length;

  return (
    <>
      <Head eyebrow="ClassTix Admin" title="Assemblies" sub="Speaker requests from districts for assembly giveaways. Confirming or declining emails the district." />
      <div className="chips">{TABS.map((x) => <Link key={x} className="chip" aria-current={tab === x ? "true" : undefined} href={`/admin/assemblies?s=${x}`}>{x} ({count(x)})</Link>)}</div>
      <section className="panel">
        {list.length ? <div className="list">{list.map((r) => (
          <div className="item" key={r.id} style={{ alignItems: "start" }}>
            <div>
              <div className="t">{sn(r.speaker_id)} · {r.school}</div>
              <div className="m"><b>{fDate(r.date)} at {fmtClock(r.start_time)}</b> · {dn.get(r.district_id)} · {r.audience} students{r.grades ? ` (${r.grades})` : ""} · {r.code}</div>
              {r.note && <div className="m">District note: {r.note}</div>}
              {r.admin_note && <div className="m">Your note: {r.admin_note}</div>}
              <div className="m">Requested {fDT(r.created_at)}</div>
            </div>
            <div className="row" style={{ gap: 8, justifyContent: "flex-end" }}>
              <Pill s={r.status} />
              {r.status === "Requested" && <Pop label="Confirm" className="btn sm">
                <ActionForm action={decideAssembly} hidden={{ id: r.id, status: "Confirmed" }} submit="Confirm and email district" pendingLabel="Saving…">
                  <div className="f"><label htmlFor={`cn-${r.id}`}>Message to the district <span className="sub">(optional)</span></label>
                    <textarea id={`cn-${r.id}`} name="note" maxLength={500} placeholder="Speaker will arrive 20 minutes early and check in at the front office." /></div>
                </ActionForm></Pop>}
              {(r.status === "Requested" || r.status === "Confirmed") && <Pop label="Decline" className="btn danger sm">
                <ActionForm action={decideAssembly} hidden={{ id: r.id, status: "Declined" }} submit="Decline and email district" buttonClass="btn danger" pendingLabel="Saving…">
                  <div className="f"><label htmlFor={`dn-${r.id}`}>Reason the district will see</label>
                    <textarea id={`dn-${r.id}`} name="note" maxLength={500} required placeholder="The Suns aren't available that week. Could you pick another day?" /></div>
                </ActionForm></Pop>}
            </div>
          </div>))}</div>
          : <Empty title="Nothing here">{tab === "Requested" ? "No speaker requests waiting." : "No assemblies in this list."}</Empty>}
      </section>

      <section className="panel">
        <div className="ph"><h2>Speakers</h2>
          <Pop label="Add speaker" className="btn sec sm">
            <ActionForm action={saveSpeaker} submit="Add speaker" resetOnOk>
              <div className="f"><label htmlFor="ns-n">Name</label><input id="ns-n" name="name" type="text" maxLength={80} required placeholder="Phoenix Mercury" /></div>
              <div className="f"><label htmlFor="ns-o">Organization</label><input id="ns-o" name="org" type="text" maxLength={80} /></div>
              <div className="f"><label htmlFor="ns-d">What districts see</label><textarea id="ns-d" name="description" maxLength={300} /></div>
            </ActionForm>
          </Pop></div>
        <div className="list">{speakers.map((x) => (
          <div className="item" key={x.id}>
            <div><div className="t">{x.name}</div><div className="m">{x.description}</div></div>
            <div className="row" style={{ gap: 8 }}>
              <Pill s={x.active ? "Active" : "Inactive"} />
              <Pop label="Edit">
                <ActionForm action={saveSpeaker} hidden={{ id: x.id }} submit="Save speaker">
                  <div className="f"><label htmlFor={`sn-${x.id}`}>Name</label><input id={`sn-${x.id}`} name="name" type="text" defaultValue={x.name} maxLength={80} required /></div>
                  <div className="f"><label htmlFor={`so-${x.id}`}>Organization</label><input id={`so-${x.id}`} name="org" type="text" defaultValue={x.org} maxLength={80} /></div>
                  <div className="f"><label htmlFor={`sd-${x.id}`}>What districts see</label><textarea id={`sd-${x.id}`} name="description" defaultValue={x.description} maxLength={300} /></div>
                  <div className="f"><label htmlFor={`sa-${x.id}`}>Shown to districts</label>
                    <select id={`sa-${x.id}`} name="active" defaultValue={x.active ? "on" : "off"}><option value="on">Yes</option><option value="off">No, hide it</option></select></div>
                </ActionForm>
              </Pop>
            </div>
          </div>))}</div>
      </section>
    </>
  );
}
