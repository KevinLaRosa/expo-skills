# React Native & Expo Performance Audit Checklist

## Bundle Size Optimization

### JavaScript Bundle Analysis
- [ ] Run `npx react-native-bundle-visualizer` to analyze bundle composition
- [ ] Check for duplicate dependencies in package.json
- [ ] Identify large dependencies that could be replaced with lighter alternatives
- [ ] Remove unused dependencies and dead code
- [ ] Enable Hermes engine (enabled by default in Expo SDK 48+)

### Code Splitting & Lazy Loading
- [ ] Implement lazy loading for screens using `React.lazy()` and `Suspense`
- [ ] Defer loading of non-critical libraries until needed
- [ ] Split large components into smaller, lazy-loaded chunks
- [ ] Use dynamic imports for heavy features (charts, maps, etc.)

```javascript
// Example: Lazy load heavy components
const ChartScreen = React.lazy(() => import('./screens/ChartScreen'));

function App() {
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <ChartScreen />
    </Suspense>
  );
}
```

### Asset Optimization
- [ ] Compress images and use appropriate formats (WebP, AVIF)
- [ ] Use vector graphics (SVG) for icons instead of PNGs
- [ ] Implement proper image caching strategies
- [ ] Use blurhash or similar for image placeholders
- [ ] Remove unused assets from the bundle

## JavaScript Performance

### Re-render Prevention
- [ ] Use `React.memo()` for components that receive stable props
- [ ] Implement `useMemo()` for expensive calculations
- [ ] Use `useCallback()` for functions passed as props
- [ ] Avoid inline object/array creation in render methods
- [ ] Use React DevTools Profiler to identify unnecessary re-renders

```javascript
// Bad: Creates new object on every render
<Component style={{ marginTop: 10 }} />

// Good: Stable reference
const styles = StyleSheet.create({
  container: { marginTop: 10 }
});
<Component style={styles.container} />
```

### List Performance
- [ ] Replace FlatList with FlashList for better performance
- [ ] Implement proper `keyExtractor` for lists
- [ ] Use `getItemLayout` for fixed-height items
- [ ] Optimize `renderItem` with React.memo
- [ ] Set appropriate `windowSize` and `maxToRenderPerBatch`
- [ ] Avoid anonymous functions in renderItem

```javascript
import { FlashList } from "@shopify/flash-list";

<FlashList
  data={items}
  renderItem={renderItem} // Memoized function
  estimatedItemSize={100}
  keyExtractor={keyExtractor}
/>
```

### State Management
- [ ] Avoid unnecessary global state
- [ ] Use context selectors to prevent cascading re-renders
- [ ] Consider state colocation (keep state close to where it's used)
- [ ] Use atomic state updates instead of large object merges
- [ ] Implement proper state normalization for complex data

### Animation Performance
- [ ] Use Reanimated 2+ for all animations (runs on UI thread)
- [ ] Avoid Animated API for complex animations
- [ ] Use `useAnimatedStyle` and worklets
- [ ] Implement native driver animations where possible
- [ ] Avoid animating layout properties (use transforms instead)

```javascript
import Animated, { useAnimatedStyle, withSpring } from 'react-native-reanimated';

const animatedStyle = useAnimatedStyle(() => ({
  transform: [{ translateX: withSpring(position.value) }]
}));
```

## Native Performance

### Bridge Communication
- [ ] Minimize bridge calls between JS and native code
- [ ] Batch native operations when possible
- [ ] Use TurboModules for performance-critical native modules
- [ ] Avoid synchronous bridge calls
- [ ] Monitor bridge traffic using performance tools

### Native Modules
- [ ] Audit third-party native modules for performance issues
- [ ] Check for memory leaks in native code
- [ ] Ensure proper cleanup in native module lifecycle
- [ ] Use JSI (JavaScript Interface) for direct JS-to-native calls
- [ ] Consider Expo Modules API for better performance

### Image Handling
- [ ] Use `expo-image` or `react-native-fast-image` for better caching
- [ ] Implement progressive image loading
- [ ] Set appropriate image cache policies
- [ ] Use placeholder images (blurhash, thumbhash)
- [ ] Resize images to display dimensions

```javascript
import { Image } from 'expo-image';

<Image
  source={uri}
  placeholder={blurhash}
  contentFit="cover"
  transition={1000}
  cachePolicy="memory-disk"
/>
```

## Network Performance

### API Optimization
- [ ] Implement request caching (React Query, SWR, Apollo)
- [ ] Use pagination for large datasets
- [ ] Implement proper loading and error states
- [ ] Add request debouncing for search/autocomplete
- [ ] Use GraphQL to fetch only needed data

### Prefetching & Background Sync
- [ ] Prefetch data for likely next screens
- [ ] Implement background data sync
- [ ] Use stale-while-revalidate pattern
- [ ] Cache API responses appropriately
- [ ] Implement optimistic updates

```javascript
import { useQuery } from '@tanstack/react-query';

const { data } = useQuery({
  queryKey: ['user', userId],
  queryFn: fetchUser,
  staleTime: 5 * 60 * 1000, // 5 minutes
  cacheTime: 10 * 60 * 1000, // 10 minutes
});
```

### Data Compression
- [ ] Enable gzip/brotli compression on API responses
- [ ] Minimize payload sizes (remove unnecessary fields)
- [ ] Use efficient data formats (Protocol Buffers vs JSON)
- [ ] Implement incremental data loading

## Startup Time Optimization

### App Launch Performance
- [ ] Measure time to interactive (TTI)
- [ ] Defer non-critical initialization
- [ ] Lazy load heavy dependencies
- [ ] Optimize splash screen duration
- [ ] Use Hermes bytecode precompilation

### Initial Bundle Loading
- [ ] Enable inline requires (Metro bundler optimization)
- [ ] Split bundles for different platforms
- [ ] Implement progressive bundle loading
- [ ] Minimize main bundle size
- [ ] Use RAM bundles for large apps

```javascript
// metro.config.js
module.exports = {
  transformer: {
    getTransformOptions: async () => ({
      transform: {
        experimentalImportSupport: false,
        inlineRequires: true, // Enable inline requires
      },
    }),
  },
};
```

### First Render Optimization
- [ ] Minimize component tree depth
- [ ] Avoid heavy computations in initial render
- [ ] Use skeleton screens for loading states
- [ ] Defer rendering of below-the-fold content
- [ ] Optimize fonts loading (use system fonts initially)

## Memory Management

### Memory Leak Detection
- [ ] Use Flashlight or React DevTools Profiler to monitor memory
- [ ] Check for lingering event listeners
- [ ] Verify cleanup in useEffect hooks
- [ ] Monitor growing heap size over time
- [ ] Test navigation flows for memory retention

### Memory Optimization
- [ ] Implement proper cleanup in unmount
- [ ] Unsubscribe from observables/listeners
- [ ] Clear timers and intervals
- [ ] Release large objects when no longer needed
- [ ] Monitor image cache size

```javascript
useEffect(() => {
  const subscription = eventEmitter.addListener('event', handler);

  return () => {
    subscription.remove(); // Cleanup
  };
}, []);
```

### Large Data Handling
- [ ] Implement pagination for large lists
- [ ] Use virtualized lists (FlashList)
- [ ] Clear old data when navigating away
- [ ] Implement data pruning strategies
- [ ] Monitor memory usage with large datasets

## Platform-Specific Optimizations

### iOS Specific
- [ ] Test on older devices (iPhone 8, iPhone X)
- [ ] Optimize for iOS 15+ features
- [ ] Check for Metal rendering issues
- [ ] Test keyboard handling performance
- [ ] Verify smooth scrolling on all screen sizes

### Android Specific
- [ ] Enable Hermes engine
- [ ] Test on low-end devices (2GB RAM)
- [ ] Optimize for Android 10+ (API 29+)
- [ ] Check for overdraw issues
- [ ] Test with different Android versions
- [ ] Enable Proguard/R8 for production builds

## Production Build Optimizations

### Release Configuration
- [ ] Enable production mode (`__DEV__` false)
- [ ] Enable code minification
- [ ] Remove console.log statements
- [ ] Enable dead code elimination
- [ ] Use production-optimized libraries

### Build Settings
- [ ] Configure proper app signing
- [ ] Enable bytecode optimization (Hermes)
- [ ] Set appropriate build optimizations
- [ ] Remove debug symbols from release builds
- [ ] Enable resource shrinking

```javascript
// babel.config.js - Remove console logs in production
module.exports = {
  presets: ['babel-preset-expo'],
  plugins: [
    process.env.NODE_ENV === 'production' &&
      'transform-remove-console'
  ].filter(Boolean),
};
```

## Monitoring & Metrics

### Performance Metrics
- [ ] Track app startup time
- [ ] Monitor frame rate (target 60 FPS)
- [ ] Measure time to interactive (TTI)
- [ ] Track bundle size over time
- [ ] Monitor memory usage patterns

### User Experience Metrics
- [ ] Measure screen transition times
- [ ] Track scroll performance
- [ ] Monitor crash rates
- [ ] Analyze slow renders
- [ ] Track API response times

### Tools & Services
- [ ] Integrate Flashlight for performance testing
- [ ] Use React DevTools Profiler
- [ ] Set up Sentry or similar for error tracking
- [ ] Monitor with Firebase Performance
- [ ] Use Flipper for debugging

## Testing & Validation

### Performance Testing
- [ ] Test on real devices (not just simulators)
- [ ] Test on low-end devices
- [ ] Test with slow network conditions
- [ ] Test with large datasets
- [ ] Profile before and after optimizations

### Regression Prevention
- [ ] Set up performance budgets
- [ ] Automate performance tests in CI/CD
- [ ] Monitor bundle size in pull requests
- [ ] Track key performance metrics
- [ ] Document performance baselines
