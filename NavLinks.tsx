"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";

export default function NavLinks({ items }: { items: { href: string; label: string; count?: number; exact?: boolean }[] }) {
  const path = usePathname();
  return (
    <nav className="nav" aria-label="Sections">
      {items.map((i) => {
        const on = i.exact ? path === i.href : path === i.href || path.startsWith(i.href + "/");
        return (
          <Link key={i.href} href={i.href} aria-current={on ? "page" : undefined}>
            <span>{i.label}</span>
            {i.count ? <span className="cnt">{i.count}</span> : null}
          </Link>
        );
      })}
    </nav>
  );
}
