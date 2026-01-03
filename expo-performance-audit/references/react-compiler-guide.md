# React Compiler Guide for Expo

Complete guide to using React Compiler (formerly React Forget) in Expo applications for automatic performance optimization.

## Overview

React Compiler is an automatic optimization tool that analyzes your React components at build time and generates optimized code. It eliminates the need for manual memoization with `React.memo`, `useMemo`, and `useCallback`.

**Key Benefits**:
- ✅ Automatic memoization of components, functions, and values
- ✅ No need to manually add memo/useCallback/useMemo
- ✅ Reduces boilerplate and cognitive overhead
- ✅ Prevents common memoization mistakes (missing dependencies, etc.)
- ✅ Analyzes data flow and only re-renders when necessary

**Requirements**:
- Expo SDK 52+ (or React Native 0.76+)
- Node.js 18+
- Babel 7+

## Installation

### Step 1: Install Dependencies

```bash
# For Expo projects
npx expo install babel-plugin-react-compiler react-compiler-runtime

# For bare React Native
npm install -D babel-plugin-react-compiler
npm install react-compiler-runtime
```

### Step 2: Configure Babel

Add the React Compiler plugin to your `babel.config.js`:

```javascript
module.exports = function (api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      [
        'babel-plugin-react-compiler',
        {
          runtimeModule: 'react-compiler-runtime',
        },
      ],
    ],
  };
};
```

### Step 3: Verify Installation

```bash
# Clear Metro cache
npx expo start --clear

# Watch Metro logs for compilation messages
# You should see: [React Compiler] Compiled X components
```

## How React Compiler Works

### Automatic Component Memoization

**Before React Compiler** (manual memoization):

```typescript
import { memo } from 'react';

const UserCard = memo(({ user, onPress }) => {
  return (
    <View>
      <Text>{user.name}</Text>
      <Button title="View" onPress={() => onPress(user.id)} />
    </View>
  );
});
```

**After React Compiler** (automatic):

```typescript
// No memo needed - compiler handles it!
function UserCard({ user, onPress }) {
  return (
    <View>
      <Text>{user.name}</Text>
      <Button title="View" onPress={() => onPress(user.id)} />
    </View>
  );
}
```

### Automatic Callback Memoization

**Before React Compiler**:

```typescript
import { useCallback } from 'react';

function UserList({ users }) {
  const handlePress = useCallback((userId: string) => {
    console.log('User pressed:', userId);
    navigation.navigate('UserDetail', { userId });
  }, [navigation]);

  return (
    <FlashList
      data={users}
      renderItem={({ item }) => (
        <UserCard user={item} onPress={handlePress} />
      )}
    />
  );
}
```

**After React Compiler**:

```typescript
// No useCallback needed!
function UserList({ users }) {
  const handlePress = (userId: string) => {
    console.log('User pressed:', userId);
    navigation.navigate('UserDetail', { userId });
  };

  return (
    <FlashList
      data={users}
      renderItem={({ item }) => (
        <UserCard user={item} onPress={handlePress} />
      )}
    />
  );
}
```

### Automatic Value Memoization

**Before React Compiler**:

```typescript
import { useMemo } from 'react';

function ChartComponent({ data }) {
  const processedData = useMemo(() => {
    return data
      .filter(item => item.value > 0)
      .map(item => ({
        x: item.date,
        y: item.value,
      }))
      .sort((a, b) => a.x - b.x);
  }, [data]);

  return <LineChart data={processedData} />;
}
```

**After React Compiler**:

```typescript
// No useMemo needed!
function ChartComponent({ data }) {
  const processedData = data
    .filter(item => item.value > 0)
    .map(item => ({
      x: item.date,
      y: item.value,
    }))
    .sort((a, b) => a.x - b.x);

  return <LineChart data={processedData} />;
}
```

## Advanced Configuration

### Compilation Options

```javascript
// babel.config.js
module.exports = function (api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      [
        'babel-plugin-react-compiler',
        {
          runtimeModule: 'react-compiler-runtime',

          // Optional: Enable/disable specific features
          sources: (filename) => {
            // Only compile files in src/ directory
            return filename.includes('src/');
          },

          // Optional: Compilation mode
          compilationMode: 'annotation', // 'annotation' | 'infer' (default: 'infer')

          // Optional: Environment
          environment: {
            // Custom configuration for your runtime environment
          },
        },
      ],
    ],
  };
};
```

### Annotation Mode

Use annotation mode to selectively opt components into compilation:

```typescript
// babel.config.js - set compilationMode: 'annotation'

// Only compiled components need 'use memo' directive
function UserCard({ user }) {
  'use memo';  // ← Explicitly opt into compilation

  return (
    <View>
      <Text>{user.name}</Text>
    </View>
  );
}

// This component NOT compiled (no directive)
function SimpleText({ text }) {
  return <Text>{text}</Text>;
}
```

### Exclude Specific Files

```javascript
// babel.config.js
plugins: [
  [
    'babel-plugin-react-compiler',
    {
      runtimeModule: 'react-compiler-runtime',
      sources: (filename) => {
        // Don't compile third-party libraries
        if (filename.includes('node_modules')) {
          return false;
        }

        // Don't compile test files
        if (filename.includes('.test.')) {
          return false;
        }

        return true;
      },
    },
  ],
],
```

## What React Compiler Does NOT Do

React Compiler **only** optimizes React re-renders. It does **not** replace:

### ✅ Still Need FlashList

```typescript
// React Compiler doesn't optimize list rendering
// You STILL need FlashList for long lists
import { FlashList } from '@shopify/flash-list';

function UserList({ users }) {
  return (
    <FlashList  // ← STILL use FlashList!
      data={users}
      renderItem={({ item }) => <UserCard user={item} />}
      estimatedItemSize={100}
    />
  );
}
```

### ✅ Still Need Reanimated Worklets

```typescript
// React Compiler doesn't optimize animations
// You STILL need Reanimated worklets for 60fps
import Animated, { useAnimatedStyle, withSpring } from 'react-native-reanimated';

function AnimatedBox() {
  const animatedStyle = useAnimatedStyle(() => {  // ← STILL use worklets!
    return {
      transform: [{ translateX: withSpring(offset.value) }],
    };
  });

  return <Animated.View style={animatedStyle} />;
}
```

### ✅ Still Need Image Optimization

```typescript
// React Compiler doesn't optimize images
// You STILL need expo-image and WebP
import { Image } from 'expo-image';

function ProductImage({ url }) {
  return (
    <Image  // ← STILL use expo-image!
      source={{ uri: url }}
      contentFit="cover"
      cachePolicy="memory-disk"
    />
  );
}
```

## Best Practices

### 1. Start Fresh

React Compiler works best on new code. For existing projects:

```typescript
// ❌ Don't mix manual and automatic memoization
const UserCard = memo(({ user }) => {  // ← Remove memo
  const name = useMemo(() => user.name, [user.name]);  // ← Remove useMemo
  const handlePress = useCallback(() => {}, []);  // ← Remove useCallback

  return <View>{/* ... */}</View>;
});

// ✅ Let React Compiler handle it all
function UserCard({ user }) {
  const name = user.name;
  const handlePress = () => {};

  return <View>{/* ... */}</View>;
}
```

### 2. Remove Manual Optimizations

After enabling React Compiler, gradually remove manual memoization:

```bash
# Search for manual memoization in your codebase
grep -r "React.memo" src/
grep -r "useCallback" src/
grep -r "useMemo" src/

# Remove them one file at a time, testing after each
```

### 3. Trust the Compiler

Don't second-guess the compiler:

```typescript
// ❌ Don't do this - compiler already handles it
const Component = memo(({ data }) => {
  // Compiler already memoizes this automatically
});

// ✅ Just write clean code
function Component({ data }) {
  // Compiler optimizes automatically
}
```

### 4. Profile Before and After

Measure the impact:

```bash
# Before React Compiler
flashlight measure --bundleId com.yourapp --duration 30

# Enable React Compiler
# ...

# After React Compiler
flashlight measure --bundleId com.yourapp --duration 30

# Compare results
flashlight report
```

## Debugging

### Check Compilation Logs

```bash
# Start with verbose logging
REACT_COMPILER_DEBUG=1 npx expo start --clear

# Look for compilation messages
# [React Compiler] Compiled 42 components in src/components/
# [React Compiler] Skipped 3 components (external)
```

### Verify Component Compilation

```typescript
// Add logging to check if component is optimized
function UserCard({ user }) {
  console.log('UserCard render:', user.id);

  return <View>{/* ... */}</View>;
}

// If React Compiler is working:
// - Should only log when user prop actually changes
// - Should NOT log on parent re-renders
```

### Common Issues

**Issue: Component still re-rendering**

```typescript
// Check if parent is passing new object references
function Parent() {
  return (
    <UserCard
      user={user}
      metadata={{ createdAt: Date.now() }}  // ← NEW object every render!
    />
  );
}

// Fix: Move objects outside or use static values
const metadata = { createdAt: Date.now() };

function Parent() {
  return <UserCard user={user} metadata={metadata} />;
}
```

**Issue: Compiler not found**

```bash
# Verify installation
npm list babel-plugin-react-compiler react-compiler-runtime

# Reinstall if missing
npx expo install babel-plugin-react-compiler react-compiler-runtime

# Clear all caches
npx expo start --clear
rm -rf node_modules/.cache
```

## Migration Guide

### Step 1: Enable React Compiler

Follow installation steps above.

### Step 2: Remove Manual Memoization (Gradually)

```typescript
// Before
import { memo, useCallback, useMemo } from 'react';

const UserCard = memo(({ user, onPress }) => {
  const displayName = useMemo(() => {
    return `${user.firstName} ${user.lastName}`;
  }, [user.firstName, user.lastName]);

  const handlePress = useCallback(() => {
    onPress(user.id);
  }, [onPress, user.id]);

  return (
    <Pressable onPress={handlePress}>
      <Text>{displayName}</Text>
    </Pressable>
  );
});

// After (with React Compiler)
function UserCard({ user, onPress }) {
  const displayName = `${user.firstName} ${user.lastName}`;

  const handlePress = () => {
    onPress(user.id);
  };

  return (
    <Pressable onPress={handlePress}>
      <Text>{displayName}</Text>
    </Pressable>
  );
}
```

### Step 3: Test Thoroughly

```bash
# Run your test suite
npm test

# Manual testing
npx expo start

# Performance testing
flashlight measure --bundleId com.yourapp

# Memory profiling (check for leaks)
# iOS: Xcode Instruments
# Android: Android Studio Profiler
```

### Step 4: Monitor Production

```typescript
// Add Sentry performance monitoring
import * as Sentry from '@sentry/react-native';

Sentry.init({
  dsn: 'your-dsn',
  enableAutoSessionTracking: true,
  tracesSampleRate: 1.0,
});

// Monitor for performance regressions after deploying React Compiler
```

## Performance Comparison

### Before React Compiler

```typescript
// Manual memoization - easy to mess up
const UserList = memo(({ users }) => {
  const sortedUsers = useMemo(() => {
    return users.sort((a, b) => a.name.localeCompare(b.name));
  }, [users]);  // ← Forgot to add sort comparator to deps!

  const handlePress = useCallback((id) => {
    navigation.navigate('User', { id });
  }, []);  // ← Missing navigation dependency!

  return (
    <FlashList
      data={sortedUsers}
      renderItem={({ item }) => (
        <UserCard user={item} onPress={handlePress} />
      )}
    />
  );
});
```

### After React Compiler

```typescript
// Automatic optimization - no mistakes possible
function UserList({ users }) {
  const sortedUsers = users.sort((a, b) => a.name.localeCompare(b.name));

  const handlePress = (id) => {
    navigation.navigate('User', { id });
  };

  return (
    <FlashList
      data={sortedUsers}
      renderItem={({ item }) => (
        <UserCard user={item} onPress={handlePress} />
      )}
    />
  );
}
```

**Result**:
- Less code (no memo/useCallback/useMemo)
- No dependency array mistakes
- Easier to read and maintain
- Compiler automatically tracks all dependencies

## Resources

- [React Compiler Documentation](https://react.dev/learn/react-compiler)
- [Expo SDK 52 Release Notes](https://expo.dev/changelog/2024/expo-sdk-52)
- [React Native 0.76 Release](https://reactnative.dev/blog/2024/10/23/release-0.76)
- [Babel Plugin React Compiler](https://www.npmjs.com/package/babel-plugin-react-compiler)

## Summary

**React Compiler is:**
- ✅ Automatic memoization for React components, functions, and values
- ✅ Build-time optimization (no runtime overhead)
- ✅ Compatible with Expo SDK 52+ and React Native 0.76+
- ✅ Reduces boilerplate and prevents common mistakes

**React Compiler is NOT:**
- ❌ A replacement for FlashList (use both!)
- ❌ A replacement for Reanimated worklets (use both!)
- ❌ A replacement for image optimization (use both!)
- ❌ A silver bullet for all performance issues (measure first!)

**Best Results**: Combine React Compiler with FlashList, Reanimated, expo-image, and proper bundle optimization for maximum performance.
