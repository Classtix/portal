"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { createClient } from "@/lib/supabase/server";
import { createAdminClient } from "@/lib/supabase/admin";
import { deliverOutbox } from "@/lib/email";
import type { ActionState } from "@/lib/types";

const SITE = () => (process.env.NEXT_PUBLIC_SITE_URL || "http://localhost:3000").replace(/\/$/, "");
const s = (fd: FormData, k: string) => String(fd.get(k) ?? "").trim();
const n = (fd: FormData, k: string) => (s(fd, k) === "" ? null : Number(s(fd, k)));
const done = (ok: string): ActionState => ({ ok, at: Date.now() });
const fail = (error: string): ActionState => ({ error, at: Date.now() });

/** Runs a database function as the signed-in person, then sends any emails it queued. */
async function rpc(fn: string, args: Record<string, unknown>) {
  const supabase = createClient();
  const { data, error } = await supabase.rpc(fn, args);
  if (error) throw new Error(cleanError(error.message));
  await deliverOutbox().catch(() => undefined);
  return data;
}
function cleanError(m: string) {
  if (/JWT|not authenticated|permission denied/i.test(m)) return "Your session ended. Sign in again.";
  return m;
}
async function guard(work: () => Promise<string>, paths: string[] = ["/", "/admin", "/district"]): Promise<ActionState> {
  try {
    const ok = await work();
    paths.forEach((p) => revalidatePath(p, "layout"));
    return done(ok);
  } catch (e) {
    return fail((e as Error).message || "That didn't save. Try again.");
  }
}
async function adminOnly() {
  const supabase = createClient();
  const { data } = await supabase.rpc("is_admin");
  if (!data) throw new Error("Only ClassTix admins can do that.");
}

/* ------------------------------------------------------------------ auth */
export async function signIn(_: ActionState, fd: FormData): Promise<ActionState> {
  const supabase = createClient();
  const { data: auth, error } = await supabase.auth.signInWithPassword({ email: s(fd, "email").toLowerCase(), password: s(fd, "password") });
  if (error || !auth.user) return fail("That email and password don't match. Try again or reset your password.");
  const { data: me } = await supabase.from("profiles").select("role,status").eq("id", auth.user.id).maybeSingle();
  if (!me || me.status === "Deactivated") {
    await supabase.auth.signOut();
    return fail("This account doesn't have access to the portal. Contact ClassTix.");
  }
  await supabase.rpc("touch_login");
  redirect(me.role === "admin" ? "/admin" : "/district");
}

export async function signOut() {
  await createClient().auth.signOut();
  redirect("/login");
}

/** Emails a branded set-password link. Never reveals whether the address has an account. */
export async function sendPasswordReset(_: ActionState, fd: FormData): Promise<ActionState> {
  const email = s(fd, "email").toLowerCase();
  if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) return fail("Enter the email your invite was sent to.");
  const admin = createAdminClient();
  const { data: prof } = await admin.from("profiles").select("name,status").eq("email", email).maybeSingle();
  if (prof && prof.status !== "Deactivated") {
    const { data, error } = await admin.auth.admin.generateLink({ type: "recovery", email });
    if (!error && data?.properties?.hashed_token) {
      const link = `${SITE()}/auth/confirm?token_hash=${data.properties.hashed_token}&type=recovery`;
      await admin.from("outbox").insert({
        to_email: email, to_name: prof.name, kind: "password",
        subject: "Reset your ClassTix password",
        body: `Hi ${prof.name || "there"},\n\nUse this link to choose a new password. It works once and expires in 1 hour.\n\n${link}\n\nIf you didn't ask for this, you can ignore this email.\n\nThe ClassTix team`,
      });
      await deliverOutbox().catch(() => undefined);
    }
  }
  return done("If that email has access, a reset link is on its way. Check your inbox.");
}

/** Uses an invite or reset token only when the person presses Continue (see auth/confirm). */
export async function continueLink(fd: FormData) {
  const token_hash = s(fd, "token_hash"), type = s(fd, "type");
  if (token_hash && ["invite", "recovery", "magiclink", "signup", "email"].includes(type)) {
    const { error } = await createClient().auth.verifyOtp({ type: type as "invite" | "recovery" | "magiclink" | "signup" | "email", token_hash });
    if (!error) redirect("/set-password");
  }
  redirect("/login?e=link");
}
export async function setPassword(_: ActionState, fd: FormData): Promise<ActionState> {
  const p1 = s(fd, "password"), p2 = s(fd, "confirm");
  if (p1.length < 10) return fail("Use at least 10 characters.");
  if (p1 !== p2) return fail("The two passwords don't match.");
  const supabase = createClient();
  const { error } = await supabase.auth.updateUser({ password: p1 });
  if (error) return fail(error.message.includes("session") ? "This link has expired. Ask ClassTix to resend your invite." : error.message);
  await supabase.rpc("touch_login");
  const { data: { user } } = await supabase.auth.getUser();
  const { data: me } = await supabase.from("profiles").select("role").eq("id", user?.id ?? "").maybeSingle();
  redirect(me?.role === "admin" ? "/admin" : "/district");
}

/* ------------------------------------------------------------------ district */
export async function submitRequest(_: ActionState, fd: FormData): Promise<ActionState> {
  let code = "";
  const res = await guard(async () => {
    code = await rpc("submit_request", { p_type: s(fd, "type_id"), p_qty: n(fd, "qty"), p_school: s(fd, "school"), p_merit: s(fd, "merit") });
    return `Request ${code} sent.`;
  });
  if (res?.error) return res;
  redirect(`/district/requests?sent=${encodeURIComponent(code)}`);
}

export async function cancelRequest(_: ActionState, fd: FormData) {
  return guard(async () => { await rpc("cancel_request", { p_id: s(fd, "id") }); return "Request cancelled. The points are back."; });
}

/* ------------------------------------------------------------------ admin: requests */
/** After a decision, stay on the same request so the admin sees its new status. */
async function decide(fd: FormData, work: () => Promise<string>): Promise<ActionState> {
  const res = await guard(work);
  if (res?.error) return res;
  const back = s(fd, "back") || "Pending";
  redirect(`/admin/requests?status=${encodeURIComponent(back)}&id=${s(fd, "id")}&ok=${encodeURIComponent(res!.ok!)}`);
}
export async function approveRequest(_: ActionState, fd: FormData) {
  return decide(fd, async () => {
    const q = n(fd, "qty");
    await rpc("approve_request", { p_id: s(fd, "id"), p_qty: q });
    return q ? `Approved ${q}. Unused points released and the district emailed.` : "Approved. The district was emailed.";
  });
}
export async function rejectRequest(_: ActionState, fd: FormData) {
  return decide(fd, async () => {
    const reason = s(fd, "reason") === "Other" ? s(fd, "other") : s(fd, "reason");
    await rpc("reject_request", { p_id: s(fd, "id"), p_reason: reason });
    return "Rejected. Points released and the district emailed.";
  });
}
export async function fulfilRequest(_: ActionState, fd: FormData) {
  return decide(fd, async () => { await rpc("fulfil_request", { p_id: s(fd, "id") }); return "Marked fulfilled and the district was emailed."; });
}
export async function saveInternalNote(_: ActionState, fd: FormData) {
  return guard(async () => { await rpc("set_internal_note", { p_id: s(fd, "id"), p_note: s(fd, "note") }); return "Internal note saved."; });
}

/* ------------------------------------------------------------------ admin: ticket files for My Tickets */
const TICKET_EXT = /\.(pdf|png|jpe?g|webp|heic|gif|pkpass|zip|txt|csv|docx?|xlsx?)$/i;
const MAX_TICKET_BYTES = 25 * 1024 * 1024;

/** Step 1 of an upload: a one-time signed URL so the browser sends the file straight to private storage. */
export async function startTicketUpload(requestId: string, fileName: string, size: number): Promise<{ path?: string; token?: string; error?: string }> {
  try {
    await adminOnly();
    if (!TICKET_EXT.test(fileName)) return { error: `${fileName}: use a PDF, image, Apple Wallet pass, ZIP or document.` };
    if (size > MAX_TICKET_BYTES) return { error: `${fileName} is over 25 MB.` };
    const { data: r } = await createClient().from("requests").select("id, district_id, status").eq("id", requestId).maybeSingle();
    if (!r) return { error: "Request not found." };
    if (r.status !== "Approved" && r.status !== "Fulfilled") return { error: "Approve the request before adding tickets." };
    const safe = fileName.normalize("NFKD").replace(/[^\w.\-]+/g, "-").replace(/-+/g, "-").slice(-120);
    const path = `${r.district_id}/${r.id}/${crypto.randomUUID().slice(0, 8)}-${safe}`;
    const { data, error } = await createAdminClient().storage.from("tickets").createSignedUploadUrl(path);
    if (error || !data) return { error: "Storage isn't set up yet. Run 0007_my_tickets.sql in Supabase." };
    return { path, token: data.token };
  } catch (e) { return { error: (e as Error).message }; }
}
/** Step 2: record the uploaded file on the request. */
export async function saveTicketFile(requestId: string, path: string, fileName: string, size: number, label: string): Promise<{ error?: string }> {
  try {
    await rpc("add_delivery", { p_request: requestId, p_kind: "file", p_label: label, p_path: path, p_file_name: fileName, p_size: size, p_url: null });
    revalidatePath("/admin", "layout"); revalidatePath("/district", "layout");
    return {};
  } catch (e) {
    await createAdminClient().storage.from("tickets").remove([path]).catch(() => undefined);
    return { error: (e as Error).message };
  }
}
export async function addTicketLink(_: ActionState, fd: FormData) {
  return guard(async () => {
    await rpc("add_delivery", { p_request: s(fd, "id"), p_kind: "link", p_label: s(fd, "label"), p_path: null, p_file_name: null, p_size: null, p_url: s(fd, "url") });
    return "Link added to the district's My Tickets.";
  });
}
export async function removeTicket(_: ActionState, fd: FormData) {
  return guard(async () => {
    const path = (await rpc("remove_delivery", { p_id: s(fd, "id") })) as string | null;
    if (path) await createAdminClient().storage.from("tickets").remove([path]);
    return "Removed.";
  });
}

/* ------------------------------------------------------------------ assemblies (speakers) */
export async function requestAssembly(_: ActionState, fd: FormData): Promise<ActionState> {
  let code = "";
  const date = s(fd, "date");
  const res = await guard(async () => {
    code = await rpc("request_assembly", {
      p_speaker: s(fd, "speaker"), p_school: s(fd, "school"), p_date: date, p_time: s(fd, "time"),
      p_audience: n(fd, "audience") ?? 0, p_grades: s(fd, "grades"), p_note: s(fd, "note"),
    });
    return `Request ${code} sent.`;
  });
  if (res?.error) return res;
  redirect(`/district/assemblies?sent=${encodeURIComponent(code)}&m=${date.slice(0, 7)}`);
}
export async function cancelAssembly(_: ActionState, fd: FormData) {
  return guard(async () => { await rpc("cancel_assembly", { p_id: s(fd, "id") }); return "Request cancelled."; });
}
export async function decideAssembly(_: ActionState, fd: FormData) {
  return guard(async () => {
    const st = s(fd, "status");
    await rpc("decide_assembly", { p_id: s(fd, "id"), p_status: st, p_note: s(fd, "note") });
    return st === "Confirmed" ? "Confirmed. The district was emailed." : "Declined. The district was emailed.";
  });
}
export async function saveSpeaker(_: ActionState, fd: FormData) {
  return guard(async () => {
    await rpc("save_speaker", { p_id: s(fd, "id") || null, p_name: s(fd, "name"), p_org: s(fd, "org"), p_description: s(fd, "description"), p_active: s(fd, "active") !== "off" });
    return "Speaker saved.";
  });
}

/* ------------------------------------------------------------------ admin: events */
export async function saveEvent(_: ActionState, fd: FormData): Promise<ActionState> {
  let id = "";
  const res = await guard(async () => {
    const payload = JSON.parse(s(fd, "payload") || "{}");
    id = await rpc("save_event", { p: payload });
    return "Saved.";
  });
  if (res?.error) return res;
  redirect(`/admin/events?saved=1`);
}
export async function setEventStatus(_: ActionState, fd: FormData) {
  return guard(async () => {
    const st = s(fd, "status");
    await rpc("set_event_status", { p_id: s(fd, "id"), p_status: st });
    return st === "Archived" ? "Archived. It's hidden from districts." : st === "Draft" ? "Moved to drafts." : "Published. Districts see it now.";
  });
}
export async function cancelEvent(_: ActionState, fd: FormData) {
  return guard(async () => {
    const count = await rpc("cancel_event", { p_id: s(fd, "id") });
    return `Event cancelled. ${count} request${count === 1 ? "" : "s"} closed, points returned and districts emailed.`;
  });
}

/* ------------------------------------------------------------------ admin: districts */
export async function createDistrict(_: ActionState, fd: FormData): Promise<ActionState> {
  let id = "";
  const res = await guard(async () => {
    id = await rpc("create_district", {
      p_name: s(fd, "name"), p_state: s(fd, "state"), p_students: n(fd, "students") ?? 0,
      p_tier: "t2", p_monthly: null, p_contact: s(fd, "contact"),
    });
    await rpc("set_district_schools", { p_id: id, p_schools: s(fd, "schools").split(/\r?\n/) });
    return "District added.";
  });
  if (res?.error) return res;
  redirect(`/admin/districts?id=${id}`);
}
export async function updateDistrict(_: ActionState, fd: FormData) {
  return guard(async () => {
    await rpc("update_district", {
      p_id: s(fd, "id"), p_name: s(fd, "name"), p_students: n(fd, "students"), p_contact: s(fd, "contact"),
      p_monthly: null, p_tier: "t2",
    });
    await rpc("set_district_schools", { p_id: s(fd, "id"), p_schools: s(fd, "schools").split(/\r?\n/) });
    return "Saved. The new monthly points apply at the next reset.";
  });
}
export async function adjustPoints(_: ActionState, fd: FormData) {
  return guard(async () => {
    await rpc("adjust_points", { p_district: s(fd, "id"), p_amount: n(fd, "amount"), p_reason: s(fd, "reason") });
    return "Points adjusted.";
  });
}
export async function setDistrictStatus(_: ActionState, fd: FormData) {
  return guard(async () => {
    const st = s(fd, "status");
    const ids = ((await rpc("set_district_status", { p_id: s(fd, "id"), p_status: st })) as string[] | null) || [];
    const admin = createAdminClient();
    for (const uid of ids) await admin.auth.admin.updateUserById(uid, { ban_duration: "876000h" });
    return st === "Inactive" ? "District deactivated. Its admins can no longer sign in." : "District reactivated. Reactivate its admins under Users.";
  });
}

/* ------------------------------------------------------------------ admin: users */
async function sendInviteLink(email: string, name: string, role: string, districtName: string | null) {
  const admin = createAdminClient();
  let { data, error } = await admin.auth.admin.generateLink({ type: "invite", email, options: { data: { name } } });
  if (error && /already|registered|exists/i.test(error.message)) {
    ({ data, error } = await admin.auth.admin.generateLink({ type: "recovery", email }));
  }
  if (error || !data?.user || !data.properties?.hashed_token) throw new Error(error?.message || "Couldn't create the invite.");
  const type = data.properties.verification_type === "invite" ? "invite" : "recovery";
  const link = `${SITE()}/auth/confirm?token_hash=${data.properties.hashed_token}&type=${type}`;
  await admin.from("outbox").insert({
    to_email: email, to_name: name, kind: "invite", subject: "Your invite to the ClassTix portal",
    body: `Hi ${name},\n\nYou've been invited to the ClassTix District Rewards Portal as a ${role === "admin" ? "ClassTix Admin" : "District Admin"}${districtName ? " for " + districtName : ""}.\n\nOpen this link to set your password and sign in. It works once; if it has expired, use \"Forgot your password?\" on the sign-in page to get a new one:\n\n${link}\n\nAfter that, sign in any time at ${SITE()}\n\nThe ClassTix team`,
  });
  return data.user.id;
}

export async function inviteUser(_: ActionState, fd: FormData) {
  return guard(async () => {
    await adminOnly();
    const name = s(fd, "name"), email = s(fd, "email").toLowerCase(), role = s(fd, "role") === "admin" ? "admin" : "district";
    const did = role === "district" ? s(fd, "district_id") : null;
    if (!name) throw new Error("Add their name.");
    if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) throw new Error("Enter a valid email address.");
    if (role === "district" && !did) throw new Error("Choose their district.");
    const supabase = createClient();
    const { data: existing } = await supabase.from("profiles").select("id,status").eq("email", email).maybeSingle();
    if (existing && existing.status !== "Invited") throw new Error("Someone with that email already has access.");
    const { data: d } = did ? await supabase.from("districts").select("name").eq("id", did).maybeSingle() : { data: null };
    const uid = await sendInviteLink(email, name, role, d?.name ?? null);
    await rpc("admin_set_profile", { p_user: uid, p_name: name, p_email: email, p_role: role, p_district: did, p_status: "Invited" });
    return `Invite sent to ${email}.`;
  });
}

export async function resendInvite(_: ActionState, fd: FormData) {
  return guard(async () => {
    await adminOnly();
    const supabase = createClient();
    const { data: p } = await supabase.from("profiles").select("*, districts(name)").eq("id", s(fd, "id")).maybeSingle();
    if (!p) throw new Error("User not found.");
    await sendInviteLink(p.email, p.name, p.role, (p as { districts?: { name: string } | null }).districts?.name ?? null);
    await rpc("admin_set_profile", { p_user: p.id, p_name: p.name, p_email: p.email, p_role: p.role, p_district: p.district_id, p_status: "Invited" });
    return `Invite sent again to ${p.email}.`;
  });
}

export async function setUserStatus(_: ActionState, fd: FormData) {
  return guard(async () => {
    const id = s(fd, "id"), st = s(fd, "status");
    await rpc("set_user_status", { p_user: id, p_status: st });
    await createAdminClient().auth.admin.updateUserById(id, { ban_duration: st === "Deactivated" ? "876000h" : "none" });
    return st === "Deactivated" ? "User deactivated. Their request history is kept." : "User reactivated.";
  });
}

/* ------------------------------------------------------------------ admin: program */
export async function updateProgram(_: ActionState, fd: FormData) {
  return guard(async () => {
    await rpc("update_settings", { p_rollover: s(fd, "rollover") === "1", p_retail: null });
    return s(fd, "rollover") === "1" ? "Saved. Unused points now roll over." : "Saved. Unused points now expire at reset.";
  });
}
export async function runResetNow() {
  return guard(async () => {
    const m = await rpc("run_monthly_reset", {});
    return `${m} started. Districts were credited and emailed.`;
  });
}
export async function retryEmails() {
  return guard(async () => {
    await adminOnly();
    const r = await deliverOutbox(100);
    if (r.skipped) throw new Error("Email sending isn't set up yet. Add RESEND_API_KEY in Vercel.");
    return `${r.sent} sent${r.failed ? `, ${r.failed} still failing` : ""}.`;
  });
}
