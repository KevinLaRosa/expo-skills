# Structured Logging Guide

Complete guide for using the structured logging system with categories and emojis.

## Quick Start

```typescript
import { logger } from '@/utils/logger';

// API calls
logger.api.info('Fetching user data', { userId: 123 });
logger.api.error('API call failed', error, { endpoint: '/users' });

// WebSocket
logger.websocket.debug('Message received', { type: 'status' });
logger.websocket.info('Connected to WebSocket', { url });

// Authentication
logger.auth.success('Login successful', { method: 'oauth' });
logger.auth.error('Token refresh failed', error);

// Storage
logger.storage.info('Saved to MMKV', { key: 'userPreferences' });
```

## Available Categories

| Category | Emoji | Usage |
|----------|-------|-------|
| `api` | 📡 | API calls and HTTP requests |
| `websocket` | 🔌 | WebSocket connections |
| `auth` | 🔐 | Authentication (JWT/OAuth) |
| `storage` | 💾 | SecureStore/MMKV operations |
| `navigation` | 🧭 | Navigation between screens |
| `ui` | 🎨 | Component lifecycle |
| `revenuecat` | 💳 | In-App Purchases |
| `webhook` | 📨 | Webhook notifications |
| `init` | 🚀 | App/service initialization |
| `notification` | 🔔 | Push notifications |
| `background` | ⏰ | Background tasks |
| `deeplink` | 🔗 | Deep linking |

Direct shortcuts (no category):
- `logger.success()` → ✅ Success
- `logger.error()` → ❌ Error
- `logger.warn()` → ⚠️ Warning

## Log Levels

1. **DEBUG** - Verbose logs (development only)
2. **INFO** - General information
3. **WARN** - Warnings
4. **ERROR** - Errors with stack traces

## Terminal Filtering

### By Category

```bash
# Metro bundler automatically saves logs
# Filter by category using grep:
tail -f metro.log | grep "📡 API"          # API logs only
tail -f metro.log | grep "🔌 WebSocket"   # WebSocket logs only
tail -f metro.log | grep "🔐 Auth"        # Auth logs only
tail -f metro.log | grep "❌ Error"       # All errors
tail -f metro.log | grep "✅ Success"     # All successes
```

### By Level

```bash
tail -f metro.log | grep "\[DEBUG\]"
tail -f metro.log | grep "\[INFO\]"
tail -f metro.log | grep "\[WARN\]"
tail -f metro.log | grep "\[ERROR\]"
```

## Migration Pattern

### Before

```typescript
console.log('📡 Creating Axios client with baseURL:', apiURL);
console.log('✅ Axios client created, authType:', this.authType);
console.error('❌ Failed to initialize RevenueCat:', error);
console.log('⚠️ No auth credentials available');
```

### After

```typescript
import { logger } from '@/utils/logger';

logger.api.info('Creating Axios client', { baseURL: apiURL });
logger.api.success('Axios client created', { authType: this.authType });
logger.revenuecat.error('Failed to initialize RevenueCat', error);
logger.auth.warn('No auth credentials available');
```

## Emoji to Category Mapping

| Current Emoji | New Category | Method |
|---------------|--------------|--------|
| 📡 | `logger.api` | `.info()` `.error()` |
| 🔌 | `logger.websocket` | `.debug()` `.info()` |
| 🔐 | `logger.auth` | `.success()` `.error()` |
| 💾 | `logger.storage` | `.info()` `.debug()` |
| 🧭 | `logger.navigation` | `.info()` |
| 🎨 | `logger.ui` | `.debug()` `.warn()` |
| 💳 | `logger.revenuecat` | `.info()` `.error()` |
| 📨 | `logger.webhook` | `.info()` `.debug()` |
| 🚀 | `logger.init` | `.info()` |
| ✅ | `logger.success()` | (direct) |
| ❌ | `logger.error()` | (direct) |
| ⚠️ | `logger.warn()` | (direct) |

## Output Format

```
[10:30:45] 📡 API Creating Axios client
{
  "baseURL": "https://api.example.com"
}

[10:30:46] ✅ Success Axios client created
{
  "authType": "jwt"
}

[10:30:50] ❌ Error Failed to fetch data
{
  "endpoint": "/users"
}
Error: Network timeout
    at ApiClient.fetch (api.ts:150:15)
```

## Best Practices

### 1. Always Include Context

```typescript
// ❌ Bad
logger.api.info('Request sent');

// ✅ Good
logger.api.info('Request sent', { endpoint: '/users', method: 'GET' });
```

### 2. Errors with Stack Trace

```typescript
// Pass Error object as second parameter
logger.api.error('API call failed', error, { endpoint });
```

### 3. Appropriate Level

- `debug()` - Detailed info for debugging (verbose)
- `info()` - Normal operation information
- `warn()` - Abnormal but non-critical situations
- `error()` - Errors requiring attention

### 4. Performance

Logs are automatically removed in production builds (zero overhead).

## Production

In production (`__DEV__ = false`), all logs are automatically stripped by Metro bundler, resulting in zero performance overhead.

## Advanced: Custom Log Levels

```typescript
import { logger, LogLevel } from '@/utils/logger';

// Disable all logs except errors
logger.setMinLevel(LogLevel.ERROR);

// Re-enable all logs
logger.setMinLevel(LogLevel.DEBUG);
```

## Examples

### API Call with Error

```typescript
try {
  logger.api.debug('Fetching user profile');
  const response = await api.get('/profile');
  logger.api.success('User profile fetched', { userId: response.data.id });
  return response.data;
} catch (error) {
  logger.api.error('Failed to fetch user profile', error, { endpoint: '/profile' });
  throw error;
}
```

### WebSocket Connection

```typescript
logger.websocket.info('Connecting to WebSocket', { url: wsUrl });

ws.on('open', () => {
  logger.websocket.success('WebSocket connected');
});

ws.on('message', (data) => {
  logger.websocket.debug('Message received', { type: data.type });
});

ws.on('error', (error) => {
  logger.websocket.error('WebSocket connection failed', error);
});
```

### Authentication Flow

```typescript
logger.auth.info('Login attempt', { method: 'oauth', provider: 'google' });

try {
  const token = await api.login(credentials);
  logger.auth.success('Login successful', { method: 'oauth' });
  return token;
} catch (error) {
  logger.auth.error('Login failed', error, { method: 'oauth' });
  throw error;
}
```

## Adding Custom Categories

To add a new category, edit `types.ts`:

```typescript
export type LogCategory =
  | 'api'
  | 'websocket'
  // ... existing categories
  | 'my-new-category'; // Add here

export const CATEGORIES: Record<LogCategory, CategoryMeta> = {
  // ... existing categories
  'my-new-category': { emoji: '🎯', name: 'MyCategory', color: '\x1b[36m' },
};
```

Then add getter in `Logger.ts`:

```typescript
get myNewCategory() {
  return this.createCategoryLogger('my-new-category');
}
```
