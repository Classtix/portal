/** Where each kind of account lands after signing in. */
export const homeFor = (role: string | null | undefined) => role === "admin" ? "/admin" : role === "sponsor" ? "/sponsor" : "/district";
export const roleLabel = (role: string) => role === "admin" ? "ClassTix Admin" : role === "sponsor" ? "Sponsor" : "District Admin";
