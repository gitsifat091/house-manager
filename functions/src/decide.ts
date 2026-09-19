import { NotificationType } from "./notify";
import { monthName } from "./format";

/**
 * What to send, decided from document data alone.
 *
 * Kept separate from the triggers so the part with the actual rules in it —
 * which transitions notify, who they go to, what they say — can be tested
 * without a Firestore or a functions emulator. The triggers do the I/O and
 * nothing else.
 */
export interface Decision {
  /** Who receives it. The trigger resolves this to a uid. */
  to: "landlord" | "tenant";
  type: NotificationType;
  title: string;
  body: string;
}

/** Loosely-typed document data, as it comes out of Firestore. */
export type Doc = Record<string, unknown>;

function str(doc: Doc, key: string, fallback = ""): string {
  const v = doc[key];
  return typeof v === "string" && v.length > 0 ? v : fallback;
}

function period(doc: Doc): string {
  const month = monthName(doc["month"]);
  const year = typeof doc["year"] === "number" ? String(doc["year"]) : "";
  return [month, year].filter((s) => s.length > 0).join(" ");
}

/** Payment status transitions. */
export function decidePayment(before: Doc, after: Doc): Decision | null {
  const was = before["status"];
  const now = after["status"];
  if (was === now) return null;

  switch (now) {
    case "submitted":
      return {
        to: "landlord",
        type: "payment_submitted",
        title: "💰 নতুন পেমেন্ট জমা",
        body: `${str(after, "tenantName", "ভাড়াটিয়া")} রুম ${str(after, "roomNumber")} এর ভাড়া জমা দিয়েছে`,
      };
    case "paid":
      return {
        to: "tenant",
        type: "payment_approved",
        title: "✅ পেমেন্ট অনুমোদিত",
        body: `${period(after)} এর ভাড়া পরিশোধ নিশ্চিত হয়েছে`,
      };
    case "rejected": {
      const reason = str(after, "rejectionReason");
      return {
        to: "tenant",
        type: "payment_rejected",
        title: "❌ পেমেন্ট বাতিল",
        body: reason ? `কারণ: ${reason}` : "পেমেন্ট বাতিল করা হয়েছে",
      };
    }
    default:
      // pending, or anything unrecognised: nothing worth a notification
      return null;
  }
}

/** Utility bill submission and approval. */
export function decideUtility(before: Doc, after: Doc): Decision | null {
  if (!before["isSubmitted"] && after["isSubmitted"] === true) {
    return {
      to: "landlord",
      type: "utility_submitted",
      title: "🧾 নতুন বিল জমা",
      body: `${str(after, "tenantName", "ভাড়াটিয়া")} ${period(after)} এর বিল জমা দিয়েছে`,
    };
  }
  if (!before["isPaid"] && after["isPaid"] === true) {
    return {
      to: "tenant",
      type: "utility_paid",
      title: "✅ বিল পরিশোধিত",
      body: `${period(after)} এর বিল পরিশোধ নিশ্চিত হয়েছে`,
    };
  }
  return null;
}

/** A new maintenance request always tells the landlord. */
export function decideMaintenanceCreated(doc: Doc): Decision {
  return {
    to: "landlord",
    type: "maintenance_created",
    title: "🔧 নতুন মেরামতের অনুরোধ",
    body: `${str(doc, "tenantName", "ভাড়াটিয়া")} (রুম ${str(doc, "roomNumber")}): ${str(doc, "title")}`,
  };
}

const MAINTENANCE_LABELS: Record<string, string> = {
  done: "সম্পন্ন হয়েছে",
  inProgress: "কাজ চলছে",
  pending: "অপেক্ষমাণ",
};

/** Maintenance status changes tell the tenant who raised it. */
export function decideMaintenanceUpdated(
  before: Doc,
  after: Doc,
): Decision | null {
  const was = before["status"];
  const now = after["status"];
  if (was === now) return null;

  const label = MAINTENANCE_LABELS[String(now)];
  if (!label) return null;

  return {
    to: "tenant",
    type: "maintenance_updated",
    title: "🔧 মেরামতের অবস্থা",
    body: `${str(after, "title", "অনুরোধ")}: ${label}`,
  };
}

/** Trims a chat message down to something that fits a notification. */
export function chatPreview(text: string, max = 120): string {
  if (text.length <= max) return text;
  return `${text.slice(0, max - 3)}...`;
}

/**
 * Which participant should hear about a message.
 *
 * Returns null when the sender is the only person we can identify, which
 * happens while a tenant has not yet claimed their record — there is no
 * account to notify, and notifying the sender would be worse than silence.
 */
export function chatRecipient(
  senderId: string,
  landlordId: string | null,
  tenantUid: string | null,
): string | null {
  if (!senderId) return null;
  const other = senderId === landlordId ? tenantUid : landlordId;
  if (!other || other === senderId) return null;
  return other;
}
