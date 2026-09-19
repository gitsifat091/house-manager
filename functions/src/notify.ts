import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";
import * as logger from "firebase-functions/logger";

/**
 * Delivering a notification: write the in-app record, then push to whatever
 * devices the recipient has registered.
 *
 * Clients no longer write to `notifications` at all. They used to, which meant
 * anyone signed in could create one addressed to anyone — and once those
 * records start producing push, that stops being cosmetic. Rules now deny
 * client creates; only this code, running with admin credentials, writes them.
 */

export type NotificationType =
  | "payment_submitted"
  | "payment_approved"
  | "payment_rejected"
  | "utility_submitted"
  | "utility_paid"
  | "maintenance_created"
  | "maintenance_updated"
  | "chat_message"
  | "notice";

export interface Notification {
  /** Firebase Auth uid of the recipient. Never a tenant document id. */
  userId: string;
  title: string;
  body: string;
  type: NotificationType;
  /** Optional routing hint for the app when a notification is tapped. */
  targetId?: string;
}

const db = () => getFirestore();

/**
 * The Auth uid behind a tenant record.
 *
 * `payments.tenantId`, `utilities.tenantId` and `maintenance.tenantId` all
 * hold the tenant *document* id, while notifications are addressed by Auth
 * uid. The old client code passed the document id straight through, so tenant
 * notifications were written with an id nothing ever queried and were never
 * seen by anybody. Resolving it here is what fixes that.
 *
 * Returns null when the tenant has not claimed their record yet, in which case
 * there is no account to notify.
 */
export async function uidForTenantRecord(
  tenantDocId: string | undefined | null,
): Promise<string | null> {
  if (!tenantDocId) return null;
  const snap = await db().collection("tenants").doc(tenantDocId).get();
  if (!snap.exists) return null;
  const userId = snap.get("userId");
  return typeof userId === "string" && userId.length > 0 ? userId : null;
}

/** Auth uids of every active tenant renting from `landlordId`. */
export async function activeTenantUids(landlordId: string): Promise<string[]> {
  const snap = await db()
    .collection("tenants")
    .where("landlordId", "==", landlordId)
    .where("isActive", "==", true)
    .get();

  const uids = new Set<string>();
  for (const doc of snap.docs) {
    const userId = doc.get("userId");
    if (typeof userId === "string" && userId.length > 0) uids.add(userId);
  }
  return [...uids];
}

/** Registered device tokens for an account. */
async function tokensFor(userId: string): Promise<string[]> {
  const snap = await db().collection("users").doc(userId).get();
  if (!snap.exists) return [];
  const tokens = snap.get("fcmTokens");
  if (!Array.isArray(tokens)) return [];
  return tokens.filter(
    (t): t is string => typeof t === "string" && t.length > 0,
  );
}

/**
 * Drops tokens the FCM backend has told us are dead.
 *
 * Without this the token list grows every time somebody reinstalls the app,
 * and every send wastes work on addresses that can never receive anything.
 */
async function pruneTokens(userId: string, dead: string[]): Promise<void> {
  if (dead.length === 0) return;
  try {
    await db()
      .collection("users")
      .doc(userId)
      .update({ fcmTokens: FieldValue.arrayRemove(...dead) });
    logger.info("pruned dead tokens", { userId, count: dead.length });
  } catch (err) {
    logger.warn("could not prune tokens", { userId, err });
  }
}

/** Sends a push to every device registered to `userId`. */
async function push(userId: string, n: Notification): Promise<void> {
  const tokens = await tokensFor(userId);
  if (tokens.length === 0) return;

  const res = await getMessaging().sendEachForMulticast({
    tokens,
    notification: { title: n.title, body: n.body },
    data: {
      type: n.type,
      ...(n.targetId ? { targetId: n.targetId } : {}),
    },
    android: {
      // No channelId: naming a channel requires one to exist on the device,
      // which needs platform code the app does not have yet. Leaving it unset
      // lets the Firebase SDK use the channel it creates itself, which works
      // on Android 8+ out of the box. See PUSH_NOTIFICATIONS.md.
      priority: "high",
    },
    apns: {
      payload: { aps: { sound: "default" } },
    },
  });

  const dead: string[] = [];
  res.responses.forEach((r, i) => {
    if (r.success) return;
    const code = r.error?.code ?? "";
    if (
      code === "messaging/registration-token-not-registered" ||
      code === "messaging/invalid-registration-token" ||
      code === "messaging/invalid-argument"
    ) {
      dead.push(tokens[i]);
    } else {
      logger.warn("push failed", { userId, code });
    }
  });
  await pruneTokens(userId, dead);
}

/**
 * Records a notification and pushes it.
 *
 * A failure to push must not lose the in-app record, so the write happens
 * first and delivery failures are logged rather than thrown — throwing would
 * make the trigger retry and write the record twice.
 */
export async function deliver(n: Notification): Promise<void> {
  if (!n.userId) return;

  await db().collection("notifications").add({
    userId: n.userId,
    title: n.title,
    body: n.body,
    type: n.type,
    isRead: false,
    createdAt: Date.now(),
  });

  try {
    await push(n.userId, n);
  } catch (err) {
    logger.error("push threw", { userId: n.userId, type: n.type, err });
  }
}

/** Delivers the same notification to several people. */
export async function deliverAll(
  userIds: string[],
  n: Omit<Notification, "userId">,
): Promise<void> {
  await Promise.all(userIds.map((userId) => deliver({ ...n, userId })));
}
