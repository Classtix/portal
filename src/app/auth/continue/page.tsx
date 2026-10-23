import { Logo } from "@/components/ui";
import { continueLink } from "@/app/actions";

export const metadata = { title: "Continue to ClassTix" };

export default function Continue({ searchParams }: { searchParams: { token_hash?: string; type?: string } }) {
  const invite = searchParams.type === "invite";
  return (
    <div className="auth">
      <div className="authcard">
        <div className="brand" style={{ color: "var(--ink)" }}><Logo /><div><b>ClassTix</b><small style={{ color: "var(--muted)" }}>District Rewards Portal</small></div></div>
        <div><h1>{invite ? "Welcome to ClassTix" : "Reset your password"}</h1>
          <p>{invite ? "Press Continue to set your password and finish signing up." : "Press Continue to choose a new password."}</p></div>
        <form action={continueLink}>
          <input type="hidden" name="token_hash" value={searchParams.token_hash || ""} />
          <input type="hidden" name="type" value={searchParams.type || ""} />
          <button className="btn" type="submit" style={{ width: "100%", justifyContent: "center" }}>Continue</button>
        </form>
      </div>
    </div>
  );
}
