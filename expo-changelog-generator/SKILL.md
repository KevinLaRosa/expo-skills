---
name: expo-changelog-generator
description: Generate App Store and Play Store release notes automatically from git commit history and prepare releases with EAS Submit
---

# Expo Changelog Generator

## Overview

Automate release notes generation from git history, format for App Store (4000 chars) and Play Store (500 chars), and streamline EAS Submit workflow.

## When to Use This Skill

- Preparing app store submissions
- Need professional release notes quickly
- Want consistent changelog format
- Automating release workflows
- Tracking features per version

## Workflow

### Step 1: Extract Commits Since Last Tag

```bash
# Use the provided script
./expo-changelog-generator/scripts/generate-changelog.sh

# Or manually
git log $(git describe --tags --abbrev=0)..HEAD --oneline
```

### Step 2: Format for App Store

```markdown
## What's New in v2.0

✨ New Features
• Real-time trade notifications
• Dark mode support
• Improved performance

🐛 Bug Fixes
• Fixed crash on startup
• Resolved WebSocket reconnection issue

📈 Improvements
• Faster load times
• Better error messages

(Max 4000 characters for App Store)
```

### Step 3: Format for Play Store

```
v2.0: Real-time notifications, dark mode, performance improvements, bug fixes
(Max 500 characters)
```

### Step 4: Prepare Release

```bash
# Bump version
npm version patch  # or minor, major

# Tag release
git tag -a v2.0.0 -m "Release v2.0.0"

# Push with tags
git push origin main --tags
```

### Step 5: Submit to Stores

```bash
# Build and submit iOS
eas build --platform ios --profile production
eas submit --platform ios --latest

# Build and submit Android
eas build --platform android --profile production
eas submit --platform android --latest
```

## Guidelines

**Do:**
- Group commits by type (features/fixes/improvements)
- Keep descriptions user-focused
- Follow character limits strictly
- Include version number prominently

**Don't:**
- Don't include technical jargon
- Don't list minor code changes
- Don't forget to test before submit

## Resources

- [Release Notes Guidelines](references/release-notes-guidelines.md)
- [Versioning Strategy](references/versioning-strategy.md)

---

## Notes

- App Store: 4000 character limit
- Play Store: 500 character limit
- Use semantic versioning (semver)
