import "server-only";
import { createAdminClient } from "./supabase/admin";

const esc = (s: string) => s.replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]!);

function html(subject: string, body: string) {
  const paras = esc(body).split(/\n{2,}/).map((p) => `<p style="margin:0 0 14px">${p.replace(/\n/g, "<br>")}</p>`).join("");
  return `<!doctype html><html><body style="margin:0;background:#EAF1F5;font-family:-apple-system,Segoe UI,Helvetica,Arial,sans-serif;color:#0E2A3B">
<div style="max-width:560px;margin:0 auto;padding:28px 16px">
<div style="font-weight:800;font-size:22px;color:#FE4001;margin-bottom:14px">ClassTix</div>
<div style="background:#fff;border-radius:12px;padding:22px 22px 8px;font-size:15px;line-height:1.55">
<h1 style="font-size:19px;margin:0 0 14px">${esc(subject)}</h1>${paras}</div>
<p style="font-size:12px;color:#557083;margin:14px 4px">ClassTix District Rewards Portal · ${esc(process.env.NEXT_PUBLIC_SITE_URL || "")}</p>
</div></body></html>`;
}

/**
 * Sends queued emails from the outbox through Resend. Safe to call often: each row is sent once.
 * Without RESEND_API_KEY, emails stay queued and remain visible in the admin Email log.
 */
export async function deliverOutbox(limit = 50): Promise<{ sent: number; failed: number; skipped: boolean }> {
  const key = process.env.RESEND_API_KEY;
  if (!key) return { sent: 0, failed: 0, skipped: true };
  const db = createAdminClient();
  const { data: rows } = await db.from("outbox").select("*").is("sent_at", null).lt("attempts", 5).order("id").limit(limit);
  let sent = 0, failed = 0;
  for (const m of rows || []) {
    try {
      const res = await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: { Authorization: `Bearer ${key}`, "Content-Type": "application/json" },
        body: JSON.stringify({
          from: process.env.EMAIL_FROM || "ClassTix <hello@classtix.org>",
          to: [m.to_email],
          reply_to: process.env.EMAIL_REPLY_TO || undefined,
          subject: m.subject,
          text: m.body,
          html: html(m.subject, m.body),
        }),
      });
      if (!res.ok) throw new Error(`${res.status} ${(await res.text()).slice(0, 300)}`);
      // sign-in links are single-use secrets: don't keep them once delivered
      const scrub = m.kind === "invite" || m.kind === "password" ? { body: m.body.replace(/https?:\/\/\S*token_hash=\S*/g, "[sign-in link removed after sending]") } : {};
      await db.from("outbox").update({ sent_at: new Date().toISOString(), attempts: m.attempts + 1, error: null, ...scrub }).eq("id", m.id);
      sent++;
    } catch (e) {
      await db.from("outbox").update({ attempts: m.attempts + 1, error: String((e as Error).message || e) }).eq("id", m.id);
      failed++;
    }
  }
  return { sent, failed, skipped: false };
}
