# Afterglow

A private, offline Android companion app for people with Post-Orgasmic Illness
Syndrome (POIS). Spec: `../POIS_App_PRD.md` (v1.2); summary and decisions in
`../POIS_App_Context.md`.

**Hard rules:** no INTERNET permission, no backend, no analytics/crash SDKs,
stock Material 3 UI following the reference apps, fast on low-end phones.

## Setup

- Flutter stable (installed at `C:\Users\pranj\flutter`; add `flutter\bin` to PATH)
- Android SDK at `%LOCALAPPDATA%\Android\Sdk`, JDK from Android Studio (`jbr`)

```sh
flutter pub get
dart run build_runner build      # Drift codegen (database.g.dart)
flutter test
flutter run                      # debug on a device/emulator
flutter build apk --release
bash tool/check_no_internet.sh   # fails if the release APK requests network access
```

## Architecture

| Layer | Choice |
|---|---|
| State | Riverpod (Drift streams → providers → widgets) |
| DB | Drift on a background isolate, encrypted with SQLite3MultipleCiphers (`hooks.user_defines.sqlite3.source: sqlite3mc` in pubspec). Random 256-bit key in Android Keystore via `flutter_secure_storage`, `kdf_iter=1` so opening skips key stretching. |
| Navigation | `go_router` `StatefulShellRoute` + Material 3 `NavigationBar` (Today · Calendar · Insights · Learn) |
| Notifications | `flutter_local_notifications`, inexact alarms, `VISIBILITY_PRIVATE`, generic user-editable text |
| Lock / privacy | `local_auth` (device PIN/biometric), `FLAG_SECURE` toggle via `afterglow/window` channel in `MainActivity.kt`, Auto Backup and device transfer disabled |

```
lib/
  core/        domain enums (EpisodeType, SymptomCluster, Severity, Feeling), theme
  data/        Drift schema, EpisodeRepository (all writes + precomputed aggregates), settings, providers
  features/    today, log (bottom sheet), checkin (Fog Mode), calendar, insights, learn, settings, lock, shell
  notifications/  check-in scheduling (+1h, +6h, +24h, then daily to day 7)
```

**Write path:** every episode/check-in write goes through `EpisodeRepository`,
which updates `Episode.peakSeverity` / `checkInCount` and rebuilds the
`DailySummaries` rows for the affected days in the same transaction. The
calendar, ring and 30-day card read only those small rows.

## Notes

- `package:sqlcipher_flutter_libs` is end-of-life; don't add it back. Encryption
  comes from the sqlite3mc build hook and is checked at runtime (`PRAGMA cipher`)
  and in `test/encryption_test.dart`.
- `dynamic_color` was dropped because it depends on the decoupled
  `material_ui` package, which conflicts with `package:flutter/material.dart`.
  The wallpaper accent is read through the window channel instead.
- Application ID `com.afterglowjournal.afterglow` is a placeholder. Change it
  before the first Play upload, because it can't be changed afterwards.
