import Link from "next/link";
import ActionForm from "@/components/ActionForm";
import { Logo } from "@/components/ui";
import { signIn } from "@/app/actions";

export const metadata = { title: "Sign in" };

export default function Login({ searchParams }: { searchParams: { e?: string } }) {
  return (
    <div className="auth">
      <div className="authcard">
        <div className="brand" style={{ color: "var(--ink)" }}><Logo /><div><b>ClassTix</b><small style={{ color: "var(--muted)" }}>District Rewards Portal</small></div></div>
        <div><h1>Sign in</h1><p>Accounts are invite-only. Use the email your invite was sent to.</p></div>
        {searchParams.e === "access" && <p className="msg-err">This account doesn&apos;t have access to the portal. Contact ClassTix.</p>}
        {searchParams.e === "link" && <p className="msg-err">That link has expired or was already used. Use “Forgot your password?” below to get a new one.</p>}
        <ActionForm action={signIn} submit="Sign in" pendingLabel="Signing in…" buttonClass="btn" >
          <div className="f"><label htmlFor="email">Email</label><input type="email" id="email" name="email" autoComplete="email" required /></div>
          <div className="f"><label htmlFor="password">Password</label><input type="password" id="password" name="password" autoComplete="current-password" required /></div>
        </ActionForm>
        <Link className="link" href="/forgot">Forgot your password?</Link>
      </div>
    </div>
  );
}
