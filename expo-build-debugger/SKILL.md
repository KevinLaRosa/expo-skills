---
name: expo-build-debugger
description: Build, run, and debug Expo apps on simulators and devices using EAS Build with optimized workflows for development, preview, and production
---

# Expo Build & Debugger

## Overview

Streamline building and debugging Expo apps with EAS Build profiles, simulator workflows, and performance profiling tools for iOS and Android.

## When to Use This Skill

- Setting up EAS Build for the first time
- Need to test on iOS/Android simulators efficiently
- Debugging native modules or platform-specific issues
- Creating development, preview, and production builds
- Profiling app performance with Xcode Instruments or Android Studio Profiler
- Troubleshooting build failures or runtime crashes

## Workflow

### Step 1: Install EAS CLI

```bash
# Install EAS CLI globally
npm install -g eas-cli

# Login to Expo account
eas login

# Initialize EAS in your project
eas build:configure
```

### Step 2: Configure Build Profiles

Edit `eas.json`:

```json
{
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "ios": {
        "simulator": true,
        "buildConfiguration": "Debug"
      },
      "android": {
        "buildType": "apk",
        "gradleCommand": ":app:assembleDebug"
      }
    },
    "preview": {
      "distribution": "internal",
      "ios": {
        "simulator": false,
        "buildConfiguration": "Release"
      },
      "android": {
        "buildType": "apk"
      }
    },
    "production": {
      "ios": {
        "buildConfiguration": "Release"
      },
      "android": {
        "buildType": "aab"
      }
    }
  },
  "submit": {
    "production": {
      "ios": {
        "appleId": "your.apple.id@example.com",
        "ascAppId": "1234567890",
        "appleTeamId": "ABCDE12345"
      },
      "android": {
        "serviceAccountKeyPath": "./google-service-account.json",
        "track": "internal"
      }
    }
  }
}
```

### Step 3: Build for Simulator

```bash
# iOS Simulator
eas build --profile development --platform ios

# Android Emulator
eas build --profile development --platform android

# Or use the provided script
./expo-build-debugger/scripts/build.sh development ios
```

### Step 4: Install and Run

```bash
# Download the build artifact
eas build:list

# iOS: Install on simulator
xcrun simctl install booted ~/Downloads/build.app

# Or use the script
./expo-build-debugger/scripts/run-simulator.sh ios

# Android: Install APK
adb install ~/Downloads/build.apk

# Or use the script
./expo-build-debugger/scripts/run-simulator.sh android
```

### Step 5: Debug with Tools

**React Native Debugger:**
```bash
# Install React Native Debugger
brew install --cask react-native-debugger

# Start debugger
open "rndebugger://set-debugger-loc?host=localhost&port=8081"

# In app, shake device → "Debug"
```

**Flipper:**
```bash
# Install Flipper
brew install --cask flipper

# Flipper auto-detects running apps
# View: Network, Logs, Layout, Database, etc.
```

**Chrome DevTools:**
```bash
# In app, shake device → "Debug with Chrome"
# Opens Chrome DevTools automatically
```

### Step 6: Profile Performance

**iOS with Xcode Instruments:**
```bash
# Open Xcode
xed ios/

# Run app: Product → Profile (⌘+I)

# Choose instrument:
# - Time Profiler (CPU usage)
# - Allocations (Memory usage)
# - Leaks (Memory leaks)
# - Network (HTTP requests)
```

**Android with Android Studio Profiler:**
```bash
# Open Android Studio
studio android/

# Run app, then open Profiler (View → Tool Windows → Profiler)

# View:
# - CPU usage
# - Memory allocations
# - Network activity
# - Energy consumption
```

### Step 7: Health Check

```bash
# Run health check script
./expo-build-debugger/scripts/check-build-health.sh

# Checks:
# ✓ EAS CLI version
# ✓ eas.json configuration
# ✓ Expo SDK compatibility
# ✓ Native dependencies
# ✓ Simulator/emulator availability
```

## Guidelines

**Do:**
- Use development builds with `expo-dev-client` for faster iteration
- Profile on physical devices for accurate performance metrics
- Keep separate profiles for dev/preview/production
- Use internal distribution for preview builds (TestFlight, Play Internal Testing)
- Check build logs when builds fail

**Don't:**
- Don't use development builds in production
- Don't skip profiling on low-end devices
- Don't ignore native module warnings in build logs
- Don't commit sensitive credentials to git (use environment variables)
- Don't build production without testing preview first

## Examples

### Development Build Workflow

```bash
# 1. Build for simulator
eas build --profile development --platform ios --local

# 2. Install on simulator
./scripts/run-simulator.sh ios

# 3. Start dev server
npx expo start --dev-client

# 4. App automatically connects to dev server
# 5. Make changes → Fast Refresh updates instantly
```

### Preview Build for Testing

```bash
# Build preview for TestFlight
eas build --profile preview --platform ios

# Submit to TestFlight
eas submit --platform ios --latest

# Testers receive build in ~30 minutes
```

### Production Build with Debugging Symbols

```json
// eas.json - production with source maps
{
  "build": {
    "production": {
      "env": {
        "SENTRY_ORG": "your-org",
        "SENTRY_PROJECT": "your-project"
      },
      "ios": {
        "buildConfiguration": "Release"
      },
      "android": {
        "buildType": "aab"
      }
    }
  }
}
```

```bash
# Build with Sentry source maps
eas build --profile production --platform all

# Source maps auto-uploaded to Sentry
```

### Debugging Native Crash

```bash
# 1. Reproduce crash on device
# 2. Get crash logs

# iOS: Xcode → Window → Devices and Simulators
#      Select device → View Device Logs

# Android: adb logcat > crash.log

# 3. Symbolicate crash report
# iOS: Drag .crash file to Xcode
# Android: Use `ndk-stack` or `addr2line`

# 4. Fix issue in native code
# 5. Rebuild and test
```

## Resources

- [EAS Build Profiles Guide](references/eas-build-profiles.md)
- [Simulator Debugging Tips](references/simulator-debugging.md)
- [EAS Build Documentation](https://docs.expo.dev/build/introduction/)
- [Debugging Guide](https://docs.expo.dev/debugging/)

## Tools & Commands

- `eas build --profile <profile> --platform <platform>` - Build with EAS
- `eas build --profile development --local` - Build locally (faster for dev)
- `eas build:list` - List recent builds
- `eas build:cancel` - Cancel running build
- `eas submit --platform <platform> --latest` - Submit to stores
- `xcrun simctl list` - List iOS simulators
- `adb devices` - List Android devices/emulators
- `expo doctor` - Check project health

## Troubleshooting

### Build fails with native module error

**Problem**: `Unable to resolve module X`

**Solution**:
```bash
# Clear caches
rm -rf node_modules
npm install

# Rebuild
eas build --profile development --platform ios --clear-cache
```

### Simulator not showing up

**Problem**: iOS Simulator not detected

**Solution**:
```bash
# List available simulators
xcrun simctl list devices

# Boot a simulator
xcrun simctl boot "iPhone 15 Pro"

# Verify
xcrun simctl list devices | grep Booted
```

### Android build fails

**Problem**: Gradle build error

**Solution**:
```bash
# Check Java version (needs JDK 17)
java -version

# Clean Gradle cache
cd android && ./gradlew clean

# Rebuild
eas build --profile development --platform android --clear-cache
```

### Dev client not connecting

**Problem**: App doesn't connect to dev server

**Solution**:
```bash
# Check both on same network
# Shake device → "Settings" → Enter dev server URL manually
# Format: exp://192.168.1.10:8081
```

---

## Notes

- Development builds are ~10x faster than full production builds
- Use `--local` flag for even faster local builds (requires Xcode/Android Studio)
- Preview builds are identical to production but use internal distribution
- Always test on physical devices before production release
