---
name: expo-sentry-integration
description: Monitor production errors and performance with Sentry integration for Expo apps including source maps and release tracking
license: MIT
compatibility: "Requires: Expo SDK 50+, Sentry account, @sentry/react-native package, EAS Build for source maps"
---

# Expo Sentry Integration

## Overview

Set up comprehensive error tracking and performance monitoring with Sentry for production Expo apps.

## When to Use This Skill

- Deploying app to production
- Need to track crashes and errors in the wild
- Want performance monitoring (APM)
- Need release tracking and source maps
- Building error recovery flows

## Workflow

### Step 1: Install Sentry SDK

```bash
npx expo install @sentry/react-native

# Initialize Sentry with wizard
npx @sentry/wizard@latest -i reactNative -p ios android
```

### Step 2: Configure Sentry

```typescript
// app/_layout.tsx
import * as Sentry from '@sentry/react-native';

Sentry.init({
  dsn: 'YOUR_DSN_HERE',
  tracesSampleRate: 1.0,
  _experiments: {
    profilesSampleRate: 1.0,
  },
  enableAutoSessionTracking: true,
  sessionTrackingIntervalMillis: 10000,
});

export default Sentry.wrap(RootLayout);
```

### Step 3: Upload Source Maps with EAS

```json
// eas.json
{
  "build": {
    "production": {
      "env": {
        "SENTRY_ORG": "your-org",
        "SENTRY_PROJECT": "your-project",
        "SENTRY_AUTH_TOKEN": "token-from-sentry"
      }
    }
  }
}
```

### Step 4: Capture Errors

```typescript
try {
  await fetchData();
} catch (error) {
  Sentry.captureException(error, {
    tags: { section: 'api' },
    extra: { endpoint: '/users' },
  });
}
```

## Guidelines

**Do:**
- Upload source maps for production builds
- Use breadcrumbs for debugging context
- Set user context for tracking
- Use performance monitoring

**Don't:**
- Don't log sensitive data
- Don't send all errors (filter noise)

## Resources

- [Sentry Expo Guide](references/sentry-expo-guide.md)
- [Source Maps](references/source-maps.md)

---

## Notes

- Source maps make stack traces readable
- Performance monitoring tracks slow operations
