import NavLinks from "./NavLinks";
import { Logo } from "./ui";
import { signOut } from "@/app/actions";
import type { Profile } from "@/lib/types";

export default function Shell({ me, districtName, nav, children }: {
  me: Profile; districtName?: string | null; nav: { href: string; label: string; count?: number; exact?: boolean }[]; children: React.ReactNode;
}) {
  return (
    <div className="app">
      <aside className="rail">
        <div className="brand"><Logo /><div><b>ClassTix</b><small>District Rewards Portal</small></div></div>
        <div className="me">
          <b>{me.name || me.email}</b>
          <span>{me.role === "admin" ? "ClassTix Admin" : districtName || "District Admin"}</span>
        </div>
        <NavLinks items={nav} />
        <div className="railfoot" style={{ display: "flex" }}>
          <form action={signOut}><button className="signout" type="submit">Sign out</button></form>
          <span>Questions? hello@classtix.org</span>
        </div>
      </aside>
      <main className="main"><div className="wrap">{children}</div></main>
    </div>
  );
}
