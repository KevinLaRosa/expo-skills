---
name: mmkv-storage
description: Ultra-fast key-value storage with react-native-mmkv - 30x faster than AsyncStorage with encryption support
license: MIT
compatibility: "Requires: React Native 0.74+, New Architecture/TurboModules enabled, react-native-mmkv 3.0+"
---

# MMKV Storage

## Overview

Implement ultra-fast key-value storage in React Native with react-native-mmkv, providing ~30x faster performance than AsyncStorage through direct JS bindings to the native C++ MMKV library.

## When to Use This Skill

- Need faster alternative to AsyncStorage
- Storing app settings and preferences
- Caching API responses locally
- Persisting user data
- Need encrypted storage
- Want synchronous storage access
- Need high-performance key-value storage
- Persist Zustand state (30x faster than AsyncStorage - see `zustand-state` skill for complete integration)

**When you see:**
- "AsyncStorage is too slow"
- "Need faster storage"
- "Persist user settings"
- "Cache data locally"
- "Zustand persist middleware"

**Prerequisites**: React Native 0.74+, New Architecture enabled.

## Workflow

### Step 1: Install MMKV

```bash
npm install react-native-mmkv

# For Expo
npx expo install react-native-mmkv
npx expo prebuild
```

**IMPORTANT**: react-native-mmkv V3 requires New Architecture/TurboModules to be enabled.

### Step 2: Basic Usage

```typescript
import { MMKV } from 'react-native-mmkv';

// Create instance
export const storage = new MMKV();

// Set values
storage.set('user.name', 'John Doe');
storage.set('user.age', 25);
storage.set('user.isPremium', true);

// Get values
const name = storage.getString('user.name');
const age = storage.getNumber('user.age');
const isPremium = storage.getBoolean('user.isPremium');

// Delete
storage.delete('user.age');

// Check existence
const hasName = storage.contains('user.name');

// Get all keys
const keys = storage.getAllKeys();

// Clear all
storage.clearAll();
```

### Step 3: Store Objects (JSON)

```typescript
// Store object
const user = { name: 'John', age: 25, premium: true };
storage.set('user', JSON.stringify(user));

// Retrieve object
const userJson = storage.getString('user');
const retrievedUser = userJson ? JSON.parse(userJson) : null;

// Helper functions
export const setObject = <T>(key: string, value: T) => {
  storage.set(key, JSON.stringify(value));
};

export const getObject = <T>(key: string): T | null => {
  const json = storage.getString(key);
  return json ? JSON.parse(json) : null;
};

// Usage
setObject('user', { name: 'John', age: 25 });
const user = getObject<{ name: string; age: number }>('user');
```

### Step 4: Encrypted Storage

```typescript
import { MMKV } from 'react-native-mmkv';

// Create encrypted instance
export const secureStorage = new MMKV({
  id: 'secure-storage',
  encryptionKey: 'your-encryption-key-here', // Generate securely!
});

// Use same as regular storage
secureStorage.set('creditCard', '1234-5678-9012-3456');
const creditCard = secureStorage.getString('creditCard');
```

**Generate encryption key securely:**

```typescript
import { MMKV } from 'react-native-mmkv';

// Generate random encryption key
const encryptionKey = Math.random().toString(36).substring(2, 15);

// Or use a secure key from your auth system
const encryptionKey = userId + secretKey;

export const secureStorage = new MMKV({
  id: `secure-${userId}`,
  encryptionKey,
});
```

### Step 5: Multiple Instances

```typescript
// Default instance
export const storage = new MMKV();

// User-specific instance
export const userStorage = new MMKV({
  id: `user-${userId}`,
});

// Cache instance
export const cacheStorage = new MMKV({
  id: 'cache',
});

// Secure instance
export const secureStorage = new MMKV({
  id: 'secure',
  encryptionKey: encryptionKey,
});

// Usage
storage.set('app.theme', 'dark');
userStorage.set('preferences.notifications', true);
cacheStorage.set('api.lastSync', Date.now());
secureStorage.set('auth.token', 'secret-token');
```

### Step 6: React Hooks Integration

```typescript
import { useMMKVString, useMMKVNumber, useMMKVBoolean } from 'react-native-mmkv';

function SettingsScreen() {
  const [theme, setTheme] = useMMKVString('app.theme', storage);
  const [fontSize, setFontSize] = useMMKVNumber('app.fontSize', storage);
  const [notifications, setNotifications] = useMMKVBoolean('app.notifications', storage);

  return (
    <View>
      <Text>Theme: {theme}</Text>
      <Button title="Toggle Theme" onPress={() => setTheme(theme === 'dark' ? 'light' : 'dark')} />

      <Text>Font Size: {fontSize}</Text>
      <Button title="Increase" onPress={() => setFontSize((fontSize || 14) + 2)} />

      <Switch value={notifications} onValueChange={setNotifications} />
    </View>
  );
}
```

### Step 7: Migration from AsyncStorage

```typescript
import AsyncStorage from '@react-native-async-storage/async-storage';
import { MMKV } from 'react-native-mmkv';

const storage = new MMKV();

async function migrateFromAsyncStorage() {
  try {
    const keys = await AsyncStorage.getAllKeys();

    for (const key of keys) {
      const value = await AsyncStorage.getItem(key);
      if (value !== null) {
        storage.set(key, value);
      }
    }

    // Optional: Clear AsyncStorage after migration
    await AsyncStorage.multiRemove(keys);

    console.log('Migration complete!');
  } catch (error) {
    console.error('Migration failed:', error);
  }
}

// Run once on app launch
migrateFromAsyncStorage();
```

## Guidelines

**Do:**
- Use MMKV for fast, synchronous storage
- Create separate instances for different data types
- Encrypt sensitive data with encryptionKey
- Use hooks for React components
- Migrate from AsyncStorage for better performance
- Use JSON.stringify/parse for objects
- Generate encryption keys securely

**Don't:**
- Don't use for large files (use FileSystem instead)
- Don't store huge objects (MMKV is for key-value, not documents)
- Don't hardcode encryption keys
- Don't use same instance for everything (organize by domain)
- Don't forget to enable New Architecture
- Don't use AsyncStorage if you need speed
- Don't store passwords without encryption

## Examples

### Settings Storage

```typescript
import { MMKV } from 'react-native-mmkv';

export const settingsStorage = new MMKV({ id: 'settings' });

export const settings = {
  getTheme: () => settingsStorage.getString('theme') ?? 'light',
  setTheme: (theme: string) => settingsStorage.set('theme', theme),

  getFontSize: () => settingsStorage.getNumber('fontSize') ?? 14,
  setFontSize: (size: number) => settingsStorage.set('fontSize', size),

  getNotifications: () => settingsStorage.getBoolean('notifications') ?? true,
  setNotifications: (enabled: boolean) => settingsStorage.set('notifications', enabled),
};
```

### Auth Token Storage

```typescript
import { MMKV } from 'react-native-mmkv';

const encryptionKey = 'your-secure-key'; // Generate securely!

export const authStorage = new MMKV({
  id: 'auth',
  encryptionKey,
});

export const auth = {
  setToken: (token: string) => authStorage.set('token', token),
  getToken: () => authStorage.getString('token'),
  clearToken: () => authStorage.delete('token'),
  isAuthenticated: () => authStorage.contains('token'),
};
```

### Cache with Expiry

```typescript
import { MMKV } from 'react-native-mmkv';

export const cacheStorage = new MMKV({ id: 'cache' });

export const cache = {
  set: <T>(key: string, value: T, ttlMs: number) => {
    const item = {
      value,
      expiry: Date.now() + ttlMs,
    };
    cacheStorage.set(key, JSON.stringify(item));
  },

  get: <T>(key: string): T | null => {
    const json = cacheStorage.getString(key);
    if (!json) return null;

    const item = JSON.parse(json);
    if (Date.now() > item.expiry) {
      cacheStorage.delete(key);
      return null;
    }

    return item.value;
  },

  clear: () => cacheStorage.clearAll(),
};

// Usage
cache.set('api.users', usersData, 5 * 60 * 1000); // 5 min TTL
const users = cache.get<User[]>('api.users');
```

### Zustand Persist Middleware Integration

Use MMKV with Zustand for 30x faster state persistence:

```typescript
// utils/mmkv-storage.ts
import { MMKV } from 'react-native-mmkv';
import { StateStorage } from 'zustand/middleware';

export const storage = new MMKV();

export const mmkvStorage: StateStorage = {
  setItem: (name, value) => {
    return storage.set(name, value);
  },
  getItem: (name) => {
    const value = storage.getString(name);
    return value ?? null;
  },
  removeItem: (name) => {
    return storage.delete(name);
  },
};
```

```typescript
// stores/settingsStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { mmkvStorage } from '../utils/mmkv-storage';

interface SettingsStore {
  theme: 'light' | 'dark';
  notifications: boolean;
  setTheme: (theme: 'light' | 'dark') => void;
  toggleNotifications: () => void;
}

export const useSettingsStore = create<SettingsStore>()(
  persist(
    (set) => ({
      theme: 'light',
      notifications: true,
      setTheme: (theme) => set({ theme }),
      toggleNotifications: () => set((state) => ({
        notifications: !state.notifications
      })),
    }),
    {
      name: 'settings-storage',
      storage: createJSONStorage(() => mmkvStorage), // 30x faster than AsyncStorage
    }
  )
);
```

**See also:** `zustand-state` skill for complete Zustand + MMKV integration guide.

## Resources

- [react-native-mmkv GitHub](https://github.com/mrousavy/react-native-mmkv)
- [NPM Package](https://www.npmjs.com/package/react-native-mmkv)
- [MMKV by Tencent](https://github.com/Tencent/MMKV)

## Tools & Commands

- `npm install react-native-mmkv` - Install MMKV
- `npx expo prebuild` - Rebuild native code (Expo)
- Check instance: `storage.getAllKeys()` - List all keys

## Troubleshooting

### Module not found

**Problem**: "Cannot find native module"

**Solution**:
```bash
# Ensure New Architecture is enabled
# android/gradle.properties
newArchEnabled=true

# ios/Podfile
:newArchEnabled => true

# Rebuild
npx expo prebuild --clean
npx expo run:ios
```

### Encryption not working

**Problem**: Can't decrypt data

**Solution**:
```typescript
// Use same encryption key consistently
const ENCRYPTION_KEY = 'same-key-always'; // Store securely!

export const secureStorage = new MMKV({
  id: 'secure',
  encryptionKey: ENCRYPTION_KEY,
});
```

---

## Notes

- 30x faster than AsyncStorage
- Synchronous API (no async/await needed)
- Requires New Architecture (React Native 0.74+)
- Supports encryption out of the box
- Used by thousands of apps in production
- Small bundle size (~30KB)
- Written in C++ for maximum performance
- Developed by Marc Rousavy (@mrousavy)
