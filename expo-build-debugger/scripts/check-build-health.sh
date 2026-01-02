#!/usr/bin/env bash
#
# Check EAS Build configuration health
#
set -euo pipefail

echo "🏥 Checking EAS Build Health..."
echo ""

# Check EAS CLI
echo "1️⃣ Checking EAS CLI..."
if command -v eas &> /dev/null; then
    EAS_VERSION=$(eas --version)
    echo "   ✅ EAS CLI installed: $EAS_VERSION"
else
    echo "   ❌ EAS CLI not found"
    echo "      Install: npm install -g eas-cli"
fi

# Check if eas.json exists
echo ""
echo "2️⃣ Checking eas.json..."
if [ -f "eas.json" ]; then
    echo "   ✅ eas.json found"

    # Validate JSON
    if command -v jq &> /dev/null; then
        if jq empty eas.json 2>/dev/null; then
            echo "   ✅ eas.json is valid JSON"
        else
            echo "   ❌ eas.json has invalid JSON syntax"
        fi
    fi
else
    echo "   ❌ eas.json not found"
    echo "      Run: eas build:configure"
fi

# Check Expo SDK
echo ""
echo "3️⃣ Checking Expo SDK..."
if [ -f "package.json" ]; then
    EXPO_VERSION=$(grep '"expo"' package.json | sed 's/.*"\([0-9.]*\)".*/\1/' | head -1)
    echo "   ✅ Expo SDK: $EXPO_VERSION"
else
    echo "   ❌ package.json not found"
fi

# Check iOS Simulator
echo ""
echo "4️⃣ Checking iOS Simulators..."
if command -v xcrun &> /dev/null; then
    SIM_COUNT=$(xcrun simctl list devices | grep -c "iPhone" || true)
    echo "   ✅ Found $SIM_COUNT iPhone simulators"

    BOOTED=$(xcrun simctl list devices | grep "Booted" || true)
    if [ -n "$BOOTED" ]; then
        echo "   ✅ Simulator is running"
    else
        echo "   ⚠️  No simulator running"
    fi
else
    echo "   ❌ Xcode not installed"
fi

# Check Android Emulator
echo ""
echo "5️⃣ Checking Android Emulators..."
if command -v adb &> /dev/null; then
    echo "   ✅ ADB installed"

    DEVICES=$(adb devices | grep "emulator" || true)
    if [ -n "$DEVICES" ]; then
        echo "   ✅ Emulator is running"
    else
        echo "   ⚠️  No emulator running"
    fi
else
    echo "   ❌ Android SDK not installed"
fi

# Check native dependencies
echo ""
echo "6️⃣ Checking native dependencies..."
if [ -f "package.json" ]; then
    NATIVE_COUNT=$(grep -E '(@react-native|react-native-)' package.json | wc -l)
    echo "   ✅ Found $NATIVE_COUNT native dependencies"
fi

echo ""
echo "✅ Health check complete!"
