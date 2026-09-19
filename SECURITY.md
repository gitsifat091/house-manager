# Security rules

Authorization for House Manager lives in [`firestore.rules`](firestore.rules)
and [`storage.rules`](storage.rules). Before these existed the database had no
rules in version control, so every access check happened in the client — which
means it was not a check at all. Any signed-in user could read every tenant
record, including NID numbers, phone numbers, rent amounts and private chats.

## Running the tests

```bash
cd test/rules && npm install && npm test
```

This starts the Firestore emulator and runs 152 tests against the real rules
file. No project credentials are needed and no live data is touched.

There are two suites:

- `firestore.test.js` — the boundaries. Landlords cannot see each other's
  data, tenants cannot see each other's, a tenant cannot mark their own rent
  paid or promote themselves to landlord, and so on.
- `app-queries.test.js` — every query shape the app actually issues. A rule
  that is too strict fails here instead of in somebody's hands.

Change a rule, run the tests. They caught two real bugs already (see
*Queries that had to change* below).

## Deploying

```bash
firebase deploy --only firestore:rules,storage:rules,functions
```

Cloud Functions produce every notification now, and the rules deny clients
writing that collection, so the two go out together — see
[PUSH_NOTIFICATIONS.md](PUSH_NOTIFICATIONS.md). Functions need the Blaze plan.

**Ship the app update at the same time.** These rules require query shapes the
older build does not use, so an old client will hit permission errors against
the new rules. Rules and app go out together.

If your project has never had Cloud Storage provisioned, `firebase deploy`
will complain about the storage target. Either enable Storage in the console
or drop the `"storage"` block from `firebase.json` — the app does not use
Storage today, so `storage.rules` simply denies everything.

## The model

Two anchors carry the authorization:

- **`landlordId`** is stored on every landlord-owned document: properties,
  tenants, payments, utilities, maintenance, notices, house rules, listings
  and rental requests. Owning a document means `landlordId == request.auth.uid`.
- **`users/{uid}.tenantDocId`** points at the caller's tenant record. Security
  rules cannot run a query, so they cannot discover "which tenant record is
  this person?" on their own. `TenantIdentityService` keeps this pointer
  current. `ownsTenantRecord` falls back to reading the tenant record directly
  if the pointer is stale or missing, so a stale pointer costs an extra
  document read rather than locking somebody out.

## Profiles are split in two

Firestore rules cannot restrict *which fields* a read returns, so a collection
readable by everyone can only hold what everyone may see.

- **`publicProfiles/{uid}`** — `{name, photoUrl}`, readable by any signed-in
  user. The field list is enforced on write, so it cannot quietly grow into a
  second copy of the user record.
- **`users/{uid}`** — phone, email, `fcmToken`, role. Readable only by its
  owner, plus one exception: a tenant may read their own landlord's record,
  because the app shows landlord contact details. `myLandlordId()` resolves
  that through the tenant record, so it cannot be pointed at anyone else.

There is no `list` rule on `users` at all. Nothing queries the collection any
more, and allowing queries would let one be shaped to enumerate the rest.

Existing accounts get a public profile written the first time they sign in, so
no migration runs over the user collection. Until then an avatar falls back to
initials, which is what those call sites already did.

`rooms` is the one collection with no `landlordId`; ownership resolves through
its parent property.

## The claim path

Tenant records created before the account linkage existed — or created by a
landlord for somebody who has not registered yet — have no `userId`. They are
claimed on first sign-in.

The rule allows a caller to read and claim a tenant record only when **all** of
these hold:

1. the record has no owner yet (`userId` is empty), and
2. its email matches `request.auth.token.email` — the address Firebase Auth
   verified, not one supplied by the client, and
3. the write sets `userId` to the caller's own uid and changes nothing else.

So knowing an email address is not enough to take over a tenancy that somebody
already holds, and a claim cannot be used to smuggle in a rent change. Legacy
records that predate the `emailLower` field are matched case-insensitively on
`email`.

## Queries that had to change

Firestore authorizes a query by what it can prove about the result set, so a
query with no ownership filter is denied even when every document it would
return happens to belong to the caller. Two places needed fixing:

- `ListingService.acceptRequest` swept competing requests with
  `where('roomId').where('status')` and no owner. Now filtered by `landlordId`.
- `landlord_edit_tenant_screen` looked up rooms by `tenantId` alone. Now also
  filtered by `propertyId`.

A third, in `payment_list_screen`, matched tenants on name + room number with
no owner at all. That is now a direct read by `payment.tenantId`, which also
fixes picking the wrong tenant when two share a name.

## Residual risks

These are real and deliberate. They are the next things to fix.

**Clients can create a notification addressed to any uid.** This is meant to
be closed — Cloud Functions write every notification and the rule denies
client creates — but the functions are not deployed, because the project is
on the Spark plan and Cloud Functions need Blaze. Until they are, the app
writes these records itself, which means any signed-in user can put a
notification in somebody else's list. The shape is validated and reads stay
restricted to the addressee, so it cannot carry arbitrary data, but it is a
spam vector.

Everything involved is marked `INTERIM`: the rule in `firestore.rules`, the
block in `NotificationService`, and the call sites in `PaymentService`. Once
`firebase deploy --only functions` succeeds, set `allow create` back to
`if false` and delete the other two.

**Profile pictures are base64 blobs, now inside the public profile.** At
300x300 and quality 50 that is tens of kilobytes of base64 pulled on every
avatar read, and it is readable by every signed-in user. Moving these to Cloud
Storage — the `firebase_storage` dependency is already declared and unused —
would fix the cost and let the picture be served by URL instead.

**Email is still trusted for the initial claim.** Scoped as tightly as it can
be (unowned records only, verified token email only), but it is the one place
an email address grants anything. It disappears once existing records have all
been claimed; the claim block can then be deleted outright.
