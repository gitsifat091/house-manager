// Unit tests for the notification decisions.
//
//   cd functions && npm test
//
// These run against the compiled output and need no emulator, because
// decide.ts is pure: document data in, a decision out.

import { test, describe } from "node:test";
import assert from "node:assert/strict";

import {
  chatPreview,
  chatRecipient,
  decideMaintenanceCreated,
  decideMaintenanceUpdated,
  decidePayment,
  decideUtility,
} from "../lib/decide.js";
import { monthName } from "../lib/format.js";

describe("monthName", () => {
  test("maps 1-12", () => {
    assert.equal(monthName(1), "জানুয়ারি");
    assert.equal(monthName(12), "ডিসেম্বর");
  });

  test("rejects anything outside the range", () => {
    for (const bad of [0, 13, -1, 1.5, "3", null, undefined, NaN]) {
      assert.equal(monthName(bad), "", `expected '' for ${String(bad)}`);
    }
  });
});

describe("decidePayment", () => {
  const base = {
    tenantName: "Alice",
    roomNumber: "1A",
    month: 1,
    year: 2026,
    landlordId: "L",
    tenantId: "REC",
  };

  test("submitted notifies the landlord", () => {
    const d = decidePayment({ ...base, status: "pending" }, { ...base, status: "submitted" });
    assert.equal(d.to, "landlord");
    assert.equal(d.type, "payment_submitted");
    assert.match(d.body, /Alice/);
    assert.match(d.body, /1A/);
  });

  test("paid notifies the tenant", () => {
    const d = decidePayment({ ...base, status: "submitted" }, { ...base, status: "paid" });
    assert.equal(d.to, "tenant");
    assert.equal(d.type, "payment_approved");
    assert.match(d.body, /জানুয়ারি 2026/);
  });

  test("rejected carries the reason when there is one", () => {
    const d = decidePayment(
      { ...base, status: "submitted" },
      { ...base, status: "rejected", rejectionReason: "wrong amount" },
    );
    assert.equal(d.to, "tenant");
    assert.match(d.body, /wrong amount/);
  });

  test("rejected without a reason still says something", () => {
    const d = decidePayment({ ...base, status: "submitted" }, { ...base, status: "rejected" });
    assert.ok(d.body.length > 0);
    assert.doesNotMatch(d.body, /undefined/);
  });

  test("no status change means no notification", () => {
    assert.equal(decidePayment({ ...base, status: "paid" }, { ...base, status: "paid" }), null);
  });

  test("a reset back to pending is not worth a notification", () => {
    assert.equal(decidePayment({ ...base, status: "paid" }, { ...base, status: "pending" }), null);
  });

  test("survives missing fields rather than rendering undefined", () => {
    const d = decidePayment({ status: "pending" }, { status: "submitted" });
    assert.doesNotMatch(d.body, /undefined/);
    assert.match(d.body, /ভাড়াটিয়া/); // the fallback name
  });
});

describe("decideUtility", () => {
  const base = { tenantName: "Alice", month: 3, year: 2026 };

  test("submission notifies the landlord", () => {
    const d = decideUtility(
      { ...base, isSubmitted: false, isPaid: false },
      { ...base, isSubmitted: true, isPaid: false },
    );
    assert.equal(d.to, "landlord");
    assert.equal(d.type, "utility_submitted");
  });

  test("payment notifies the tenant", () => {
    const d = decideUtility(
      { ...base, isSubmitted: true, isPaid: false },
      { ...base, isSubmitted: true, isPaid: true },
    );
    assert.equal(d.to, "tenant");
    assert.equal(d.type, "utility_paid");
  });

  test("an unrelated edit notifies nobody", () => {
    assert.equal(
      decideUtility(
        { ...base, isSubmitted: true, isPaid: true },
        { ...base, isSubmitted: true, isPaid: true, amount: 99 },
      ),
      null,
    );
  });

  test("a rejection clearing isSubmitted does not notify", () => {
    assert.equal(
      decideUtility(
        { ...base, isSubmitted: true, isPaid: false },
        { ...base, isSubmitted: false, isPaid: false },
      ),
      null,
    );
  });
});

describe("decideMaintenance", () => {
  test("a new request names the tenant and room", () => {
    const d = decideMaintenanceCreated({
      tenantName: "Alice", roomNumber: "1A", title: "Tap leaking",
    });
    assert.equal(d.to, "landlord");
    assert.match(d.body, /Alice/);
    assert.match(d.body, /Tap leaking/);
  });

  test("a status change tells the tenant", () => {
    const d = decideMaintenanceUpdated(
      { status: "pending", title: "Tap" },
      { status: "done", title: "Tap" },
    );
    assert.equal(d.to, "tenant");
    assert.match(d.body, /সম্পন্ন হয়েছে/);
  });

  test("an edit that leaves the status alone notifies nobody", () => {
    assert.equal(
      decideMaintenanceUpdated(
        { status: "pending", title: "Tap" },
        { status: "pending", title: "Tap in kitchen" },
      ),
      null,
    );
  });

  test("an unrecognised status notifies nobody", () => {
    assert.equal(
      decideMaintenanceUpdated({ status: "pending" }, { status: "wat" }),
      null,
    );
  });
});

describe("chatRecipient", () => {
  test("a landlord message goes to the tenant", () => {
    assert.equal(chatRecipient("L", "L", "T"), "T");
  });

  test("a tenant message goes to the landlord", () => {
    assert.equal(chatRecipient("T", "L", "T"), "L");
  });

  test("nobody is notified when the tenant has not claimed their record", () => {
    assert.equal(chatRecipient("L", "L", null), null);
  });

  test("never notifies the sender", () => {
    assert.equal(chatRecipient("L", "L", "L"), null);
  });

  test("an unknown sender notifies nobody", () => {
    assert.equal(chatRecipient("", "L", "T"), null);
  });
});

describe("chatPreview", () => {
  test("leaves a short message alone", () => {
    assert.equal(chatPreview("hello"), "hello");
  });

  test("truncates a long one to the limit", () => {
    const out = chatPreview("x".repeat(500));
    assert.equal(out.length, 120);
    assert.ok(out.endsWith("..."));
  });

  test("does not truncate at exactly the limit", () => {
    const text = "y".repeat(120);
    assert.equal(chatPreview(text), text);
  });
});
