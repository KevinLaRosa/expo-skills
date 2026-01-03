---
name: expo-secure-store
description: Secure storage with Expo Secure Store - encrypted key-value storage using Keychain (iOS) and EncryptedSharedPreferences (Android)
license: MIT
compatibility: "Requires: Expo SDK 50+, expo-secure-store"
---

# Expo Secure Store

## Overview

Expo SecureStore provides encrypted key-value storage for sensitive data on iOS and Android devices. It leverages native platform security mechanisms to protect authentication tokens, passwords, API keys, and other sensitive information.

**Platform Implementations:**
- **iOS**: Uses Keychain Services (`kSecClassGenericPassword`)
- **Android**: Uses Android Keystore with EncryptedSharedPreferences

Each Expo project maintains isolated storage that is inaccessible to other apps, ensuring data privacy and security.

**Key Features:**
- Encrypted storage for sensitive key-value pairs
- Biometric authentication support (Face ID, Touch ID, fingerprint)
- Platform-native security mechanisms
- Simple async/sync API
- Per-key access control options (iOS)

## When to Use

**Use Expo SecureStore for:**
- Authentication tokens (JWT, OAuth tokens, refresh tokens)
- API keys and secrets
- User credentials (passwords, PINs)
- Session identifiers
- Encryption keys
- Sensitive user preferences (e.g., biometric settings)
- Private user data that must persist securely

**Don't use SecureStore for:**
- Large data storage (limit ~2048 bytes on some iOS versions)
- Non-sensitive application state (use AsyncStorage instead)
- Data requiring complex queries (use SQLite/database)
- Sole backup for critical data (implement additional backup strategy)
- High-frequency read/write operations (performance overhead)

## Workflow

### 1. Install Dependencies

```bash
npx expo install expo-secure-store
```

Add iOS permissions to `app.json` for biometric authentication:

```json
{
  "expo": {
    "ios": {
      "infoPlist": {
        "NSFaceIDUsageDescription": "Allow $(PRODUCT_NAME) to use Face ID to secure your data."
      }
    }
  }
}
```

### 2. Configure Android Auto Backup

Exclude SecureStore from Android Auto Backup (data becomes inaccessible after restore):

Create `android/app/src/main/res/xml/backup_rules.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
  <exclude domain="sharedpref" path="RCTAsyncLocalStorage_SecureStore" />
</full-backup-content>
```

Reference in `app.json`:

```json
{
  "expo": {
    "android": {
      "dataRetentionPolicy": "remove_all",
      "allowBackup": false
    }
  }
}
```

### 3. Create Storage Service

Build a reusable service with TypeScript:

```typescript
import * as SecureStore from 'expo-secure-store';

export class SecureStorageService {
  /**
   * Store sensitive data securely
   */
  static async setItem(
    key: string,
    value: string,
    options?: SecureStore.SecureStoreOptions
  ): Promise<void> {
    try {
      await SecureStore.setItemAsync(key, value, options);
    } catch (error) {
      console.error(`Error storing ${key}:`, error);
      throw error;
    }
  }

  /**
   * Retrieve stored data
   */
  static async getItem(
    key: string,
    options?: SecureStore.SecureStoreOptions
  ): Promise<string | null> {
    try {
      return await SecureStore.getItemAsync(key, options);
    } catch (error) {
      console.error(`Error retrieving ${key}:`, error);
      return null;
    }
  }

  /**
   * Delete stored data
   */
  static async deleteItem(
    key: string,
    options?: SecureStore.SecureStoreOptions
  ): Promise<void> {
    try {
      await SecureStore.deleteItemAsync(key, options);
    } catch (error) {
      console.error(`Error deleting ${key}:`, error);
      throw error;
    }
  }

  /**
   * Check if biometric authentication is available
   */
  static async isBiometricAvailable(): Promise<boolean> {
    try {
      const result = await SecureStore.canUseBiometricAuthentication();
      return result;
    } catch {
      return false;
    }
  }
}
```

### 4. Implement Authentication Token Storage

Store and retrieve authentication tokens:

```typescript
const AUTH_TOKEN_KEY = 'auth_token';
const REFRESH_TOKEN_KEY = 'refresh_token';

export async function saveAuthTokens(
  accessToken: string,
  refreshToken: string
): Promise<void> {
  await Promise.all([
    SecureStorageService.setItem(AUTH_TOKEN_KEY, accessToken),
    SecureStorageService.setItem(REFRESH_TOKEN_KEY, refreshToken),
  ]);
}

export async function getAuthToken(): Promise<string | null> {
  return await SecureStorageService.getItem(AUTH_TOKEN_KEY);
}

export async function clearAuthTokens(): Promise<void> {
  await Promise.all([
    SecureStorageService.deleteItem(AUTH_TOKEN_KEY),
    SecureStorageService.deleteItem(REFRESH_TOKEN_KEY),
  ]);
}
```

### 5. Add Biometric Protection

Enable biometric authentication for sensitive operations:

```typescript
const SENSITIVE_DATA_KEY = 'user_credentials';

export async function storeSensitiveData(
  data: string
): Promise<void> {
  const canUseBiometric = await SecureStore.canUseBiometricAuthentication();

  const options: SecureStore.SecureStoreOptions = {
    requireAuthentication: canUseBiometric,
    authenticationPrompt: 'Authenticate to save your credentials',
  };

  await SecureStore.setItemAsync(SENSITIVE_DATA_KEY, data, options);
}

export async function retrieveSensitiveData(): Promise<string | null> {
  try {
    const options: SecureStore.SecureStoreOptions = {
      requireAuthentication: true,
      authenticationPrompt: 'Authenticate to access your credentials',
    };

    return await SecureStore.getItemAsync(SENSITIVE_DATA_KEY, options);
  } catch (error) {
    // User cancelled authentication or biometric failed
    return null;
  }
}
```

### 6. Configure iOS Keychain Access Control

Set keychain accessibility for different security requirements:

```typescript
import * as SecureStore from 'expo-secure-store';

// Data accessible only when device is unlocked
export async function storeWithUnlockedAccess(
  key: string,
  value: string
): Promise<void> {
  await SecureStore.setItemAsync(key, value, {
    keychainAccessible: SecureStore.WHEN_UNLOCKED,
  });
}

// Data accessible after first unlock (persists during device lock)
export async function storeWithBackgroundAccess(
  key: string,
  value: string
): Promise<void> {
  await SecureStore.setItemAsync(key, value, {
    keychainAccessible: SecureStore.AFTER_FIRST_UNLOCK,
  });
}

// Data not shared across devices (no iCloud Keychain sync)
export async function storeLocalOnly(
  key: string,
  value: string
): Promise<void> {
  await SecureStore.setItemAsync(key, value, {
    keychainAccessible: SecureStore.WHEN_UNLOCKED_THIS_DEVICE_ONLY,
  });
}
```

### 7. Integrate with Authentication Flow

Complete authentication integration:

```typescript
interface AuthState {
  isAuthenticated: boolean;
  accessToken: string | null;
  refreshToken: string | null;
}

export async function login(
  username: string,
  password: string
): Promise<AuthState> {
  try {
    // Call authentication API
    const response = await fetch('https://api.example.com/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username, password }),
    });

    const { accessToken, refreshToken } = await response.json();

    // Store tokens securely
    await saveAuthTokens(accessToken, refreshToken);

    return {
      isAuthenticated: true,
      accessToken,
      refreshToken,
    };
  } catch (error) {
    console.error('Login failed:', error);
    throw error;
  }
}

export async function logout(): Promise<void> {
  await clearAuthTokens();
}

export async function restoreSession(): Promise<AuthState> {
  const accessToken = await getAuthToken();

  return {
    isAuthenticated: !!accessToken,
    accessToken,
    refreshToken: await SecureStorageService.getItem(REFRESH_TOKEN_KEY),
  };
}
```

### 8. Handle Data Size Limitations

Implement chunking for larger data:

```typescript
const CHUNK_SIZE = 1800; // Safe size under iOS 2048 byte limit

export async function storeLargeData(
  baseKey: string,
  data: string
): Promise<void> {
  const chunks = data.match(new RegExp(`.{1,${CHUNK_SIZE}}`, 'g')) || [];

  // Store chunk count
  await SecureStore.setItemAsync(`${baseKey}_count`, chunks.length.toString());

  // Store each chunk
  await Promise.all(
    chunks.map((chunk, index) =>
      SecureStore.setItemAsync(`${baseKey}_${index}`, chunk)
    )
  );
}

export async function retrieveLargeData(baseKey: string): Promise<string | null> {
  const countStr = await SecureStore.getItemAsync(`${baseKey}_count`);
  if (!countStr) return null;

  const count = parseInt(countStr, 10);
  const chunks: string[] = [];

  for (let i = 0; i < count; i++) {
    const chunk = await SecureStore.getItemAsync(`${baseKey}_${i}`);
    if (chunk) chunks.push(chunk);
  }

  return chunks.join('');
}
```

## Guidelines

### Do:
- **Always use async methods** (`setItemAsync`, `getItemAsync`) to avoid blocking the JavaScript thread
- **Implement error handling** for all SecureStore operations
- **Check platform availability** with `isAvailableAsync()` before use
- **Use descriptive key names** with alphanumeric characters, dots, dashes, and underscores
- **Validate data size** before storage (stay under 2048 bytes for iOS compatibility)
- **Configure Auto Backup exclusions** on Android to prevent data loss
- **Store minimal data** - only what's absolutely necessary for security
- **Implement token refresh logic** for authentication flows
- **Test biometric flows** on physical devices (simulators may behave differently)
- **Use TypeScript interfaces** to ensure type safety for stored data structures
- **Clear sensitive data** on logout or session expiration
- **Handle biometric changes** gracefully (data becomes inaccessible if biometrics change)

### Don't:
- **Don't store large objects** without chunking (iOS ~2048 byte limit)
- **Don't use as primary database** - it's for sensitive key-value pairs only
- **Don't store non-sensitive data** - use AsyncStorage for better performance
- **Don't rely solely on SecureStore** for critical data backup
- **Don't use synchronous methods** (`setItem`, `getItem`) in production
- **Don't store unencrypted passwords** - let SecureStore handle encryption
- **Don't ignore platform differences** - iOS persists after uninstall, Android doesn't
- **Don't test requireAuthentication** in Expo Go without proper configuration
- **Don't hardcode keys** - use constants for maintainability
- **Don't skip error handling** - storage operations can fail
- **Don't forget NSFaceIDUsageDescription** on iOS for biometric features
- **Don't assume biometric availability** - always check with `canUseBiometricAuthentication()`

## Examples

### Basic Token Management

```typescript
import * as SecureStore from 'expo-secure-store';

// Store auth token
async function saveToken(token: string): Promise<void> {
  await SecureStore.setItemAsync('userToken', token);
}

// Retrieve auth token
async function getToken(): Promise<string | null> {
  return await SecureStore.getItemAsync('userToken');
}

// Delete auth token
async function deleteToken(): Promise<void> {
  await SecureStore.deleteItemAsync('userToken');
}
```

### Authentication Context with SecureStore

```typescript
import React, { createContext, useContext, useState, useEffect } from 'react';
import * as SecureStore from 'expo-secure-store';

interface AuthContextType {
  isAuthenticated: boolean;
  login: (token: string) => Promise<void>;
  logout: () => Promise<void>;
  isLoading: boolean;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [isLoading, setIsLoading] = useState(true);

  // Restore session on app start
  useEffect(() => {
    async function restoreAuth() {
      try {
        const token = await SecureStore.getItemAsync('auth_token');
        setIsAuthenticated(!!token);
      } catch (error) {
        console.error('Failed to restore auth:', error);
      } finally {
        setIsLoading(false);
      }
    }

    restoreAuth();
  }, []);

  const login = async (token: string) => {
    await SecureStore.setItemAsync('auth_token', token);
    setIsAuthenticated(true);
  };

  const logout = async () => {
    await SecureStore.deleteItemAsync('auth_token');
    setIsAuthenticated(false);
  };

  return (
    <AuthContext.Provider value={{ isAuthenticated, login, logout, isLoading }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
}
```

### Biometric-Protected Storage

```typescript
import * as SecureStore from 'expo-secure-store';
import * as LocalAuthentication from 'expo-local-authentication';

async function storeWithBiometric(
  key: string,
  value: string
): Promise<boolean> {
  try {
    // Check if biometric is available
    const hasHardware = await LocalAuthentication.hasHardwareAsync();
    const isEnrolled = await LocalAuthentication.isEnrolledAsync();

    if (!hasHardware || !isEnrolled) {
      // Fallback to storage without biometric
      await SecureStore.setItemAsync(key, value);
      return false;
    }

    // Store with biometric protection
    await SecureStore.setItemAsync(key, value, {
      requireAuthentication: true,
      authenticationPrompt: 'Authenticate to secure your data',
    });

    return true;
  } catch (error) {
    console.error('Biometric storage failed:', error);
    throw error;
  }
}

async function retrieveWithBiometric(key: string): Promise<string | null> {
  try {
    return await SecureStore.getItemAsync(key, {
      requireAuthentication: true,
      authenticationPrompt: 'Authenticate to access your data',
    });
  } catch (error) {
    console.error('Authentication failed:', error);
    return null;
  }
}
```

### Storing Complex Objects

```typescript
interface UserCredentials {
  username: string;
  apiKey: string;
  refreshToken: string;
}

async function saveUserCredentials(
  credentials: UserCredentials
): Promise<void> {
  const serialized = JSON.stringify(credentials);

  // Check size before storing
  if (serialized.length > 2000) {
    throw new Error('Credentials too large for secure storage');
  }

  await SecureStore.setItemAsync('user_credentials', serialized);
}

async function getUserCredentials(): Promise<UserCredentials | null> {
  const serialized = await SecureStore.getItemAsync('user_credentials');

  if (!serialized) return null;

  try {
    return JSON.parse(serialized) as UserCredentials;
  } catch (error) {
    console.error('Failed to parse credentials:', error);
    return null;
  }
}
```

### Platform-Specific Configuration

```typescript
import * as SecureStore from 'expo-secure-store';
import { Platform } from 'react-native';

async function storePlatformOptimized(
  key: string,
  value: string
): Promise<void> {
  const options: SecureStore.SecureStoreOptions = {};

  if (Platform.OS === 'ios') {
    // iOS-specific: use stricter keychain access
    options.keychainAccessible = SecureStore.WHEN_UNLOCKED_THIS_DEVICE_ONLY;
  }

  if (Platform.OS === 'android') {
    // Android-specific configuration if needed
  }

  await SecureStore.setItemAsync(key, value, options);
}
```

### Custom Storage Hook

```typescript
import { useState, useEffect, useCallback } from 'react';
import * as SecureStore from 'expo-secure-store';

export function useSecureStorage<T>(
  key: string,
  initialValue: T
): [T, (value: T) => Promise<void>, () => Promise<void>] {
  const [storedValue, setStoredValue] = useState<T>(initialValue);

  // Load value on mount
  useEffect(() => {
    async function loadValue() {
      try {
        const item = await SecureStore.getItemAsync(key);
        if (item) {
          setStoredValue(JSON.parse(item));
        }
      } catch (error) {
        console.error(`Error loading ${key}:`, error);
      }
    }

    loadValue();
  }, [key]);

  // Save value
  const setValue = useCallback(
    async (value: T) => {
      try {
        setStoredValue(value);
        await SecureStore.setItemAsync(key, JSON.stringify(value));
      } catch (error) {
        console.error(`Error saving ${key}:`, error);
        throw error;
      }
    },
    [key]
  );

  // Remove value
  const removeValue = useCallback(async () => {
    try {
      setStoredValue(initialValue);
      await SecureStore.deleteItemAsync(key);
    } catch (error) {
      console.error(`Error removing ${key}:`, error);
      throw error;
    }
  }, [key, initialValue]);

  return [storedValue, setValue, removeValue];
}

// Usage
function MyComponent() {
  const [token, setToken, clearToken] = useSecureStorage<string | null>(
    'auth_token',
    null
  );

  return (
    <View>
      <Text>Token: {token || 'Not set'}</Text>
      <Button title="Set Token" onPress={() => setToken('abc123')} />
      <Button title="Clear Token" onPress={clearToken} />
    </View>
  );
}
```

## Resources

### Official Documentation
- [Expo SecureStore Documentation](https://docs.expo.dev/versions/latest/sdk/securestore/)
- [Expo SecureStore API Reference](https://docs.expo.dev/versions/latest/sdk/securestore/#api)
- [iOS Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
- [Android EncryptedSharedPreferences](https://developer.android.com/reference/androidx/security/crypto/EncryptedSharedPreferences)

### Related Expo Libraries
- [expo-local-authentication](https://docs.expo.dev/versions/latest/sdk/local-authentication/) - Biometric authentication
- [expo-crypto](https://docs.expo.dev/versions/latest/sdk/crypto/) - Cryptographic operations
- [expo-app-auth](https://docs.expo.dev/versions/latest/sdk/app-auth/) - OAuth flows

### Security Resources
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [Expo Security Best Practices](https://docs.expo.dev/guides/security/)

## Tools & Commands

### Installation

```bash
# Install expo-secure-store
npx expo install expo-secure-store

# Install with local authentication
npx expo install expo-secure-store expo-local-authentication

# Create development build (required for testing biometrics)
eas build --profile development --platform ios
eas build --profile development --platform android
```

### Check SecureStore Availability

```typescript
import * as SecureStore from 'expo-secure-store';

async function checkAvailability() {
  const isAvailable = await SecureStore.isAvailableAsync();
  console.log('SecureStore available:', isAvailable);
}
```

### Debug Storage

```typescript
// List all keys (for debugging only - not recommended in production)
const ALL_KEYS = [
  'auth_token',
  'refresh_token',
  'user_credentials',
];

async function debugStorage() {
  for (const key of ALL_KEYS) {
    const value = await SecureStore.getItemAsync(key);
    console.log(`${key}:`, value ? 'Set' : 'Not set');
  }
}
```

### Clear All Data

```typescript
async function clearAllSecureData() {
  const keysToDelete = [
    'auth_token',
    'refresh_token',
    'user_credentials',
    // Add all your keys here
  ];

  await Promise.all(
    keysToDelete.map(key => SecureStore.deleteItemAsync(key))
  );
}
```

## Troubleshooting

### Issue: "SecureStore is not available on this platform"

**Cause:** SecureStore only works on iOS and Android devices/simulators.

**Solution:**
```typescript
import * as SecureStore from 'expo-secure-store';

async function safeStore(key: string, value: string) {
  const isAvailable = await SecureStore.isAvailableAsync();

  if (!isAvailable) {
    console.warn('SecureStore not available, using fallback');
    // Use AsyncStorage as fallback for web/other platforms
    return;
  }

  await SecureStore.setItemAsync(key, value);
}
```

### Issue: Data becomes inaccessible after biometric changes

**Cause:** iOS/Android invalidate keys when fingerprints or Face ID data changes.

**Solution:**
```typescript
async function handleInvalidatedKey(key: string) {
  try {
    await SecureStore.getItemAsync(key, {
      requireAuthentication: true,
    });
  } catch (error) {
    // Key may be invalidated
    console.warn('Key inaccessible, requesting new authentication');

    // Delete invalidated key
    await SecureStore.deleteItemAsync(key);

    // Prompt user to re-authenticate
    // ... redirect to login
  }
}
```

### Issue: "Value too large" error on iOS

**Cause:** iOS Keychain has a ~2048 byte limit per item.

**Solution:**
```typescript
const MAX_ITEM_SIZE = 2000;

async function safeStore(key: string, value: string) {
  if (value.length > MAX_ITEM_SIZE) {
    // Implement chunking or compression
    throw new Error(`Value exceeds maximum size of ${MAX_ITEM_SIZE} bytes`);
  }

  await SecureStore.setItemAsync(key, value);
}
```

### Issue: requireAuthentication not working in Expo Go

**Cause:** Expo Go doesn't include NSFaceIDUsageDescription by default.

**Solution:**
Create a development build:
```bash
# Build for iOS
eas build --profile development --platform ios

# Build for Android
eas build --profile development --platform android

# Install on device
eas build:run --profile development
```

### Issue: Android Auto Backup restores encrypted data

**Cause:** Android restores SecureStore data but keystore is wiped on reinstall.

**Solution:**
Configure `app.json`:
```json
{
  "expo": {
    "android": {
      "allowBackup": false
    }
  }
}
```

Or exclude SecureStore from backup with backup rules.

### Issue: Data persists after app uninstall on iOS

**Cause:** iOS Keychain data survives app uninstallation when same bundle ID is used.

**Solution:**
```typescript
// Clear keychain on first launch after reinstall
import * as Application from 'expo-application';
import AsyncStorage from '@react-native-async-storage/async-storage';

async function clearKeychainOnReinstall() {
  const hasLaunchedBefore = await AsyncStorage.getItem('has_launched');

  if (!hasLaunchedBefore) {
    // First launch - clear any old keychain data
    await clearAllSecureData();
    await AsyncStorage.setItem('has_launched', 'true');
  }
}
```

### Issue: Authentication prompt appears unexpectedly

**Cause:** iOS prompts for authentication when reading/updating existing values with `requireAuthentication: true`.

**Solution:**
```typescript
// Only require authentication for sensitive operations
async function getTokenSilently(key: string): Promise<string | null> {
  try {
    // First attempt without authentication
    return await SecureStore.getItemAsync(key);
  } catch (error) {
    // If it requires auth, handle accordingly
    return null;
  }
}
```

## Notes

### Platform Behavior Differences

**iOS Keychain:**
- Data persists across app uninstallations (same bundle ID)
- Authentication required only when reading/updating existing values
- Supports granular accessibility controls
- ~2048 byte limit per item (varies by iOS version)
- Syncs via iCloud Keychain unless using `THIS_DEVICE_ONLY` option

**Android EncryptedSharedPreferences:**
- Data deleted on app uninstallation
- Authentication required for all operations (create/read/update)
- Keystore wiped after uninstall (Auto Backup issues)
- No practical size limit for reasonable use cases

### Security Considerations

1. **Encryption**: Data is automatically encrypted using platform-native mechanisms
2. **Isolation**: Each app has isolated storage; other apps cannot access
3. **Biometric invalidation**: Keys become inaccessible if device biometrics change
4. **Root/Jailbreak**: SecureStore may be vulnerable on compromised devices
5. **Not a silver bullet**: Implement additional security layers for highly sensitive apps

### Performance

- **Async operations**: Always use async methods to avoid blocking UI thread
- **Batch operations**: Use `Promise.all()` for multiple simultaneous reads/writes
- **Caching**: Consider in-memory caching for frequently accessed values
- **Size matters**: Smaller values = faster operations

### Best Practices Summary

1. Store only sensitive data (tokens, credentials, keys)
2. Implement proper error handling for all operations
3. Configure Android Auto Backup exclusions
4. Use TypeScript for type safety
5. Test on physical devices, especially biometric flows
6. Clear data on logout
7. Handle platform differences appropriately
8. Keep stored values small (<2KB)
9. Don't rely solely on SecureStore for critical backups
10. Document your keys and data structures

### Common Key Naming Conventions

```typescript
// Use consistent, descriptive naming
const KEYS = {
  AUTH_TOKEN: 'auth_token',
  REFRESH_TOKEN: 'refresh_token',
  USER_ID: 'user_id',
  API_KEY: 'api_key',
  BIOMETRIC_ENABLED: 'biometric_enabled',
} as const;
```

### Migration Strategy

When updating existing apps to use SecureStore:

```typescript
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as SecureStore from 'expo-secure-store';

async function migrateToSecureStore() {
  // Migrate sensitive data from AsyncStorage
  const token = await AsyncStorage.getItem('auth_token');

  if (token) {
    await SecureStore.setItemAsync('auth_token', token);
    await AsyncStorage.removeItem('auth_token');
    console.log('Migrated auth_token to SecureStore');
  }
}
```
