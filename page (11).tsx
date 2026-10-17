import { redirect } from "next/navigation";
import { getMe } from "@/lib/session";

export default async function Home() {
  const { profile } = await getMe();
  redirect(profile.role === "admin" ? "/admin" : "/district");
}
