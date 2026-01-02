---
name: expo-fast-image
description: Load and cache images efficiently with react-native-fast-image - solves flickering, poor caching, and performance issues of React Native Image component
license: MIT
compatibility: "Requires: React Native 0.60+, SDWebImage (iOS), Glide (Android)"
---

# Expo Fast Image

## Overview

Load and cache images efficiently using react-native-fast-image, a performant replacement for React Native's built-in Image component that uses SDWebImage (iOS) and Glide (Android) for aggressive caching and smooth rendering.

## When to Use This Skill

- Images flicker during loading
- Poor image caching behavior
- Slow image loading performance
- Need authorization headers for images
- Loading many images in lists (FlatList)
- Need priority loading for critical images
- Want to preload images before displaying
- Need GIF support with good performance

**When you see:**
- "Images reloading on every render"
- "Image component flickering"
- "Slow image loads"
- "Cache not working"

**Alternative**: Use Expo's `expo-image` for Expo SDK 50+ (also performant, more Expo-integrated).

## Workflow

### Step 1: Install react-native-fast-image

```bash
# Install package
yarn add react-native-fast-image

# iOS
cd ios && pod install && cd ..

# Rebuild app
npx expo run:ios
npx expo run:android
```

**Requirements**:
- React Native 0.60+
- Not compatible with Expo Go (requires custom dev client)

### Step 2: Basic Usage

Replace `<Image>` with `<FastImage>`:

```typescript
import FastImage from 'react-native-fast-image';

export function MyComponent() {
  return (
    <FastImage
      style={{ width: 200, height: 200 }}
      source={{
        uri: 'https://example.com/image.png',
        priority: FastImage.priority.normal,
      }}
      resizeMode={FastImage.resizeMode.cover}
    />
  );
}
```

### Step 3: Configure Caching Strategy

```typescript
<FastImage
  source={{
    uri: 'https://example.com/avatar.png',
    // Cache strategy
    cache: FastImage.cacheControl.immutable,  // Default: only reload if URI changes
    // cache: FastImage.cacheControl.web,     // Respect HTTP cache headers
    // cache: FastImage.cacheControl.cacheOnly, // Never fetch from network
  }}
  style={{ width: 100, height: 100 }}
/>
```

**Cache strategies:**
- `immutable` (default) - Update only when URI changes (most aggressive)
- `web` - Respect HTTP cache headers (like browser)
- `cacheOnly` - Only use cached images, never network

### Step 4: Set Loading Priority

```typescript
<FastImage
  source={{
    uri: 'https://example.com/hero-image.png',
    priority: FastImage.priority.high,  // Load first
  }}
  style={{ width: '100%', height: 300 }}
/>

// Priority options
FastImage.priority.low      // Background images
FastImage.priority.normal   // Default
FastImage.priority.high     // Hero images, critical UI
```

### Step 5: Add Authorization Headers

```typescript
<FastImage
  source={{
    uri: 'https://api.example.com/private/image.png',
    headers: {
      Authorization: `Bearer ${token}`,
      'X-Custom-Header': 'value',
    },
  }}
  style={{ width: 200, height: 200 }}
/>
```

### Step 6: Handle Loading States

```typescript
import { useState } from 'react';
import FastImage from 'react-native-fast-image';

export function ImageWithLoading({ uri }: { uri: string }) {
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(false);

  return (
    <View>
      <FastImage
        source={{ uri }}
        style={{ width: 200, height: 200 }}
        onLoadStart={() => setLoading(true)}
        onLoad={() => setLoading(false)}
        onError={() => {
          setLoading(false);
          setError(true);
        }}
      />
      {loading && <ActivityIndicator style={StyleSheet.absoluteFill} />}
      {error && <Text>Failed to load image</Text>}
    </View>
  );
}
```

### Step 7: Preload Images

```typescript
import FastImage from 'react-native-fast-image';

// Preload before navigating to screen
useEffect(() => {
  FastImage.preload([
    {
      uri: 'https://example.com/image1.png',
      headers: { Authorization: token },
    },
    {
      uri: 'https://example.com/image2.png',
    },
    {
      uri: 'https://example.com/image3.png',
      priority: FastImage.priority.high,
    },
  ]);
}, []);

// Then images render instantly
<FastImage source={{ uri: 'https://example.com/image1.png' }} ... />
```

## Guidelines

**Do:**
- Use FastImage for all images in production apps
- Set priority for critical images (hero, above-fold)
- Preload images before navigation
- Use `immutable` cache for static images
- Use authorization headers for protected images
- Clear cache when needed (user logout, etc.)
- Use in FlatList for smooth scrolling

**Don't:**
- Don't use with Expo Go (requires custom dev client)
- Don't forget to preload images for better UX
- Don't use default Image component for lists
- Don't set high priority on all images (defeats purpose)
- Don't skip error handling
- Don't mix FastImage and Image (choose one)

## Examples

### FlatList with FastImage

```typescript
import { FlatList } from 'react-native';
import FastImage from 'react-native-fast-image';

export function ImageList({ images }: { images: string[] }) {
  return (
    <FlatList
      data={images}
      keyExtractor={(item) => item}
      renderItem={({ item }) => (
        <FastImage
          source={{
            uri: item,
            priority: FastImage.priority.normal,
          }}
          style={{ width: '100%', height: 200 }}
          resizeMode={FastImage.resizeMode.cover}
        />
      )}
    />
  );
}
```

### Placeholder Image

```typescript
<FastImage
  source={{ uri: 'https://example.com/image.png' }}
  defaultSource={require('./assets/placeholder.png')}  // Local placeholder
  style={{ width: 200, height: 200 }}
/>
```

### GIF Support

```typescript
<FastImage
  source={{
    uri: 'https://example.com/animation.gif',
  }}
  style={{ width: 300, height: 200 }}
  resizeMode={FastImage.resizeMode.contain}
/>
```

### Progress Indicator

```typescript
export function ImageWithProgress({ uri }: { uri: string }) {
  const [progress, setProgress] = useState(0);

  return (
    <View>
      <FastImage
        source={{ uri }}
        style={{ width: 300, height: 200 }}
        onProgress={(e) => {
          const percent = (e.nativeEvent.loaded / e.nativeEvent.total) * 100;
          setProgress(percent);
        }}
        onLoadEnd={() => setProgress(100)}
      />
      {progress < 100 && (
        <View style={StyleSheet.absoluteFill}>
          <ProgressBar progress={progress / 100} />
        </View>
      )}
    </View>
  );
}
```

### Clear Cache

```typescript
import FastImage from 'react-native-fast-image';

// Clear memory cache
await FastImage.clearMemoryCache();

// Clear disk cache
await FastImage.clearDiskCache();

// Common use case: logout
async function logout() {
  await FastImage.clearDiskCache();
  await FastImage.clearMemoryCache();
  // Clear other data...
}
```

### Border Radius

```typescript
<FastImage
  source={{ uri: 'https://example.com/avatar.png' }}
  style={{
    width: 100,
    height: 100,
    borderRadius: 50,  // Circle avatar
  }}
/>
```

### Resize Modes

```typescript
// Cover (default) - scale to fill, may crop
<FastImage
  source={{ uri }}
  resizeMode={FastImage.resizeMode.cover}
  style={{ width: 200, height: 200 }}
/>

// Contain - scale to fit, no cropping
<FastImage
  source={{ uri }}
  resizeMode={FastImage.resizeMode.contain}
  style={{ width: 200, height: 200 }}
/>

// Stretch - distort to fill
<FastImage
  source={{ uri }}
  resizeMode={FastImage.resizeMode.stretch}
  style={{ width: 200, height: 200 }}
/>

// Center - no scaling
<FastImage
  source={{ uri }}
  resizeMode={FastImage.resizeMode.center}
  style={{ width: 200, height: 200 }}
/>
```

### Preload with Navigation

```typescript
import { useFocusEffect } from '@react-navigation/native';

function HomeScreen() {
  useFocusEffect(
    useCallback(() => {
      // Preload images for next screen
      FastImage.preload([
        { uri: 'https://example.com/profile/avatar.png' },
        { uri: 'https://example.com/profile/cover.png' },
      ]);
    }, [])
  );

  return <View>...</View>;
}
```

## Resources

- [FastImage GitHub](https://github.com/margelo/react-native-fast-image)
- [SDWebImage (iOS)](https://github.com/SDWebImage/SDWebImage)
- [Glide (Android)](https://github.com/bumptech/glide)
- [expo-image Alternative](https://docs.expo.dev/versions/latest/sdk/image/)

## Tools & Commands

- `yarn add react-native-fast-image` - Install package
- `cd ios && pod install` - Install iOS dependencies
- `FastImage.clearMemoryCache()` - Clear RAM cache
- `FastImage.clearDiskCache()` - Clear disk cache

## Troubleshooting

### Images not caching

**Problem**: Images reload on every render

**Solution**:
```typescript
// Use immutable cache
<FastImage
  source={{
    uri: imageUrl,
    cache: FastImage.cacheControl.immutable,
  }}
/>

// Ensure URI doesn't change on re-render (move outside component or useMemo)
const IMAGE_URI = 'https://example.com/image.png';
```

### Images flickering

**Problem**: Brief flash when image loads

**Solution**:
1. Use `defaultSource` for placeholder
2. Preload images before navigation
3. Ensure cache is enabled

### Authorization not working

**Problem**: Protected images fail to load

**Solution**:
```typescript
<FastImage
  source={{
    uri: 'https://api.example.com/image.png',
    headers: {
      Authorization: `Bearer ${token}`,
    },
  }}
/>

// Ensure token is valid and not expired
```

### Not working in Expo Go

**Problem**: FastImage crashes in Expo Go

**Solution**:
FastImage requires native code. Create custom dev client:
```bash
npx expo prebuild
npx expo run:ios
npx expo run:android
```

### Large memory usage

**Problem**: App uses too much memory

**Solution**:
```typescript
// Clear cache periodically
useEffect(() => {
  return () => {
    FastImage.clearMemoryCache();
  };
}, []);

// Or on low memory warning
import { AppState } from 'react-native';

AppState.addEventListener('memoryWarning', () => {
  FastImage.clearMemoryCache();
});
```

---

## Notes

- FastImage wraps SDWebImage (iOS) and Glide (Android)
- Not compatible with Expo Go (requires custom dev client)
- More performant than React Native's Image component
- Aggressive caching by default (immutable)
- Supports GIF with hardware acceleration
- Priority loading for critical images
- Can preload images for instant display
- Authorization headers support for protected images
- Alternative: `expo-image` for Expo SDK 50+ (also performant)
