---
name: expo-sentry-integration
description: Monitor production errors and performance with Sentry integration for Expo apps including source maps and release tracking
license: MIT
compatibility: "Requires: Expo SDK 50+, Sentry account, @sentry/react-native package, EAS Build for source maps"
---

# Expo Sentry Integration

## Overview

Sentry provides comprehensive error tracking and performance monitoring for production Expo applications. It automatically captures crashes, exceptions, and performance metrics while providing readable stack traces through source maps and detailed context through breadcrumbs and custom data.

**Key Capabilities:**
- **Error Tracking**: Automatic capture of JavaScript errors, native crashes, and unhandled promise rejections
- **Performance Monitoring**: Trace transactions, measure app startup time, and monitor API performance
- **Release Health**: Track crash-free sessions and user adoption across app versions
- **Source Maps**: Transform minified production stack traces into readable source code locations
- **User Context**: Associate errors with specific users and add custom debugging context
- **Breadcrumbs**: Track user actions and system events leading up to errors
- **Screenshots & Replays**: Capture visual context when errors occur

**Platform Support:**
- iOS (via CocoaPods native integration)
- Android (via Gradle plugin)
- Expo managed workflow (SDK 50+)
- Expo bare workflow

## When to Use This Skill

### Use Sentry for:
- Deploying apps to production and need visibility into crashes
- Tracking error rates and crash-free session percentages
- Performance monitoring and identifying slow operations
- Debugging production issues with source maps and breadcrumbs
- Release tracking to correlate errors with specific app versions
- Understanding user impact of errors and performance issues
- Setting up alerts for critical errors or performance degradation
- Compliance requirements for error logging and monitoring

### Don't use Sentry for:
- Local development debugging (use Metro DevTools and React Native Debugger)
- Logging all console output (too much noise, use filters)
- Storing sensitive user data (implement data scrubbing)
- Real-time analytics (use dedicated analytics platforms)
- Replacing crash reporting entirely (complement with platform-specific tools)

## Workflow

### Step 1: Create Sentry Account and Project

Create a Sentry account and project before installation:

1. Sign up at [sentry.io](https://sentry.io)
2. Create new project with platform "React Native"
3. Note your DSN (Data Source Name) - looks like `https://[key]@[org].ingest.sentry.io/[project]`
4. Generate an auth token: Settings > Account > API > Auth Tokens
5. Set token scopes: `project:releases`, `project:write`, `org:read`

**Project Setup:**
```bash
# Create organization and project via Sentry web UI
# Or use Sentry CLI (optional)
sentry-cli login
sentry-cli organizations list
sentry-cli projects create -o your-org -n your-project-name --platform react-native
```

### Step 2: Install Sentry SDK

Install the Sentry React Native SDK in your Expo project:

```bash
# Install Sentry SDK for Expo
npx expo install @sentry/react-native

# Run Sentry Wizard for automatic configuration
npx @sentry/wizard@latest -i reactNative -p ios android

# For Expo managed workflow, use expo-sentry instead
npx expo install sentry-expo
```

The wizard configures:
- Metro bundler for source map generation
- iOS build phases for symbol upload
- Android Gradle for source map upload
- Basic Sentry initialization code

**Manual Installation (if wizard fails):**
```bash
# Install core package
npm install @sentry/react-native --save

# Link native dependencies (Expo bare workflow)
npx pod-install
```

### Step 3: Configure Sentry Initialization

Initialize Sentry in your app's entry point with comprehensive configuration:

```typescript
// app/_layout.tsx (Expo Router)
import * as Sentry from '@sentry/react-native';
import { isDevice } from 'expo-device';

// Initialize before app loads
Sentry.init({
  dsn: 'https://[key]@[org].ingest.sentry.io/[project]',

  // Enable performance monitoring
  tracesSampleRate: __DEV__ ? 1.0 : 0.2, // 20% in production

  // Enable profiling (optional)
  _experiments: {
    profilesSampleRate: 0.1, // 10% of transactions
  },

  // Session tracking
  enableAutoSessionTracking: true,
  sessionTrackingIntervalMillis: 30000, // 30 seconds

  // Environment and release
  environment: __DEV__ ? 'development' : 'production',
  release: 'your-app@1.0.0', // Update from app.json version
  dist: '1', // Increment for each build

  // Breadcrumbs
  maxBreadcrumbs: 50,

  // Attach stack traces to all messages
  attachStacktrace: true,

  // Enable native crashes
  enableNative: true,
  enableNativeCrashHandling: true,

  // Auto-detect native releases
  enableAutoPerformanceTracing: true,
  enableNativeFramesTracking: true,

  // Before send hook (filter/modify events)
  beforeSend(event, hint) {
    // Don't send events in development
    if (__DEV__) {
      console.log('Sentry event (dev):', event);
      return null;
    }

    // Filter out specific errors
    if (event.exception?.values?.[0]?.value?.includes('Network request failed')) {
      return null; // Don't send network errors
    }

    return event;
  },

  // Integrations
  integrations: [
    new Sentry.ReactNativeTracing({
      routingInstrumentation: Sentry.reactNavigationIntegration(),
      enableUserInteractionTracing: true,
      enableNativeFramesTracking: true,
    }),
  ],
});

// Wrap your root component
function RootLayout() {
  // Your app layout
  return <Stack />;
}

// Export wrapped component
export default Sentry.wrap(RootLayout);
```

**For Expo managed workflow (sentry-expo):**
```typescript
import * as Sentry from 'sentry-expo';

Sentry.init({
  dsn: 'your-dsn',
  enableInExpoDevelopment: false, // Don't send in Expo Go
  debug: __DEV__,
});
```

### Step 4: Configure Environment Variables

Store sensitive configuration in environment variables:

Create `.env` file:
```bash
# Sentry Configuration
EXPO_PUBLIC_SENTRY_DSN=https://[key]@[org].ingest.sentry.io/[project]
SENTRY_ORG=your-organization-slug
SENTRY_PROJECT=your-project-name
SENTRY_AUTH_TOKEN=your-auth-token-here

# Build configuration
SENTRY_DISABLE_AUTO_UPLOAD=false
```

Update `app.json`:
```json
{
  "expo": {
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
            "project": "your-project"
          }
        }
      ]
    }
  }
}
```

Access in code:
```typescript
import Constants from 'expo-constants';

const sentryDsn = Constants.expoConfig?.extra?.sentryDsn;
```

### Step 5: Configure Source Maps Upload

Configure EAS Build to automatically upload source maps:

**Update eas.json:**
```json
{
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal",
      "env": {
        "SENTRY_ORG": "your-org",
        "SENTRY_PROJECT": "your-project",
        "SENTRY_AUTH_TOKEN": "from-sentry-account"
      }
    },
    "production": {
      "env": {
        "SENTRY_ORG": "your-org",
        "SENTRY_PROJECT": "your-project",
        "SENTRY_AUTH_TOKEN": "from-sentry-account"
      },
      "autoIncrement": true
    }
  }
}
```

**Configure app.json for releases:**
```json
{
  "expo": {
    "version": "1.0.0",
    "ios": {
      "buildNumber": "1"
    },
    "android": {
      "versionCode": 1
    }
  }
}
```

**Create postPublish hook** (`scripts/sentry-upload.js`):
```javascript
const sentryRelease = require('@sentry/react-native/scripts/sentry-release');

sentryRelease({
  config: {
    organization: process.env.SENTRY_ORG,
    project: process.env.SENTRY_PROJECT,
    authToken: process.env.SENTRY_AUTH_TOKEN,
  },
  release: `${process.env.APP_VERSION}+${process.env.APP_BUILD}`,
  dist: process.env.APP_BUILD,
});
```

### Step 6: Implement Error Boundaries

Create error boundaries to catch React errors and report to Sentry:

```typescript
// components/ErrorBoundary.tsx
import React from 'react';
import * as Sentry from '@sentry/react-native';
import { View, Text, Button, StyleSheet } from 'react-native';

interface Props {
  children: React.ReactNode;
  fallback?: React.ComponentType<{ error: Error; resetError: () => void }>;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

class ErrorBoundary extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    // Log error to Sentry
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
      const FallbackComponent = this.props.fallback;

      if (FallbackComponent) {
        return (
          <FallbackComponent
            error={this.state.error!}
            resetError={this.resetError}
          />
        );
      }

      return (
        <View style={styles.container}>
          <Text style={styles.title}>Something went wrong</Text>
          <Text style={styles.message}>{this.state.error?.message}</Text>
          <Button title="Try Again" onPress={this.resetError} />
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
    padding: 20,
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  message: {
    fontSize: 14,
    color: '#666',
    marginBottom: 20,
    textAlign: 'center',
  },
});

export default ErrorBoundary;
```

**Use in app:**
```typescript
// app/_layout.tsx
import ErrorBoundary from '@/components/ErrorBoundary';

export default function RootLayout() {
  return (
    <ErrorBoundary>
      <Stack />
    </ErrorBoundary>
  );
}
```

### Step 7: Add Breadcrumbs and Context

Implement breadcrumbs to track user actions and add context to errors:

```typescript
// utils/sentry.ts
import * as Sentry from '@sentry/react-native';

/**
 * Add navigation breadcrumb
 */
export function logNavigation(routeName: string, params?: any) {
  Sentry.addBreadcrumb({
    category: 'navigation',
    message: `Navigated to ${routeName}`,
    level: 'info',
    data: params,
  });
}

/**
 * Add user action breadcrumb
 */
export function logUserAction(action: string, data?: any) {
  Sentry.addBreadcrumb({
    category: 'user-action',
    message: action,
    level: 'info',
    data,
    timestamp: Date.now() / 1000,
  });
}

/**
 * Add API call breadcrumb
 */
export function logApiCall(url: string, method: string, status?: number) {
  Sentry.addBreadcrumb({
    category: 'http',
    type: 'http',
    data: {
      url,
      method,
      status_code: status,
    },
    level: status && status >= 400 ? 'error' : 'info',
  });
}

/**
 * Set user context
 */
export function setUserContext(user: {
  id: string;
  email?: string;
  username?: string;
}) {
  Sentry.setUser({
    id: user.id,
    email: user.email,
    username: user.username,
  });
}

/**
 * Clear user context on logout
 */
export function clearUserContext() {
  Sentry.setUser(null);
}

/**
 * Set custom context
 */
export function setCustomContext(key: string, context: any) {
  Sentry.setContext(key, context);
}

/**
 * Add tag for filtering
 */
export function setTag(key: string, value: string) {
  Sentry.setTag(key, value);
}
```

**Usage in app:**
```typescript
import { logUserAction, logApiCall, setUserContext } from '@/utils/sentry';

// Track user actions
function handleButtonPress() {
  logUserAction('Button pressed', { screen: 'Home', buttonId: 'submit' });
  // ... button logic
}

// Track API calls
async function fetchData() {
  try {
    const response = await fetch('https://api.example.com/data');
    logApiCall('https://api.example.com/data', 'GET', response.status);
    return await response.json();
  } catch (error) {
    logApiCall('https://api.example.com/data', 'GET');
    throw error;
  }
}

// Set user on login
function handleLogin(user) {
  setUserContext({
    id: user.id,
    email: user.email,
    username: user.username,
  });
}
```

### Step 8: Implement Performance Monitoring

Track performance with custom transactions and spans:

```typescript
// utils/performance.ts
import * as Sentry from '@sentry/react-native';

/**
 * Track screen load performance
 */
export async function trackScreenLoad(
  screenName: string,
  loadFunction: () => Promise<void>
) {
  const transaction = Sentry.startTransaction({
    name: `${screenName} Load`,
    op: 'screen.load',
  });

  try {
    await loadFunction();
    transaction.setStatus('ok');
  } catch (error) {
    transaction.setStatus('unknown_error');
    throw error;
  } finally {
    transaction.finish();
  }
}

/**
 * Track API request performance
 */
export async function trackApiRequest<T>(
  endpoint: string,
  requestFn: () => Promise<T>
): Promise<T> {
  const transaction = Sentry.getCurrentHub().getScope()?.getTransaction();

  const span = transaction?.startChild({
    op: 'http.client',
    description: `API ${endpoint}`,
  });

  try {
    const result = await requestFn();
    span?.setStatus('ok');
    return result;
  } catch (error) {
    span?.setStatus('internal_error');
    throw error;
  } finally {
    span?.finish();
  }
}

/**
 * Measure operation duration
 */
export async function measureOperation<T>(
  operationName: string,
  operation: () => Promise<T>
): Promise<T> {
  const transaction = Sentry.startTransaction({
    name: operationName,
    op: 'custom',
  });

  try {
    const result = await operation();
    transaction.setStatus('ok');
    return result;
  } catch (error) {
    transaction.setStatus('unknown_error');
    throw error;
  } finally {
    transaction.finish();
  }
}
```

**Track navigation performance:**
```typescript
import { useEffect } from 'react';
import * as Sentry from '@sentry/react-native';

export function useScreenTracking(screenName: string) {
  useEffect(() => {
    const transaction = Sentry.startTransaction({
      name: screenName,
      op: 'navigation',
    });

    return () => {
      transaction.finish();
    };
  }, [screenName]);
}
```

### Step 9: Configure Release Management

Set up release tracking to correlate errors with app versions:

```typescript
// scripts/create-sentry-release.js
const { execSync } = require('child_process');
const fs = require('fs');

// Read version from app.json
const appJson = JSON.parse(fs.readFileSync('./app.json', 'utf8'));
const version = appJson.expo.version;
const buildNumber = appJson.expo.ios.buildNumber;
const release = `${appJson.expo.slug}@${version}+${buildNumber}`;

console.log('Creating Sentry release:', release);

// Create release
execSync(
  `sentry-cli releases new "${release}"`,
  { stdio: 'inherit' }
);

// Set commits
execSync(
  `sentry-cli releases set-commits "${release}" --auto`,
  { stdio: 'inherit' }
);

// Finalize release
execSync(
  `sentry-cli releases finalize "${release}"`,
  { stdio: 'inherit' }
);

console.log('Release created successfully');
```

**Add to package.json:**
```json
{
  "scripts": {
    "sentry:release": "node scripts/create-sentry-release.js",
    "build:ios": "npm run sentry:release && eas build --platform ios",
    "build:android": "npm run sentry:release && eas build --platform android"
  }
}
```

### Step 10: Test Integration and Deploy

Verify Sentry integration before deploying to production:

```typescript
// utils/test-sentry.ts
import * as Sentry from '@sentry/react-native';

/**
 * Test Sentry integration (development only)
 */
export function testSentryIntegration() {
  if (!__DEV__) {
    console.warn('Sentry test should only run in development');
    return;
  }

  console.log('Testing Sentry integration...');

  // Test 1: Capture message
  Sentry.captureMessage('Sentry test message', 'info');

  // Test 2: Capture exception
  try {
    throw new Error('Sentry test error');
  } catch (error) {
    Sentry.captureException(error);
  }

  // Test 3: Add breadcrumb
  Sentry.addBreadcrumb({
    category: 'test',
    message: 'Test breadcrumb',
    level: 'info',
  });

  // Test 4: Set user
  Sentry.setUser({
    id: 'test-user',
    email: 'test@example.com',
  });

  // Test 5: Test transaction
  const transaction = Sentry.startTransaction({
    name: 'Test Transaction',
    op: 'test',
  });

  setTimeout(() => {
    transaction.finish();
  }, 100);

  console.log('Sentry tests sent. Check Sentry dashboard.');
}
```

**Production deployment checklist:**
```bash
# 1. Update version in app.json
# 2. Build with EAS
eas build --platform ios --profile production
eas build --platform android --profile production

# 3. Verify source maps uploaded
sentry-cli releases files [release] list

# 4. Submit to stores
eas submit --platform ios
eas submit --platform android

# 5. Monitor Sentry dashboard for errors
```

## Examples

### Basic Error Capture

```typescript
import * as Sentry from '@sentry/react-native';

// Capture exception with context
try {
  await processPayment(amount);
} catch (error) {
  Sentry.captureException(error, {
    tags: {
      section: 'payment',
      amount: amount.toString(),
    },
    extra: {
      userId: currentUser.id,
      timestamp: new Date().toISOString(),
    },
    level: 'error',
  });

  // Show user-friendly error
  Alert.alert('Payment Failed', 'Please try again later');
}
```

### Custom Error Boundary with Retry

```typescript
import React, { useState } from 'react';
import * as Sentry from '@sentry/react-native';
import { View, Text, Button } from 'react-native';

function ErrorFallback({
  error,
  resetError
}: {
  error: Error;
  resetError: () => void;
}) {
  const [hasReported, setHasReported] = useState(false);

  const reportFeedback = () => {
    Sentry.captureUserFeedback({
      event_id: Sentry.lastEventId() || '',
      name: 'User',
      email: 'user@example.com',
      comments: 'App crashed while using feature X',
    });
    setHasReported(true);
  };

  return (
    <View style={{ flex: 1, justifyContent: 'center', padding: 20 }}>
      <Text style={{ fontSize: 20, fontWeight: 'bold', marginBottom: 10 }}>
        Oops! Something went wrong
      </Text>
      <Text style={{ marginBottom: 20, color: '#666' }}>
        {error.message}
      </Text>
      <Button title="Try Again" onPress={resetError} />
      {!hasReported && (
        <Button title="Report Problem" onPress={reportFeedback} />
      )}
    </View>
  );
}

export default function App() {
  return (
    <ErrorBoundary fallback={ErrorFallback}>
      <YourApp />
    </ErrorBoundary>
  );
}
```

### Breadcrumb Integration with Navigation

```typescript
// app/navigation.tsx
import { useNavigationContainerRef } from 'expo-router';
import * as Sentry from '@sentry/react-native';

export function NavigationWrapper() {
  const navigationRef = useNavigationContainerRef();

  const routingInstrumentation = new Sentry.ReactNavigationInstrumentation();

  Sentry.wrap(() => {
    return (
      <NavigationContainer
        ref={navigationRef}
        onReady={() => {
          routingInstrumentation.registerNavigationContainer(navigationRef);
        }}
      >
        <Stack />
      </NavigationContainer>
    );
  });
}
```

### API Client with Sentry Integration

```typescript
// services/api.ts
import * as Sentry from '@sentry/react-native';

class ApiClient {
  private baseUrl: string;

  constructor(baseUrl: string) {
    this.baseUrl = baseUrl;
  }

  async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const url = `${this.baseUrl}${endpoint}`;
    const transaction = Sentry.getCurrentHub().getScope()?.getTransaction();

    const span = transaction?.startChild({
      op: 'http.client',
      description: `${options.method || 'GET'} ${endpoint}`,
    });

    // Add breadcrumb
    Sentry.addBreadcrumb({
      category: 'http',
      type: 'http',
      data: {
        url,
        method: options.method || 'GET',
      },
      level: 'info',
    });

    try {
      const response = await fetch(url, {
        ...options,
        headers: {
          'Content-Type': 'application/json',
          ...options.headers,
        },
      });

      span?.setData('status_code', response.status);

      if (!response.ok) {
        const error = new Error(`HTTP ${response.status}: ${response.statusText}`);

        Sentry.captureException(error, {
          tags: {
            endpoint,
            status: response.status.toString(),
          },
          extra: {
            url,
            method: options.method,
          },
        });

        span?.setStatus('internal_error');
        throw error;
      }

      const data = await response.json();
      span?.setStatus('ok');
      return data;
    } catch (error) {
      span?.setStatus('internal_error');

      Sentry.captureException(error, {
        tags: {
          endpoint,
          error_type: 'network',
        },
      });

      throw error;
    } finally {
      span?.finish();
    }
  }

  async get<T>(endpoint: string): Promise<T> {
    return this.request<T>(endpoint, { method: 'GET' });
  }

  async post<T>(endpoint: string, data: any): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: JSON.stringify(data),
    });
  }
}

export const api = new ApiClient('https://api.example.com');
```

### Performance Monitoring Hook

```typescript
// hooks/usePerformanceTracking.ts
import { useEffect, useRef } from 'react';
import * as Sentry from '@sentry/react-native';

export function usePerformanceTracking(screenName: string) {
  const transactionRef = useRef<any>(null);

  useEffect(() => {
    // Start transaction
    transactionRef.current = Sentry.startTransaction({
      name: screenName,
      op: 'screen.load',
    });

    const startTime = Date.now();

    return () => {
      // Finish transaction
      const loadTime = Date.now() - startTime;

      transactionRef.current?.setMeasurement('screen_load_time', loadTime, 'millisecond');
      transactionRef.current?.setStatus('ok');
      transactionRef.current?.finish();
    };
  }, [screenName]);

  const trackOperation = (operationName: string, operation: () => void) => {
    const span = transactionRef.current?.startChild({
      op: 'operation',
      description: operationName,
    });

    try {
      operation();
      span?.setStatus('ok');
    } catch (error) {
      span?.setStatus('internal_error');
      throw error;
    } finally {
      span?.finish();
    }
  };

  return { trackOperation };
}

// Usage
function HomeScreen() {
  const { trackOperation } = usePerformanceTracking('Home Screen');

  const handleLoadData = async () => {
    trackOperation('Load user data', async () => {
      await fetchUserData();
    });
  };

  return <View>...</View>;
}
```

### User Context Management

```typescript
// contexts/SentryContext.tsx
import React, { createContext, useContext, useCallback } from 'react';
import * as Sentry from '@sentry/react-native';

interface SentryContextType {
  setUser: (user: { id: string; email?: string; username?: string }) => void;
  clearUser: () => void;
  addBreadcrumb: (message: string, category: string, data?: any) => void;
  captureError: (error: Error, context?: any) => void;
}

const SentryContext = createContext<SentryContextType | undefined>(undefined);

export function SentryProvider({ children }: { children: React.ReactNode }) {
  const setUser = useCallback((user: { id: string; email?: string; username?: string }) => {
    Sentry.setUser({
      id: user.id,
      email: user.email,
      username: user.username,
    });
  }, []);

  const clearUser = useCallback(() => {
    Sentry.setUser(null);
  }, []);

  const addBreadcrumb = useCallback((
    message: string,
    category: string,
    data?: any
  ) => {
    Sentry.addBreadcrumb({
      message,
      category,
      data,
      level: 'info',
      timestamp: Date.now() / 1000,
    });
  }, []);

  const captureError = useCallback((error: Error, context?: any) => {
    Sentry.captureException(error, {
      extra: context,
    });
  }, []);

  return (
    <SentryContext.Provider
      value={{ setUser, clearUser, addBreadcrumb, captureError }}
    >
      {children}
    </SentryContext.Provider>
  );
}

export function useSentry() {
  const context = useContext(SentryContext);
  if (!context) {
    throw new Error('useSentry must be used within SentryProvider');
  }
  return context;
}
```

### Advanced Error Filtering

```typescript
// app/_layout.tsx
import * as Sentry from '@sentry/react-native';

Sentry.init({
  dsn: 'your-dsn',

  beforeSend(event, hint) {
    const error = hint.originalException;

    // Filter out specific error messages
    const ignoredErrors = [
      'Network request failed',
      'Timeout',
      'AbortError',
    ];

    if (error && typeof error === 'object' && 'message' in error) {
      const errorMessage = error.message as string;
      if (ignoredErrors.some(ignored => errorMessage.includes(ignored))) {
        return null; // Don't send to Sentry
      }
    }

    // Scrub sensitive data
    if (event.request?.url) {
      event.request.url = event.request.url.replace(/token=[\w-]+/, 'token=[REDACTED]');
    }

    // Add custom context
    event.tags = {
      ...event.tags,
      app_version: Constants.expoConfig?.version,
      platform: Platform.OS,
    };

    return event;
  },

  beforeBreadcrumb(breadcrumb, hint) {
    // Filter out console breadcrumbs in production
    if (breadcrumb.category === 'console' && !__DEV__) {
      return null;
    }

    // Scrub sensitive data from breadcrumbs
    if (breadcrumb.data?.password) {
      breadcrumb.data.password = '[REDACTED]';
    }

    return breadcrumb;
  },
});
```

## Guidelines

### Do:

1. **Upload source maps for production builds** - Essential for readable stack traces
2. **Use environment-specific configuration** - Different settings for dev/staging/production
3. **Implement error boundaries** - Catch React errors and prevent white screens
4. **Add breadcrumbs for user actions** - Track navigation, button presses, API calls
5. **Set user context on login** - Associate errors with specific users
6. **Filter sensitive data** - Scrub passwords, tokens, PII before sending
7. **Use performance monitoring** - Track screen loads, API calls, and slow operations
8. **Tag errors appropriately** - Use tags for filtering and grouping in Sentry
9. **Test integration before deploying** - Verify errors appear in Sentry dashboard
10. **Set up alerts for critical errors** - Get notified of crashes and performance issues
11. **Use release tracking** - Correlate errors with app versions
12. **Implement beforeSend hooks** - Filter noise and enrich events
13. **Add custom context** - Include app state, device info, feature flags
14. **Track navigation performance** - Monitor screen transition times
15. **Document your Sentry setup** - Maintain configuration docs for team

### Don't:

1. **Don't send events in development** - Use `__DEV__` check or `enableInExpoDevelopment: false`
2. **Don't log all console output** - Creates noise and quota issues
3. **Don't send sensitive data** - PII, passwords, tokens should be scrubbed
4. **Don't ignore source map configuration** - Unreadable stack traces are useless
5. **Don't use 100% sample rate in production** - Reduce to 10-20% for performance
6. **Don't forget to set release/dist** - Required for matching source maps
7. **Don't send network errors without filtering** - Creates too much noise
8. **Don't skip error boundaries** - Uncaught errors cause app crashes
9. **Don't hardcode DSN and tokens** - Use environment variables
10. **Don't forget platform-specific setup** - iOS and Android have different configs
11. **Don't ignore quota limits** - Monitor event volume to avoid bill shock
12. **Don't send duplicate events** - Implement deduplication logic
13. **Don't skip testing** - Always verify integration works before production
14. **Don't forget to clear user context on logout** - Prevents misattribution
15. **Don't rely solely on Sentry** - Complement with device logs and crash reports

## Tools & Commands

### Installation Commands

```bash
# Install Sentry SDK for Expo
npx expo install @sentry/react-native

# Install for Expo managed workflow
npx expo install sentry-expo

# Run Sentry Wizard (automatic setup)
npx @sentry/wizard@latest -i reactNative -p ios android

# Install Sentry CLI globally
npm install -g @sentry/cli

# Login to Sentry CLI
sentry-cli login
```

### Release Management

```bash
# Create new release
sentry-cli releases new "my-app@1.0.0+1"

# Upload source maps
sentry-cli releases files "my-app@1.0.0+1" upload-sourcemaps \
  --dist 1 \
  --rewrite \
  dist/

# Associate commits
sentry-cli releases set-commits "my-app@1.0.0+1" --auto

# Finalize release
sentry-cli releases finalize "my-app@1.0.0+1"

# Deploy release
sentry-cli releases deploys "my-app@1.0.0+1" new -e production

# List releases
sentry-cli releases list

# Delete release
sentry-cli releases delete "my-app@1.0.0+1"
```

### Source Map Debugging

```bash
# List uploaded files for release
sentry-cli releases files "my-app@1.0.0+1" list

# Validate source maps
sentry-cli sourcemaps explain [event-id]

# Check if source maps are working
sentry-cli releases files "my-app@1.0.0+1" upload-sourcemaps \
  --validate \
  dist/

# Debug source map upload
SENTRY_LOG_LEVEL=debug sentry-cli releases files "my-app@1.0.0+1" upload-sourcemaps dist/
```

### EAS Build Configuration

```bash
# Build with Sentry source maps
eas build --platform ios --profile production

# Build without uploading source maps
SENTRY_DISABLE_AUTO_UPLOAD=true eas build --platform ios

# Check build logs for Sentry upload
eas build:view [build-id]

# Download build artifacts
eas build:download [build-id]
```

### Testing Commands

```typescript
// Test error capture
Sentry.captureException(new Error('Test error'));

// Test message capture
Sentry.captureMessage('Test message', 'info');

// Test breadcrumbs
Sentry.addBreadcrumb({ message: 'Test breadcrumb' });

// Get last event ID
const eventId = Sentry.lastEventId();

// Test crash (native)
Sentry.nativeCrash();
```

### Environment Variables

```bash
# Required for source map upload
export SENTRY_ORG=your-organization
export SENTRY_PROJECT=your-project
export SENTRY_AUTH_TOKEN=your-auth-token

# Optional configuration
export SENTRY_DISABLE_AUTO_UPLOAD=false
export SENTRY_LOG_LEVEL=info
export SENTRY_ALLOW_FAILURE=true # Continue build on upload failure
```

### Monitoring Commands

```bash
# View project issues
sentry-cli issues list --project your-project

# View project events
sentry-cli events list --project your-project

# Get project stats
sentry-cli stats --project your-project

# Check quota usage
sentry-cli stats
```

## Troubleshooting

### Source Maps Not Working

**Issue:** Stack traces show minified code instead of source code

**Symptoms:**
- Error locations show bundle files like `index.android.bundle:1:234567`
- Function names are mangled like `a`, `b`, `c`
- Can't identify actual source files

**Solutions:**

1. **Verify release and dist match:**
```typescript
// Ensure these match in init() and upload
Sentry.init({
  release: 'my-app@1.0.0',
  dist: '1',
});
```

2. **Check source maps uploaded:**
```bash
# List files for release
sentry-cli releases files "my-app@1.0.0" list

# Should show .map files
# index.android.bundle
# index.android.bundle.map
```

3. **Verify bundle names match:**
```bash
# Stack trace shows: index.android.bundle:123
# Uploaded file must be: index.android.bundle.map
```

4. **Enable RewriteFrames:**
```typescript
Sentry.init({
  integrations: [
    new Sentry.ReactNativeTracing({
      // ... other options
    }),
  ],
});
```

5. **Check Hermes configuration:**
```json
// app.json
{
  "expo": {
    "jsEngine": "hermes" // or "jsc"
  }
}
```

6. **Manual upload if auto-upload fails:**
```bash
sentry-cli releases files "my-app@1.0.0" upload-sourcemaps \
  --dist 1 \
  --rewrite \
  --strip-prefix /path/to/project \
  dist/
```

7. **Debug with explain command:**
```bash
sentry-cli sourcemaps explain [event-id]
```

### Errors Not Appearing in Sentry

**Issue:** Events not showing up in Sentry dashboard

**Solutions:**

1. **Check DSN is correct:**
```typescript
// Verify DSN format
const dsn = 'https://[key]@[org].ingest.sentry.io/[project]';
```

2. **Verify not in development mode:**
```typescript
Sentry.init({
  dsn: 'your-dsn',
  beforeSend(event) {
    if (__DEV__) return null; // Remove this to test
    return event;
  },
});
```

3. **Check network connectivity:**
```bash
# Test Sentry endpoint
curl -X POST https://[org].ingest.sentry.io/api/[project]/store/ \
  -H "X-Sentry-Auth: Sentry sentry_key=[key]"
```

4. **Verify event sent:**
```typescript
try {
  throw new Error('Test error');
} catch (error) {
  const eventId = Sentry.captureException(error);
  console.log('Event ID:', eventId); // Should log event ID
}
```

5. **Check beforeSend not filtering:**
```typescript
beforeSend(event, hint) {
  console.log('Sending event:', event);
  return event; // Don't return null
}
```

6. **Verify sample rate:**
```typescript
Sentry.init({
  tracesSampleRate: 1.0, // Set to 1.0 for testing
});
```

### Performance Monitoring Issues

**Issue:** Transactions not appearing or incomplete

**Solutions:**

1. **Enable tracing:**
```typescript
Sentry.init({
  tracesSampleRate: 1.0, // Must be > 0
  enableAutoPerformanceTracing: true,
});
```

2. **Add routing instrumentation:**
```typescript
import { ReactNavigationInstrumentation } from '@sentry/react-native';

const routingInstrumentation = new ReactNavigationInstrumentation();

Sentry.init({
  integrations: [
    new Sentry.ReactNativeTracing({
      routingInstrumentation,
    }),
  ],
});
```

3. **Manually finish transactions:**
```typescript
const transaction = Sentry.startTransaction({ name: 'test' });
// ... do work
transaction.finish(); // Don't forget this!
```

4. **Check transaction timeout:**
```typescript
// Transactions auto-finish after 30s by default
const transaction = Sentry.startTransaction({
  name: 'test',
  trimEnd: true, // Auto-trim on finish
});
```

### Build Failures with Sentry

**Issue:** EAS build fails during Sentry upload

**Solutions:**

1. **Allow failure on upload error:**
```bash
# In eas.json env
SENTRY_ALLOW_FAILURE=true
```

2. **Check auth token scopes:**
- Required: `project:releases`, `project:write`, `org:read`

3. **Verify environment variables:**
```json
// eas.json
{
  "build": {
    "production": {
      "env": {
        "SENTRY_ORG": "your-org",
        "SENTRY_PROJECT": "your-project",
        "SENTRY_AUTH_TOKEN": "your-token"
      }
    }
  }
}
```

4. **Check build logs:**
```bash
eas build:view [build-id]
# Look for Sentry upload errors
```

5. **Disable auto-upload for testing:**
```bash
SENTRY_DISABLE_AUTO_UPLOAD=true eas build --platform ios
```

### Android-Specific Issues

**Issue:** Android builds failing or source maps not uploading

**Solutions:**

1. **Update Sentry Gradle plugin:**
```gradle
// android/build.gradle
buildscript {
  dependencies {
    classpath 'io.sentry:sentry-android-gradle-plugin:3.+'
  }
}
```

2. **Apply plugin in app/build.gradle:**
```gradle
apply plugin: 'io.sentry.android.gradle'

sentry {
  autoUploadProguardMapping = true
  uploadNativeSymbols = true
}
```

3. **Check ProGuard mapping:**
```gradle
android {
  buildTypes {
    release {
      minifyEnabled true
      proguardFiles getDefaultProguardFile('proguard-android.txt')
    }
  }
}
```

### iOS-Specific Issues

**Issue:** iOS builds failing or dSYM upload issues

**Solutions:**

1. **Check Xcode build phase:**
```bash
# Should have Sentry upload phase
# Run Script: /path/to/sentry-cli upload-dif
```

2. **Verify bundle ID:**
```typescript
Sentry.init({
  dist: Platform.OS === 'ios' ? appConfig.ios.buildNumber : appConfig.android.versionCode,
});
```

3. **Upload dSYM manually:**
```bash
sentry-cli upload-dif --org your-org --project your-project /path/to/dSYMs
```

### Quota Exceeded

**Issue:** Hitting Sentry quota limits

**Solutions:**

1. **Reduce sample rate:**
```typescript
Sentry.init({
  tracesSampleRate: 0.1, // 10% instead of 100%
});
```

2. **Filter noise:**
```typescript
beforeSend(event) {
  // Filter network errors
  if (event.exception?.values?.[0]?.value?.includes('Network')) {
    return null;
  }
  return event;
}
```

3. **Use inbound filters in Sentry UI:**
- Settings > Inbound Filters
- Filter by browser, release, error message

4. **Implement rate limiting:**
```typescript
let errorCount = 0;
const MAX_ERRORS_PER_MINUTE = 10;

beforeSend(event) {
  errorCount++;
  if (errorCount > MAX_ERRORS_PER_MINUTE) {
    return null;
  }
  return event;
}

// Reset counter every minute
setInterval(() => { errorCount = 0; }, 60000);
```

## Resources

### Official Documentation
- [Sentry React Native Documentation](https://docs.sentry.io/platforms/react-native/)
- [Sentry Expo Integration](https://docs.sentry.io/platforms/react-native/manual-setup/expo/)
- [Source Maps Guide](references/source-maps.md)
- [Complete Expo Setup](references/sentry-expo-guide.md)

### Related Tools
- [@sentry/react-native](https://www.npmjs.com/package/@sentry/react-native) - Core SDK
- [sentry-expo](https://www.npmjs.com/package/sentry-expo) - Expo-specific integration
- [@sentry/cli](https://www.npmjs.com/package/@sentry/cli) - Command-line tool
- [Sentry Wizard](https://github.com/getsentry/sentry-wizard) - Automatic setup

### Best Practices
- [Error Monitoring Best Practices](https://docs.sentry.io/product/sentry-basics/)
- [Performance Monitoring Guide](https://docs.sentry.io/product/performance/)
- [Release Health](https://docs.sentry.io/product/releases/health/)

---

## Notes

### Platform Differences

**iOS:**
- Requires CocoaPods installation (`npx pod-install`)
- dSYM upload for native crash symbolication
- Xcode build phases for automatic upload
- NSFaceIDUsageDescription for crash reports with device context

**Android:**
- Gradle plugin for automatic configuration
- ProGuard mapping upload for obfuscated code
- Native symbol upload for NDK crashes
- Requires Sentry Gradle plugin in build.gradle

### Performance Impact

- Minimal overhead when properly configured (<1% CPU/memory)
- Source map upload happens during build, not runtime
- Sample rates control data volume and performance
- Breadcrumbs stored in memory (configurable limit)

### Security Considerations

1. **Never commit auth tokens** - Use environment variables
2. **Scrub sensitive data** - Implement beforeSend filters
3. **Limit PII collection** - Set sendDefaultPii: false
4. **Use HTTPS** - Sentry endpoints use HTTPS by default
5. **Implement data retention** - Configure in Sentry project settings

### Cost Management

- Free tier: 5,000 errors + 10,000 transactions per month
- Monitor quota usage in Sentry dashboard
- Implement sampling to reduce event volume
- Filter noise with beforeSend and inbound filters
- Use spike protection to prevent bill shock
