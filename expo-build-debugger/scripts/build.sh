#!/usr/bin/env bash
#
# Build Expo app with EAS Build
# Usage: ./build.sh <profile> <platform>
# Example: ./build.sh development ios
#
set -euo pipefail

PROFILE="${1:-development}"
PLATFORM="${2:-ios}"

echo "🔨 Building Expo app..."
echo "   Profile: $PROFILE"
echo "   Platform: $PLATFORM"
echo ""

# Check if EAS CLI is installed
if ! command -v eas &> /dev/null; then
    echo "❌ EAS CLI not found. Install it first:"
    echo "   npm install -g eas-cli"
    exit 1
fi

# Check if logged in
if ! eas whoami &> /dev/null; then
    echo "❌ Not logged in to EAS. Run:"
    echo "   eas login"
    exit 1
fi

# Build
echo "🚀 Starting build..."
eas build --profile "$PROFILE" --platform "$PLATFORM"

echo ""
echo "✅ Build started successfully!"
echo "   Track progress: https://expo.dev/accounts/[account]/projects/[project]/builds"
