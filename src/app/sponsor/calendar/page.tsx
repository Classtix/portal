import { requireSponsor } from "@/lib/session";
import { Head } from "@/components/ui";
import CalendarView, { calendarParams } from "@/components/CalendarView";
import { sortTypes } from "@/lib/format";
import type { EventRow } from "@/lib/types";

export const metadata = { title: "Music & Sports Calendar" };

export default async function SponsorCalendar({ searchParams }: { searchParams: { m?: string; view?: string; cat?: string; g?: string } }) {
  const { supabase, profile } = await requireSponsor();
  const { data } = await supabase.from("events").select("*, ticket_types(*)").eq("status", "Published").order("date", { ascending: true, nullsFirst: false });
  return (
    <>
      <Head eyebrow={`${profile.partner} · Sponsor`} title="Music & Sports Calendar" sub="Everything districts can request on their calendar, the same way they see it. Browsing only." />
      <CalendarView events={((data || []) as EventRow[]).map(sortTypes)} {...calendarParams(searchParams)}
        basePath="/sponsor/calendar" hrefFor={(id) => `/sponsor/events/${id}`} />
    </>
  );
}
