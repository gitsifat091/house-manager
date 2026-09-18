#!/usr/bin/env python3
"""Change the Android application ID and iOS bundle identifier.

    python tool/rename_app_id.py io.github.gitsifat091.housemanager

Run this only AFTER registering the new package name in the Firebase console
and replacing android/app/google-services.json. The Google Services Gradle
plugin fails the build when applicationId does not match a client in that
file, so this script refuses to run until it does. See
android/CHANGING_THE_APP_ID.md for the full sequence.

The application ID is permanent once an app is published: Google Play treats a
different ID as a different app. Nothing here is reversible for a listing that
already exists.
"""
import io
import json
import os
import re
import shutil
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

GRADLE = 'android/app/build.gradle.kts'
GOOGLE_SERVICES = 'android/app/google-services.json'
PBXPROJ = 'ios/Runner.xcodeproj/project.pbxproj'
KOTLIN_ROOT = 'android/app/src/main/kotlin'

VALID = re.compile(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$')


def fail(msg):
    print('error: ' + msg)
    sys.exit(1)


def read(rel):
    with io.open(os.path.join(ROOT, rel), encoding='utf-8', newline='') as f:
        return f.read()


def write(rel, text):
    with io.open(os.path.join(ROOT, rel), 'w', encoding='utf-8', newline='') as f:
        f.write(text)


def current_application_id(gradle_text):
    m = re.search(r'applicationId\s*=\s*"([^"]+)"', gradle_text)
    if not m:
        fail('could not find applicationId in ' + GRADLE)
    return m.group(1)


def check_google_services(new_id):
    path = os.path.join(ROOT, GOOGLE_SERVICES)
    if not os.path.exists(path):
        fail(GOOGLE_SERVICES + ' is missing')
    with io.open(path, encoding='utf-8') as f:
        data = json.load(f)
    packages = [
        c.get('client_info', {}).get('android_client_info', {}).get('package_name')
        for c in data.get('client', [])
    ]
    if new_id not in packages:
        fail(
            'google-services.json does not list "%s".\n'
            '       It currently has: %s\n'
            '       Add the app in the Firebase console and download a fresh\n'
            '       google-services.json first. See android/CHANGING_THE_APP_ID.md'
            % (new_id, ', '.join(p for p in packages if p) or '(none)')
        )


def move_main_activity(old_id, new_id):
    old_dir = os.path.join(ROOT, KOTLIN_ROOT, *old_id.split('.'))
    new_dir = os.path.join(ROOT, KOTLIN_ROOT, *new_id.split('.'))
    src = os.path.join(old_dir, 'MainActivity.kt')
    if not os.path.exists(src):
        print('  ! MainActivity.kt not found at %s, skipping move' % old_dir)
        return
    os.makedirs(new_dir, exist_ok=True)
    with io.open(src, encoding='utf-8', newline='') as f:
        text = f.read()
    text = text.replace('package ' + old_id, 'package ' + new_id)
    dst = os.path.join(new_dir, 'MainActivity.kt')
    with io.open(dst, 'w', encoding='utf-8', newline='') as f:
        f.write(text)
    os.remove(src)
    # prune now-empty directories left behind by the old package
    d = old_dir
    kotlin_root = os.path.join(ROOT, KOTLIN_ROOT)
    while os.path.normpath(d) != os.path.normpath(kotlin_root) and os.path.isdir(d):
        if os.listdir(d):
            break
        os.rmdir(d)
        d = os.path.dirname(d)
    print('  moved MainActivity.kt -> %s' % os.path.relpath(dst, ROOT))


def main():
    if len(sys.argv) != 2:
        print(__doc__)
        sys.exit(2)
    new_id = sys.argv[1].strip()

    if not VALID.match(new_id):
        fail('"%s" is not a valid package name (lowercase segments separated '
             'by dots, e.g. io.github.you.appname)' % new_id)
    if new_id.startswith('com.example.'):
        fail('Google Play rejects com.example.* — that is the ID you are '
             'trying to get away from')

    gradle = read(GRADLE)
    old_id = current_application_id(gradle)
    if old_id == new_id:
        print('applicationId is already %s, nothing to do' % new_id)
        return

    check_google_services(new_id)

    print('%s  ->  %s' % (old_id, new_id))

    # Android: applicationId and namespace
    gradle = gradle.replace('applicationId = "%s"' % old_id,
                            'applicationId = "%s"' % new_id)
    gradle = re.sub(r'namespace\s*=\s*"[^"]+"',
                    'namespace = "%s"' % new_id, gradle, count=1)
    # the TODO no longer applies
    gradle = gradle.replace(
        '        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).\n', '')
    write(GRADLE, gradle)
    print('  updated %s (applicationId + namespace)' % GRADLE)

    move_main_activity(old_id, new_id)

    # iOS: PRODUCT_BUNDLE_IDENTIFIER, including the RunnerTests variants
    pbx_path = os.path.join(ROOT, PBXPROJ)
    if os.path.exists(pbx_path):
        pbx = read(PBXPROJ)
        shutil.copyfile(pbx_path, pbx_path + '.bak')
        # camelCase form Flutter generates for iOS, plus any exact old id
        ios_old = re.findall(r'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);', pbx)
        base = sorted({v.replace('.RunnerTests', '') for v in ios_old})
        for b in base:
            pbx = pbx.replace('PRODUCT_BUNDLE_IDENTIFIER = %s.RunnerTests;' % b,
                              'PRODUCT_BUNDLE_IDENTIFIER = %s.RunnerTests;' % new_id)
            pbx = pbx.replace('PRODUCT_BUNDLE_IDENTIFIER = %s;' % b,
                              'PRODUCT_BUNDLE_IDENTIFIER = %s;' % new_id)
        write(PBXPROJ, pbx)
        print('  updated %s (bundle identifiers; .bak kept)' % PBXPROJ)

    print('')
    print('Done. Now run:')
    print('  flutter clean && flutter build apk --debug')
    print('')
    print('Then sign in on a device and confirm Firestore reads still work.')
    print('A mismatched google-services.json usually shows up as auth working')
    print('and every Firestore call failing.')


if __name__ == '__main__':
    main()
