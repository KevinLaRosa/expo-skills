---
name: react-native-advanced-optimization
description: Advanced React Native optimization with data-driven profiling, FPS/TTI metrics, Concurrent React, New Architecture, and production-grade tooling
license: MIT
compatibility: "Requires: React Native 0.76+, New Architecture enabled, Expo SDK 52+, Xcode Instruments, Android Studio Profiler"
---

# React Native Advanced Optimization

## Overview

Master data-driven React Native optimization using advanced profiling techniques, focusing on two critical metrics: **FPS (Frames Per Second)** for runtime fluidity and **TTI (Time to Interactive)** for startup speed. Move beyond intuitive guessing to professional-grade performance engineering.

## When to Use This Skill

- Need to achieve consistent 60 FPS (16.6ms per frame)
- App startup time (TTI) is too slow
- Profiling with Xcode Instruments or Android Studio Profiler
- Migrating to New Architecture (Fabric + Turbo Modules)
- Implementing Concurrent React patterns
- Using atomic state management (Jotai/Zustand)
- Optimizing Android APK/AAB size with R8
- Hunting memory leaks with native profilers
- Understanding threading models (UI, JS, Native Modules)

**Key insight**: ~80% of performance issues originate on the JavaScript side, not native code.

## Workflow

### Step 1: Measure Key Metrics (FPS & TTI)

**FPS (Frames Per Second)** - Target: 60 FPS (16.6ms per frame)

```bash
# Enable React Perf Monitor (Dev Menu)
# Shows live FPS for UI thread and JS thread

# Or use Flashlight (Android)
npx flashlight measure --bundleId com.yourapp --duration 30
```

**TTI (Time to Interactive)** - Measure startup performance

```bash
npm install react-native-performance
```

```typescript
import { PerformanceObserver, performance } from 'react-native-performance';

// Set markers across initialization pipeline
performance.mark('nativeLaunchStart');  // Native process init
performance.mark('jsLoadStart');        // JS bundle loading
performance.mark('screenInteractive');  // Screen becomes usable

// Measure TTI
const observer = new PerformanceObserver((list) => {
  const entries = list.getEntries();
  entries.forEach((entry) => {
    console.log(`${entry.name}: ${entry.duration}ms`);
  });
});

observer.observe({ entryTypes: ['measure'] });

performance.measure('TTI', 'nativeLaunchStart', 'screenInteractive');
```

### Step 2: Advanced Profiling with Native Tools

**React Native DevTools** - Identify redundant re-renders

```bash
npx react-devtools
```

- Use **Flame Graphs** to visualize component render times
- Check **"Ranked" view** to see which components rendered most
- Use **"Why did this render?"** to identify unnecessary updates
- **Memory tab**: Hunt JavaScript memory leaks

**Xcode Instruments (iOS)** - Deep native profiling

```bash
# Build app
npx expo run:ios

# Open Instruments
# Product → Profile (⌘+I)
```

**Key templates:**
- **Time Profiler**: Identify CPU hotspots (slowest functions)
- **Leaks**: Find native memory leaks
- **Allocations**: Track memory allocation patterns

**How to use:**
1. Record a session while interacting with app
2. Look for "heavy" stack traces in Time Profiler
3. In Leaks, red bars indicate memory leaks - click to inspect
4. In Allocations, filter by "Created & Still Living" to find leaks

**Android Studio Profiler**

```bash
# Build app
npx expo run:android

# Open Android Studio
# View → Tool Windows → Profiler
```

**Features:**
- **CPU Profiler**: Trace method calls, find hotspots
- **Memory Profiler**: Track heap allocations, force GC, find leaks
- **Network Profiler**: Monitor API calls and data transfer

**Perfetto** - System-level Android tracing

```bash
# Capture trace on device
adb shell perfetto --out /data/misc/perfetto-traces/trace

# Download trace
adb pull /data/misc/perfetto-traces/trace .

# Open in browser
open https://ui.perfetto.dev/
```

### Step 3: Concurrent React Patterns

**useTransition** - Prioritize urgent UI updates

```typescript
import { useTransition, useState } from 'react';

function SearchScreen() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);
  const [isPending, startTransition] = useTransition();

  const handleSearch = (text: string) => {
    setQuery(text);  // Urgent: update input immediately

    startTransition(() => {
      // Non-urgent: heavy search can be deferred
      const filtered = data.filter(item =>
        item.name.toLowerCase().includes(text.toLowerCase())
      );
      setResults(filtered);
    });
  };

  return (
    <View>
      <TextInput
        value={query}
        onChangeText={handleSearch}  // Always responsive!
      />

      {isPending && <ActivityIndicator />}

      <FlatList data={results} />
    </View>
  );
}
```

**useDeferredValue** - Defer expensive re-renders

```typescript
import { useDeferredValue, useMemo } from 'react';

function ChartComponent({ data }) {
  // Defer chart updates when data changes rapidly
  const deferredData = useDeferredValue(data);

  const chartData = useMemo(() => {
    // Expensive calculation only runs when deferredData changes
    return processChartData(deferredData);
  }, [deferredData]);

  return <Chart data={chartData} />;
}
```

**Difference:**
- `useTransition`: Mark state updates as low-priority
- `useDeferredValue`: Defer a value that changes frequently

### Step 4: Atomic State Management

**Problem**: Global state changes trigger entire tree re-renders

**Solution**: Use Jotai or Zustand for atomic state

**Jotai** - Atomic state units

```typescript
import { atom, useAtom } from 'jotai';

// Each atom is independent
const nameAtom = atom('John');
const ageAtom = atom(25);
const emailAtom = atom('john@example.com');

function UserProfile() {
  const [name] = useAtom(nameAtom);  // Only re-renders when name changes

  return <Text>{name}</Text>;
}

function AgeDisplay() {
  const [age] = useAtom(ageAtom);  // Independent - won't re-render when name changes!

  return <Text>{age}</Text>;
}
```

**Zustand** - Simple stores

```typescript
import { create } from 'zustand';

const useStore = create((set) => ({
  name: 'John',
  age: 25,
  setName: (name) => set({ name }),
  setAge: (age) => set({ age }),
}));

function UserProfile() {
  // Only subscribes to 'name' - won't re-render on age changes
  const name = useStore((state) => state.name);

  return <Text>{name}</Text>;
}
```

### Step 5: New Architecture (Fabric + Turbo Modules)

**Why**: Enables synchronous JS ↔ Native communication (no more async bridge)

**Enable New Architecture:**

```bash
# For Expo SDK 52+ (enabled by default for new projects)
npx expo prebuild --clean

# Verify in android/gradle.properties
newArchEnabled=true

# Verify in ios/Podfile
:newArchEnabled => true
```

**Turbo Modules** - Synchronous native calls

```typescript
// Old Bridge (async)
const result = await NativeModules.MyModule.getValue();  // Slow!

// Turbo Modules (sync)
import { TurboModuleRegistry } from 'react-native';
const MyModule = TurboModuleRegistry.get('MyModule');
const result = MyModule.getValue();  // Instant!
```

**Fabric** - C++ renderer

- Direct manipulation of Shadow Tree
- Synchronous layout calculations
- Better interop with native views

**Check if New Architecture is enabled:**

```typescript
import { Platform } from 'react-native';

const isNewArchEnabled = (global as any).RN$Bridgeless === true;
console.log('New Architecture:', isNewArchEnabled);
```

### Step 6: InteractionManager for Long Tasks

**Problem**: Long-running tasks block UI and drop frames

**Solution**: Schedule after animations complete

```typescript
import { InteractionManager } from 'react-native';

function DataScreen() {
  useEffect(() => {
    // Wait for animations to complete
    const task = InteractionManager.runAfterInteractions(() => {
      // Heavy operation - won't block UI
      processLargeDataset();
      generateComplexReport();
    });

    return () => task.cancel();
  }, []);
}
```

**Use cases:**
- Loading large datasets after screen transitions
- Complex calculations after user interactions
- Background processing that doesn't need immediate results

### Step 7: Tree Shaking and Bundle Optimization

**Tree Shaking** - Remove dead code from bundle

```bash
# Expo SDK 52+ (experimental)
npx expo export --tree-shaking

# Or use Re.Pack
npm install @callstack/repack
```

**Avoid Barrel Exports** - They bloat bundles

```typescript
// ❌ BAD: index.ts barrel export
export * from './ComponentA';
export * from './ComponentB';
export * from './ComponentC';

// When you import ONE component:
import { ComponentA } from './components';

// Metro evaluates ALL exports, increasing bundle size!

// ✅ GOOD: Direct imports
import { ComponentA } from './components/ComponentA';
```

**Why barrel exports are slow:**
1. Metro evaluates every module in the file
2. Increases bundle size with unused code
3. Adds runtime overhead

### Step 8: Android-Specific Optimizations

**Disable JS Bundle Compression** - Faster TTI with memory mapping

Edit `android/app/build.gradle`:

```gradle
android {
    // Add this
    aaptOptions {
        noCompress "bundle"
    }
}
```

**Why**: Hermes engine can use memory mapping for uncompressed bundles, reducing TTI by ~300ms.

**Enable R8** - Shrink, optimize, obfuscate

Edit `android/gradle.properties`:

```properties
android.enableR8=true
android.enableR8.fullMode=true
```

**What R8 does:**
1. **Code shrinking**: Remove unused classes and methods
2. **Obfuscation**: Rename classes/methods to short names
3. **Resource minification**: Remove unused resources

**Asset Optimization** - App Thinning

**iOS - Xcode Asset Catalogs:**

```bash
# Move images from assets/ to Xcode Asset Catalog
# Xcode automatically delivers only needed resolutions (1x, 2x, 3x)
```

**Android - Density folders:**

```
android/app/src/main/res/
  drawable-mdpi/    (1x)
  drawable-hdpi/    (1.5x)
  drawable-xhdpi/   (2x)
  drawable-xxhdpi/  (3x)
  drawable-xxxhdpi/ (4x)
```

Device only downloads its specific density, reducing APK size.

### Step 9: High-Performance Lists

**Legend List** - Next-gen list for New Architecture

```bash
npm install @legendapp/list
```

```typescript
import { List } from '@legendapp/list';

function ProductList({ products }) {
  return (
    <List
      data={products}
      renderItem={({ item }) => <ProductCard product={item} />}
      estimatedItemSize={100}
    />
  );
}
```

**Why Legend List:**
- Built specifically for New Architecture
- Even faster than FlashList
- Better memory management
- Smoother scrolling with thousands of items

**FlashList** - Still excellent for current projects

```bash
npm install @shopify/flash-list
```

```typescript
import { FlashList } from '@shopify/flash-list';

<FlashList
  data={items}
  renderItem={({ item }) => <ItemCard item={item} />}
  estimatedItemSize={80}
/>
```

### Step 10: Memory Leak Hunting

**JavaScript Leaks** - Use React DevTools Profiler

Common causes:
- Event listeners not removed
- Timers not cleared
- Closures holding references

```typescript
// ❌ Memory leak
useEffect(() => {
  window.addEventListener('resize', handleResize);
  // Missing cleanup!
}, []);

// ✅ Fixed
useEffect(() => {
  window.addEventListener('resize', handleResize);
  return () => window.removeEventListener('resize', handleResize);
}, []);
```

**Native Leaks** - Use Xcode Instruments (Leaks template)

1. Record while using app
2. Red bars indicate leaks
3. Click leak to see allocation stack trace
4. Check for:
   - Retain cycles in Swift/Obj-C
   - Missing `unregisterObserver` calls
   - Strong references in blocks/closures

## Guidelines

**Do:**
- Measure FPS and TTI before optimizing (data-driven)
- Use React DevTools flame graphs to find redundant renders
- Profile with native tools (Xcode Instruments, Android Studio Profiler)
- Use Concurrent React (useTransition, useDeferredValue) for heavy computations
- Adopt atomic state (Jotai/Zustand) to prevent full-tree re-renders
- Enable New Architecture for synchronous JS ↔ Native
- Use InteractionManager for long-running tasks
- Implement tree shaking (Expo SDK 52+ or Re.Pack)
- Avoid barrel exports (use direct imports)
- Enable R8 on Android for code shrinking
- Use Legend List or FlashList for high-performance lists
- Disable JS bundle compression on Android (Hermes memory mapping)
- Use Asset Catalogs for app thinning

**Don't:**
- Don't guess bottlenecks - always profile first
- Don't ignore native profilers (Instruments, Android Studio)
- Don't use global state for everything (causes full re-renders)
- Don't run heavy computations on JS thread during interactions
- Don't use barrel exports (index.ts re-exporting everything)
- Don't compress JS bundle on Android (breaks Hermes optimization)
- Don't skip R8 on production builds
- Don't use FlatList for 1000+ items (use FlashList or Legend List)
- Don't test performance in development mode (enable production mode)

## Examples

### TTI Measurement Setup

```typescript
// App.tsx
import { PerformanceObserver, performance } from 'react-native-performance';

export default function App() {
  useEffect(() => {
    // Mark initialization complete
    performance.mark('appReady');

    // Measure from native launch to app ready
    performance.measure('TTI', 'nativeLaunchStart', 'appReady');

    const observer = new PerformanceObserver((list) => {
      list.getEntries().forEach((entry) => {
        console.log(`📊 ${entry.name}: ${entry.duration.toFixed(2)}ms`);

        // Send to analytics
        analytics.trackTiming('performance', entry.name, entry.duration);
      });
    });

    observer.observe({ entryTypes: ['measure'] });

    return () => observer.disconnect();
  }, []);

  return <NavigationContainer>{/* ... */}</NavigationContainer>;
}
```

### Concurrent React Search

```typescript
import { useTransition, useState, useMemo } from 'react';

function SmartSearch({ data }) {
  const [query, setQuery] = useState('');
  const [isPending, startTransition] = useTransition();

  const handleSearch = (text: string) => {
    setQuery(text);  // Urgent: keep input responsive

    startTransition(() => {
      // Non-urgent: heavy filtering can be deferred
      // React will interrupt this if user keeps typing
    });
  };

  const results = useMemo(() => {
    if (!query) return data;

    return data.filter(item =>
      item.name.toLowerCase().includes(query.toLowerCase())
    );
  }, [query, data]);

  return (
    <View>
      <TextInput
        value={query}
        onChangeText={handleSearch}
        placeholder="Search..."
      />

      {isPending && <Text>Searching...</Text>}

      <FlashList
        data={results}
        renderItem={({ item }) => <ResultCard item={item} />}
        estimatedItemSize={80}
      />
    </View>
  );
}
```

### Atomic State with Jotai

```typescript
import { atom, useAtom } from 'jotai';

// Split state into independent atoms
const userNameAtom = atom('');
const userAgeAtom = atom(0);
const userEmailAtom = atom('');
const userAvatarAtom = atom('');

// Derived atom (computed)
const userDisplayAtom = atom((get) => {
  const name = get(userNameAtom);
  const age = get(userAgeAtom);
  return `${name} (${age})`;
});

function ProfileName() {
  const [name, setName] = useAtom(userNameAtom);
  // Only re-renders when name changes - NOT when age/email/avatar change!

  return <TextInput value={name} onChangeText={setName} />;
}

function ProfileAge() {
  const [age, setAge] = useAtom(userAgeAtom);
  // Independent - won't re-render when name changes!

  return <TextInput value={String(age)} />;
}

function ProfileDisplay() {
  const [display] = useAtom(userDisplayAtom);
  // Only re-renders when name OR age change

  return <Text>{display}</Text>;
}
```

### InteractionManager for Heavy Tasks

```typescript
import { InteractionManager } from 'react-native';

function ExpensiveDataScreen() {
  const [data, setData] = useState(null);

  useEffect(() => {
    // Wait for screen transition to complete
    const task = InteractionManager.runAfterInteractions(() => {
      // Heavy operations that would drop frames
      const processed = processLargeDataset();
      const analytics = generateAnalytics(processed);
      const charts = createChartData(analytics);

      setData(charts);
    });

    return () => task.cancel();
  }, []);

  if (!data) return <LoadingSpinner />;

  return <ChartView data={data} />;
}
```

## Resources

- [React Native Performance](https://reactnative.dev/docs/performance)
- [New Architecture](https://reactnative.dev/docs/the-new-architecture/landing-page)
- [React Concurrent Features](https://react.dev/reference/react/useTransition)
- [Jotai Documentation](https://jotai.org/)
- [Zustand Documentation](https://zustand-demo.pmnd.rs/)
- [Flashlight](https://github.com/bamlab/flashlight)
- [react-native-performance](https://github.com/oblador/react-native-performance)
- [Legend List](https://legendapp.com/open-source/list/)
- [Re.Pack](https://re-pack.dev/)

## Tools & Commands

**Profiling:**
- `npx react-devtools` - React component profiling
- `npx flashlight measure` - Android FPS/CPU/RAM profiling
- Xcode Instruments - iOS native profiling (⌘+I)
- Android Studio Profiler - Android native profiling

**Performance Measurement:**
- `npm install react-native-performance` - TTI tracking
- React Perf Monitor (Dev Menu) - Live FPS display

**Bundle Analysis:**
- `npm install -g bundlephobia` - Check package sizes
- Import Cost (VS Code extension) - Inline package sizes
- Ruler (Gradle plugin) - Android APK/AAB size analysis
- Emerge Tools - Deep binary size analysis (paid)

**Build Optimization:**
- `npx expo export --tree-shaking` - Dead code elimination (SDK 52+)
- `npm install @callstack/repack` - Webpack-based bundler with tree shaking
- R8 (enabled in gradle.properties) - Android code shrinking

## Troubleshooting

### Poor FPS despite optimization

**Problem**: App still drops frames even after memoization

**Solution**:
```typescript
// Move heavy work OFF the JS thread
import { runOnUI } from 'react-native-reanimated';

// ❌ Runs on JS thread - blocks UI
const calculate = () => {
  return heavyCalculation(data);
};

// ✅ Runs on UI thread using Reanimated worklet
const calculate = runOnUI(() => {
  'worklet';
  return heavyCalculation(data);
});
```

### High TTI (slow startup)

**Problem**: App takes too long to become interactive

**Solution**:
```bash
# 1. Measure with react-native-performance to identify bottleneck
# 2. Check bundle size with Expo Atlas
EXPO_ATLAS=true npx expo export

# 3. Enable Android optimizations
# android/gradle.properties
newArchEnabled=true
android.enableR8.fullMode=true

# android/app/build.gradle
aaptOptions {
    noCompress "bundle"
}

# 4. Lazy load heavy screens
const HeavyScreen = lazy(() => import('./HeavyScreen'));
```

### Memory leaks not found with React DevTools

**Problem**: Native memory leak invisible to JS profiler

**Solution**:
```bash
# iOS: Use Xcode Instruments Leaks template
# 1. Build: npx expo run:ios
# 2. Profile: Product → Profile (⌘+I)
# 3. Select "Leaks" template
# 4. Record while using app
# 5. Red bars = leaks, click to see stack trace

# Android: Use Android Studio Profiler
# 1. Build: npx expo run:android
# 2. Open Android Studio → Profiler
# 3. Select Memory profiler
# 4. Force GC and check "Created & Still Living" objects
```

---

## Notes

- **80% of performance issues** are on the JavaScript side, not native
- **FPS**: Aim for 60 FPS (16.6ms per frame budget)
- **TTI**: Measure from native launch to screen interactive
- **New Architecture** enables synchronous JS ↔ Native (no bridge delay)
- **Concurrent React** prioritizes urgent UI updates over heavy computations
- **Atomic state** prevents full component tree re-renders
- **InteractionManager** schedules tasks after animations complete
- **Tree shaking** removes dead code from production bundles
- **Barrel exports** cause Metro to evaluate all modules (avoid them)
- **R8** shrinks Android APK by 30-50% with obfuscation
- **Legend List** is optimized for New Architecture (faster than FlashList)
- **Memory leaks** require native profilers (Instruments, Android Studio)
- Always **profile in production mode** for accurate measurements
