import Link from "next/link";
import { districtContext } from "@/lib/district";
import { Head, Pill, Empty } from "@/components/ui";
import ActionForm from "@/components/ActionForm";
import Pop from "@/components/Pop";
import { requestAssembly, cancelAssembly } from "@/app/actions";
import { ASSEMBLY_TIMES, assemblyEarliest, fDate, fmtClock, mLabel, mNext, mPrev, p2, thisMonth } from "@/lib/format";
import type { AssemblyRequest, Speaker } from "@/lib/types";

export const metadata = { title: "Assembly Giveaway" };

export default async function Assemblies({ searchParams }: { searchParams: { m?: string; d?: string; speaker?: string; sent?: string } }) {
  const { supabase, district } = await districtContext();
  if (!district) return null;
  const [{ data: sp }, { data: rq }] = await Promise.all([
    supabase.from("speakers").select("*").eq("active", true).order("sort"),
    supabase.from("assembly_requests").select("*").order("date", { ascending: true }).limit(300),
  ]);
  const speakers = (sp || []) as Speaker[];
  const reqs = (rq || []) as AssemblyRequest[];
  const name = (id: string) => speakers.find((x) => x.id === id)?.name || "Speaker";
  const earliest = assemblyEarliest();
  const sel = /^\d{4}-\d{2}-\d{2}$/.test(searchParams.d || "") && searchParams.d! >= earliest ? searchParams.d! : "";
  const k = /^\d{4}-\d{2}$/.test(searchParams.m || "") ? searchParams.m! : (sel || earliest).slice(0, 7);
  const speaker = speakers.find((x) => x.id === searchParams.speaker)?.id || "";
  const href = (p: Record<string, string>) => `/district/assemblies?${new URLSearchParams({ m: k, ...(sel ? { d: sel } : {}), ...(speaker ? { speaker } : {}), ...p })}#book`;
  const open = reqs.filter((r) => r.status === "Requested" || r.status === "Confirmed");
  const schools = district.schools?.length ? district.schools : ["District-wide"];

  // month grid
  const [y, m] = k.split("-").map(Number);
  const first = new Date(y, m - 1, 1); const start = new Date(first); start.setDate(1 - first.getDay());
  const cells: React.ReactNode[] = [];
  for (let i = 0; i < 42; i++) {
    const dd = new Date(start); dd.setDate(start.getDate() + i);
    if (i >= 35 && dd.getMonth() !== m - 1) break;
    const iso = `${dd.getFullYear()}-${p2(dd.getMonth() + 1)}-${p2(dd.getDate())}`;
    const out = dd.getMonth() !== m - 1;
    const weekend = dd.getDay() === 0 || dd.getDay() === 6;
    const ok = !weekend && iso >= earliest;
    const mine = open.filter((r) => r.date === iso);
    const inner = <><span className="n">{dd.getDate()}</span>{mine.map((r) => <span key={r.id} className={`tag ${r.status}`}>{name(r.speaker_id)} · {r.school}</span>)}</>;
    const cls = `d ${out ? "out" : ""} ${ok ? "" : "off"} ${iso === sel ? "sel" : ""} ${mine.length ? "has" : ""}`;
    cells.push(ok
      ? <Link key={iso} className={cls} href={href({ d: iso, m: k })} aria-label={`Pick ${fDate(iso)}`}>{inner}</Link>
      : <div key={iso} className={cls}>{inner}</div>);
  }

  return (
    <>
      <Head eyebrow={district.name} title="Assembly Giveaway"
        sub="Book a speaker for a schoolwide assembly where students who earned rewards are recognized. Pick a school day at least two weeks out; ClassTix confirms the visit by email." />
      {searchParams.sent && <p className="msg-ok">Request {searchParams.sent} sent. ClassTix will confirm the speaker by email.</p>}

      <section className="panel">
        <div className="ph"><h2>Speakers</h2><span className="sub">Choose one, then pick a day</span></div>
        <div className="spk">{speakers.map((x) => (
          <Link key={x.id} href={href({ speaker: x.id })} aria-current={speaker === x.id ? "true" : undefined}>
            <b>{x.name}</b><span>{x.description}</span>
          </Link>))}</div>
      </section>

      <div className="grid2" id="book">
        <section className="panel">
          <div className="row" style={{ marginBottom: 10 }}>
            <Link className="btn sec sm" href={href({ m: mPrev(k) })} aria-label="Previous month">‹</Link>
            <h2 style={{ fontSize: 20, minWidth: 160, textAlign: "center", margin: 0 }}>{mLabel(k)}</h2>
            <Link className="btn sec sm" href={href({ m: mNext(k) })} aria-label="Next month">›</Link>
            {k !== thisMonth() && <Link className="link" href={href({ m: thisMonth() })}>This month</Link>}
          </div>
          <div className="acal">{["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"].map((x) => <div key={x} className="dh">{x}</div>)}{cells}</div>
          <p className="sub" style={{ margin: "8px 0 0" }}>Grey days can&apos;t be booked: weekends and anything sooner than {fDate(earliest)}.</p>
        </section>

        <section className="panel">
          <h2>Request a speaker</h2>
          <ActionForm action={requestAssembly} submit="Send request" pendingLabel="Sending…">
            <div className="f"><label htmlFor="as-sp">Speaker</label>
              <select id="as-sp" name="speaker" defaultValue={speaker} required key={`sp-${speaker}`}>
                <option value="" disabled>Choose a speaker</option>
                {speakers.map((x) => <option key={x.id} value={x.id}>{x.name}</option>)}
              </select></div>
            <div className="f"><label htmlFor="as-sc">School</label>
              <select id="as-sc" name="school" defaultValue={schools.length === 1 ? schools[0] : ""} required>
                {schools.length > 1 && <option value="" disabled>Choose a school</option>}
                {schools.map((x) => <option key={x}>{x}</option>)}
              </select></div>
            <div className="form" style={{ gridTemplateColumns: "1fr 1fr" }}>
              <div className="f"><label htmlFor="as-d">Day</label>
                <input id="as-d" name="date" type="date" min={earliest} defaultValue={sel} required key={`d-${sel}`} /></div>
              <div className="f"><label htmlFor="as-t">Start time</label>
                <select id="as-t" name="time" defaultValue="" required>
                  <option value="" disabled>Choose a time</option>
                  {ASSEMBLY_TIMES.map((t) => <option key={t} value={t}>{fmtClock(t)}</option>)}
                </select></div>
              <div className="f"><label htmlFor="as-a">Expected students</label>
                <input id="as-a" name="audience" type="number" min={1} max={5000} placeholder="400" required /></div>
              <div className="f"><label htmlFor="as-g">Grades</label>
                <input id="as-g" name="grades" type="text" maxLength={60} placeholder="9–12" /></div>
            </div>
            <div className="f"><label htmlFor="as-n">Notes for ClassTix</label>
              <textarea id="as-n" name="note" maxLength={500} placeholder="Gym, 45 minutes. Recognizing perfect attendance." /></div>
          </ActionForm>
        </section>
      </div>

      <section className="panel">
        <div className="ph"><h2>Your assembly requests</h2></div>
        {reqs.length ? <div className="list">{[...reqs].reverse().map((r) => (
          <div className="item" key={r.id}>
            <div>
              <div className="t">{name(r.speaker_id)} · {r.school}</div>
              <div className="m">{fDate(r.date)} at {fmtClock(r.start_time)} · {r.audience} students{r.grades ? ` (${r.grades})` : ""} · {r.code}</div>
              {r.admin_note && <div className="m">ClassTix: {r.admin_note}</div>}
            </div>
            <div className="row" style={{ gap: 8 }}>
              <Pill s={r.status} />
              {(r.status === "Requested" || r.status === "Confirmed") && <Pop label="Cancel" className="btn ghost sm">
                <p style={{ margin: 0 }}>Cancel {name(r.speaker_id)} at {r.school} on {fDate(r.date)}?</p>
                <ActionForm action={cancelAssembly} hidden={{ id: r.id }} submit="Cancel request" buttonClass="btn danger" pendingLabel="Cancelling…" />
              </Pop>}
            </div>
          </div>))}</div>
          : <Empty title="No requests yet">Pick a speaker and a day above.</Empty>}
      </section>
    </>
  );
}
