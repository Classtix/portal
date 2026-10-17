import { requireAdmin } from "@/lib/session";
import { Head, Empty } from "@/components/ui";
import ActionForm from "@/components/ActionForm";
import { retryEmails } from "@/app/actions";
import { fDT } from "@/lib/format";

export const metadata = { title: "Email log" };
const mask = (s: string) => s.replace(/https?:\/\/\S*token_hash=\S*/g, "[private sign-in link]");

export default async function EmailLog() {
  const { supabase } = await requireAdmin();
  const { data } = await supabase.from("outbox").select("*").order("id", { ascending: false }).limit(200);
  const rows = data || [];
  const unsent = rows.filter((m) => !m.sent_at).length;
  const sending = !!process.env.RESEND_API_KEY;
  return (
    <>
      <Head eyebrow="ClassTix Admin" title="Email log" sub="Every notification the portal sends: invites, new requests, decisions, fulfilment, cancellations and monthly resets."
        right={unsent ? <ActionForm action={retryEmails} submit={`Send ${unsent} waiting`} buttonClass="btn sec" inlineMsg /> : undefined} />
      {!sending && <p className="note">Email sending isn&apos;t switched on yet. Emails are queued here and go out once RESEND_API_KEY is set in Vercel.</p>}
      <section className="panel">
        {rows.length ? rows.map((m) => (
          <details className="mail" key={m.id}>
            <summary><span><b>{m.subject}</b><div className="sub">To {m.to_name ? `${m.to_name} <${m.to_email}>` : m.to_email}</div></span>
              <span className="sub">{fDT(m.at)} · {m.sent_at ? "Sent" : m.error ? "Failed" : "Waiting"}</span></summary>
            <pre>{mask(m.body)}</pre>
            {m.error && <p className="msg-err">Last error: {m.error}</p>}
          </details>)) : <Empty title="No emails yet">They appear here as people invite, request, approve and reset.</Empty>}
      </section>
    </>
  );
}
