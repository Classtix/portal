import type { EventRow } from "./types";

/**
 * Calendar color groups: each team and each music venue gets its own color.
 * Matching is by import series first (asu-, suns-, cardinals-, concert-), then by title, partner and venue,
 * so listings added by hand in the admin are colored too.
 */
export type ColorGroup = { key: string; label: string; color: string };

export const GROUPS: ColorGroup[] = [
  { key: "asu", label: "ASU Sun Devils", color: "#8C1D40" },
  { key: "suns", label: "Phoenix Suns", color: "#5A2D82" },
  { key: "cardinals", label: "Arizona Cardinals", color: "#E31837" },
  { key: "statefarm", label: "State Farm Stadium", color: "#0E8A7E" },
  { key: "chase", label: "Chase Field", color: "#1F6FB2" },
  { key: "mmc", label: "Mortgage Matchup Center", color: "#E56020" },
  { key: "talkingstick", label: "Talking Stick Resort Amphitheatre", color: "#3E8E2F" },
  { key: "azfin", label: "Arizona Financial Theatre", color: "#C2187A" },
  { key: "other", label: "Other events", color: "#5B7A8C" },
];
const BY_KEY = Object.fromEntries(GROUPS.map((g) => [g.key, g]));

const VENUES: [RegExp, string][] = [
  [/state farm stadium/i, "statefarm"],
  [/chase field/i, "chase"],
  [/mortgage matchup|footprint center/i, "mmc"],
  [/talking stick/i, "talkingstick"],
  [/arizona financial theat/i, "azfin"],
];

export function groupOf(e: Pick<EventRow, "series" | "title" | "partner" | "venue" | "cat">): ColorGroup {
  const s = (e.series || "").toLowerCase();
  const t = `${e.title} ${e.partner}`;
  if (s.startsWith("asu-") || /\b(ASU|Arizona State|Sun Devil)/i.test(t)) return BY_KEY.asu;
  if (s.startsWith("suns-") || /phoenix suns/i.test(t)) return BY_KEY.suns;
  if (s.startsWith("cardinals-") || /arizona cardinals/i.test(t)) return BY_KEY.cardinals;
  if (s.startsWith("concert-") || e.cat === "music") {
    for (const [re, key] of VENUES) if (re.test(e.venue || "")) return BY_KEY[key];
  }
  return BY_KEY.other;
}
