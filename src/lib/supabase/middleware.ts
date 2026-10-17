import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

const PUBLIC = ["/login", "/forgot", "/auth", "/api/cron"];

/** A plain page explaining a setup problem, instead of a generic crash. */
function setupError(message: string) {
  const html = `<!doctype html><meta name="viewport" content="width=device-width,initial-scale=1"><title>ClassTix portal setup</title>
<body style="font-family:system-ui,sans-serif;max-width:560px;margin:48px auto;padding:0 16px;color:#0E2A3B;line-height:1.5">
<h1 style="font-size:22px">The portal isn't fully set up yet</h1><p>${message}</p>
<p style="color:#557083;font-size:14px">After changing environment variables in Vercel, redeploy: Deployments → ⋯ → Redeploy.</p></body>`;
  return new NextResponse(html, { status: 503, headers: { "content-type": "text/html; charset=utf-8" } });
}

export async function updateSession(request: NextRequest) {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  const missing = [!url && "NEXT_PUBLIC_SUPABASE_URL", !key && "NEXT_PUBLIC_SUPABASE_ANON_KEY"].filter(Boolean);
  if (missing.length) return setupError(`Vercel is missing these environment variables: <b>${missing.join(", ")}</b>. Add them under Project → Settings → Environment Variables (exact names, Production ticked).`);
  if (!/^https:\/\/[a-z0-9-]+\.supabase\.co\/?$/i.test(url!) && !url!.startsWith("http://localhost")) {
    return setupError("<b>NEXT_PUBLIC_SUPABASE_URL</b> doesn't look right. It should be the Project URL from Supabase → Project Settings → API, like https://abcdefgh.supabase.co, with nothing after .co.");
  }
  let response = NextResponse.next({ request });
  const supabase = createServerClient(
    url!.replace(/\/$/, ""),
    key!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll();
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
          response = NextResponse.next({ request });
          cookiesToSet.forEach(({ name, value, options }) => response.cookies.set(name, value, options));
        },
      },
    }
  );
  let user = null;
  try {
    ({ data: { user } } = await supabase.auth.getUser());
  } catch {
    return setupError("The portal couldn't reach Supabase. Check that the Supabase project is running (not paused) and that NEXT_PUBLIC_SUPABASE_ANON_KEY is the <b>anon public</b> key.");
  }
  const path = request.nextUrl.pathname;
  if (!user && !PUBLIC.some((p) => path === p || path.startsWith(p + "/"))) {
    const url = request.nextUrl.clone();
    url.pathname = "/login";
    url.search = "";
    return NextResponse.redirect(url);
  }
  return response;
}
