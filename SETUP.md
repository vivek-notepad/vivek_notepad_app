# Setup on a new laptop

Use this checklist when continuing work on **Simple Notepad** from another machine.

## Prerequisites

Install these before opening the project:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK ^3.8)
- [Android Studio](https://developer.android.com/studio) with:
  - Android SDK (compileSdk 35)
  - Android SDK Build-Tools
  - An emulator or a physical device with USB debugging
- Git

Verify Flutter:

```bash
flutter doctor
```

Fix anything marked as a blocker before building.

## Get the code

```bash
git clone https://github.com/vivek-notepad/vivek_notepad_app.git
cd vivek_notepad_app
flutter pub get
```

Run on a connected device or emulator:

```bash
flutter run
```

Gradle and Flutter will recreate ignored folders such as `build/`, `.dart_tool/`, and `android/.gradle/`. That is expected.

## Machine-specific files (not in Git)

| File | Purpose |
|------|---------|
| `android/local.properties` | Points Gradle to your Flutter SDK. Created automatically when you build, or by Flutter/Android Studio. |
| `android/key.properties` | Release signing passwords and keystore path. **Copy manually** from your old laptop. |
| `*.jks` / `*.keystore` | Release signing key. **Copy manually** and keep private. |

Do **not** commit `key.properties` or keystore files. They are already in `.gitignore`.

## Release builds (Play Store)

Debug builds work without a keystore. For a release APK/AAB:

1. Copy your keystore file to a safe local path on the new laptop.
2. Create `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=YOUR_KEY_ALIAS
storeFile=C:/path/to/your/upload-keystore.jks
```

3. Build:

```bash
flutter build appbundle
```

Use the **same keystore** as previous Play Store uploads. Google Play rejects updates signed with a different key.

Current Android version (in `android/app/build.gradle.kts`): `versionName` **1.7**, `versionCode` **8**.

## Firebase

Firebase config is already in the repo: `android/app/google-services.json`.

- **Project:** `notepad-app-a61e0`
- **Package:** `com.viveksingh.notepad_app`

You need access to the [Firebase Console](https://console.firebase.google.com/) with the same Google account used for this project.

Cloud data (notes, settings) lives in Firebase, not in Git. A fresh install on a new emulator/device creates a new anonymous user, so notes may look empty until you test with the same install or account flow you use in production.

**Update notifications:** Firestore document `app_settings/production` and FCM topic `app_updates` are managed in Firebase Console, not in this repo.

## Before leaving your current laptop

```bash
git status
git push origin main
```

Push any unpushed commits so the other laptop gets the latest code.

## Version numbers

Keep these aligned when preparing a release:

- `android/app/build.gradle.kts` — `versionCode` and `versionName` (used for Play Store)
- `pubspec.yaml` — `version:` (used by Flutter tooling)

## Common issues

**`flutter.sdk not set in local.properties`**

Run `flutter pub get` or open the project in Android Studio and sync Gradle. Flutter should write the SDK path.

**Build fails after clone**

```bash
flutter clean
flutter pub get
flutter run
```

**Release build fails on signing**

`key.properties` or the keystore file is missing on the new laptop. Copy both from the machine used for previous Play Store uploads.

**Firebase / Google Play errors**

Confirm package name is `com.viveksingh.notepad_app` and `google-services.json` matches the Firebase Android app.
