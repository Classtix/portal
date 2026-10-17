import Link from "next/link";
import ActionForm from "@/components/ActionForm";
import { Logo } from "@/components/ui";
import { sendPasswordReset } from "@/app/actions";

export const metadata = { title: "Reset password" };

export default function Forgot() {
  return (
    <div className="auth">
      <div className="authcard">
        <div className="brand" style={{ color: "var(--ink)" }}><Logo /><div><b>ClassTix</b></div></div>
        <div><h1>Reset your password</h1><p>We&apos;ll email you a link to choose a new one.</p></div>
        <ActionForm action={sendPasswordReset} submit="Email me a link" pendingLabel="Sending…" resetOnOk>
          <div className="f"><label htmlFor="email">Email</label><input type="email" id="email" name="email" autoComplete="email" required /></div>
        </ActionForm>
        <Link className="link" href="/login">Back to sign in</Link>
      </div>
    </div>
  );
}
