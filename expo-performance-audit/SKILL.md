---
name: expo-performance-audit
description: Audit and optimize Expo/React Native app performance with React Compiler, bundle analysis, Flashlight profiling, and proven optimization patterns
license: MIT
compatibility: "Requires: Node.js 18+, Expo SDK 52+ (for React Compiler), Flashlight, source-map-explorer, iOS/Android device for profiling"
---

# Expo Performance Audit

## Overview

Systematically analyze and optimize your Expo app's performance using React Compiler (automatic memoization), bundle analysis, Flashlight profiling, memory leak detection, and React Native performance best practices.

## When to Use This Skill

- App feels slow or laggy
- Long lists are scrolling poorly
- App crashes due to memory issues
- Bundle size is too large
- Need to optimize before production release
- Want to achieve 60fps animations
- Investigating performance regressions

## Workflow

### Step 1: Analyze Bundle Size

```bash
# Export production bundle
npx expo export --platform ios

# Analyze bundle with source-map-explorer
npx source-map-explorer dist/**/*.js --html bundle-report.html

# Open report
open bundle-report.html

# Or use the script
./expo-performance-audit/scripts/analyze-bundle.sh
```

**Look for:**
- Large dependencies (>100KB)
- Duplicate packages
- Unused code

### Step 2: Check for Unused Dependencies

```bash
# Install depcheck
npm install -g depcheck

# Run analysis
depcheck

# Install knip for more thorough analysis
npm install -D knip

# Run knip
npx knip

# Or use the script
./expo-performance-audit/scripts/check-deps.sh
```

### Step 3: Profile with Flashlight

```bash
# Install Flashlight
curl https://get.flashlight.dev | bash

# Start profiling
flashlight measure --bundleId com.yourapp.bundle --testCommand "yarn e2e"

# Or profile manually
flashlight measure --bundleId com.yourapp.bundle --duration 30

# View report
flashlight report

# Or use the script
./expo-performance-audit/scripts/run-flashlight.sh
```

**Metrics to watch:**
- FPS (target: 60fps)
- CPU usage (< 50%)
- Memory (< 200MB for medium apps)
- Time to Interactive (< 3s)

### Step 4: Optimize Lists with FlashList

```typescript
// ❌ Before: FlatList
import { FlatList } from 'react-native';

<FlatList
  data={items}
  renderItem={({ item }) => <ItemCard item={item} />}
  keyExtractor={(item) => item.id}
/>

// ✅ After: FlashList
import { FlashList } from '@shopify/flash-list';

<FlashList
  data={items}
  renderItem={({ item }) => <ItemCard item={item} />}
  estimatedItemSize={100}  // Add this for best performance
  keyExtractor={(item) => item.id}
/>
```

### Step 5: Memoize Components

```typescript
import React, { memo, useCallback, useMemo } from 'react';

// ❌ Before: Component re-renders on every parent update
function UserCard({ user, onPress }) {
  return (
    <Pressable onPress={() => onPress(user.id)}>
      <Text>{user.name}</Text>
    </Pressable>
  );
}

// ✅ After: Memoized component
const UserCard = memo(({ user, onPress }) => {
  return (
    <Pressable onPress={() => onPress(user.id)}>
      <Text>{user.name}</Text>
    </Pressable>
  );
});

// ✅ In parent: Use useCallback
function UserList({ users }) {
  const handlePress = useCallback((userId) => {
    console.log('User pressed:', userId);
  }, []);

  return (
    <FlashList
      data={users}
      renderItem={({ item }) => (
        <UserCard user={item} onPress={handlePress} />
      )}
      estimatedItemSize={80}
    />
  );
}
```

### Step 6: Enable React Compiler (Auto-Optimization)

React Compiler (formerly React Forget) automatically optimizes your components, eliminating the need for manual `React.memo`, `useMemo`, and `useCallback`.

**Requirements**: React Native 0.76+, Expo SDK 52+

```bash
# Install React Compiler
npm install -D babel-plugin-react-compiler

# For Expo SDK 52+
npx expo install babel-plugin-react-compiler
```

**Configure babel.config.js:**

```javascript
module.exports = function (api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      ['babel-plugin-react-compiler', {
        runtimeModule: 'react-compiler-runtime'
      }]
    ],
  };
};
```

**Install runtime:**

```bash
npm install react-compiler-runtime
```

**What React Compiler Does:**
- ✅ Automatically memoizes components (no more `React.memo`)
- ✅ Auto-memoizes callbacks (no more `useCallback`)
- ✅ Auto-memoizes calculations (no more `useMemo`)
- ✅ Analyzes dependency arrays automatically
- ✅ Only re-renders when actual data changes

**Before React Compiler:**

```typescript
import { memo, useCallback, useMemo } from 'react';

const UserCard = memo(({ user, onPress }) => {
  return (
    <Pressable onPress={() => onPress(user.id)}>
      <Text>{user.name}</Text>
    </Pressable>
  );
});

function UserList({ users }) {
  const handlePress = useCallback((userId) => {
    console.log('User pressed:', userId);
  }, []);

  const sortedUsers = useMemo(() => {
    return users.sort((a, b) => a.name.localeCompare(b.name));
  }, [users]);

  return <FlashList data={sortedUsers} />;
}
```

**After React Compiler (Automatic!):**

```typescript
// No memo, useCallback, or useMemo needed!
function UserCard({ user, onPress }) {
  return (
    <Pressable onPress={() => onPress(user.id)}>
      <Text>{user.name}</Text>
    </Pressable>
  );
}

function UserList({ users }) {
  // Automatically memoized by compiler
  const handlePress = (userId) => {
    console.log('User pressed:', userId);
  };

  // Automatically memoized by compiler
  const sortedUsers = users.sort((a, b) => a.name.localeCompare(b.name));

  return <FlashList data={sortedUsers} />;
}
```

**Verify React Compiler is working:**

```bash
# Check Metro bundler logs for compilation info
npx expo start --clear

# You should see: [React Compiler] Compiled X components
```

**Note**: React Compiler doesn't replace FlashList, Reanimated worklets, or image optimizations - it specifically optimizes React re-renders.

### Step 7: Optimize Images

```typescript
// Install expo-image
npx expo install expo-image

// ❌ Before: React Native Image
import { Image } from 'react-native';

<Image
  source={{ uri: 'https://example.com/image.jpg' }}
  style={{ width: 100, height: 100 }}
/>

// ✅ After: Expo Image with optimizations
import { Image } from 'expo-image';

<Image
  source={{ uri: 'https://example.com/image.jpg' }}
  placeholder={blurhash}  // Progressive loading
  contentFit="cover"
  transition={200}
  cachePolicy="memory-disk"  // Aggressive caching
  style={{ width: 100, height: 100 }}
/>

// ✅ Use WebP format for better compression
<Image
  source={require('./assets/image.webp')}
  style={{ width: 100, height: 100 }}
/>
```

### Step 8: Detect Memory Leaks

```bash
# iOS: Use Xcode Instruments
# 1. Build app: npx expo run:ios
# 2. Open Xcode: xed ios/
# 3. Product → Profile (⌘+I)
# 4. Choose "Leaks" instrument
# 5. Run app and interact
# 6. Look for red bars (leaks detected)

# Android: Use Android Studio Profiler
# 1. Build app: npx expo run:android
# 2. Open Android Studio: studio android/
# 3. View → Tool Windows → Profiler
# 4. Select app process
# 5. Monitor memory usage over time
# 6. Look for increasing memory (potential leak)
```

## Guidelines

**Do:**
- Use React Compiler (Expo SDK 52+) for automatic memoization
- Use FlashList instead of FlatList for lists >20 items
- Memoize expensive components with React.memo (if not using React Compiler)
- Use useCallback for functions passed to child components (if not using React Compiler)
- Use useMemo for expensive calculations (if not using React Compiler)
- Optimize images (WebP, blurhash, caching)
- Remove console.log in production
- Use Reanimated worklets for animations
- Profile on low-end devices

**Don't:**
- Don't optimize prematurely (measure first!)
- Don't manually add memo/useCallback/useMemo if using React Compiler (it's automatic)
- Don't use inline functions in render (unless using React Compiler)
- Don't create new objects/arrays in render (unless using React Compiler)
- Don't forget to set estimatedItemSize on FlashList
- Don't ignore the why-did-you-render warnings
- Don't use ScrollView for long lists
- Don't skip React.memo when passing callbacks (unless using React Compiler)

## Examples

### Performance Checklist

```typescript
// ✅ Performance Optimizations Checklist

// 0. React Compiler (Expo SDK 52+) - BEST OPTION
// Install: npx expo install babel-plugin-react-compiler react-compiler-runtime
// Configure babel.config.js with plugin
// Automatic memoization - no manual memo/useCallback/useMemo needed!

// 1. Lists
import { FlashList } from '@shopify/flash-list';

// 2. Images
import { Image } from 'expo-image';

// 3. Memoization (ONLY if NOT using React Compiler)
const Component = memo(({ data }) => {
  const processed = useMemo(() => expensiveCalc(data), [data]);
  const handlePress = useCallback(() => {}, []);

  return <View>{/* ... */}</View>;
});

// 4. Animations (use Reanimated worklets)
import Animated, { useAnimatedStyle, withSpring } from 'react-native-reanimated';

const animatedStyle = useAnimatedStyle(() => ({
  transform: [{ translateX: withSpring(offset.value) }],
}));

// 5. Avoid inline styles (unless using React Compiler)
const styles = StyleSheet.create({
  container: { flex: 1 },
});

// 6. Remove development-only code
if (__DEV__) {
  // Development-only code
}
```

### Optimizing Heavy Calculations

```typescript
import { useMemo } from 'react';

function ChartComponent({ data }) {
  // ❌ Recalculates on every render
  const chartData = processChartData(data);

  // ✅ Only recalculates when data changes
  const chartData = useMemo(
    () => processChartData(data),
    [data]
  );

  return <Chart data={chartData} />;
}
```

### Lazy Loading Components

```typescript
import { lazy, Suspense } from 'react';

// ✅ Load heavy components only when needed
const HeavyChart = lazy(() => import('./HeavyChart'));

function Dashboard() {
  const [showChart, setShowChart] = useState(false);

  return (
    <View>
      <Button onPress={() => setShowChart(true)}>Show Chart</Button>

      {showChart && (
        <Suspense fallback={<ActivityIndicator />}>
          <HeavyChart />
        </Suspense>
      )}
    </View>
  );
}
```

## Resources

- [React Compiler Guide](references/react-compiler-guide.md)
- [Performance Checklist](references/performance-checklist.md)
- [Flashlight Guide](references/flashlight-guide.md)
- [Optimization Patterns](references/optimization-patterns.md)
- [React Native Performance](https://reactnative.dev/docs/performance)

## Tools & Commands

- `npx expo install babel-plugin-react-compiler` - Install React Compiler
- `npx expo export --platform ios` - Export production bundle
- `npx source-map-explorer dist/**/*.js` - Analyze bundle
- `depcheck` - Find unused dependencies
- `npx knip` - Detect unused code
- `flashlight measure` - Profile app performance
- `npx react-devtools` - React performance profiler

## Troubleshooting

### App is slow but profiler shows 60fps

**Problem**: UI feels slow despite good FPS

**Solution**: Check JavaScript thread usage
```typescript
// Use Reanimated for animations (runs on UI thread)
import Animated from 'react-native-reanimated';

// Move heavy calculations to worklets
const expensiveCalc = useWorklet(() => {
  'worklet';
  // Runs on UI thread
});
```

### Memory keeps increasing

**Problem**: Memory leak suspected

**Solution**:
```typescript
// Check for uncleared timers/intervals
useEffect(() => {
  const interval = setInterval(() => {}, 1000);
  return () => clearInterval(interval);  // ← Don't forget this!
}, []);

// Check for uncleaned subscriptions
useEffect(() => {
  const subscription = api.subscribe();
  return () => subscription.unsubscribe();  // ← Clean up
}, []);
```

### React Compiler not working

**Problem**: Components still re-rendering unnecessarily

**Solution**:
```bash
# 1. Verify installation
npm list babel-plugin-react-compiler react-compiler-runtime

# 2. Check babel.config.js includes the plugin
cat babel.config.js

# 3. Clear Metro cache and rebuild
npx expo start --clear

# 4. Check Metro logs for compilation messages
# Should see: [React Compiler] Compiled X components

# 5. Verify Expo SDK version (need 52+)
npx expo --version
```

**Common issues**:
- React Compiler requires Expo SDK 52+ and React Native 0.76+
- Must install BOTH `babel-plugin-react-compiler` and `react-compiler-runtime`
- Must clear Metro cache after adding plugin
- Some third-party libraries may not be compatible yet

---

## Notes

- **React Compiler** (Expo SDK 52+) automates memoization - use it for new projects
- Profile on actual devices, not simulators/emulators
- Low-end devices reveal performance issues first
- Bundle size directly impacts app startup time
- 60fps = 16.67ms per frame (budget carefully!)
- React Compiler eliminates need for manual memo/useCallback/useMemo
- Combine React Compiler with FlashList and Reanimated for best performance
