# Flashlight Performance Testing Guide

Flashlight is a powerful tool for measuring React Native app performance on real devices. It provides detailed metrics about CPU usage, memory consumption, FPS, and network activity.

## Installation & Setup

### Prerequisites
- Physical iOS or Android device (required - simulators not supported)
- macOS (for iOS testing)
- Android Studio (for Android testing)
- Node.js 16+

### Install Flashlight

```bash
# Install globally
npm install -g @perf-profiler/profiler

# Or use with npx
npx @perf-profiler/profiler
```

### iOS Setup

1. Install dependencies:
```bash
# Install Flipper dependencies
brew install idb-companion

# Install additional tools
npm install -g ios-deploy
```

2. Connect your iOS device:
- Connect via USB
- Trust the computer on your device
- Ensure device is unlocked during testing

3. Verify device connection:
```bash
xcrun devicectl list devices
```

### Android Setup

1. Enable USB debugging on your device:
- Go to Settings > About Phone
- Tap "Build Number" 7 times to enable Developer Options
- Go to Settings > Developer Options
- Enable "USB Debugging"

2. Install ADB:
```bash
brew install android-platform-tools
```

3. Verify device connection:
```bash
adb devices
```

## Running Performance Tests

### Basic Test

```bash
# Start profiling
flashlight test

# Or specify the app bundle ID
flashlight test --bundleId com.yourapp.example
```

### Test Specific Interactions

```bash
# Record a specific flow (e.g., 30 seconds)
flashlight test --duration 30000

# Test with custom iteration count
flashlight test --iterationCount 10
```

### Automated Testing with Maestro

Flashlight works great with Maestro for automated UI testing:

```bash
# Install Maestro
brew tap mobile-dev-inc/tap
brew install maestro

# Run performance test with Maestro flow
flashlight test --bundleId com.yourapp --beforeEach "maestro test flow.yaml"
```

Example Maestro flow (`flow.yaml`):
```yaml
appId: com.yourapp
---
- launchApp
- tapOn: "Home Tab"
- scroll
- tapOn: "Settings"
- back
- tapOn: "Profile"
- scroll
```

### Platform-Specific Commands

#### iOS
```bash
# Specify device by UDID
flashlight test --deviceId <UDID>

# Test specific app
flashlight test --bundleId com.yourapp.example
```

#### Android
```bash
# Specify device by serial
flashlight test --deviceId <DEVICE_SERIAL>

# Test specific app
flashlight test --appId com.yourapp.example
```

## Understanding Metrics

### Frame Rate (FPS)

**What it measures:** Frames rendered per second

**Target:** 60 FPS (or 120 FPS on ProMotion displays)

**Interpretation:**
- **60 FPS:** Smooth, optimal performance
- **45-59 FPS:** Noticeable jank, needs investigation
- **Below 45 FPS:** Poor performance, serious issues

**Common causes of low FPS:**
- Heavy JavaScript computations on main thread
- Inefficient list rendering
- Too many re-renders
- Complex layout calculations
- Unoptimized animations

```javascript
// Bad: Animation on JS thread
Animated.timing(value, {
  toValue: 100,
  useNativeDriver: false, // Runs on JS thread
});

// Good: Animation on UI thread
Animated.timing(value, {
  toValue: 100,
  useNativeDriver: true, // Runs on native thread
});
```

### CPU Usage

**What it measures:** Percentage of CPU used by the app

**Target:** Below 50% during normal operation

**Interpretation:**
- **0-30%:** Excellent, efficient app
- **30-50%:** Acceptable for active usage
- **50-70%:** High usage, check for inefficiencies
- **Above 70%:** Problematic, drains battery

**Common causes of high CPU:**
- Inefficient algorithms
- Too many re-renders
- Heavy computation in render
- Polling instead of event-driven updates
- Unoptimized image processing

### Memory Usage

**What it measures:** RAM consumption by the app

**Target:**
- Low-end devices: < 200MB
- Mid-range devices: < 300MB
- High-end devices: < 500MB

**Interpretation:**
- **Stable memory:** Good, no leaks
- **Slowly growing:** Potential memory leak
- **Rapidly growing:** Serious memory leak
- **Sudden spikes:** Large object allocation

**Common causes of high memory:**
- Memory leaks (event listeners, timers)
- Cached images without limits
- Large data structures in memory
- Retained navigation state
- Unoptimized component tree

```javascript
// Memory leak example
useEffect(() => {
  const interval = setInterval(() => {
    // Do something
  }, 1000);

  // Missing cleanup - MEMORY LEAK!
  // return () => clearInterval(interval);
});

// Fixed version
useEffect(() => {
  const interval = setInterval(() => {
    // Do something
  }, 1000);

  return () => clearInterval(interval); // Cleanup
}, []);
```

### Network Activity

**What it measures:** Network requests and data transfer

**Target:** Minimize requests, batch when possible

**Interpretation:**
- **Few requests:** Efficient data fetching
- **Many requests:** Consider batching/caching
- **Large payloads:** Optimize API responses
- **Slow requests:** Backend or network issues

**Optimization strategies:**
- Implement request caching
- Use GraphQL to fetch only needed data
- Batch multiple requests
- Enable compression (gzip/brotli)
- Prefetch anticipated data

### Startup Time

**What it measures:** Time from app launch to interactive

**Target:**
- Cold start: < 3 seconds
- Warm start: < 1 second

**Interpretation:**
- **Under 2s:** Excellent startup
- **2-4s:** Acceptable
- **4-6s:** Slow, needs optimization
- **Over 6s:** Very slow, critical issue

**Optimization strategies:**
- Enable Hermes bytecode
- Use inline requires
- Defer heavy initialization
- Lazy load screens
- Optimize splash screen

## Analyzing Results

### Web Report

Flashlight generates an interactive HTML report:

```bash
# Generate and open report
flashlight report
```

The report includes:
- FPS timeline graph
- CPU usage over time
- Memory consumption chart
- Network request waterfall
- Detailed statistics

### Interpreting Graphs

#### FPS Timeline
- Look for consistent drops below 60 FPS
- Identify specific user interactions causing jank
- Check if drops correlate with other metrics

#### CPU Usage
- Identify spikes during user interactions
- Check baseline usage when idle
- Compare before/after optimizations

#### Memory Graph
- Look for steady increases (memory leaks)
- Check for spikes when navigating
- Verify memory is released after navigation

#### Network Waterfall
- Identify slow requests
- Look for redundant requests
- Check request timing and dependencies

### Performance Score

Flashlight provides an overall score based on:
- Average FPS
- CPU efficiency
- Memory stability
- Startup time

**Score ranges:**
- **90-100:** Excellent performance
- **70-89:** Good performance
- **50-69:** Needs improvement
- **Below 50:** Poor performance

## Common Performance Patterns

### Pattern 1: FPS Drops During Scroll

**Symptoms:**
- FPS drops when scrolling lists
- Stuttering or jank visible to users

**Diagnosis:**
```bash
# Test scrolling performance
flashlight test --scenario scroll
```

**Solutions:**
- Use FlashList instead of FlatList
- Implement `getItemLayout` for fixed-height items
- Memoize renderItem components
- Reduce complexity of list items
- Use `windowSize` optimization

```javascript
import { FlashList } from "@shopify/flash-list";

const renderItem = React.memo(({ item }) => (
  <ListItem data={item} />
));

<FlashList
  data={items}
  renderItem={renderItem}
  estimatedItemSize={100}
/>
```

### Pattern 2: High CPU on Screen Transition

**Symptoms:**
- CPU spikes when navigating between screens
- Slow animation during transitions

**Diagnosis:**
- Monitor CPU during navigation
- Check for heavy initial renders

**Solutions:**
- Lazy load screen components
- Defer heavy initialization
- Use skeleton screens
- Optimize navigation animations

```javascript
const HeavyScreen = React.lazy(() => import('./HeavyScreen'));

<Suspense fallback={<SkeletonScreen />}>
  <HeavyScreen />
</Suspense>
```

### Pattern 3: Growing Memory Usage

**Symptoms:**
- Memory increases over time
- App crashes after extended use

**Diagnosis:**
```bash
# Test memory over extended session
flashlight test --duration 60000
```

**Solutions:**
- Add cleanup in useEffect
- Unsubscribe from event listeners
- Clear timers and intervals
- Implement proper navigation cleanup

```javascript
useEffect(() => {
  const subscription = API.subscribe(data => {
    setData(data);
  });

  return () => {
    subscription.unsubscribe(); // Cleanup
  };
}, []);
```

### Pattern 4: Slow Startup Time

**Symptoms:**
- App takes too long to become interactive
- White screen or splash screen persists

**Diagnosis:**
- Measure time to interactive
- Profile initial bundle execution

**Solutions:**
- Enable Hermes engine
- Use inline requires
- Lazy load heavy libraries
- Defer non-critical initialization

```javascript
// metro.config.js
module.exports = {
  transformer: {
    getTransformOptions: async () => ({
      transform: {
        inlineRequires: true,
      },
    }),
  },
};
```

## Creating Performance Reports

### Automated Testing in CI/CD

```yaml
# .github/workflows/performance.yml
name: Performance Tests

on:
  pull_request:
    branches: [main]

jobs:
  performance:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: 18

      - name: Install dependencies
        run: npm ci

      - name: Install Flashlight
        run: npm install -g @perf-profiler/profiler

      - name: Run performance tests
        run: |
          flashlight test --bundleId com.yourapp \
            --duration 30000 \
            --output performance-report.json

      - name: Upload report
        uses: actions/upload-artifact@v3
        with:
          name: performance-report
          path: performance-report.json
```

### Comparing Before/After

```bash
# Baseline test
flashlight test --output baseline.json

# Make optimizations...

# Test again
flashlight test --output optimized.json

# Compare results
flashlight compare baseline.json optimized.json
```

### Custom Reports

```javascript
// analyze-performance.js
const fs = require('fs');
const report = JSON.parse(fs.readFileSync('performance-report.json'));

const avgFPS = report.measures.fps.average;
const avgCPU = report.measures.cpu.average;
const avgMemory = report.measures.ram.average;

console.log(`Average FPS: ${avgFPS}`);
console.log(`Average CPU: ${avgCPU}%`);
console.log(`Average Memory: ${avgMemory}MB`);

// Set performance budget thresholds
if (avgFPS < 55) {
  console.error('FPS below threshold!');
  process.exit(1);
}
```

## Best Practices

### Testing Strategy

1. **Test on real devices:** Simulators don't reflect real performance
2. **Test on low-end devices:** Performance issues show up more clearly
3. **Test realistic scenarios:** Use actual user flows
4. **Test with real data:** Use production-like dataset sizes
5. **Test network conditions:** Simulate slow/unreliable networks

### Continuous Monitoring

- Run performance tests on every PR
- Set up performance budgets
- Track metrics over time
- Alert on regressions
- Document baselines

### Optimization Workflow

1. **Measure baseline:** Get current performance metrics
2. **Identify bottlenecks:** Find worst-performing areas
3. **Prioritize fixes:** Focus on high-impact issues
4. **Implement changes:** Make targeted optimizations
5. **Measure again:** Verify improvements
6. **Prevent regressions:** Add tests to prevent future issues

## Troubleshooting

### Device Not Detected

**iOS:**
```bash
# Check device connection
xcrun devicectl list devices

# Reset trust settings
xcrun devicectl device info trust
```

**Android:**
```bash
# Check ADB connection
adb devices

# Reset ADB
adb kill-server
adb start-server
```

### App Not Launching

- Verify bundle ID is correct
- Ensure app is installed on device
- Check device is unlocked
- Verify developer certificates

### Inconsistent Results

- Close other apps on device
- Disable battery saver mode
- Run multiple iterations
- Allow device to cool between tests
- Use consistent starting state

## Resources

- [Flashlight Documentation](https://github.com/bamlab/flashlight)
- [React Native Performance](https://reactnative.dev/docs/performance)
- [Expo Performance](https://docs.expo.dev/guides/performance/)
- [Maestro Testing](https://maestro.mobile.dev/)
