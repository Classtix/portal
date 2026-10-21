import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";

export const dynamic = "force-dynamic";

/**
 * Sends a district to one of its ticket files or links.
 * Row-level security decides whether the signed-in person can see the delivery; only then is a
 * 2-minute download link created for the private file.
 */
export async function GET(req: Request, { params }: { params: { id: string } }) {
  const supabase = createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return NextResponse.redirect(new URL("/login", req.url));
  const { data: d } = await supabase.from("deliveries").select("id, kind, path, file_name, url").eq("id", params.id).maybeSingle();
  if (!d) return new NextResponse("That ticket isn't available. It may have been replaced; check My tickets again.", { status: 404 });
  await supabase.rpc("mark_downloaded", { p_id: d.id });
  if (d.kind === "link") return NextResponse.redirect(d.url!);
  const { data, error } = await createAdminClient().storage.from("tickets").createSignedUrl(d.path!, 120, { download: d.file_name || true });
  if (error || !data) return new NextResponse("The file couldn't be opened. Try again, or email hello@classtix.org.", { status: 502 });
  return NextResponse.redirect(data.signedUrl);
}
