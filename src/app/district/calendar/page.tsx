import { districtContext } from "@/lib/district";
import { Head } from "@/components/ui";
import CalendarView, { calendarParams } from "@/components/CalendarView";
import { pts, sortTypes } from "@/lib/format";
import type { EventRow } from "@/lib/types";

export const metadata = { title: "Music & Sports Events Calendar" };

export default async function Calendar({ searchParams }: { searchParams: { m?: string; view?: string; cat?: string; g?: string } }) {
  const { supabase, district, available } = await districtContext();
  if (!district) return null;
  const { data } = await supabase.from("events").select("*, ticket_types(*)").eq("status", "Published").order("date", { ascending: true, nullsFirst: false });
  return (
    <>
      <Head eyebrow={district.name} title="Music & Sports Events Calendar" sub={<>You have <b>{pts(available)}</b> available. Pick an event to see seats, point costs and the request deadline.</>} />
      <CalendarView events={((data || []) as EventRow[]).map(sortTypes)} {...calendarParams(searchParams)}
        basePath="/district/calendar" hrefFor={(id) => `/district/events/${id}`} />
    </>
  );
}
