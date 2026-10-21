import { NextResponse, type NextRequest } from "next/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { deliverOutbox } from "@/lib/email";

export const dynamic = "force-dynamic";

/**
 * Runs daily (vercel.json). Starts the new month on the 1st (expire/roll over points, credit allocations,
 * email districts) and sends queued email.
 */
export async function GET(request: NextRequest) {
  const secret = process.env.CRON_SECRET;
  if (!secret || request.headers.get("authorization") !== `Bearer ${secret}`) {
    return NextResponse.json({ error: "unauthorized" }, { status: 401 });
  }
  const db = createAdminClient();
  const { data, error } = await db.rpc("cron_tick");
  if (error) return NextResponse.json({ error: error.message }, { status: 500 });
  const email = await deliverOutbox(200);
  return NextResponse.json({ ok: true, ...data, email });
}
