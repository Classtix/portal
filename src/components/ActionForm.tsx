"use client";

import { useEffect, useRef } from "react";
import { useFormState, useFormStatus } from "react-dom";
import type { ActionState } from "@/lib/types";

type Action = (state: ActionState, fd: FormData) => Promise<ActionState>;

function Submit({ label, pendingLabel, className, disabled }: { label: string; pendingLabel?: string; className?: string; disabled?: boolean }) {
  const { pending } = useFormStatus();
  return (
    <button type="submit" className={className ?? "btn"} disabled={pending || disabled}>
      {pending ? pendingLabel ?? "Saving…" : label}
    </button>
  );
}

/**
 * A form wired to a server action, with a pending state and the result shown in place.
 * `hidden` adds hidden inputs; `children` are the visible fields; `extra` sits beside the submit button.
 */
export default function ActionForm({
  action, hidden, children, submit, pendingLabel, buttonClass, className, resetOnOk, disabled, extra, inlineMsg,
}: {
  action: Action; hidden?: Record<string, string | number | null | undefined>; children?: React.ReactNode; submit: string;
  pendingLabel?: string; buttonClass?: string; className?: string; resetOnOk?: boolean; disabled?: boolean;
  extra?: React.ReactNode; inlineMsg?: boolean;
}) {
  const [state, formAction] = useFormState(action, null);
  const ref = useRef<HTMLFormElement>(null);
  useEffect(() => { if (state?.ok && resetOnOk) ref.current?.reset(); }, [state, resetOnOk]);
  const msg = state?.error ? <p className="msg-err" role="alert">{state.error}</p> : state?.ok ? <p className="msg-ok" role="status">{state.ok}</p> : null;
  return (
    <form ref={ref} action={formAction} className={className ?? (inlineMsg ? "inline" : "stack")} style={inlineMsg ? undefined : { display: "flex", flexDirection: "column", gap: 12 }}>
      {hidden && Object.entries(hidden).map(([k, v]) => <input key={k} type="hidden" name={k} value={v ?? ""} />)}
      {children}
      <div className="row">
        <Submit label={submit} pendingLabel={pendingLabel} className={buttonClass} disabled={disabled} />
        {extra}
      </div>
      {msg}
    </form>
  );
}
