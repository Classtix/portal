"use client";

import { useRef, useState } from "react";
import { useRouter } from "next/navigation";
import { createClient } from "@/lib/supabase/browser";
import { startTicketUpload, saveTicketFile } from "@/app/actions";

/** Admin: upload ticket or gift card files straight to private storage, then attach them to the request. */
export default function TicketUploader({ requestId }: { requestId: string }) {
  const router = useRouter();
  const input = useRef<HTMLInputElement>(null);
  const [label, setLabel] = useState("");
  const [busy, setBusy] = useState("");
  const [msg, setMsg] = useState<{ ok?: string; error?: string }>({});

  async function upload() {
    const files = Array.from(input.current?.files || []);
    if (!files.length) { setMsg({ error: "Choose at least one file." }); return; }
    setMsg({});
    const supabase = createClient();
    let done = 0;
    for (const f of files) {
      setBusy(`Uploading ${f.name} (${done + 1} of ${files.length})…`);
      const start = await startTicketUpload(requestId, f.name, f.size);
      if (start.error || !start.path || !start.token) { setMsg({ error: start.error || "Upload failed." }); break; }
      const { error } = await supabase.storage.from("tickets").uploadToSignedUrl(start.path, start.token, f, { contentType: f.type || "application/octet-stream" });
      if (error) { setMsg({ error: `${f.name} didn't upload. Try again.` }); break; }
      const saved = await saveTicketFile(requestId, start.path, f.name, f.size, label);
      if (saved.error) { setMsg({ error: saved.error }); break; }
      done++;
    }
    setBusy("");
    if (done) {
      if (done === files.length) setMsg({ ok: `${done} file${done === 1 ? "" : "s"} added to the district's My Tickets.` });
      if (input.current) input.current.value = "";
      setLabel("");
      router.refresh();
    }
  }

  return (
    <div className="form" style={{ gridTemplateColumns: "1fr" }}>
      <div className="f"><label htmlFor="tf">Ticket or gift card files</label>
        <input ref={input} id="tf" type="file" multiple accept=".pdf,.png,.jpg,.jpeg,.webp,.heic,.gif,.pkpass,.zip,.txt,.csv,.doc,.docx,.xls,.xlsx" />
        <span className="hint">PDF, image, Apple Wallet pass or ZIP, up to 25 MB each. Only this district can download them.</span></div>
      <div className="f"><label htmlFor="tl">Label <span className="sub">(optional)</span></label>
        <input id="tl" type="text" maxLength={120} value={label} onChange={(e) => setLabel(e.target.value)} placeholder="Section 210, Row 4" /></div>
      <div className="row">
        <button type="button" className="btn sec sm" onClick={upload} disabled={!!busy}>{busy ? "Uploading…" : "Upload files"}</button>
        {busy && <span className="sub">{busy}</span>}
      </div>
      {msg.ok && <p className="msg-ok" role="status">{msg.ok}</p>}
      {msg.error && <p className="msg-err" role="alert">{msg.error}</p>}
    </div>
  );
}
