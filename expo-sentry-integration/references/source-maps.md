# Source Maps Upload Guide for EAS Build

Complete guide to configuring, uploading, and troubleshooting source maps for Sentry in Expo applications using EAS Build.

## Table of Contents

- [Overview](#overview)
- [Why Source Maps Matter](#why-source-maps-matter)
- [How Source Maps Work](#how-source-maps-work)
- [Configuration](#configuration)
- [Automatic Upload](#automatic-upload)
- [Manual Upload](#manual-upload)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)
- [Advanced Topics](#advanced-topics)

## Overview

Source maps enable Sentry to transform minified, production JavaScript bundle stack traces into readable source code locations. Without source maps, production errors appear as:

```
Error: Cannot read property 'id' of undefined
  at a (index.android.bundle:1:234567)
  at b (index.android.bundle:1:345678)
  at c (index.android.bundle:1:456789)
```

With source maps, the same error becomes:

```
Error: Cannot read property 'id' of undefined
  at UserProfile.render (screens/UserProfile.tsx:42:18)
  at UserDashboard.loadUser (screens/Dashboard.tsx:89:12)
  at App.componentDidMount (App.tsx:25:5)
```

## Why Source Maps Matter

### Production Code is Minified

React Native production builds are heavily optimized:
- **Minification**: Variable names shortened (`userProfile` → `a`)
- **Tree shaking**: Unused code removed
- **Dead code elimination**: Unreachable code stripped
- **Module bundling**: All files combined into single bundle
- **Hermes bytecode**: Additional compilation for performance

### Without Source Maps

Debugging production errors is nearly impossible:
- Can't identify which file caused error
- Function names are meaningless (`a`, `b`, `c`)
- Line numbers reference bundle, not source
- No visibility into execution flow

### With Source Maps

Full debugging context:
- Exact source file and line number
- Original function names
- Full stack trace with context
- Ability to correlate with code commits

## How Source Maps Work

### Build Process

1. **Development Build**
   ```
   Source Code → Metro Bundler → Bundle + Source Map
                                  ↓
                              Dev Server (automatic symbolication)
   ```

2. **Production Build**
   ```
   Source Code → Metro Bundler → Minified Bundle + Source Map
                                  ↓
                              Upload to Sentry
                                  ↓
                              Sentry Storage
   ```

### Runtime Error Flow

1. **Error occurs** in production app
2. **Sentry captures** minified stack trace
3. **Sentry looks up** source map for release/dist
4. **Sentry transforms** minified trace to source locations
5. **Developer sees** readable stack trace in dashboard

### Release and Dist

Source maps are matched to errors using two identifiers:

- **Release**: App version (e.g., `my-app@1.0.0`)
- **Dist**: Build number (e.g., `1` for iOS build 1)

These MUST match exactly between:
- Sentry initialization in app
- Source map upload
- Error events

## Configuration

### Prerequisites

1. **Sentry CLI installed**
   ```bash
   npm install -g @sentry/cli
   sentry-cli login
   ```

2. **Auth token created**
   - Go to Sentry > Settings > Account > API > Auth Tokens
   - Create token with scopes: `project:releases`, `project:write`, `org:read`

3. **Environment variables set**
   ```bash
   SENTRY_ORG=your-organization-slug
   SENTRY_PROJECT=your-project-name
   SENTRY_AUTH_TOKEN=your-auth-token
   ```

### EAS Build Configuration

Update `eas.json`:

```json
{
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "env": {
        "SENTRY_DISABLE_AUTO_UPLOAD": "true"
      }
    },
    "preview": {
      "distribution": "internal",
      "env": {
        "SENTRY_ORG": "your-org",
        "SENTRY_PROJECT": "your-project",
        "SENTRY_AUTH_TOKEN": "your-auth-token",
        "SENTRY_DISABLE_AUTO_UPLOAD": "false"
      }
    },
    "production": {
      "env": {
        "SENTRY_ORG": "your-org",
        "SENTRY_PROJECT": "your-project",
        "SENTRY_AUTH_TOKEN": "your-auth-token",
        "SENTRY_DISABLE_AUTO_UPLOAD": "false",
        "SENTRY_ALLOW_FAILURE": "true"
      },
      "autoIncrement": true
    }
  }
}
```

### App Configuration

Set release and dist in `app/_layout.tsx`:

```typescript
import * as Sentry from 'sentry-expo'; // or '@sentry/react-native'
import Constants from 'expo-constants';
import { Platform } from 'react-native';

const appVersion = Constants.expoConfig?.version;
const appSlug = Constants.expoConfig?.slug;

const release = `${appSlug}@${appVersion}`;
const dist = Platform.select({
  ios: Constants.expoConfig?.ios?.buildNumber,
  android: Constants.expoConfig?.android?.versionCode?.toString(),
});

Sentry.init({
  dsn: 'your-dsn',
  release,
  dist,
  // ... other config
});
```

**CRITICAL**: The `release` and `dist` values here must EXACTLY match the values used during source map upload.

## Automatic Upload

### Managed Workflow (sentry-expo)

For managed workflow, source maps upload automatically when using `sentry-expo` with EAS Build:

1. **Configure app.json hooks:**

```json
{
  "expo": {
    "hooks": {
      "postPublish": [
        {
          "file": "sentry-expo/upload-sourcemaps",
          "config": {
            "organization": "your-org",
            "project": "your-project",
            "authToken": "your-auth-token"
          }
        }
      ]
    }
  }
}
```

2. **Set environment variables in eas.json** (as shown above)

3. **Build with EAS:**

```bash
eas build --platform ios --profile production
eas build --platform android --profile production
```

Source maps are automatically uploaded during the build process.

### Bare Workflow (@sentry/react-native)

For bare workflow, the Sentry Wizard configures automatic upload:

1. **Run Sentry Wizard:**

```bash
npx @sentry/wizard@latest -i reactNative -p ios android
```

This configures:

2. **iOS (Xcode build phase):**
   - Adds build phase script to upload dSYMs and source maps
   - Located in: `ios/YourApp.xcodeproj/project.pbxproj`

3. **Android (Gradle plugin):**
   - Adds Sentry Gradle plugin
   - Configured in: `android/app/build.gradle`

```gradle
apply plugin: 'io.sentry.android.gradle'

sentry {
    autoUploadProguardMapping = true
    uploadNativeSymbols = true
}
```

4. **Build with EAS:**

```bash
eas build --platform ios --profile production
eas build --platform android --profile production
```

### Verify Automatic Upload

Check EAS build logs:

```bash
eas build:view [build-id]
```

Look for Sentry upload output:
```
> Uploading source maps to Sentry
> Source Map Upload Report
> Minified Scripts
>   ~/index.android.bundle (114 KB)
> Source Maps
>   ~/index.android.bundle.map (628 KB)
> Successfully uploaded source maps
```

## Manual Upload

If automatic upload fails, upload source maps manually:

### Step 1: Build Locally

```bash
# Build JavaScript bundle and source map
npx expo export --platform ios
npx expo export --platform android
```

This creates bundles in `dist/` directory:
- `dist/bundles/ios-[hash].js`
- `dist/bundles/ios-[hash].js.map`
- `dist/bundles/android-[hash].js`
- `dist/bundles/android-[hash].js.map`

### Step 2: Get Release Info

From `app.json`:
```json
{
  "expo": {
    "slug": "my-app",
    "version": "1.0.0",
    "ios": { "buildNumber": "1" },
    "android": { "versionCode": 1 }
  }
}
```

Calculate release and dist:
```bash
RELEASE="my-app@1.0.0"
IOS_DIST="1"
ANDROID_DIST="1"
```

### Step 3: Create Release

```bash
# Create release in Sentry
sentry-cli releases new "$RELEASE"

# Associate with commits (optional)
sentry-cli releases set-commits "$RELEASE" --auto
```

### Step 4: Upload iOS Source Maps

```bash
sentry-cli releases files "$RELEASE" upload-sourcemaps \
  --dist "$IOS_DIST" \
  --rewrite \
  --strip-prefix /path/to/project \
  dist/bundles/ios-*.js dist/bundles/ios-*.js.map
```

Parameters:
- `--dist`: Must match iOS buildNumber
- `--rewrite`: Rewrite source paths in source maps
- `--strip-prefix`: Remove local path prefix from source files

### Step 5: Upload Android Source Maps

```bash
sentry-cli releases files "$RELEASE" upload-sourcemaps \
  --dist "$ANDROID_DIST" \
  --rewrite \
  --strip-prefix /path/to/project \
  dist/bundles/android-*.js dist/bundles/android-*.js.map
```

### Step 6: Finalize Release

```bash
sentry-cli releases finalize "$RELEASE"
```

### Upload Script

Create `scripts/upload-sourcemaps.sh`:

```bash
#!/bin/bash
set -e

# Read from app.json
SLUG=$(node -p "require('./app.json').expo.slug")
VERSION=$(node -p "require('./app.json').expo.version")
IOS_BUILD=$(node -p "require('./app.json').expo.ios.buildNumber")
ANDROID_BUILD=$(node -p "require('./app.json').expo.android.versionCode")

RELEASE="$SLUG@$VERSION"

echo "Creating release: $RELEASE"
sentry-cli releases new "$RELEASE"
sentry-cli releases set-commits "$RELEASE" --auto

echo "Uploading iOS source maps (dist: $IOS_BUILD)"
sentry-cli releases files "$RELEASE" upload-sourcemaps \
  --dist "$IOS_BUILD" \
  --rewrite \
  --strip-prefix "$(pwd)" \
  dist/bundles/ios-*.js dist/bundles/ios-*.js.map

echo "Uploading Android source maps (dist: $ANDROID_BUILD)"
sentry-cli releases files "$RELEASE" upload-sourcemaps \
  --dist "$ANDROID_BUILD" \
  --rewrite \
  --strip-prefix "$(pwd)" \
  dist/bundles/android-*.js dist/bundles/android-*.js.map

echo "Finalizing release"
sentry-cli releases finalize "$RELEASE"

echo "Source maps uploaded successfully!"
```

Make executable and run:
```bash
chmod +x scripts/upload-sourcemaps.sh
./scripts/upload-sourcemaps.sh
```

## Verification

### List Uploaded Files

```bash
# List all files for release
sentry-cli releases files "my-app@1.0.0" list

# Expected output for iOS (dist: 1):
# DISTRIBUTION  NAME                    SIZE
# 1             index.ios.bundle        114 KB
# 1             index.ios.bundle.map    628 KB

# Expected output for Android (dist: 1):
# DISTRIBUTION  NAME                      SIZE
# 1             index.android.bundle      118 KB
# 1             index.android.bundle.map  642 KB
```

### Check Source Map Details

```bash
# View specific file
sentry-cli releases files "my-app@1.0.0" list --dist 1

# Delete file if wrong
sentry-cli releases files "my-app@1.0.0" delete --dist 1 index.ios.bundle
```

### Test with Error

1. **Trigger test error in app:**

```typescript
import * as Sentry from 'sentry-expo';

function testSourceMaps() {
  try {
    throw new Error('Source map test error');
  } catch (error) {
    Sentry.captureException(error);
  }
}
```

2. **Check Sentry dashboard:**
   - Go to Issues
   - Find test error
   - Verify stack trace shows source file names and line numbers
   - NOT minified code like `a.js:1:234567`

### Explain Command

If stack traces are still minified:

```bash
# Get event ID from Sentry dashboard
EVENT_ID="abc123..."

# Explain why source maps aren't working
sentry-cli sourcemaps explain "$EVENT_ID"
```

Output shows:
- Whether source map was found
- If release/dist match
- If bundle names match
- What's misconfigured

## Troubleshooting

### Issue: Stack traces show minified code

**Symptoms:**
```
at a (index.android.bundle:1:234567)
at b (index.android.bundle:1:345678)
```

**Causes & Solutions:**

1. **Release/Dist mismatch**

Check app initialization matches upload:

```typescript
// app/_layout.tsx
console.log('Sentry release:', release); // "my-app@1.0.0"
console.log('Sentry dist:', dist);       // "1"
```

Then verify uploaded files:
```bash
sentry-cli releases files "my-app@1.0.0" list --dist 1
```

If mismatch, upload with correct values.

2. **Bundle name mismatch**

Stack trace shows: `index.android.bundle:1:234567`
Uploaded file: `main.android.bundle.map`

Solution: Rename uploaded file to match exactly:
```bash
# Delete wrong file
sentry-cli releases files "$RELEASE" delete --dist "$DIST" main.android.bundle.map

# Upload with correct name
sentry-cli releases files "$RELEASE" upload-sourcemaps \
  --dist "$DIST" \
  --rewrite \
  index.android.bundle index.android.bundle.map
```

3. **Source map not uploaded**

Check if .map file exists:
```bash
sentry-cli releases files "$RELEASE" list --dist "$DIST"
```

If missing, upload source maps.

4. **Wrong JavaScript engine**

Hermes vs JavaScriptCore generate different bundles.

Check `app.json`:
```json
{
  "expo": {
    "jsEngine": "hermes" // or "jsc"
  }
}
```

Source maps must match JS engine used for build.

### Issue: Build fails during source map upload

**Error:**
```
> Source map upload failed
> Build failed
```

**Solutions:**

1. **Allow build to continue on upload failure:**

In `eas.json`:
```json
{
  "build": {
    "production": {
      "env": {
        "SENTRY_ALLOW_FAILURE": "true"
      }
    }
  }
}
```

Build succeeds even if upload fails. Upload manually later.

2. **Check auth token scopes:**

Token must have:
- `project:releases`
- `project:write`
- `org:read`

Regenerate token if missing scopes.

3. **Check network connectivity:**

EAS build servers must reach `sentry.io`. Usually not an issue, but check if upload consistently fails.

4. **Check environment variables:**

Verify in `eas.json`:
```json
{
  "build": {
    "production": {
      "env": {
        "SENTRY_ORG": "your-org",           // Not org ID!
        "SENTRY_PROJECT": "your-project",   // Project slug
        "SENTRY_AUTH_TOKEN": "sntrys_..."   // Full token
      }
    }
  }
}
```

### Issue: Multiple releases for same version

**Problem:** Uploaded source maps for `my-app@1.0.0` multiple times with different builds.

**Solution:** Use unique dist for each build:

```typescript
// Don't do this:
const dist = "1"; // Same for every build

// Do this:
const dist = Platform.select({
  ios: Constants.expoConfig?.ios?.buildNumber,      // "1", "2", "3"...
  android: Constants.expoConfig?.android?.versionCode?.toString(),
});
```

In `app.json`, set `autoIncrement: true` in `eas.json`:
```json
{
  "build": {
    "production": {
      "autoIncrement": true  // Auto-increments buildNumber and versionCode
    }
  }
}
```

### Issue: Source maps too large

**Error:**
```
413 Request Entity Too Large
```

**Solution:**

Source maps can be very large (>10MB). Sentry has upload limits.

Options:

1. **Upload in chunks** (handled automatically by CLI)

2. **Use compression:**
```bash
sentry-cli releases files "$RELEASE" upload-sourcemaps \
  --dist "$DIST" \
  --rewrite \
  --strip-prefix "$(pwd)" \
  --ignore node_modules \
  dist/
```

3. **Enable tree shaking** to reduce bundle size

4. **Split bundles** for large apps

### Issue: Wrong source file paths

**Problem:** Stack trace shows absolute paths:
```
at UserProfile (/Users/dev/MyApp/src/screens/UserProfile.tsx:42)
```

**Solution:** Use `--strip-prefix`:

```bash
sentry-cli releases files "$RELEASE" upload-sourcemaps \
  --dist "$DIST" \
  --rewrite \
  --strip-prefix "/Users/dev/MyApp" \
  dist/
```

Result:
```
at UserProfile (src/screens/UserProfile.tsx:42)
```

Or use `--strip-common-prefix` to automatically detect:
```bash
sentry-cli releases files "$RELEASE" upload-sourcemaps \
  --dist "$DIST" \
  --rewrite \
  --strip-common-prefix \
  dist/
```

### Issue: Hermes bytecode not symbolicated

**Problem:** Using Hermes, but stack traces still minified.

**Solution:**

Hermes requires special handling:

1. **Ensure Hermes is enabled:**
```json
// app.json
{
  "expo": {
    "jsEngine": "hermes"
  }
}
```

2. **Upload Hermes source maps:**

Hermes generates both:
- JavaScript bundle + source map
- Hermes bytecode bundle + source map

Both must be uploaded.

3. **Use Sentry SDK 5.11.0+:**

Older versions don't support Hermes source maps.

```bash
npm install @sentry/react-native@latest
```

## Advanced Topics

### Multiple Platforms

Upload separate source maps for iOS and Android:

```typescript
// app/_layout.tsx
const release = `${appSlug}@${appVersion}`;
const dist = Platform.select({
  ios: `ios-${iosVersion}`,
  android: `android-${androidVersion}`,
});
```

Upload with platform-specific dist:
```bash
# iOS
sentry-cli releases files "$RELEASE" upload-sourcemaps \
  --dist "ios-1" \
  dist/ios/

# Android
sentry-cli releases files "$RELEASE" upload-sourcemaps \
  --dist "android-1" \
  dist/android/
```

### OTA Updates (Expo Updates)

When using Expo Updates, each update needs source maps:

```typescript
import * as Updates from 'expo-updates';

const release = `${appSlug}@${appVersion}`;
const dist = Updates.updateId || 'embedded'; // Use update ID as dist
```

Upload source maps for each OTA update:
```bash
UPDATE_ID="abc-123-def-456"

sentry-cli releases files "$RELEASE" upload-sourcemaps \
  --dist "$UPDATE_ID" \
  dist/
```

### CI/CD Integration

Upload source maps in CI/CD pipeline:

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Setup Node
        uses: actions/setup-node@v2

      - name: Install dependencies
        run: npm install

      - name: Build with EAS
        env:
          EXPO_TOKEN: ${{ secrets.EXPO_TOKEN }}
          SENTRY_ORG: ${{ secrets.SENTRY_ORG }}
          SENTRY_PROJECT: ${{ secrets.SENTRY_PROJECT }}
          SENTRY_AUTH_TOKEN: ${{ secrets.SENTRY_AUTH_TOKEN }}
        run: |
          eas build --platform all --non-interactive

      - name: Verify source maps
        run: |
          RELEASE="my-app@$(node -p "require('./app.json').expo.version")"
          sentry-cli releases files "$RELEASE" list
```

### Monitoring Upload Success

Track source map upload metrics:

```bash
# Check recent releases
sentry-cli releases list --limit 10

# Check file count for release
sentry-cli releases files "$RELEASE" list | wc -l
# Should show 4 files (2 bundles + 2 source maps for iOS/Android)

# View upload history
sentry-cli releases files "$RELEASE" list --verbose
```

Set up monitoring:
1. Alert if source map upload fails
2. Verify source maps exist before deployment
3. Test source maps with automated error

---

## Summary

### Checklist for Source Maps

- [ ] Sentry CLI installed and authenticated
- [ ] Auth token created with correct scopes
- [ ] Environment variables configured in `eas.json`
- [ ] Release and dist set in app initialization
- [ ] Release and dist match between app and upload
- [ ] Source maps automatically uploaded via EAS Build
- [ ] Uploaded files verified with `sentry-cli releases files list`
- [ ] Test error sent and verified in Sentry dashboard
- [ ] Stack traces show readable source locations

### Key Takeaways

1. **Release and dist must match exactly** between app and upload
2. **Bundle names must match** between stack trace and uploaded files
3. **Use SENTRY_ALLOW_FAILURE=true** to prevent build failures
4. **Verify upload** with `sentry-cli releases files list`
5. **Test with real error** before production deployment

### Quick Reference

```bash
# List files for release
sentry-cli releases files "my-app@1.0.0" list --dist 1

# Upload source maps
sentry-cli releases files "my-app@1.0.0" upload-sourcemaps \
  --dist 1 \
  --rewrite \
  --strip-common-prefix \
  dist/

# Explain why source maps aren't working
sentry-cli sourcemaps explain [event-id]

# Delete wrong files
sentry-cli releases files "my-app@1.0.0" delete --dist 1 index.ios.bundle

# View release details
sentry-cli releases info "my-app@1.0.0"
```

---

*Last updated: 2026-01-04*
