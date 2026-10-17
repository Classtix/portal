import { type EmailOtpType } from "@supabase/supabase-js";
import { NextResponse, type NextRequest } from "next/server";
import { createClient } from "@/lib/supabase/server";

/** Invite and password-reset links land here: verify the one-time token, then choose a password. */
export async function GET(request: NextRequest) {
  const url = new URL(request.url);
  const token_hash = url.searchParams.get("token_hash");
  const type = url.searchParams.get("type") as EmailOtpType | null;
  const dest = new URL("/set-password", url.origin);
  if (token_hash && type && ["invite", "recovery", "magiclink", "signup", "email"].includes(type)) {
    const supabase = createClient();
    const { error } = await supabase.auth.verifyOtp({ type, token_hash });
    if (!error) return NextResponse.redirect(dest);
  }
  return NextResponse.redirect(new URL("/login?e=link", url.origin));
}
