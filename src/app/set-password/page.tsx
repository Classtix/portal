import ActionForm from "@/components/ActionForm";
import { Logo } from "@/components/ui";
import { setPassword } from "@/app/actions";
import { getMe } from "@/lib/session";

export const metadata = { title: "Set your password" };

export default async function SetPassword() {
  const { profile } = await getMe();
  return (
    <div className="auth">
      <div className="authcard">
        <div className="brand" style={{ color: "var(--ink)" }}><Logo /><div><b>ClassTix</b></div></div>
        <div><h1>Set your password</h1><p>Welcome{profile.name ? `, ${profile.name}` : ""}. Choose a password for {profile.email}.</p></div>
        <ActionForm action={setPassword} submit="Save and continue" pendingLabel="Saving…">
          <div className="f"><label htmlFor="password">New password</label><input type="password" id="password" name="password" autoComplete="new-password" minLength={10} required /><span className="hint">At least 10 characters.</span></div>
          <div className="f"><label htmlFor="confirm">Type it again</label><input type="password" id="confirm" name="confirm" autoComplete="new-password" minLength={10} required /></div>
        </ActionForm>
      </div>
    </div>
  );
}
