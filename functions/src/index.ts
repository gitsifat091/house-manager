import { initializeApp } from "firebase-admin/app";
import {
  onDocumentCreated,
  onDocumentUpdated,
} from "firebase-functions/v2/firestore";
import { setGlobalOptions } from "firebase-functions/v2";
import * as logger from "firebase-functions/logger";

import {
  activeTenantUids,
  deliver,
  deliverAll,
  uidForTenantRecord,
} from "./notify";
import {
  Decision,
  Doc,
  chatPreview,
  chatRecipient,
  decideMaintenanceCreated,
  decideMaintenanceUpdated,
  decidePayment,
  decideUtility,
} from "./decide";

initializeApp();

/**
 * Must match the location of your Firestore database, or the deploy fails.
 *
 * Check it at Firebase console -> Firestore Database, top of the page. A
 * multi-region "nam5" maps to us-central1 and "eur3" to europe-west1; a
 * single-region location is used as-is (asia-south1 for Mumbai, and so on).
 * us-central1 is the default a project gets when nobody chooses.
 */
const REGION = "us-central1";

setGlobalOptions({ region: REGION, maxInstances: 10 });

/**
 * Notifications are produced here rather than by the app.
 *
 * Two reasons. The app cannot send a push — it has no credentials to do so, so
 * FCM tokens were being collected and never used. And letting clients write
 * the `notifications` collection meant anyone signed in could address one to
 * anyone, which becomes a way to push spam to a stranger's phone the moment
 * those records start producing notifications.
 *
 * What to send lives in decide.ts, which is pure and unit tested. These
 * wrappers only resolve recipients and write.
 */

/** Resolves a decision to an account and delivers it. */
async function dispatch(
  decision: Decision | null,
  doc: Doc,
  targetId: string,
): Promise<void> {
  if (!decision) return;

  const recipient =
    decision.to === "landlord"
      ? typeof doc["landlordId"] === "string"
        ? doc["landlordId"]
        : null
      : await uidForTenantRecord(doc["tenantId"] as string | undefined);

  if (!recipient) {
    // A tenant who has not claimed their record yet has no account to notify.
    logger.debug("no recipient", { type: decision.type, targetId });
    return;
  }

  await deliver({
    userId: recipient,
    type: decision.type,
    title: decision.title,
    body: decision.body,
    targetId,
  });
}

// ── Payments ────────────────────────────────────────────────────────

export const onPaymentUpdated = onDocumentUpdated(
  "payments/{paymentId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;
    await dispatch(decidePayment(before, after), after, event.params.paymentId);
  },
);

// ── Utilities ───────────────────────────────────────────────────────

export const onUtilityUpdated = onDocumentUpdated(
  "utilities/{utilityId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;
    await dispatch(decideUtility(before, after), after, event.params.utilityId);
  },
);

// ── Maintenance ─────────────────────────────────────────────────────

export const onMaintenanceCreated = onDocumentCreated(
  "maintenance/{requestId}",
  async (event) => {
    const doc = event.data?.data();
    if (!doc) return;
    await dispatch(decideMaintenanceCreated(doc), doc, event.params.requestId);
  },
);

export const onMaintenanceUpdated = onDocumentUpdated(
  "maintenance/{requestId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    if (!before || !after) return;
    await dispatch(
      decideMaintenanceUpdated(before, after),
      after,
      event.params.requestId,
    );
  },
);

// ── Chat ────────────────────────────────────────────────────────────

export const onChatMessageCreated = onDocumentCreated(
  "chatRooms/{roomId}/messages/{messageId}",
  async (event) => {
    const msg = event.data;
    if (!msg) return;

    const senderId = msg.get("senderId");
    if (typeof senderId !== "string") return;

    const room = await msg.ref.parent.parent?.get();
    if (!room?.exists) return;

    const landlordId = room.get("landlordId");
    const tenantUid = await uidForTenantRecord(room.get("tenantId"));

    const recipient = chatRecipient(
      senderId,
      typeof landlordId === "string" ? landlordId : null,
      tenantUid,
    );
    if (!recipient) return;

    await deliver({
      userId: recipient,
      type: "chat_message",
      title: `💬 ${msg.get("senderName") ?? "নতুন বার্তা"}`,
      body: chatPreview(String(msg.get("text") ?? "")),
      targetId: event.params.roomId,
    });
  },
);

// ── Notices ─────────────────────────────────────────────────────────

export const onNoticeCreated = onDocumentCreated(
  "notices/{noticeId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;
    const landlordId = snap.get("landlordId");
    if (typeof landlordId !== "string" || !landlordId) return;

    const uids = await activeTenantUids(landlordId);
    if (uids.length === 0) return;

    logger.info("notice fan-out", {
      noticeId: event.params.noticeId,
      recipients: uids.length,
    });

    await deliverAll(uids, {
      type: "notice",
      title: `📢 ${snap.get("title") ?? "নতুন নোটিশ"}`,
      body: String(snap.get("body") ?? ""),
      targetId: event.params.noticeId,
    });
  },
);
