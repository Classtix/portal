import Link from "next/link";
import { requireAdmin } from "@/lib/session";
import { Head, Pill, Empty } from "@/components/ui";
import ActionForm from "@/components/ActionForm";
import Pop from "@/components/Pop";
import LedgerTable from "@/components/LedgerTable";
import { createDistrict, updateDistrict, adjustPoints, setDistrictStatus } from "@/app/actions";
import { num, pts } from "@/lib/format";
import type { District, LedgerRow, Profile, RequestRow } from "@/lib/types";

export const metadata = { title: "Districts" };

export default async function AdminDistricts({ searchParams }: { searchParams: { id?: string; status?: string } }) {
  const { supabase } = await requireAdmin();
  const [{ data: districts }, { data: ledger }, { data: pending }] = await Promise.all([
    supabase.from("districts").select("*").order("name"),
    supabase.from("ledger").select("district_id, amount"),
    supabase.from("requests").select("district_id, qty, points_each").eq("status", "Pending"),
  ]);
  const all = (districts || []) as District[];
  const avail = (id: string) => (ledger || []).filter((l) => l.district_id === id).reduce((s, l) => s + l.amount, 0);
  const held = (id: string) => (pending || []).filter((r) => r.district_id === id).reduce((s, r) => s + r.qty * r.points_each, 0);
  const list = all.filter((d) => (!searchParams.status || d.status === searchParams.status));
  const d = all.find((x) => x.id === searchParams.id) || list[0] || null;
  return (
    <>
      <Head eyebrow="ClassTix Admin" title="Districts" sub="Every district is funded at $2 per student. Monthly points = students × 0.95, rounded to the nearest 10, credited on the 1st."
        right={<Pop label="New district" className="btn">
          <ActionForm action={createDistrict} submit="Add district" pendingLabel="Adding…">
            <div className="form">
              <div className="f full"><label htmlFor="nd-name">District name</label><input id="nd-name" name="name" type="text" maxLength={80} required /></div>
              <div className="f"><label htmlFor="nd-state">State</label><input id="nd-state" name="state" type="text" maxLength={2} defaultValue="AZ" /></div>
              <div className="f"><label htmlFor="nd-st">Students</label><input id="nd-st" name="students" type="number" min={1} required /><span className="hint">Sets the monthly points: 0.95 per student.</span></div>
              <div className="f full"><label htmlFor="nd-c">Contact email</label><input id="nd-c" name="contact" type="email" maxLength={120} /></div>
            </div>
          </ActionForm>
        </Pop>} />
      <form className="row" action="/admin/districts">
        <select className="sel" name="status" defaultValue={searchParams.status || ""} aria-label="Status"><option value="">Any status</option><option>Active</option><option>Inactive</option></select>
        <button className="btn sec sm" type="submit">Filter</button>
      </form>
      <section className="panel">
        {list.length ? <div className="tbl-wrap"><table>
          <thead><tr><th>District</th><th className="n">Students</th><th className="n">Monthly</th><th className="n">Available</th><th className="n">On hold</th><th>Status</th></tr></thead>
          <tbody>{list.map((x) => (
            <tr key={x.id} className={x.id === d?.id ? "on" : ""}>
              <td><Link href={`/admin/districts?id=${x.id}`}><b>{x.name}</b></Link><div className="sub">{x.state}</div></td>
              <td className="n">{num(x.students)}</td><td className="n">{pts(x.monthly)}</td>
              <td className="n">{pts(avail(x.id))}</td><td className="n">{pts(held(x.id))}</td><td><Pill s={x.status} /></td>
            </tr>))}</tbody></table></div>
          : <Empty title="No districts match">Choose New district to add one.</Empty>}
      </section>
      {d && <Detail d={d} avail={avail(d.id)} held={held(d.id)} />}
    </>
  );
}

async function Detail({ d, avail, held }: { d: District; avail: number; held: number }) {
  const { supabase } = await requireAdmin();
  const [{ data: users }, { data: ledger }, { data: reqs }] = await Promise.all([
    supabase.from("profiles").select("*").eq("district_id", d.id).order("name"),
    supabase.from("ledger").select("*").eq("district_id", d.id).order("at").order("id"),
    supabase.from("requests").select("status").eq("district_id", d.id),
  ]);
  const R = (reqs || []) as Pick<RequestRow, "status">[];
  const c = (s: string) => R.filter((r) => r.status === s).length;
  return (
    <div className="grid2">
      <section className="panel">
        <div className="ph"><h2>{d.name}</h2><Pill s={d.status} /></div>
        <p className="sub" style={{ margin: "0 0 14px" }}>{R.length} requests · {c("Pending")} pending · {c("Approved")} approved, not yet sent</p>
        <ActionForm action={updateDistrict} hidden={{ id: d.id }} submit="Save district" buttonClass="btn sec">
          <div className="form">
            <div className="f full"><label htmlFor="dn">Name</label><input id="dn" name="name" type="text" defaultValue={d.name} maxLength={80} /></div>
            <div className="f"><label htmlFor="ds">Students</label><input id="ds" name="students" type="number" min={0} defaultValue={d.students} /></div>
            <div className="f"><label htmlFor="dc">Contact email</label><input id="dc" name="contact" type="email" defaultValue={d.contact} /></div>
            <div className="f full"><span className="lab">Monthly points</span><b className="num" style={{ fontSize: 18 }}>{pts(d.monthly)}</b><span className="hint">{num(d.students)} students × $2 = ${num(d.students * 2)}; 95% becomes points. Change the student count to update it; the new amount applies at the next reset.</span></div>
          </div>
        </ActionForm>
        <div className="row" style={{ marginTop: 14, alignItems: "flex-start" }}>
          <Pop label="Adjust points">
            <ActionForm action={adjustPoints} hidden={{ id: d.id }} submit="Save adjustment" resetOnOk>
              <p className="sub" style={{ margin: 0 }}>{d.name} has {pts(avail)} available.</p>
              <div className="f"><label htmlFor="aa">Points (+ or −)</label><input id="aa" name="amount" type="number" step={1} required placeholder="-50" /></div>
              <div className="f"><label htmlFor="ar">Reason the district will see</label><input id="ar" name="reason" type="text" maxLength={120} required placeholder="Correction for cancelled game" /></div>
            </ActionForm>
          </Pop>
          <span className="spacer" />
          {d.status === "Active" ? <Pop label="Deactivate district" className="btn danger sm">
            <p style={{ margin: 0 }}>Its admins lose access and pending requests are cancelled with points released.{c("Approved") ? ` ${c("Approved")} approved requests still need tickets sent or a decision in Requests.` : ""}</p>
            <ActionForm action={setDistrictStatus} hidden={{ id: d.id, status: "Inactive" }} submit="Deactivate" buttonClass="btn danger" />
          </Pop> : <ActionForm action={setDistrictStatus} hidden={{ id: d.id, status: "Active" }} submit="Reactivate district" buttonClass="btn ghost sm" />}
        </div>
        <h3 style={{ fontSize: 16, margin: "20px 0 6px" }}>District Admins</h3>
        {(users || []).length ? <div className="list">{((users || []) as Profile[]).map((u) => (
          <div className="item" key={u.id}><div><div className="t">{u.name}</div><div className="m">{u.email}</div></div><Pill s={u.status} /></div>))}</div>
          : <p className="sub">No District Admins yet. <Link href="/admin/users">Invite one under Users.</Link></p>}
      </section>
      <section className="panel">
        <div className="ph"><h2>Points</h2><span className="sub">{pts(avail)} available · {pts(held)} on hold</span></div>
        <LedgerTable rows={(ledger || []) as LedgerRow[]} limit={15} />
      </section>
    </div>
  );
}
