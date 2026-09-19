# Changing the application ID

The app still ships as `com.example.house_manager`. Google Play **rejects**
any package beginning `com.example.`, so this must change before the first
release. It cannot change after that release: the application ID is the
permanent identity of a Play Store listing, and a new one is a new app that
existing users would have to install by hand.

Nothing in this repo applies the change yet, because it would break the build
until the Firebase side is done first. The order below matters.

## The chosen ID

```
io.github.gitsifat091.housemanager
```

Reverse-DNS package names assume you control the domain. `com.housemanager.*`
would imply owning `housemanager.com` and could collide with another
developer's app. `io.github.<username>` is the established convention for
publishing without a domain of your own — it maps to a namespace GitHub
already guarantees is uniquely yours. Nobody sees this string; it does not
appear anywhere in the UI.

If you would rather use a domain you own, substitute it reversed
(`housemanager.example.com` becomes `com.example.housemanager`) and pass it to
the script below.

## Step 1 — Firebase, before touching any code

The Google Services Gradle plugin verifies that `applicationId` matches a
client listed in `android/app/google-services.json` and **fails the build** if
it does not. So Firebase has to know the new name first.

1. Firebase console -> your project -> Project settings -> General
2. *Your apps* -> **Add app** -> Android
3. Android package name: `io.github.gitsifat091.housemanager`
4. Register, then **Download google-services.json**
5. Replace `android/app/google-services.json` with the downloaded file
6. While you are there, add the iOS app with the same bundle ID if you plan to
   ship on iOS, and replace `ios/Runner/GoogleService-Info.plist`

Do not delete the old `com.example.house_manager` app in Firebase yet. Any
build already installed on a phone still reports as that package. Remove it
once nothing runs the old ID.

## Step 2 — apply the change

```bash
python tool/rename_app_id.py io.github.gitsifat091.housemanager
```

The script rewrites:

- `android/app/build.gradle.kts` — `applicationId` and `namespace`
- `android/app/src/main/kotlin/**/MainActivity.kt` — the `package` declaration,
  and moves the file into the matching directory
- `ios/Runner.xcodeproj/project.pbxproj` — `PRODUCT_BUNDLE_IDENTIFIER`,
  including the `RunnerTests` variants

It refuses to run if `google-services.json` does not already list the new
package, so you cannot do this in the wrong order.

## Step 3 — verify

```bash
flutter clean
flutter build apk --debug
```

Then sign in on a device and confirm Firestore reads work. A mismatched
`google-services.json` typically shows up as auth succeeding and every
Firestore call failing.

## Note on Firestore data

The application ID has nothing to do with your Firestore data — documents are
keyed by Firebase Auth uid, which does not change. Existing accounts and
tenancies are unaffected.
