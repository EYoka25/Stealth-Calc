# Stealth-Calc

Android calculator app with hidden stealth chat features.

## Build the APK in a GitHub Codespace

This project builds with Gradle and the Android Gradle Plugin. Use JDK 17 for Android builds.

### Quick build

From the repository root, run:

```bash
./scripts/build-apk-codespace.sh
```

The debug APK is written to:

```text
app/build/outputs/apk/debug/app-debug.apk
```

### Manual build steps

If you prefer to run the commands yourself:

```bash
# If your Codespace uses mise and has JDK 17 installed:
export JAVA_HOME="$(mise where java@17)"
export PATH="$JAVA_HOME/bin:$PATH"

# Point Gradle at the Android SDK installed in the Codespace:
echo "sdk.dir=$ANDROID_SDK_ROOT" > local.properties

chmod +x ./gradlew
./gradlew :app:assembleDebug
```

Use `:app:assembleDebug` when you only need the Android APK. It avoids building unrelated modules.

### Downloading the APK from Codespaces

After the build completes, right-click `app/build/outputs/apk/debug/app-debug.apk` in the VS Code file explorer and choose **Download**.

### Troubleshooting

- If Gradle fails immediately with a Java version error, switch to JDK 17 and rerun the build.
- If `ANDROID_SDK_ROOT` is empty, install the Android SDK in the Codespace or rebuild the Codespace with an Android-enabled dev container.
- If dependency downloads fail, make sure the Codespace has internet access to Google Maven, Maven Central, Gradle Plugin Portal, and JitPack.
