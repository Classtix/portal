import Link from "next/link";
import { requireAdmin } from "@/lib/session";
import { Head } from "@/components/ui";
import EventForm from "@/components/EventForm";
import { sortTypes } from "@/lib/format";
import type { EventRow } from "@/lib/types";

export const metadata = { title: "New listing" };

export default async function NewEvent({ searchParams }: { searchParams: { from?: string } }) {
  const { supabase } = await requireAdmin();
  let src: EventRow | null = null;
  if (searchParams.from) {
    const { data } = await supabase.from("events").select("*, ticket_types(*)").eq("id", searchParams.from).maybeSingle();
    src = data ? sortTypes(data as EventRow) : null;
  }
  return (
    <>
      <Head eyebrow="New listing" title={src ? `Copy of ${src.title}` : "New event or item"}
        sub={src ? "Set the new date, then publish. It starts as a draft." : "Publish it to put it in front of every district right away."}
        right={<Link className="btn sec" href="/admin/events">Back to list</Link>} />
      <EventForm event={src} copy={!!src} />
    </>
  );
}
