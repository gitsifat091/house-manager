# Push notifications

Notifications are produced by Cloud Functions in [`functions/`](functions),
not by the app. The app registers device tokens and displays what arrives.

## Why the app does not send them

It cannot. Sending through FCM needs server credentials, which a phone app has
no business holding. Before this existed the app collected tokens and never
used them, so nothing was ever pushed to anybody.

Letting clients write the `notifications` collection had a second problem:
anyone signed in could create one addressed to anyone. That was cosmetic while
the records only appeared in an in-app list. It stops being cosmetic the
moment those records produce a push. Rules now deny client creates entirely.

## What was broken

Four separate things, each enough on its own:

1. **No `POST_NOTIFICATIONS` permission.** On Android 13+ the permission could
   not be granted, so `requestPermission()` returned denied — and because the
   token save sat inside `if (authorizationStatus == authorized)`, the token
   was never even stored.
2. **The background handler was registered from inside a widget `build()`.**
   It re-registered on every rebuild and leaked a token-refresh listener and a
   foreground listener each time. It must run once, before `runApp`.
3. **The background handler never called `Firebase.initializeApp()`.** It runs
   in its own isolate and would have thrown the moment it touched Firebase.
4. **Nothing sent anything.** No functions, no server.

And one that made tenant notifications invisible even in-app: `notifyTenant`
was passed `payment.tenantId`, a tenant *document* id, while the notification
list queries by Auth uid. Those records were addressed to an id nothing ever
queried. `uidForTenantRecord` in `functions/src/notify.ts` resolves it properly.

## What triggers a notification

| Event | Goes to |
|---|---|
| Payment status → `submitted` | Landlord |
| Payment status → `paid` | Tenant |
| Payment status → `rejected` | Tenant, with the reason |
| Utility bill submitted | Landlord |
| Utility bill marked paid | Tenant |
| Maintenance request created | Landlord |
| Maintenance status changed | Tenant |
| Chat message sent | The other participant |
| Notice created | Every active tenant of that landlord |

The decisions — which transitions notify, who they reach, what they say — live
in [`functions/src/decide.ts`](functions/src/decide.ts), which is pure and unit
tested. The triggers in `index.ts` only resolve recipients and write.

## Current state

**Not deployed.** The project is on the Spark plan, which cannot run Cloud
Functions, so nothing below is live yet.

Until it is, the app writes notification records itself — see the `INTERIM`
blocks in `firestore.rules`, `NotificationService` and `PaymentService`. That
fills the in-app notification list but sends no push, because sending through
FCM needs server credentials the app does not have.

Deploying the functions is what replaces that. At the same time, set
`allow create` on `notifications` back to `if false` and delete the two
interim blocks in the Dart.

## Deploying

**Cloud Functions require the Blaze plan.** The free Spark plan cannot deploy
functions at all. Blaze is pay-as-you-go with a free tier that a project this
size will sit inside comfortably, but it does require a billing account, and
that is a decision only you can make.

**Set the region first.** `REGION` at the top of `functions/src/index.ts` must
match your Firestore database location or the deploy fails. Check it at
Firebase console → Firestore Database. A multi-region `nam5` maps to
`us-central1`, `eur3` to `europe-west1`; single-region locations are used
as-is. It currently says `us-central1`, the default a project gets when nobody
picks.

```bash
cd functions && npm install
cd .. && firebase deploy --only functions,firestore:rules
```

Deploy the rules at the same time: the rules change that denies client writes
to `notifications` and the functions that take over those writes belong
together. Deploying one without the other either drops notifications on the
floor or leaves the spam vector open.

## Tests

```bash
cd functions && npm test      # 25 unit tests, no emulator needed
cd test/rules && npm test     # includes the notification and token rules
```

The unit tests cover the transitions, the fallbacks when fields are missing
(so a notification never renders `undefined` at somebody), truncation of long
chat messages, and that a message never notifies its own sender.

## Checking it works

1. Sign in on a real device — an emulator without Play Services will not get a
   token. Accept the notification prompt.
2. Confirm `users/{uid}.fcmTokens` has an entry.
3. Have a tenant submit a payment. The landlord should get a push.
4. If nothing arrives, `firebase functions:log` shows whether the trigger ran
   and what it found. A `no recipient` line means the tenant has not claimed
   their record yet, so there is no account to notify.

## Known limits

**Foreground messages show as an in-app snackbar, not a system notification.**
Android does not draw a notification for a message that arrives while the app
is open; that needs `flutter_local_notifications` and a notification channel.
The snackbar covers it for now. Background and terminated delivery — the cases
that actually matter — are handled by the system.

**No custom notification channel.** Naming one requires the channel to exist
on the device, which needs platform code. Leaving it unset lets the Firebase
SDK use the channel it creates itself, which works on Android 8+. Adding
`flutter_local_notifications` would address this and the point above together.

**Notification taps do not route anywhere yet.** Each notification carries a
`type` and a `targetId` in its data payload, so the wiring is there for
`getInitialMessage` and `onMessageOpenedApp` to open the right screen. Nothing
consumes them yet.

**The notice fan-out is sequential.** A landlord with a very large number of
tenants would be better served by FCM topics than by a loop over tokens.
