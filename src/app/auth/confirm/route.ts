import { NextResponse, type NextRequest } from "next/server";

/**
 * Invite and password-reset links land here. We do NOT use the one-time token on this GET:
 * school email filters (Microsoft Safe Links, Barracuda, Mimecast…) open every link to scan it,
 * which would burn the token before the person clicks. Instead we show a page with a Continue
 * button; the token is only used when a human presses it.
 */
export async function GET(request: NextRequest) {
  const url = new URL(request.url);
  const next = new URL("/auth/continue", url.origin);
  for (const k of ["token_hash", "type"]) { const v = url.searchParams.get(k); if (v) next.searchParams.set(k, v); }
  return NextResponse.redirect(next);
}
