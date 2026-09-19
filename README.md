# House Manager

A Flutter app for managing rented property, built around two roles.

A **landlord** keeps properties, rooms and tenants; issues monthly rent and
utility bills; approves or rejects the payments tenants submit; posts notices
and house rules; handles maintenance requests; and advertises vacant rooms on
a public to-let board.

A **tenant** sees their own room and rent, submits payments and utility bills
for approval, raises maintenance requests, reads their landlord's notices and
rules, browses the to-let board, and chats with their landlord.

The interface is in Bengali.

## Stack

Flutter 3.41 / Dart 3, with Firebase for everything on the server side:

| | |
|---|---|
| Auth | Firebase Auth, email and password |
| Data | Cloud Firestore |
| Push | Firebase Cloud Messaging, sent by Cloud Functions |
| State | `provider` |
| Charts | `fl_chart` |
| Reports | `pdf` + `printing` |

## Getting started

```bash
flutter pub get
flutter run
```

You need a Firebase project of your own. Replace
`android/app/google-services.json` and regenerate `lib/firebase_options.dart`
with `flutterfire configure`, then deploy the rules and indexes before signing
in — the app cannot read anything without them:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

## How the pieces fit

### Identity

A tenant is two things: a Firebase Auth account, and a record in the `tenants`
collection. They are joined by `tenants.userId`, which holds the Auth uid.

Nothing resolves a tenant by email. Email is mutable, typed by hand by the
landlord, and matched case-sensitively by Firestore, so it cannot carry
identity. `TenantIdentityService` is the single place that answers "which
tenant record is this account?", and every tenant screen goes through it.

Records created before that linkage existed, or created by a landlord for
somebody who has not registered yet, carry no `userId`. They are claimed on
first sign-in: a record whose email matches the caller's **verified** token
email, and which nobody owns yet, gets the uid stamped on it. Knowing an email
address is not enough to take over a tenancy somebody already holds.

### Authorization

Every rule is in [`firestore.rules`](firestore.rules) and tested. Nothing is
enforced in the client — a query filter is not a permission check.

Ownership rests on `landlordId`, stored on every landlord-owned document, and
on `users/{uid}.tenantDocId`, a pointer that exists because security rules
cannot run a query and so cannot discover a caller's tenant record by
themselves.

Profiles are split in two, because rules cannot restrict *which fields* a read
returns: `publicProfiles/{uid}` holds a name and a picture and is readable by
any signed-in user, while `users/{uid}` holds phone, email and FCM tokens and
is readable only by its owner — plus their tenants, who need the contact
details.

[SECURITY.md](SECURITY.md) has the full model and the risks that remain.

### Notifications

Cloud Functions in [`functions/`](functions) watch payments, utilities,
maintenance, chat and notices, write the in-app record, and push to the
recipient's devices. The app cannot send push itself — that needs server
credentials — and clients are denied write access to the `notifications`
collection so nobody can address one to a stranger.

[PUSH_NOTIFICATIONS.md](PUSH_NOTIFICATIONS.md) covers the triggers, the Blaze
plan requirement and the region setting.

### Queries

Every list query is ordered in Firestore and carries a limit. Firestore bills
per document read, so an unbounded stream costs more every month it exists.
Chat loads the newest 50 messages and widens on demand; the other lists are
bounded by a generous ceiling.

The composite indexes those queries need are generated rather than hand-listed
— the to-let search alone has sixteen filter combinations:

```bash
python tool/generate_indexes.py
```

## Layout

```
lib/
  main.dart                  app entry, theme, auth-state routing
  models/                    Firestore document shapes
  services/                  all Firestore and Firebase access
  screens/
    auth/                    sign in, register, password
    landlord/                properties, rooms, tenants, payments,
                             utilities, notices, rules, maintenance,
                             to-let listings, charts, settings
    tenant/                  own room, payments, utilities, notices,
                             rules, maintenance, find-a-home, history
    shared/                  chat, notifications
    community/               per-property group chat
  widgets/                   avatars, empty states
functions/src/               Cloud Functions (TypeScript)
test/rules/                  Firestore rules tests
tool/                        maintenance scripts
```

Screens are meant to reach Firestore through `services/`, but about half of
them still hold inline queries — 19 of 40 at last count. Those are worth
moving into a service as they are touched, both to keep query shapes in one
place and because the rules tests exercise the service layer.

## Tests

```bash
flutter test                              # Dart unit tests
cd test/rules  && npm install && npm test # security rules, against the emulator
cd functions   && npm install && npm test # notification logic
```

The rules tests are the ones that matter most. One suite proves the boundaries
hold — landlords cannot see each other's data, a tenant cannot mark their own
rent paid or promote themselves to landlord. The other runs every query shape
the app actually issues, so a rule that is too strict fails there rather than
in somebody's hands.

They need Java for the Firestore emulator. Gradle rejects Java 25; if
`./gradlew` fails with a bare version number, point `JAVA_HOME` at the JDK
bundled with Android Studio.

## Deploying

```bash
firebase deploy --only firestore:rules,firestore:indexes,storage:rules,functions
flutter build appbundle --release
```

**Rules, indexes, functions and the app go out together.** The rules need query
shapes only the current build uses, and they deny the client writes that the
functions take over. Shipping one without the others breaks something.

Release signing reads `android/key.properties`, which is not in version
control — see [`android/key.properties.example`](android/key.properties.example).
Without it the release build falls back to the debug key and cannot be
published.

## Known gaps

- **The application ID is still `com.example.house_manager`**, which Google
  Play rejects. Changing it needs a Firebase console step first; see
  [android/CHANGING_THE_APP_ID.md](android/CHANGING_THE_APP_ID.md), then
  `python tool/rename_app_id.py <new.id>`.
- **Profile pictures are base64 blobs in Firestore.** `firebase_storage` is
  declared and unused; moving them there would cut the cost of every avatar.
- **Foreground notifications show as an in-app snackbar**, not a system
  notification. That needs `flutter_local_notifications` and a channel.
- **Load-more exists only in chat.** Other lists stop at their limit.
- **No email verification**, and roles are self-selected at registration.
- 579 analyzer lints remain, most of them deprecated `withOpacity` calls.
