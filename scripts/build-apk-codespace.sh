#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if command -v mise >/dev/null 2>&1 && mise where java@17 >/dev/null 2>&1; then
  export JAVA_HOME="$(mise where java@17)"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

if ! command -v java >/dev/null 2>&1; then
  echo "Java is required. In a GitHub Codespace, install/use JDK 17 before running this script." >&2
  exit 1
fi

java_version="$(java -version 2>&1 | sed -n '1s/.*version "\([0-9][0-9]*\).*/\1/p')"
if [[ "${java_version:-}" != "17" ]]; then
  echo "Warning: Android Gradle builds should use JDK 17; current java -version reports: ${java_version:-unknown}" >&2
fi

if [[ -z "${ANDROID_SDK_ROOT:-}" && -z "${ANDROID_HOME:-}" ]]; then
  echo "ANDROID_SDK_ROOT or ANDROID_HOME must point to an installed Android SDK." >&2
  echo "In GitHub Codespaces, use an Android/devcontainer image or install cmdline-tools first." >&2
  exit 1
fi

sdk_dir="${ANDROID_SDK_ROOT:-$ANDROID_HOME}"
printf 'sdk.dir=%s\n' "$sdk_dir" > local.properties
chmod +x ./gradlew

./gradlew :app:assembleDebug

echo "Debug APK created at: $ROOT_DIR/app/build/outputs/apk/debug/app-debug.apk"
