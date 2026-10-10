#!/usr/bin/env bash
# Fails if the release APK requests any network permission (PRD §10.8).
# Usage: tool/check_no_internet.sh [path/to/app-release.apk]
set -euo pipefail

APK="${1:-build/app/outputs/flutter-apk/app-release.apk}"
SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/AppData/Local/Android/Sdk}}"
AAPT2="$(ls -d "$SDK"/build-tools/*/ | sort -V | tail -1)aapt2"
[[ -x "$AAPT2" || -x "$AAPT2.exe" ]] || { echo "aapt2 not found under $SDK"; exit 2; }
[[ -f "$APK" ]] || { echo "APK not found: $APK (run: flutter build apk --release)"; exit 2; }

PERMS="$("$AAPT2" dump permissions "$APK")"
echo "$PERMS"

BANNED='android.permission.(INTERNET|ACCESS_NETWORK_STATE|ACCESS_WIFI_STATE|CHANGE_NETWORK_STATE)'
if grep -Eq "$BANNED" <<<"$PERMS"; then
  echo
  echo "FAIL: release APK requests a network permission:"
  grep -E "$BANNED" <<<"$PERMS"
  exit 1
fi
echo
echo "OK: no network permissions in $APK"
