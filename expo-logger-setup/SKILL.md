---
name: expo-logger-setup
description: Install and configure a structured logging system with categories, emojis, and zero production overhead for Expo/React Native projects
license: MIT
compatibility: "Requires: Expo/React Native project, TypeScript recommended"
---

# Expo Logger Setup

## Overview

Set up a production-ready structured logging system with category-based organization, colored emoji output, and automatic production stripping. Inspired by FreqWatch's logging architecture.

## When to Use This Skill

- Starting a new Expo project that needs proper logging
- Replacing scattered `console.log` statements with structured logging
- Need to filter/debug specific parts of your app (API, WebSocket, Auth, etc.)
- Want zero-overhead logging in production builds
- Integrating with monitoring tools like Sentry

## Workflow

### Step 1: Copy Logger Templates

Copy all logger files to your project:

```bash
# Create logger directory
mkdir -p src/utils/logger

# Copy templates
cp expo-logger-setup/templates/* src/utils/logger/
```

**Files copied:**
- `Logger.ts` - Main logger class (singleton pattern)
- `formatters.ts` - Console and file formatters
- `types.ts` - TypeScript types and category definitions
- `index.ts` - Public exports

### Step 2: Configure Categories

Edit `src/utils/logger/types.ts` to customize categories for your app:

```typescript
export type LogCategory =
  | 'api'           // HTTP/REST API calls
  | 'websocket'     // WebSocket connections
  | 'auth'          // Authentication flows
  | 'storage'       // MMKV/SecureStore operations
  | 'navigation'    // Screen navigation
  | 'ui'            // Component lifecycle
  | 'revenuecat'    // In-app purchases
  | 'webhook'       // Webhook notifications
  // Add your custom categories:
  | 'database'
  | 'analytics'
  | 'push-notifications';

export const CATEGORIES: Record<LogCategory, CategoryMeta> = {
  // ... existing categories
  database: { emoji: '🗄️', name: 'Database', color: '\x1b[36m' },
  analytics: { emoji: '📊', name: 'Analytics', color: '\x1b[35m' },
  'push-notifications': { emoji: '📲', name: 'Push', color: '\x1b[33m' },
};
```

### Step 3: Add Category Getters

For each custom category in `types.ts`, add a getter in `src/utils/logger/Logger.ts`:

```typescript
class Logger {
  // ... existing code

  get database() {
    return this.createCategoryLogger('database');
  }

  get analytics() {
    return this.createCategoryLogger('analytics');
  }

  get pushNotifications() {
    return this.createCategoryLogger('push-notifications');
  }
}
```

### Step 4: Create Global Type Declaration

Create `src/types/global.d.ts` for `__DEV__` support:

```typescript
declare const __DEV__: boolean;
```

Update `tsconfig.json`:

```json
{
  "compilerOptions": {
    "types": ["src/types/global.d.ts"]
  },
  "include": ["src/**/*"]
}
```

### Step 5: Use in Your Code

Import and use the logger:

```typescript
import { logger } from '@/utils/logger';

// API calls
logger.api.info('Fetching user data', { userId: 123 });
logger.api.error('Request failed', error, { endpoint: '/users' });

// Authentication
logger.auth.success('Login successful', { method: 'oauth' });

// WebSocket
logger.websocket.debug('Message received', { type: 'status' });

// Storage
logger.storage.info('Data saved', { key: 'preferences' });

// Direct methods (no category)
logger.success('Operation completed');
logger.error('Something went wrong', error);
logger.warn('Deprecated API usage');
```

### Step 6: Filter Logs in Terminal

Use grep to filter by category or level:

```bash
# Filter by category (emoji)
npx expo start | grep "📡 API"
npx expo start | grep "🔐 Auth"
npx expo start | grep "❌ Error"

# Filter by level
npx expo start | grep "\[DEBUG\]"
npx expo start | grep "\[ERROR\]"
```

### Step 7: Integrate with Sentry (Optional)

Create a Sentry transport:

```typescript
import * as Sentry from '@sentry/react-native';
import { Transport, LogEntry, LogLevel } from '@/utils/logger';

export class SentryTransport implements Transport {
  write(entry: LogEntry): void {
    // Only send warnings and errors
    if (entry.level < LogLevel.WARN) return;

    const breadcrumb = {
      category: entry.category,
      message: entry.message,
      level: entry.level === LogLevel.ERROR ? 'error' : 'warning',
      data: entry.data,
      timestamp: new Date(entry.timestamp).getTime() / 1000,
    };

    Sentry.addBreadcrumb(breadcrumb);

    // Capture errors
    if (entry.level === LogLevel.ERROR && entry.error) {
      Sentry.captureException(new Error(entry.error.message), {
        contexts: {
          log: {
            category: entry.category,
            data: entry.data,
          },
        },
      });
    }
  }
}

// Add to logger
import { logger } from '@/utils/logger';
logger.addTransport(new SentryTransport());
```

## Guidelines

**Do:**
- Always pass context objects with relevant data
- Use appropriate log levels (debug/info/warn/error)
- Add custom categories for domain-specific features
- Filter logs during development using grep
- Pass Error objects for stack traces: `logger.api.error('Failed', error, { context })`

**Don't:**
- Don't log sensitive data (passwords, tokens, PII)
- Don't use generic messages without context
- Don't forget to test that logs are stripped in production
- Don't mix console.log with logger (be consistent)

## Examples

### Migrating from console.log

```typescript
// ❌ Before
console.log('📡 API call started');
console.log('Response:', response);
console.error('Failed:', error);

// ✅ After
logger.api.info('API call started', { endpoint: '/users' });
logger.api.success('Response received', { data: response });
logger.api.error('API call failed', error, { endpoint: '/users' });
```

### API Service

```typescript
class ApiClient {
  async fetchUsers() {
    logger.api.debug('Fetching users list');

    try {
      const response = await axios.get('/users');
      logger.api.success('Users fetched', {
        count: response.data.length,
        endpoint: '/users',
      });
      return response.data;
    } catch (error) {
      logger.api.error('Failed to fetch users', error, {
        endpoint: '/users',
        status: error.response?.status,
      });
      throw error;
    }
  }
}
```

### Authentication Flow

```typescript
async function login(email: string, password: string) {
  logger.auth.info('Login attempt', { email, method: 'credentials' });

  try {
    const token = await authApi.login({ email, password });
    await SecureStore.setItemAsync('auth_token', token);

    logger.auth.success('Login successful', { email });
    logger.storage.info('Token saved to SecureStore', { key: 'auth_token' });

    return token;
  } catch (error) {
    logger.auth.error('Login failed', error, { email });
    throw error;
  }
}
```

### WebSocket Connection

```typescript
function setupWebSocket(url: string) {
  logger.websocket.info('Initializing WebSocket', { url });

  const ws = new WebSocket(url);

  ws.onopen = () => {
    logger.websocket.success('WebSocket connected');
  };

  ws.onmessage = (event) => {
    const data = JSON.parse(event.data);
    logger.websocket.debug('Message received', { type: data.type });
  };

  ws.onerror = (error) => {
    logger.websocket.error('WebSocket error', error);
  };

  return ws;
}
```

## Resources

- [Logging Guide](references/logging-guide.md) - Complete usage documentation
- [FreqWatch Logging Architecture](https://github.com/KevinLaRosa/FreqWatch) - Original inspiration

## Tools & Commands

- `npx expo start | grep "📡 API"` - Filter API logs
- `npx expo start | grep "\[ERROR\]"` - Show only errors
- `npx expo start | tee metro.log` - Save logs to file
- `tail -f metro.log | grep "🔐 Auth"` - Live filter auth logs

## Troubleshooting

### `__DEV__` is not defined

**Problem**: TypeScript error about `__DEV__`

**Solution**: Create `src/types/global.d.ts`:
```typescript
declare const __DEV__: boolean;
```

### Logs not showing in production

**Problem**: Need to verify logs are stripped

**Solution**: Build production bundle and check:
```bash
npx expo export --platform ios
grep -r "logger\\.api" dist/   # Should find nothing
```

### Emoji not displaying in terminal

**Problem**: Terminal doesn't support emojis

**Solution**: Disable colors in logger config:
```typescript
logger.getInstance({ enableColors: false });
```

---

## Notes

- Logs are automatically stripped in production (`__DEV__ = false`)
- Zero runtime overhead after Metro bundler optimization
- Compatible with all Expo SDK versions
- Works with EAS Build and bare React Native
