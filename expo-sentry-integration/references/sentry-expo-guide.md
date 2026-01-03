# Complete Sentry Setup Guide for Expo

This guide provides comprehensive instructions for integrating Sentry error tracking and performance monitoring into Expo applications, covering both managed and bare workflows.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Error Tracking](#error-tracking)
- [Performance Monitoring](#performance-monitoring)
- [User Context and Breadcrumbs](#user-context-and-breadcrumbs)
- [Source Maps](#source-maps)
- [Release Management](#release-management)
- [Testing](#testing)
- [Production Deployment](#production-deployment)
- [Best Practices](#best-practices)

## Overview

Sentry provides production-grade error tracking and performance monitoring for Expo applications. It captures:

- **JavaScript errors** - Runtime errors, unhandled promise rejections
- **Native crashes** - iOS and Android native crashes
- **Performance metrics** - Screen load times, API latency, app startup
- **User context** - Session tracking, user identification, custom data
- **Breadcrumbs** - User actions and events leading to errors

### Expo Workflow Support

| Feature | Managed Workflow | Bare Workflow |
|---------|-----------------|---------------|
| Error tracking | ✅ Full support | ✅ Full support |
| Performance monitoring | ✅ Full support | ✅ Full support |
| Source maps | ✅ With EAS Build | ✅ With EAS Build |
| Native crash reporting | ⚠️ Limited (via sentry-expo) | ✅ Full support |
| Automatic upload | ✅ Yes | ✅ Yes |

## Prerequisites

Before installing Sentry, ensure you have:

1. **Sentry Account**
   - Sign up at [sentry.io](https://sentry.io)
   - Create a new project (platform: React Native)
   - Note your DSN (Data Source Name)

2. **Development Environment**
   - Expo SDK 50 or higher
   - Node.js 18+ and npm/yarn
   - EAS CLI installed (`npm install -g eas-cli`)

3. **Sentry CLI**
   ```bash
   npm install -g @sentry/cli
   sentry-cli login
   ```

4. **Auth Token**
   - Generate at: Sentry > Settings > Account > API > Auth Tokens
   - Required scopes: `project:releases`, `project:write`, `org:read`

## Installation

### Managed Workflow

For Expo managed workflow, use the `sentry-expo` package:

```bash
# Install sentry-expo
npx expo install sentry-expo

# Install peer dependencies
npx expo install @sentry/react-native expo-application expo-constants expo-device
```

### Bare Workflow

For bare workflow, use the full `@sentry/react-native` SDK:

```bash
# Install Sentry SDK
npx expo install @sentry/react-native

# Run Sentry Wizard for automatic configuration
npx @sentry/wizard@latest -i reactNative -p ios android

# Install iOS dependencies
npx pod-install
```

The wizard automatically configures:
- Metro bundler for source map generation
- iOS Xcode build phases for dSYM upload
- Android Gradle for ProGuard mapping upload
- Basic initialization code

## Configuration

### Environment Variables

Create `.env` file in your project root:

```bash
# Sentry DSN (public, can be committed)
EXPO_PUBLIC_SENTRY_DSN=https://[key]@[org].ingest.sentry.io/[project]

# Sentry credentials (NEVER commit these!)
SENTRY_ORG=your-organization-slug
SENTRY_PROJECT=your-project-name
SENTRY_AUTH_TOKEN=your-sentry-auth-token

# Build configuration
SENTRY_DISABLE_AUTO_UPLOAD=false
SENTRY_ALLOW_FAILURE=true
```

Add `.env` to `.gitignore`:
```bash
echo ".env" >> .gitignore
```

### App Configuration

Update `app.json` to include Sentry configuration:

```json
{
  "expo": {
    "name": "Your App Name",
    "slug": "your-app-slug",
    "version": "1.0.0",
    "extra": {
      "sentryDsn": process.env.EXPO_PUBLIC_SENTRY_DSN,
      "eas": {
        "projectId": "your-eas-project-id"
      }
    },
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
    },
    "ios": {
      "buildNumber": "1",
      "bundleIdentifier": "com.yourcompany.yourapp"
    },
    "android": {
      "versionCode": 1,
      "package": "com.yourcompany.yourapp"
    }
  }
}
```

### Initialize Sentry

#### Managed Workflow Initialization

```typescript
// app/_layout.tsx
import * as Sentry from 'sentry-expo';
import Constants from 'expo-constants';

Sentry.init({
  dsn: Constants.expoConfig?.extra?.sentryDsn,
  enableInExpoDevelopment: false,
  debug: __DEV__,

  // Environment
  environment: __DEV__ ? 'development' : 'production',

  // Release tracking
  release: Constants.expoConfig?.version,
  dist: Constants.expoConfig?.ios?.buildNumber || Constants.expoConfig?.android?.versionCode?.toString(),

  // Performance monitoring
  tracesSampleRate: __DEV__ ? 1.0 : 0.2,

  // Session tracking
  enableAutoSessionTracking: true,
  sessionTrackingIntervalMillis: 30000,

  // Integrations
  integrations: [
    new Sentry.Native.ReactNativeTracing({
      enableNativeFramesTracking: true,
      enableUserInteractionTracing: true,
    }),
  ],
});

export default function RootLayout() {
  return (
    // Your app layout
  );
}
```

#### Bare Workflow Initialization

```typescript
// app/_layout.tsx
import * as Sentry from '@sentry/react-native';
import Constants from 'expo-constants';
import { Platform } from 'react-native';

// Initialize Sentry before app loads
Sentry.init({
  dsn: Constants.expoConfig?.extra?.sentryDsn,

  // Don't send events in development
  beforeSend(event, hint) {
    if (__DEV__) {
      console.log('Sentry event (dev):', event);
      return null;
    }
    return event;
  },

  // Environment and release
  environment: __DEV__ ? 'development' : 'production',
  release: `${Constants.expoConfig?.slug}@${Constants.expoConfig?.version}`,
  dist: Platform.select({
    ios: Constants.expoConfig?.ios?.buildNumber,
    android: Constants.expoConfig?.android?.versionCode?.toString(),
  }),

  // Performance monitoring
  tracesSampleRate: __DEV__ ? 1.0 : 0.2,
  enableAutoPerformanceTracing: true,

  // Profiling (optional)
  _experiments: {
    profilesSampleRate: 0.1,
  },

  // Error tracking
  attachStacktrace: true,
  enableNative: true,
  enableNativeCrashHandling: true,
  enableNativeFramesTracking: true,

  // Breadcrumbs
  maxBreadcrumbs: 50,

  // Session tracking
  enableAutoSessionTracking: true,
  sessionTrackingIntervalMillis: 30000,

  // Integrations
  integrations: [
    new Sentry.ReactNativeTracing({
      enableUserInteractionTracing: true,
      enableNativeFramesTracking: true,
      enableAppStartTracking: true,
    }),
  ],
});

function RootLayout() {
  // Your app layout
  return <Stack />;
}

// Wrap root component
export default Sentry.wrap(RootLayout);
```

## Error Tracking

### Automatic Error Capture

Sentry automatically captures:
- Unhandled JavaScript exceptions
- Unhandled promise rejections
- Native crashes (iOS/Android)
- React component errors (with error boundaries)

### Manual Error Capture

```typescript
import * as Sentry from 'sentry-expo'; // or '@sentry/react-native'

// Capture exception
try {
  await fetchUserData();
} catch (error) {
  Sentry.captureException(error, {
    tags: {
      section: 'user-data',
      action: 'fetch',
    },
    extra: {
      userId: currentUser.id,
      timestamp: Date.now(),
    },
    level: 'error',
  });

  // Handle error locally
  showErrorToast('Failed to load user data');
}

// Capture message
Sentry.captureMessage('User completed onboarding', {
  level: 'info',
  tags: { feature: 'onboarding' },
});
```

### Error Boundaries

Create error boundary component:

```typescript
// components/ErrorBoundary.tsx
import React, { Component, ReactNode } from 'react';
import * as Sentry from 'sentry-expo';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';

interface Props {
  children: ReactNode;
  fallback?: (error: Error, resetError: () => void) => ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    Sentry.captureException(error, {
      contexts: {
        react: {
          componentStack: errorInfo.componentStack,
        },
      },
    });
  }

  resetError = () => {
    this.setState({ hasError: false, error: null });
  };

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback(this.state.error!, this.resetError);
      }

      return (
        <View style={styles.container}>
          <Text style={styles.title}>Something went wrong</Text>
          <Text style={styles.message}>
            {this.state.error?.message || 'An unexpected error occurred'}
          </Text>
          <TouchableOpacity style={styles.button} onPress={this.resetError}>
            <Text style={styles.buttonText}>Try Again</Text>
          </TouchableOpacity>
        </View>
      );
    }

    return this.props.children;
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 24,
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 8,
  },
  message: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    marginBottom: 24,
  },
  button: {
    backgroundColor: '#007AFF',
    paddingHorizontal: 24,
    paddingVertical: 12,
    borderRadius: 8,
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
});
```

Use in app:

```typescript
// app/_layout.tsx
import { ErrorBoundary } from '@/components/ErrorBoundary';

export default function RootLayout() {
  return (
    <ErrorBoundary>
      <Stack />
    </ErrorBoundary>
  );
}
```

### Error Filtering

Filter unwanted errors before sending to Sentry:

```typescript
Sentry.init({
  dsn: 'your-dsn',

  beforeSend(event, hint) {
    const error = hint.originalException;

    // Don't send development errors
    if (__DEV__) {
      console.log('Sentry event (dev):', event);
      return null;
    }

    // Filter network errors
    if (error && 'message' in error) {
      const message = (error as Error).message;
      if (message.includes('Network request failed')) {
        return null;
      }
    }

    // Scrub sensitive data
    if (event.request?.url) {
      event.request.url = event.request.url.replace(
        /token=[\w-]+/g,
        'token=[REDACTED]'
      );
    }

    // Add custom tags
    event.tags = {
      ...event.tags,
      platform: Platform.OS,
      version: Constants.expoConfig?.version,
    };

    return event;
  },
});
```

## Performance Monitoring

### Automatic Performance Tracking

Sentry automatically tracks:
- App startup time
- Screen navigation
- HTTP requests
- Native frame rates

### Custom Transactions

Track custom operations:

```typescript
import * as Sentry from 'sentry-expo';

async function loadUserDashboard() {
  const transaction = Sentry.startTransaction({
    name: 'Load User Dashboard',
    op: 'screen.load',
  });

  try {
    // Track individual operations
    const userSpan = transaction.startChild({
      op: 'fetch',
      description: 'Fetch user data',
    });
    const userData = await fetchUser();
    userSpan.finish();

    const postsSpan = transaction.startChild({
      op: 'fetch',
      description: 'Fetch user posts',
    });
    const posts = await fetchPosts();
    postsSpan.finish();

    transaction.setStatus('ok');
    return { userData, posts };
  } catch (error) {
    transaction.setStatus('internal_error');
    throw error;
  } finally {
    transaction.finish();
  }
}
```

### Screen Load Tracking Hook

```typescript
import { useEffect } from 'react';
import * as Sentry from 'sentry-expo';

export function useScreenPerformance(screenName: string) {
  useEffect(() => {
    const transaction = Sentry.startTransaction({
      name: `${screenName} Screen`,
      op: 'navigation',
    });

    const startTime = Date.now();

    return () => {
      const loadTime = Date.now() - startTime;
      transaction.setMeasurement('screen_load_time', loadTime, 'millisecond');
      transaction.setStatus('ok');
      transaction.finish();
    };
  }, [screenName]);
}

// Usage
function HomeScreen() {
  useScreenPerformance('Home');

  return <View>...</View>;
}
```

### API Request Tracking

```typescript
import * as Sentry from 'sentry-expo';

export async function trackedFetch<T>(
  url: string,
  options?: RequestInit
): Promise<T> {
  const transaction = Sentry.getCurrentHub().getScope()?.getTransaction();

  const span = transaction?.startChild({
    op: 'http.client',
    description: `${options?.method || 'GET'} ${url}`,
  });

  try {
    const response = await fetch(url, options);

    span?.setData('status_code', response.status);
    span?.setData('url', url);

    if (!response.ok) {
      span?.setStatus('internal_error');
      throw new Error(`HTTP ${response.status}`);
    }

    span?.setStatus('ok');
    return await response.json();
  } catch (error) {
    span?.setStatus('internal_error');
    throw error;
  } finally {
    span?.finish();
  }
}
```

## User Context and Breadcrumbs

### Setting User Context

```typescript
import * as Sentry from 'sentry-expo';

// Set user on login
function handleLogin(user: User) {
  Sentry.setUser({
    id: user.id,
    email: user.email,
    username: user.username,
    // Additional custom fields
    subscription: user.subscriptionTier,
  });
}

// Clear user on logout
function handleLogout() {
  Sentry.setUser(null);
}
```

### Adding Breadcrumbs

Track user actions and system events:

```typescript
import * as Sentry from 'sentry-expo';

// Navigation breadcrumb
function onNavigate(routeName: string) {
  Sentry.addBreadcrumb({
    category: 'navigation',
    message: `Navigated to ${routeName}`,
    level: 'info',
    timestamp: Date.now() / 1000,
  });
}

// User action breadcrumb
function onButtonPress(buttonId: string) {
  Sentry.addBreadcrumb({
    category: 'user-action',
    message: `Pressed button: ${buttonId}`,
    level: 'info',
    data: { screen: currentScreen },
  });
}

// API call breadcrumb
function logApiCall(endpoint: string, status: number) {
  Sentry.addBreadcrumb({
    category: 'http',
    type: 'http',
    data: { url: endpoint, status_code: status },
    level: status >= 400 ? 'error' : 'info',
  });
}
```

### Custom Context

Add custom debugging context:

```typescript
import * as Sentry from 'sentry-expo';

// Set app state context
Sentry.setContext('app_state', {
  isConnected: netInfo.isConnected,
  currentScreen: navigation.getCurrentRoute()?.name,
  hasToken: !!authToken,
});

// Set feature flags
Sentry.setContext('feature_flags', {
  newDesign: true,
  betaFeatures: false,
});

// Set tags for filtering
Sentry.setTag('user_type', 'premium');
Sentry.setTag('experiment_group', 'control');
```

## Source Maps

Source maps transform minified production stack traces into readable source code locations.

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
        "SENTRY_AUTH_TOKEN": "your-auth-token"
      }
    },
    "production": {
      "env": {
        "SENTRY_ORG": "your-org",
        "SENTRY_PROJECT": "your-project",
        "SENTRY_AUTH_TOKEN": "your-auth-token"
      },
      "autoIncrement": true
    }
  },
  "submit": {
    "production": {}
  }
}
```

### Automatic Upload

For `sentry-expo`, source maps are automatically uploaded on EAS builds when environment variables are configured.

For `@sentry/react-native`, the Sentry Wizard configures automatic upload via:
- iOS: Xcode build phase script
- Android: Gradle plugin

### Manual Upload

If automatic upload fails:

```bash
# Get release version
RELEASE="your-app@1.0.0"
DIST="1"

# Upload source maps
sentry-cli releases new "$RELEASE"
sentry-cli releases files "$RELEASE" upload-sourcemaps \
  --dist "$DIST" \
  --rewrite \
  --strip-prefix /path/to/project \
  dist/

# Finalize release
sentry-cli releases finalize "$RELEASE"
```

### Verify Upload

```bash
# List files for release
sentry-cli releases files "your-app@1.0.0" list

# Expected output:
# index.android.bundle
# index.android.bundle.map
# index.ios.bundle
# index.ios.bundle.map
```

### Troubleshooting Source Maps

See [source-maps.md](./source-maps.md) for detailed troubleshooting.

## Release Management

### Creating Releases

Releases associate errors with specific app versions:

```typescript
// app/_layout.tsx
import Constants from 'expo-constants';
import { Platform } from 'react-native';

const release = `${Constants.expoConfig?.slug}@${Constants.expoConfig?.version}`;
const dist = Platform.select({
  ios: Constants.expoConfig?.ios?.buildNumber,
  android: Constants.expoConfig?.android?.versionCode?.toString(),
});

Sentry.init({
  dsn: 'your-dsn',
  release,
  dist,
});
```

### Release Script

Create `scripts/create-sentry-release.js`:

```javascript
const { execSync } = require('child_process');
const fs = require('fs');

// Read app.json
const appJson = JSON.parse(fs.readFileSync('./app.json', 'utf8'));
const { slug, version } = appJson.expo;
const buildNumber = appJson.expo.ios?.buildNumber || appJson.expo.android?.versionCode;

const release = `${slug}@${version}`;
const dist = buildNumber?.toString();

console.log(`Creating Sentry release: ${release} (dist: ${dist})`);

// Create release
execSync(`sentry-cli releases new "${release}"`, { stdio: 'inherit' });

// Associate commits
execSync(`sentry-cli releases set-commits "${release}" --auto`, { stdio: 'inherit' });

// Finalize
execSync(`sentry-cli releases finalize "${release}"`, { stdio: 'inherit' });

console.log('Release created successfully!');
```

Add to `package.json`:

```json
{
  "scripts": {
    "sentry:release": "node scripts/create-sentry-release.js",
    "build:ios:prod": "npm run sentry:release && eas build --platform ios --profile production",
    "build:android:prod": "npm run sentry:release && eas build --platform android --profile production"
  }
}
```

## Testing

### Test Error Capture

```typescript
// utils/test-sentry.ts
import * as Sentry from 'sentry-expo';

export function testSentryIntegration() {
  console.log('Testing Sentry integration...');

  // 1. Test message
  Sentry.captureMessage('Sentry test message', 'info');

  // 2. Test exception
  try {
    throw new Error('Sentry test error');
  } catch (error) {
    Sentry.captureException(error);
  }

  // 3. Test breadcrumb
  Sentry.addBreadcrumb({
    category: 'test',
    message: 'Test breadcrumb',
    level: 'info',
  });

  // 4. Test user context
  Sentry.setUser({
    id: 'test-user-123',
    email: 'test@example.com',
  });

  // 5. Test transaction
  const transaction = Sentry.startTransaction({
    name: 'Test Transaction',
    op: 'test',
  });
  setTimeout(() => transaction.finish(), 100);

  console.log('Tests sent! Check Sentry dashboard in a few seconds.');
}
```

Call from debug screen:

```typescript
import { testSentryIntegration } from '@/utils/test-sentry';

function DebugScreen() {
  return (
    <Button
      title="Test Sentry"
      onPress={testSentryIntegration}
    />
  );
}
```

### Verify in Dashboard

1. Go to Sentry dashboard
2. Navigate to Issues
3. Look for test errors (usually appear within 30 seconds)
4. Check Performance tab for test transaction
5. Verify source maps show readable stack traces

## Production Deployment

### Pre-Deployment Checklist

- [ ] Update version in `app.json`
- [ ] Increment build numbers (iOS/Android)
- [ ] Set production sample rates (10-20%)
- [ ] Configure error filters
- [ ] Test Sentry integration
- [ ] Verify source map upload works
- [ ] Set up alerts in Sentry

### Build and Deploy

```bash
# Update version
# Edit app.json: version, buildNumber, versionCode

# Build production apps
eas build --platform ios --profile production
eas build --platform android --profile production

# Verify source maps uploaded
RELEASE="your-app@1.0.0"
sentry-cli releases files "$RELEASE" list

# Submit to stores
eas submit --platform ios
eas submit --platform android
```

### Monitor Release

1. **Check Release Health**
   - Sentry > Releases > Your version
   - Monitor crash-free session rate
   - Track new issues introduced

2. **Set Up Alerts**
   - Sentry > Alerts > Create Alert
   - Alert on new issues
   - Alert on crash rate threshold
   - Alert on performance degradation

3. **Review Issues**
   - Check for errors specific to new version
   - Prioritize by user impact
   - Use breadcrumbs to understand context

## Best Practices

### Error Handling

1. **Use Error Boundaries**
   - Wrap entire app in error boundary
   - Add boundaries around feature sections
   - Provide fallback UI for better UX

2. **Add Context**
   - Always include relevant tags
   - Add extra data for debugging
   - Set user context when available

3. **Filter Noise**
   - Filter known network errors
   - Exclude development events
   - Use sample rates appropriately

### Performance

1. **Use Sample Rates**
   - Development: 100% (1.0)
   - Staging: 50% (0.5)
   - Production: 10-20% (0.1-0.2)

2. **Track Key Operations**
   - Screen loads
   - API requests
   - Database queries
   - Heavy computations

3. **Set Performance Budgets**
   - Define acceptable load times
   - Alert on threshold violations
   - Monitor trends over time

### Security

1. **Protect Credentials**
   - Never commit auth tokens
   - Use environment variables
   - Rotate tokens periodically

2. **Scrub Sensitive Data**
   - Remove passwords, tokens, PII
   - Filter sensitive URLs
   - Sanitize user input

3. **Limit Data Collection**
   - Set `sendDefaultPii: false`
   - Review breadcrumb data
   - Implement data retention policies

### Cost Management

1. **Monitor Quota**
   - Check usage in Sentry dashboard
   - Set up quota alerts
   - Review monthly trends

2. **Optimize Volume**
   - Use appropriate sample rates
   - Filter noise and duplicates
   - Archive old releases

3. **Use Spike Protection**
   - Enable in project settings
   - Prevents quota overages
   - Throttles during traffic spikes

---

## Troubleshooting

### Common Issues

**Source maps not working**
- See [source-maps.md](./source-maps.md)

**Events not appearing**
- Check DSN is correct
- Verify `beforeSend` not filtering all events
- Check network connectivity
- Ensure not in development mode

**Build failures**
- Set `SENTRY_ALLOW_FAILURE=true`
- Check auth token scopes
- Verify environment variables

**Quota exceeded**
- Reduce sample rates
- Filter noisy errors
- Use inbound filters in Sentry UI

### Getting Help

- [Sentry Documentation](https://docs.sentry.io/platforms/react-native/)
- [Expo Forums](https://forums.expo.dev/)
- [Sentry Discord](https://discord.gg/sentry)
- [GitHub Issues](https://github.com/getsentry/sentry-react-native)

---

*Last updated: 2026-01-04*
