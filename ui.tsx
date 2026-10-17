import { CATS } from "@/lib/format";

export const Pill = ({ s, ev }: { s: string; ev?: boolean }) => <span className={`pill ${s.replace(/\s/g, "")} ${ev ? "ev" : ""}`}>{s}</span>;
export const CatPill = ({ c }: { c: string }) => <span className="cat">{CATS[c] || c || "Other"}</span>;
export const Kpi = ({ label, value, small, hot }: { label: string; value: React.ReactNode; small?: React.ReactNode; hot?: boolean }) => (
  <div className={`kpi ${hot ? "hot" : ""}`}><span>{label}</span><b>{value}</b>{small ? <small>{small}</small> : null}</div>
);
export const Head = ({ eyebrow, title, sub, right }: { eyebrow: React.ReactNode; title: React.ReactNode; sub?: React.ReactNode; right?: React.ReactNode }) => (
  <div className="head">
    <div><p className="eyebrow">{eyebrow}</p><h1>{title}</h1>{sub ? <p>{sub}</p> : null}</div>
    {right ? <div className="row">{right}</div> : null}
  </div>
);
export const Empty = ({ title, children }: { title: string; children?: React.ReactNode }) => (
  <div className="empty"><strong>{title}</strong>{children}</div>
);
export const Logo = () => (
  <svg width="40" height="34" viewBox="0 0 44 36" aria-hidden="true">
    <g transform="rotate(-14 22 18)">
      <rect x="4" y="9" width="26" height="17" rx="3" fill="#FE4001" opacity=".5" />
      <path d="M12 7h26a3 3 0 0 1 3 3v4a3 3 0 0 0 0 6v4a3 3 0 0 1-3 3H12a3 3 0 0 1-3-3v-4a3 3 0 0 0 0-6v-4a3 3 0 0 1 3-3z" fill="#FE4001" />
      <path d="M30 9v16" stroke="#fff" strokeWidth="1.6" strokeDasharray="2 2" />
    </g>
  </svg>
);
