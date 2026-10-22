import Link from "next/link";
import { requireAdmin } from "@/lib/session";
import { Head } from "@/components/ui";
import CalendarView, { calendarParams } from "@/components/CalendarView";
import { sortTypes } from "@/lib/format";
import type { EventRow } from "@/lib/types";

export const metadata = { title: "Calendar" };

export default async function AdminCalendar({ searchParams }: { searchParams: { m?: string; view?: string; cat?: string; g?: string } }) {
  const { supabase } = await requireAdmin();
  const { data } = await supabase.from("events").select("*, ticket_types(*)").in("status", ["Published", "Draft"]).order("date", { ascending: true, nullsFirst: false });
  return (
    <>
      <Head eyebrow="ClassTix Admin" title="Calendar"
        sub="What districts see on their Music &amp; Sports Calendar, plus your drafts. Click any event to edit it."
        right={<Link className="btn" href="/admin/events/new">New event or item</Link>} />
      <CalendarView events={((data || []) as EventRow[]).map(sortTypes)} {...calendarParams(searchParams)}
        basePath="/admin/calendar" hrefFor={(id) => `/admin/events/${id}`} admin />
    </>
  );
}
