#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ANDROID_COMPILE_SDK="${ANDROID_COMPILE_SDK:-35}"
ANDROID_BUILD_TOOLS="${ANDROID_BUILD_TOOLS:-35.0.0}"
ANDROID_SDK_INSTALL_DIR="${ANDROID_SDK_INSTALL_DIR:-$HOME/android-sdk}"
CMDLINE_TOOLS_ZIP_URL="${CMDLINE_TOOLS_ZIP_URL:-https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip}"

use_jdk_17_if_available() {
  if command -v mise >/dev/null 2>&1 && mise where java@17 >/dev/null 2>&1; then
    export JAVA_HOME="$(mise where java@17)"
    export PATH="$JAVA_HOME/bin:$PATH"
  fi
}

require_java() {
  if ! command -v java >/dev/null 2>&1; then
    echo "Java is required. In a GitHub Codespace, install/use JDK 17 before running this script." >&2
    exit 1
  fi

  local java_version
  java_version="$(java -version 2>&1 | sed -n '1s/.*version "\([0-9][0-9]*\).*/\1/p')"
  if [[ "${java_version:-}" != "17" ]]; then
    echo "Warning: Android Gradle builds should use JDK 17; current java -version reports: ${java_version:-unknown}" >&2
  fi
}

sdkmanager_path() {
  if [[ -n "${ANDROID_SDK_ROOT:-}" && -x "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" ]]; then
    printf '%s\n' "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager"
  elif [[ -n "${ANDROID_HOME:-}" && -x "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]]; then
    printf '%s\n' "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager"
  elif [[ -x "$ANDROID_SDK_INSTALL_DIR/cmdline-tools/latest/bin/sdkmanager" ]]; then
    printf '%s\n' "$ANDROID_SDK_INSTALL_DIR/cmdline-tools/latest/bin/sdkmanager"
  else
    return 1
  fi
}

install_android_cmdline_tools() {
  local sdk_dir="$ANDROID_SDK_INSTALL_DIR"
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "${tmp_dir:-}"' RETURN

  echo "Android SDK was not found. Installing command line tools into: $sdk_dir"
  mkdir -p "$sdk_dir/cmdline-tools"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$CMDLINE_TOOLS_ZIP_URL" -o "$tmp_dir/cmdline-tools.zip"
  elif command -v wget >/dev/null 2>&1; then
    wget -q "$CMDLINE_TOOLS_ZIP_URL" -O "$tmp_dir/cmdline-tools.zip"
  else
    echo "curl or wget is required to install the Android SDK command line tools." >&2
    exit 1
  fi

  unzip -q "$tmp_dir/cmdline-tools.zip" -d "$tmp_dir"
  rm -rf "$sdk_dir/cmdline-tools/latest"
  mv "$tmp_dir/cmdline-tools" "$sdk_dir/cmdline-tools/latest"
  rm -rf "$tmp_dir"
  trap - RETURN
}

ensure_android_sdk() {
  local sdkmanager
  if ! sdkmanager="$(sdkmanager_path)"; then
    install_android_cmdline_tools
    sdkmanager="$(sdkmanager_path)"
  fi

  local sdk_dir
  sdk_dir="$(cd "$(dirname "$sdkmanager")/../../.." && pwd)"
  export ANDROID_SDK_ROOT="$sdk_dir"
  export ANDROID_HOME="$sdk_dir"
  export PATH="$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"

  echo "Installing/verifying Android SDK packages..."
  yes | "$sdkmanager" --licenses >/dev/null || true
  "$sdkmanager" \
    "platform-tools" \
    "platforms;android-$ANDROID_COMPILE_SDK" \
    "build-tools;$ANDROID_BUILD_TOOLS"

  printf 'sdk.dir=%s\n' "$ANDROID_SDK_ROOT" > local.properties
}

use_jdk_17_if_available
require_java
ensure_android_sdk
chmod +x ./gradlew

./gradlew :app:assembleDebug

echo "Debug APK created at: $ROOT_DIR/app/build/outputs/apk/debug/app-debug.apk"
