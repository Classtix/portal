import { districtContext } from "@/lib/district";
import { Head, Kpi } from "@/components/ui";
import LedgerTable from "@/components/LedgerTable";
import { pts, mLabel, mNext, TIERS } from "@/lib/format";
import type { LedgerRow } from "@/lib/types";

export const metadata = { title: "Points history" };

export default async function Points() {
  const { supabase, district: d, available, held, settings } = await districtContext();
  if (!d) return null;
  const { data } = await supabase.from("ledger").select("*").eq("district_id", d.id).order("at").order("id");
  return (
    <>
      <Head eyebrow={d.name} title="Points history" sub="Every allocation, hold, release, spend and adjustment, newest first." />
      <div className="kpis">
        <Kpi label="Available" value={pts(available)} hot />
        <Kpi label="On hold" value={pts(held)} small="pending requests" />
        <Kpi label="Monthly allocation" value={pts(d.monthly)} small={TIERS[d.tier]} />
        <Kpi label="Next reset" value={mLabel(mNext(settings.current_month))} small={settings.rollover ? "Unused points roll over" : "Unused points expire"} />
      </div>
      <section className="panel"><LedgerTable rows={(data || []) as LedgerRow[]} /></section>
    </>
  );
}
