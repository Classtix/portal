import { requireAdmin } from "@/lib/session";
import { Head, Pill, Empty } from "@/components/ui";
import ActionForm from "@/components/ActionForm";
import Pop from "@/components/Pop";
import { inviteUser, resendInvite, setUserStatus } from "@/app/actions";
import { fShort } from "@/lib/format";
import type { District, Profile } from "@/lib/types";

export const metadata = { title: "Users" };

export default async function AdminUsers({ searchParams }: { searchParams: { d?: string } }) {
  const { supabase, profile: me } = await requireAdmin();
  const [{ data: users }, { data: districts }] = await Promise.all([
    supabase.from("profiles").select("*").order("name"),
    supabase.from("districts").select("*").order("name"),
  ]);
  const D = (districts || []) as District[];
  const list = ((users || []) as Profile[]).filter((u) => !searchParams.d || (searchParams.d === "ct" ? u.role === "admin" : u.district_id === searchParams.d));
  return (
    <>
      <Head eyebrow="ClassTix Admin" title="Users" sub="Everyone with access to the portal. Access is invite-only; invite links work once and expire after 24 hours."
        right={<Pop label="Invite user" className="btn">
          <ActionForm action={inviteUser} submit="Send invite" pendingLabel="Sending…" resetOnOk>
            <div className="f"><label htmlFor="iu-n">Full name</label><input id="iu-n" name="name" type="text" maxLength={80} required /></div>
            <div className="f"><label htmlFor="iu-e">Email</label><input id="iu-e" name="email" type="email" maxLength={120} required /></div>
            <div className="f"><label htmlFor="iu-r">Role</label><select id="iu-r" name="role" defaultValue="district"><option value="district">District Admin</option><option value="admin">ClassTix Admin</option></select></div>
            <div className="f"><label htmlFor="iu-d">District (District Admins only)</label><select id="iu-d" name="district_id" defaultValue={searchParams.d && searchParams.d !== "ct" ? searchParams.d : ""}>
              <option value="">Choose a district</option>{D.filter((d) => d.status === "Active").map((d) => <option key={d.id} value={d.id}>{d.name}</option>)}</select></div>
          </ActionForm>
        </Pop>} />
      <form className="row" action="/admin/users">
        <select className="sel" name="d" defaultValue={searchParams.d || ""} aria-label="Filter users">
          <option value="">Everyone</option><option value="ct">ClassTix team</option>{D.map((d) => <option key={d.id} value={d.id}>{d.name}</option>)}
        </select>
        <button className="btn sec sm" type="submit">Filter</button>
      </form>
      <section className="panel">
        {list.length ? <div className="tbl-wrap"><table>
          <thead><tr><th>Name</th><th>Role</th><th>District</th><th>Status</th><th>Last sign-in</th><th></th></tr></thead>
          <tbody>{list.map((u) => (
            <tr key={u.id}>
              <td><b>{u.name}</b><div className="sub">{u.email}</div></td>
              <td>{u.role === "admin" ? "ClassTix Admin" : "District Admin"}</td>
              <td>{D.find((d) => d.id === u.district_id)?.name || "—"}</td>
              <td><Pill s={u.status} /></td>
              <td>{u.last_login ? fShort(u.last_login) : "—"}</td>
              <td><div className="row" style={{ justifyContent: "flex-end" }}>
                {u.status === "Invited" && <ActionForm action={resendInvite} hidden={{ id: u.id }} submit="Resend invite" buttonClass="btn sec sm" inlineMsg />}
                {u.status !== "Deactivated" && u.id !== me.id && <ActionForm action={setUserStatus} hidden={{ id: u.id, status: "Deactivated" }} submit="Deactivate" buttonClass="btn danger sm" inlineMsg />}
                {u.status === "Deactivated" && <ActionForm action={setUserStatus} hidden={{ id: u.id, status: "Active" }} submit="Reactivate" buttonClass="btn ghost sm" inlineMsg />}
              </div></td>
            </tr>))}</tbody></table></div>
          : <Empty title="No users here">Choose Invite user to add a District Admin or a ClassTix teammate.</Empty>}
      </section>
    </>
  );
}
