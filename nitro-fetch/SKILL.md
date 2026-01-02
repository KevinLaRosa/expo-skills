---
name: nitro-fetch
description: Ultra-fast HTTP requests with react-native-nitro-fetch - drop-in fetch replacement with HTTP/2, HTTP/3, prefetching, and worklet support for 220ms faster TTI
license: MIT
compatibility: "Requires: React Native 0.75+, react-native-nitro-modules, Cronet (Android), URLSession (iOS)"
---

# Nitro Fetch

## Overview

Make ultra-fast HTTP requests with react-native-nitro-fetch, a drop-in replacement for fetch() built with Nitro Modules that uses native HTTP stacks (Cronet/URLSession), supports HTTP/2, HTTP/3, prefetching, and worklet-based parsing for 220ms faster time-to-interactive.

## When to Use This Skill

- Need faster network requests than standard fetch()
- Want HTTP/2, HTTP/3, and Brotli compression
- Building offline-first apps with prefetching
- Need background thread data parsing (worklets)
- Want to prefetch data before screen navigation
- Require native disk caching
- Building performance-critical apps

**When you see:**
- "Slow API requests"
- "Network requests blocking UI"
- "Want to preload data"
- "Need HTTP/3 support"

**Alternative**: Use standard `fetch()` for simple use cases where performance isn't critical.

## Workflow

### Step 1: Install Nitro Fetch

```bash
# Install packages
npm install react-native-nitro-fetch react-native-nitro-modules

# iOS
cd ios && pod install && cd ..

# Rebuild app
npx expo run:ios
npx expo run:android
```

**Requirements**:
- React Native 0.75+
- react-native-nitro-modules
- Not compatible with Expo Go

### Step 2: Basic Usage (Drop-in Replacement)

Replace `fetch()` with `nitroFetch()`:

```typescript
import { nitroFetch } from 'react-native-nitro-fetch';

// Identical API to fetch()
const response = await nitroFetch('https://api.example.com/users');
const data = await response.json();

// With options
const response = await nitroFetch('https://api.example.com/users', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    Authorization: `Bearer ${token}`,
  },
  body: JSON.stringify({ name: 'John' }),
});
```

### Step 3: Prefetch Data Before Navigation

Preload data before navigating to screen:

```typescript
import { nitroFetch, prefetch } from 'react-native-nitro-fetch';

// On HomeScreen - prefetch data for ProfileScreen
function HomeScreen() {
  const navigateToProfile = async (userId: string) => {
    // Start prefetching immediately
    const prefetchId = prefetch(`https://api.example.com/users/${userId}`);

    // Navigate
    navigation.navigate('Profile', { userId, prefetchId });
  };

  return <Button onPress={() => navigateToProfile('123')}>View Profile</Button>;
}

// On ProfileScreen - use prefetched data
function ProfileScreen({ route }) {
  const { userId, prefetchId } = route.params;

  useEffect(() => {
    async function loadProfile() {
      // This will use cached prefetch - instant!
      const response = await nitroFetch(`https://api.example.com/users/${userId}`, {
        prefetchId,  // Link to prefetched request
      });
      const user = await response.json();
      setUser(user);
    }
    loadProfile();
  }, [userId, prefetchId]);

  return <View>...</View>;
}
```

**Result**: ~220ms faster TTI (time-to-interactive)

### Step 4: Schedule Prefetch on App Launch

Prefetch data when app opens, use later:

```typescript
import { schedulePrefetch } from 'react-native-nitro-fetch';
import { useEffect } from 'react';

// In App.tsx or root component
useEffect(() => {
  // Schedule prefetches for next app launch
  schedulePrefetch([
    'https://api.example.com/trending',
    'https://api.example.com/featured',
    'https://api.example.com/user/feed',
  ]);
}, []);

// Later in HomeScreen - data already cached!
const response = await nitroFetch('https://api.example.com/trending');
const trending = await response.json();  // Instant from cache
```

### Step 5: Parse JSON in Worklet (Background Thread)

Offload JSON parsing to background thread:

```typescript
import { nitroFetch } from 'react-native-nitro-fetch';
import { runOnJS } from 'react-native-reanimated';

async function fetchUserWorklet() {
  'worklet';

  const response = await nitroFetch('https://api.example.com/users');

  // Parse JSON on worklet thread (doesn't block UI)
  const users = await response.json();

  // Process data on worklet thread
  const processed = users.map(u => ({
    id: u.id,
    name: u.name.toUpperCase(),
  }));

  // Send to JS thread
  runOnJS(setUsers)(processed);
}
```

### Step 6: Use with React Query

```typescript
import { useQuery } from '@tanstack/react-query';
import { nitroFetch } from 'react-native-nitro-fetch';

function useUsers() {
  return useQuery({
    queryKey: ['users'],
    queryFn: async () => {
      const response = await nitroFetch('https://api.example.com/users');
      return response.json();
    },
  });
}

// With prefetching
function useUser(userId: string, prefetchId?: string) {
  return useQuery({
    queryKey: ['user', userId],
    queryFn: async () => {
      const response = await nitroFetch(`https://api.example.com/users/${userId}`, {
        prefetchId,
      });
      return response.json();
    },
  });
}
```

### Step 7: Advanced Configuration

```typescript
import { nitroFetch, configure } from 'react-native-nitro-fetch';

// Configure globally
configure({
  // Enable HTTP/3 over QUIC
  http3: true,

  // Enable Brotli compression
  brotli: true,

  // Disk cache size (bytes)
  cacheSize: 100 * 1024 * 1024,  // 100MB

  // Timeout
  timeout: 30000,  // 30 seconds
});
```

## Guidelines

**Do:**
- Use for all network requests in performance-critical apps
- Prefetch data before navigation
- Schedule prefetches on app launch for frequently accessed data
- Use worklets for heavy JSON parsing
- Combine with React Query for caching
- Enable HTTP/3 for faster requests
- Use native disk caching

**Don't:**
- Don't use with Expo Go (requires custom dev client)
- Don't forget to pass `prefetchId` when using prefetched data
- Don't parse large JSON on main thread (use worklets)
- Don't over-prefetch (impacts battery/data)
- Don't skip error handling
- Don't use for simple apps (standard fetch is fine)

## Examples

### Complete Prefetch Flow

```typescript
// 1. List Screen - Prefetch detail data
import { prefetch } from 'react-native-nitro-fetch';

function UserList() {
  const handleUserPress = (userId: string) => {
    // Start prefetch
    const prefetchId = prefetch(`https://api.example.com/users/${userId}`);

    // Navigate with prefetch ID
    navigation.navigate('UserDetail', { userId, prefetchId });
  };

  return (
    <FlatList
      data={users}
      renderItem={({ item }) => (
        <Pressable onPress={() => handleUserPress(item.id)}>
          <Text>{item.name}</Text>
        </Pressable>
      )}
    />
  );
}

// 2. Detail Screen - Use prefetched data
function UserDetail({ route }) {
  const { userId, prefetchId } = route.params;
  const [user, setUser] = useState(null);

  useEffect(() => {
    async function load() {
      // Use prefetched data (instant!)
      const response = await nitroFetch(`https://api.example.com/users/${userId}`, {
        prefetchId,
      });
      const data = await response.json();
      setUser(data);
    }
    load();
  }, [userId, prefetchId]);

  if (!user) return <Loading />;
  return <UserProfile user={user} />;
}
```

### Error Handling

```typescript
import { nitroFetch, NitroFetchError } from 'react-native-nitro-fetch';

async function fetchUsers() {
  try {
    const response = await nitroFetch('https://api.example.com/users');

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const users = await response.json();
    return users;
  } catch (error) {
    if (error instanceof NitroFetchError) {
      console.error('Network error:', error.message);
      // Handle network failure (timeout, no connection, etc.)
    } else {
      console.error('Other error:', error);
    }
    throw error;
  }
}
```

### POST Request

```typescript
const response = await nitroFetch('https://api.example.com/users', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    Authorization: `Bearer ${token}`,
  },
  body: JSON.stringify({
    name: 'John Doe',
    email: 'john@example.com',
  }),
});

const newUser = await response.json();
```

### File Upload

```typescript
const formData = new FormData();
formData.append('file', {
  uri: fileUri,
  type: 'image/jpeg',
  name: 'photo.jpg',
});

const response = await nitroFetch('https://api.example.com/upload', {
  method: 'POST',
  body: formData,
  headers: {
    'Content-Type': 'multipart/form-data',
  },
});
```

### Abort Request

```typescript
const controller = new AbortController();

const response = nitroFetch('https://api.example.com/slow-endpoint', {
  signal: controller.signal,
});

// Cancel request
controller.abort();
```

### Custom Headers

```typescript
const response = await nitroFetch('https://api.example.com/data', {
  headers: {
    'X-API-Key': API_KEY,
    'User-Agent': 'MyApp/1.0',
    'Accept-Language': 'en-US',
  },
});
```

## Resources

- [Nitro Fetch GitHub](https://github.com/margelo/react-native-nitro-fetch)
- [Nitro Modules](https://nitro.margelo.com/)
- [Cronet (Android)](https://chromium.googlesource.com/chromium/src/+/main/components/cronet/)
- [URLSession (iOS)](https://developer.apple.com/documentation/foundation/urlsession)

## Tools & Commands

- `npm install react-native-nitro-fetch` - Install package
- `npx expo prebuild` - Generate native projects
- `npx expo run:ios` - Run on iOS
- `npx expo run:android` - Run on Android

## Troubleshooting

### Not working in Expo Go

**Problem**: Crashes or "module not found" in Expo Go

**Solution**:
Nitro Fetch requires native code:
```bash
npx expo prebuild
npx expo run:ios
npx expo run:android
```

### Prefetch not faster

**Problem**: Prefetched requests still slow

**Solution**:
1. Ensure you pass `prefetchId`:
```typescript
await nitroFetch(url, { prefetchId });
```
2. Check that prefetch() is called before nitroFetch()
3. Verify network conditions (prefetch needs time to complete)

### HTTP/3 not working

**Problem**: Requests not using HTTP/3

**Solution**:
```typescript
import { configure } from 'react-native-nitro-fetch';

configure({
  http3: true,  // Enable HTTP/3
});

// Server must support HTTP/3 (check with curl --http3)
```

### Timeout errors

**Problem**: Requests timing out

**Solution**:
```typescript
await nitroFetch(url, {
  timeout: 60000,  // 60 seconds
});

// Or configure globally
configure({
  timeout: 60000,
});
```

### JSON parsing slow

**Problem**: UI freezes during JSON parsing

**Solution**:
Use worklets for background parsing:
```typescript
async function fetchDataWorklet() {
  'worklet';
  const response = await nitroFetch(url);
  const data = await response.json();  // Parsed on worklet thread
  runOnJS(setData)(data);
}
```

---

## Notes

- Alpha status - API may change (production-ready though)
- Requires React Native 0.75+
- Uses Cronet (Android) and URLSession (iOS) - native HTTP stacks
- Supports HTTP/1, HTTP/2, HTTP/3 over QUIC
- Brotli compression support
- Native disk caching
- Prefetching reduces TTI by ~220ms
- Worklet support for background parsing
- Not compatible with Expo Go (requires custom dev client)
- Drop-in replacement for fetch()
- HTTP streaming and WebSocket not yet supported
- Alternative to Axios, fetch(), react-native-fetch-api
