# Stealth-Calc

Android calculator app with hidden stealth chat features.

## Build the APK in a GitHub Codespace

This project builds with Gradle and the Android Gradle Plugin. Use JDK 17 for Android builds.

### Quick build

From the repository root, first make sure your Codespace has the latest repository contents, then run the helper:

```bash
git pull
./scripts/build-apk-codespace.sh
```

If the Android SDK is missing, the helper installs the Android command line tools into `$HOME/android-sdk`, installs the required SDK packages, writes `local.properties`, and then builds the APK.

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
- If `./scripts/build-apk-codespace.sh` is missing, run `git pull` and confirm you are on the branch that contains this README update.
- If `ANDROID_SDK_ROOT` is empty, run `./scripts/build-apk-codespace.sh`; it can install the Android SDK command line tools into `$HOME/android-sdk` and write `local.properties` for you.
- If dependency downloads fail, make sure the Codespace has internet access to Google Maven, Maven Central, Gradle Plugin Portal, and JitPack.
