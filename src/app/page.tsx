import { redirect } from "next/navigation";
import { getMe } from "@/lib/session";
import { homeFor } from "@/lib/roles";

export default async function Home() {
  const { profile } = await getMe();
  redirect(homeFor(profile.role));
}
