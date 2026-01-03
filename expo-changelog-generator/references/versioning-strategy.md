# Versioning Strategy

## Semantic Versioning (SemVer)

### Format: MAJOR.MINOR.PATCH

```
1.0.0
│ │ │
│ │ └─── PATCH: Bug fixes and minor changes
│ └───── MINOR: New features, backward compatible
└─────── MAJOR: Breaking changes, incompatible API changes
```

### Version Number Rules

1. **MAJOR (X.0.0)** - Increment when:
   - Breaking changes to API or user interface
   - Removing features or functionality
   - Complete redesign or rewrite
   - Changes requiring user action (data migration, new permissions)

2. **MINOR (x.X.0)** - Increment when:
   - Adding new features (backward compatible)
   - Significant improvements to existing features
   - Deprecating functionality (but not removing)
   - Adding optional new dependencies

3. **PATCH (x.x.X)** - Increment when:
   - Bug fixes
   - Security patches
   - Performance improvements
   - Minor UI tweaks
   - Documentation updates

### Pre-release Versions

```
1.0.0-alpha.1   → Early development, unstable
1.0.0-beta.1    → Feature complete, testing phase
1.0.0-rc.1      → Release candidate, final testing
1.0.0           → Stable release
```

## Version Bumping Strategies

### Using npm version

```bash
# Patch version (1.0.0 → 1.0.1)
npm version patch

# Minor version (1.0.0 → 1.1.0)
npm version minor

# Major version (1.0.0 → 2.0.0)
npm version major

# Pre-release versions
npm version prerelease --preid=alpha  # 1.0.0 → 1.0.1-alpha.0
npm version prerelease --preid=beta   # 1.0.0 → 1.0.1-beta.0
npm version prerelease --preid=rc     # 1.0.0 → 1.0.1-rc.0
```

### Manual Versioning

Update these files when versioning:

1. **package.json**
```json
{
  "version": "1.2.3"
}
```

2. **app.json / app.config.js** (Expo)
```json
{
  "expo": {
    "version": "1.2.3",
    "ios": {
      "buildNumber": "10"
    },
    "android": {
      "versionCode": 10
    }
  }
}
```

3. **Info.plist** (iOS native)
```xml
<key>CFBundleShortVersionString</key>
<string>1.2.3</string>
<key>CFBundleVersion</key>
<string>10</string>
```

4. **build.gradle** (Android native)
```gradle
versionName "1.2.3"
versionCode 10
```

### Automated Version Bumping Script

```bash
#!/bin/bash
# bump-version.sh

VERSION_TYPE=$1  # patch, minor, or major

if [ -z "$VERSION_TYPE" ]; then
  echo "Usage: ./bump-version.sh [patch|minor|major]"
  exit 1
fi

# Bump version in package.json
npm version $VERSION_TYPE --no-git-tag-version

# Get new version
NEW_VERSION=$(node -p "require('./package.json').version")

# Update app.json (for Expo)
if [ -f "app.json" ]; then
  # Using jq for JSON manipulation
  jq ".expo.version = \"$NEW_VERSION\"" app.json > tmp.json && mv tmp.json app.json
fi

# Increment build numbers
# iOS buildNumber
CURRENT_IOS_BUILD=$(jq -r '.expo.ios.buildNumber' app.json)
NEW_IOS_BUILD=$((CURRENT_IOS_BUILD + 1))
jq ".expo.ios.buildNumber = \"$NEW_IOS_BUILD\"" app.json > tmp.json && mv tmp.json app.json

# Android versionCode
CURRENT_ANDROID_CODE=$(jq -r '.expo.android.versionCode' app.json)
NEW_ANDROID_CODE=$((CURRENT_ANDROID_CODE + 1))
jq ".expo.android.versionCode = $NEW_ANDROID_CODE" app.json > tmp.json && mv tmp.json app.json

echo "Version bumped to $NEW_VERSION"
echo "iOS buildNumber: $NEW_IOS_BUILD"
echo "Android versionCode: $NEW_ANDROID_CODE"
```

## Git Tagging Best Practices

### Creating Tags

```bash
# Annotated tag (recommended)
git tag -a v1.2.3 -m "Release version 1.2.3"

# Lightweight tag (not recommended for releases)
git tag v1.2.3

# Tag with detailed message
git tag -a v1.2.3 -m "$(cat <<EOF
Release version 1.2.3

New Features:
- Dark mode support
- Offline functionality

Bug Fixes:
- Fixed crash on startup
- Resolved notification issues
EOF
)"
```

### Tag Naming Conventions

```bash
# Standard releases
v1.0.0
v1.2.3
v2.0.0

# Pre-releases
v1.0.0-alpha.1
v1.0.0-beta.2
v1.0.0-rc.1

# Platform-specific releases (if needed)
v1.0.0-ios
v1.0.0-android

# Environment-specific tags
v1.0.0-staging
v1.0.0-production
```

### Tag Management

```bash
# List all tags
git tag
git tag -l "v1.*"

# Show tag details
git show v1.2.3

# Push tags to remote
git push origin v1.2.3          # Push single tag
git push origin --tags          # Push all tags

# Delete tags
git tag -d v1.2.3               # Delete local tag
git push origin :refs/tags/v1.2.3  # Delete remote tag
git push origin --delete v1.2.3    # Delete remote tag (newer syntax)

# Get latest tag
git describe --tags --abbrev=0

# Get commits since last tag
git log $(git describe --tags --abbrev=0)..HEAD --oneline
```

### Tag Signing (Security)

```bash
# Create signed tag (requires GPG setup)
git tag -s v1.2.3 -m "Release version 1.2.3"

# Verify signed tag
git tag -v v1.2.3
```

## EAS Update Versioning

### Understanding EAS Update vs App Store Builds

```
App Store Build (Binary Update)
├─ Requires: New build, store review, user download
├─ Version: 1.0.0 → 1.1.0
├─ Build Number: 10 → 11
└─ Use for: Major changes, native code changes, permissions

EAS Update (OTA Update)
├─ Requires: Only JS/assets update, instant delivery
├─ Runtime Version: Same as last build
├─ Update Message: "Bug fixes and improvements"
└─ Use for: Bug fixes, UI tweaks, content updates
```

### EAS Update Configuration

**eas.json**
```json
{
  "build": {
    "production": {
      "channel": "production",
      "distribution": "store"
    },
    "preview": {
      "channel": "preview",
      "distribution": "internal"
    }
  },
  "submit": {
    "production": {
      "ios": {
        "appleId": "your-apple-id@example.com",
        "ascAppId": "1234567890"
      },
      "android": {
        "serviceAccountKeyPath": "./path/to/key.json"
      }
    }
  }
}
```

### Runtime Version Strategy

**app.json**
```json
{
  "expo": {
    "runtimeVersion": {
      "policy": "sdkVersion"
    }
  }
}
```

**Options:**

1. **sdkVersion** (Default)
   - Runtime version = Expo SDK version
   - Simple but limits flexibility
   - Good for simple apps

2. **appVersion**
   - Runtime version = app version from package.json
   - More control over compatibility
   - Good for frequent updates

3. **nativeVersion**
   - Custom runtime version in app config
   - Full control over update compatibility
   - Best for complex apps

**Custom Runtime Version:**
```json
{
  "expo": {
    "runtimeVersion": "1.0.0"
  }
}
```

### Publishing Updates

```bash
# Publish update to production channel
eas update --branch production --message "Bug fixes and performance improvements"

# Publish to specific channel
eas update --branch preview --message "Testing new feature"

# Publish with auto message (uses git commit)
eas update --branch production --auto

# View published updates
eas update:list --branch production

# Rollback to previous update
eas update:republish --branch production --group [group-id]
```

## Build Number vs Version Number

### Understanding the Difference

| Aspect | Version Number | Build Number |
|--------|---------------|--------------|
| **Purpose** | User-facing release identifier | Internal build identifier |
| **Format** | Semantic (1.2.3) | Sequential integer |
| **Visibility** | App Store, Settings | Settings (iOS), Play Console |
| **Changes** | When content changes | Every build, always increases |
| **Example** | 1.0.0, 1.1.0, 2.0.0 | 1, 2, 3, 4, 5... |

### Version Number

```
User sees: "Version 1.2.3"
├─ Indicates: Feature set and compatibility
├─ Updates: When releasing to users
└─ Examples: 1.0.0 (launch), 1.1.0 (new feature), 1.1.1 (bug fix)
```

### Build Number

```
System sees: "Build 42"
├─ Indicates: Specific compiled binary
├─ Updates: Every time you create a build
└─ Examples: 1 (first build), 2 (fixed crash), 3 (tested locally), 4 (production)
```

### Practical Examples

**Scenario 1: Bug Fix Release**
```
Before:
  Version: 1.0.0
  iOS Build: 5
  Android Version Code: 5

After (one bug fix release):
  Version: 1.0.1
  iOS Build: 6
  Android Version Code: 6
```

**Scenario 2: Multiple Test Builds**
```
Initial:
  Version: 1.1.0
  iOS Build: 10

Test Build 1 (internal testing):
  Version: 1.1.0
  iOS Build: 11

Test Build 2 (fixed crash):
  Version: 1.1.0
  iOS Build: 12

Final Production Release:
  Version: 1.1.0
  iOS Build: 13  ← Only this goes to App Store
```

### iOS Build Number Rules

- Must be a string of integers separated by periods
- Monotonically increasing
- Each build submitted must have unique build number
- Format: "1" or "1.0" or "1.0.1"

```json
{
  "expo": {
    "ios": {
      "buildNumber": "15"
    }
  }
}
```

### Android Version Code Rules

- Must be a positive integer
- Strictly increasing
- Cannot reuse previous version codes
- Maximum value: 2100000000

```json
{
  "expo": {
    "android": {
      "versionCode": 15
    }
  }
}
```

### Build Number Strategies

**Strategy 1: Simple Sequential**
```
Build 1, 2, 3, 4, 5...
✓ Simple
✓ Clear ordering
✗ No version information encoded
```

**Strategy 2: Date-Based**
```
Build 20240115 (January 15, 2024)
✓ Timestamp information
✓ Clear when build was created
✗ Can be confusing
✗ May exceed Android limit
```

**Strategy 3: Version + Build**
```
Version 1.2.3 → Build 10203
Version 1.2.4 → Build 10204
✓ Encodes version information
✓ Sortable
✗ More complex
✗ Requires calculation
```

## Release Branches Strategy

### Git Flow for Mobile Apps

```
main (production)
  ├─ develop (integration)
  │   ├─ feature/dark-mode
  │   ├─ feature/offline-sync
  │   └─ feature/new-dashboard
  ├─ release/1.2.0 (release preparation)
  └─ hotfix/1.1.1 (emergency fixes)
```

### Branch Strategy

1. **main** - Production releases only
   - Always tagged with version
   - Always deployable
   - Protected branch

2. **develop** - Integration branch
   - Latest development work
   - Feature branches merge here
   - Source for release branches

3. **feature/** - New features
   - Branch from: develop
   - Merge to: develop
   - Naming: feature/short-description

4. **release/** - Release preparation
   - Branch from: develop
   - Merge to: main + develop
   - Naming: release/X.Y.0

5. **hotfix/** - Emergency fixes
   - Branch from: main
   - Merge to: main + develop
   - Naming: hotfix/X.Y.Z

### Release Branch Workflow

```bash
# Start release branch
git checkout develop
git pull origin develop
git checkout -b release/1.2.0

# Bump version numbers
npm version minor  # 1.1.x → 1.2.0

# Update changelog
# Test thoroughly
# Fix any bugs found during testing

# When ready, merge to main
git checkout main
git merge --no-ff release/1.2.0
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin main --tags

# Merge back to develop
git checkout develop
git merge --no-ff release/1.2.0
git push origin develop

# Delete release branch
git branch -d release/1.2.0
git push origin --delete release/1.2.0
```

### Hotfix Workflow

```bash
# Create hotfix branch from main
git checkout main
git checkout -b hotfix/1.2.1

# Fix the critical bug
# Update version
npm version patch  # 1.2.0 → 1.2.1

# Merge to main
git checkout main
git merge --no-ff hotfix/1.2.1
git tag -a v1.2.1 -m "Hotfix version 1.2.1"
git push origin main --tags

# Merge to develop
git checkout develop
git merge --no-ff hotfix/1.2.1
git push origin develop

# Delete hotfix branch
git branch -d hotfix/1.2.1
```

### Feature Branch Workflow

```bash
# Create feature branch
git checkout develop
git checkout -b feature/dark-mode

# Work on feature
git add .
git commit -m "Add dark mode toggle"

# Keep up to date with develop
git fetch origin
git rebase origin/develop

# When done, create PR to develop
git push origin feature/dark-mode

# After review and approval, merge
# (Usually done via PR interface)
```

## Complete Release Workflow Example

### Preparing a Minor Release (1.1.0 → 1.2.0)

**Step 1: Create Release Branch**
```bash
git checkout develop
git pull origin develop
git checkout -b release/1.2.0
```

**Step 2: Bump Versions**
```bash
# Update package.json
npm version minor --no-git-tag-version  # 1.1.0 → 1.2.0

# Update app.json
NEW_VERSION="1.2.0"
jq ".expo.version = \"$NEW_VERSION\"" app.json > tmp.json && mv tmp.json app.json

# Increment build numbers
# iOS
CURRENT_BUILD=$(jq -r '.expo.ios.buildNumber' app.json)
NEW_BUILD=$((CURRENT_BUILD + 1))
jq ".expo.ios.buildNumber = \"$NEW_BUILD\"" app.json > tmp.json && mv tmp.json app.json

# Android
CURRENT_CODE=$(jq -r '.expo.android.versionCode' app.json)
NEW_CODE=$((CURRENT_CODE + 1))
jq ".expo.android.versionCode = $NEW_CODE" app.json > tmp.json && mv tmp.json app.json
```

**Step 3: Generate Changelog**
```bash
# Get commits since last release
git log v1.1.0..HEAD --oneline --no-merges > COMMITS.txt

# Organize into release notes
# (Manual process - categorize by type)
```

**Step 4: Test Thoroughly**
```bash
# Build preview version
eas build --profile preview --platform all

# Test on devices
# Fix any bugs found
# Commit fixes to release branch
```

**Step 5: Finalize Release**
```bash
# Commit version changes
git add package.json app.json
git commit -m "Bump version to 1.2.0"

# Merge to main
git checkout main
git merge --no-ff release/1.2.0

# Tag release
git tag -a v1.2.0 -m "$(cat <<EOF
Release version 1.2.0

New Features:
- Dark mode support
- Offline sync
- Custom widgets

Improvements:
- 2x faster startup
- Better error handling

Bug Fixes:
- Fixed crash on login
- Resolved notification issues
EOF
)"

# Push to remote
git push origin main --tags

# Merge back to develop
git checkout develop
git merge --no-ff release/1.2.0
git push origin develop

# Clean up
git branch -d release/1.2.0
```

**Step 6: Build and Submit**
```bash
# Build production versions
eas build --profile production --platform ios
eas build --profile production --platform android

# Submit to stores
eas submit --platform ios --latest
eas submit --platform android --latest
```

## Version History Examples

### Example App Version History

```
v2.0.0 (Build 25) - Jan 15, 2024
  - Complete redesign
  - New navigation structure
  - Breaking: Removed legacy API support

v1.3.0 (Build 24) - Dec 10, 2023
  - Added dark mode
  - New dashboard widgets
  - Performance improvements

v1.2.1 (Build 23) - Nov 28, 2023
  - Hotfix: Crash on startup
  - Fixed notification sounds

v1.2.0 (Build 22) - Nov 15, 2023
  - Offline mode
  - Voice search
  - Custom themes

v1.1.2 (Build 21) - Oct 20, 2023
  - Bug fixes
  - Security updates

v1.1.1 (Build 20) - Oct 12, 2023
  - Hotfix: Login issues

v1.1.0 (Build 19) - Oct 5, 2023
  - Push notifications
  - Share functionality
  - UI improvements

v1.0.0 (Build 18) - Sep 1, 2023
  - Initial public release
```

## Tools and Automation

### Version Bump Scripts

**package.json scripts**
```json
{
  "scripts": {
    "version:patch": "npm version patch && git push --tags",
    "version:minor": "npm version minor && git push --tags",
    "version:major": "npm version major && git push --tags",
    "version:show": "node -p \"require('./package.json').version\"",
    "changelog": "git log $(git describe --tags --abbrev=0)..HEAD --oneline"
  }
}
```

### Automated Changelog Generation

```bash
#!/bin/bash
# generate-changelog.sh

LAST_TAG=$(git describe --tags --abbrev=0)
CURRENT_BRANCH=$(git branch --show-current)

echo "Changelog from $LAST_TAG to $CURRENT_BRANCH"
echo "============================================"
echo ""

echo "New Features:"
git log $LAST_TAG..HEAD --oneline --grep="feat:" --grep="feature:"

echo ""
echo "Bug Fixes:"
git log $LAST_TAG..HEAD --oneline --grep="fix:" --grep="bug:"

echo ""
echo "Improvements:"
git log $LAST_TAG..HEAD --oneline --grep="improve:" --grep="perf:"
```

## Best Practices Summary

1. **Always use semantic versioning** - Clear and predictable
2. **Increment build numbers every build** - Required by stores
3. **Tag all releases** - Maintain clear history
4. **Use annotated tags** - Include release notes
5. **Keep version files in sync** - Avoid mismatches
6. **Document breaking changes** - Help users upgrade
7. **Use release branches** - Isolate release preparation
8. **Automate where possible** - Reduce human error
9. **Test before tagging** - Don't tag broken code
10. **Follow platform guidelines** - Ensure store compliance
