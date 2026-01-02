---
name: expo-performance-audit
description: Audit and optimize Expo/React Native app performance with bundle analysis, Flashlight profiling, and proven optimization patterns
license: MIT
compatibility: "Requires: Node.js 18+, Flashlight, source-map-explorer, iOS/Android device for profiling"
---

# Expo Performance Audit

## Overview

Systematically analyze and optimize your Expo app's performance using bundle analysis, Flashlight profiling, memory leak detection, and React Native performance best practices.

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

### Step 6: Optimize Images

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

### Step 7: Detect Memory Leaks

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
- Use FlashList instead of FlatList for lists >20 items
- Memoize expensive components with React.memo
- Use useCallback for functions passed to child components
- Use useMemo for expensive calculations
- Optimize images (WebP, blurhash, caching)
- Remove console.log in production
- Use Reanimated worklets for animations
- Profile on low-end devices

**Don't:**
- Don't optimize prematurely (measure first!)
- Don't use inline functions in render
- Don't create new objects/arrays in render
- Don't forget to set estimatedItemSize on FlashList
- Don't ignore the why-did-you-render warnings
- Don't use ScrollView for long lists
- Don't skip React.memo when passing callbacks

## Examples

### Performance Checklist

```typescript
// ✅ Performance Optimizations Checklist

// 1. Lists
import { FlashList } from '@shopify/flash-list';

// 2. Images
import { Image } from 'expo-image';

// 3. Memoization
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

// 5. Avoid inline styles
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

- [Performance Checklist](references/performance-checklist.md)
- [Flashlight Guide](references/flashlight-guide.md)
- [Optimization Patterns](references/optimization-patterns.md)
- [React Native Performance](https://reactnative.dev/docs/performance)

## Tools & Commands

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

---

## Notes

- Profile on actual devices, not simulators/emulators
- Low-end devices reveal performance issues first
- Bundle size directly impacts app startup time
- 60fps = 16.67ms per frame (budget carefully!)
