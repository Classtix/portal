"use client";
import { useEffect, useRef } from "react";

/** A button that opens a small panel in place (used for confirm steps and short forms). Closes itself after success. */
export default function Pop({ label, className, children }: { label: string; className?: string; children: React.ReactNode }) {
  const ref = useRef<HTMLDetailsElement>(null);
  useEffect(() => {
    const el = ref.current; if (!el) return;
    const obs = new MutationObserver(() => {
      if (el.querySelector(".msg-ok")) setTimeout(() => { if (el) el.open = false; }, 1600);
    });
    obs.observe(el, { childList: true, subtree: true });
    return () => obs.disconnect();
  }, []);
  return (
    <details className="pop" ref={ref}>
      <summary className={className ?? "btn sec sm"} role="button">{label}</summary>
      <div className="popbody">{children}</div>
    </details>
  );
}
