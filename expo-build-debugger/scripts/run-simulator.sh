#!/usr/bin/env bash
#
# Install and run Expo app on simulator/emulator
# Usage: ./run-simulator.sh <platform> [build-path]
# Example: ./run-simulator.sh ios ~/Downloads/build.app
#
set -euo pipefail

PLATFORM="${1:-ios}"
BUILD_PATH="${2:-}"

if [ "$PLATFORM" = "ios" ]; then
    echo "📱 Running on iOS Simulator..."

    # Check if build path provided
    if [ -z "$BUILD_PATH" ]; then
        echo "❌ Build path required for iOS"
        echo "   Usage: $0 ios ~/Downloads/build.app"
        exit 1
    fi

    # Check if simulator is booted
    BOOTED=$(xcrun simctl list devices | grep "Booted" || true)

    if [ -z "$BOOTED" ]; then
        echo "🚀 Booting iOS Simulator..."
        # Boot default simulator
        xcrun simctl boot "iPhone 15 Pro" || true
        sleep 3
    fi

    # Install app
    echo "📦 Installing app on simulator..."
    xcrun simctl install booted "$BUILD_PATH"

    # Get bundle ID from Info.plist
    BUNDLE_ID=$(defaults read "$BUILD_PATH/Info.plist" CFBundleIdentifier)

    # Launch app
    echo "🎯 Launching app..."
    xcrun simctl launch booted "$BUNDLE_ID"

    echo "✅ App launched successfully!"

elif [ "$PLATFORM" = "android" ]; then
    echo "🤖 Running on Android Emulator..."

    # Check if build path provided
    if [ -z "$BUILD_PATH" ]; then
        echo "❌ Build path required for Android"
        echo "   Usage: $0 android ~/Downloads/build.apk"
        exit 1
    fi

    # Check if emulator is running
    DEVICES=$(adb devices | grep "emulator" || true)

    if [ -z "$DEVICES" ]; then
        echo "❌ No Android emulator detected"
        echo "   Start an emulator first"
        exit 1
    fi

    # Install APK
    echo "📦 Installing APK..."
    adb install -r "$BUILD_PATH"

    # Get package name
    PACKAGE=$(aapt dump badging "$BUILD_PATH" | grep package | awk '{print $2}' | sed s/name=//g | tr -d "'")

    # Launch app
    echo "🎯 Launching app..."
    adb shell monkey -p "$PACKAGE" 1

    echo "✅ App launched successfully!"

else
    echo "❌ Unknown platform: $PLATFORM"
    echo "   Supported: ios, android"
    exit 1
fi
