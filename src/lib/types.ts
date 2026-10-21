export type Role = "admin" | "district";
export type Profile = {
  id: string; name: string; email: string; role: Role; district_id: string | null;
  status: "Invited" | "Active" | "Deactivated"; invited_at: string; last_login: string | null;
};
export type District = {
  id: string; name: string; state: string; students: number; tier: "t1" | "t2" | "sub";
  next_tier: "t1" | "t2" | "sub" | null; monthly: number; contact: string; status: "Active" | "Inactive"; created_at: string; schools: string[];
};
export type TicketType = { id: string; event_id: string; name: string; qty: number; points: number; seats: number; approved: number; sort: number };
export type EventRow = {
  id: string; title: string; cat: string; partner: string; description: string; dated: boolean; date: string | null;
  time: string; venue: string; deadline: string | null; max_per_request: number | null;
  status: "Published" | "Draft" | "Cancelled" | "Archived"; series: string | null; created_at: string; updated_at: string;
  ticket_types: TicketType[];
};
export type RequestStatus = "Pending" | "Approved" | "Rejected" | "Fulfilled" | "Cancelled";
export type RequestRow = {
  id: string; code: string; district_id: string; event_id: string; type_id: string; qty: number; points_each: number;
  approved_qty: number; status: RequestStatus; note: string; school: string; merit: string; reason: string; created_at: string;
  decided_at: string | null; fulfilled_at: string | null;
};
export type LedgerRow = { id: number; district_id: string; at: string; entry: string; amount: number; ref: string };
export type Settings = {
  id: number; current_month: string; rollover: boolean; last_reset_at: string | null; portal_url: string;
  retail: { days: number[]; retailers: string[]; denoms: { label: string; points: number; qty: number }[] };
};
export type ActionState = { ok?: string; error?: string; at?: number } | null;

export type Delivery = {
  id: string; request_id: string; district_id: string; kind: "file" | "link"; label: string; path: string | null;
  file_name: string | null; size: number | null; url: string | null; created_at: string; downloaded_at: string | null;
};
