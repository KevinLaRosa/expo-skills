---
name: expo-native-modules
description: Create Expo modules with Swift/Kotlin to expose native APIs, integrate native SDKs, and bridge platform functionality to React Native
---

# Expo Native Modules

## Overview

Build custom native modules using Expo Modules API to expose Swift/Kotlin functionality to React Native, integrate native SDKs, and access platform APIs not available in Expo SDK.

## When to Use This Skill

- Need native functionality not in Expo SDK
- Integrating native SDKs (payment, analytics, etc.)
- Accessing platform-specific APIs
- Creating reusable native modules
- Bridging Swift/Kotlin code to JavaScript
- Building complex native features

**Note**: For iOS widgets, notification extensions, WatchKit apps, use `expo-apple-targets` skill instead.

## Workflow

### Step 1: Create Expo Module

```bash
# Create standalone module
npx create-expo-module@latest my-native-module

# Or in existing project's modules directory
cd modules
npx create-expo-module@latest camera-utils
```

This scaffolds:
```
my-native-module/
├── android/          # Kotlin implementation
├── ios/              # Swift implementation
├── src/              # TypeScript types
├── expo-module.config.json
└── package.json
```

### Step 2: Define Module API

Edit `expo-module.config.json`:

```json
{
  "platforms": ["ios", "android"],
  "ios": {
    "modules": ["MyNativeModule"]
  },
  "android": {
    "modules": ["expo.modules.mynative.MyNativeModule"]
  }
}
```

### Step 3: Implement Swift Module (iOS)

Edit `ios/MyNativeModule.swift`:

```swift
import ExpoModulesCore

public class MyNativeModule: Module {
  public func definition() -> ModuleDefinition {
    Name("MyNative")

    // Synchronous function
    Function("getBatteryLevel") { () -> Float in
      UIDevice.current.isBatteryMonitoringEnabled = true
      return UIDevice.current.batteryLevel
    }

    // Async function
    AsyncFunction("requestPermission") { (promise: Promise) in
      // Request permission asynchronously
      AVCaptureDevice.requestAccess(for: .video) { granted in
        promise.resolve(granted)
      }
    }

    // Function with parameters
    Function("multiply") { (a: Int, b: Int) -> Int in
      return a * b
    }

    // Events
    Events("onBatteryChange")

    // View manager (if creating native views)
    View(MyNativeView.self) {
      Prop("color") { (view: MyNativeView, color: String) in
        view.backgroundColor = UIColor(hex: color)
      }
    }
  }

  // Send events to JavaScript
  func sendBatteryEvent() {
    sendEvent("onBatteryChange", [
      "level": UIDevice.current.batteryLevel
    ])
  }
}
```

### Step 4: Implement Kotlin Module (Android)

Edit `android/src/main/java/expo/modules/mynative/MyNativeModule.kt`:

```kotlin
package expo.modules.mynative

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import android.os.BatteryManager
import android.content.Context

class MyNativeModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("MyNative")

    // Synchronous function
    Function("getBatteryLevel") {
      val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
      val batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
      return@Function batteryLevel.toFloat() / 100.0f
    }

    // Async function
    AsyncFunction("requestPermission") { promise: Promise ->
      // Request permission
      promise.resolve(true)
    }

    // Function with parameters
    Function("multiply") { a: Int, b: Int ->
      return@Function a * b
    }

    // Events
    Events("onBatteryChange")
  }

  // Send events to JavaScript
  fun sendBatteryEvent() {
    sendEvent("onBatteryChange", mapOf(
      "level" to 0.75
    ))
  }
}
```

### Step 5: Create TypeScript Types

Edit `src/MyNativeModule.types.ts`:

```typescript
export type BatteryEvent = {
  level: number;
};

export type MyNativeModuleType = {
  getBatteryLevel(): number;
  requestPermission(): Promise<boolean>;
  multiply(a: number, b: number): number;
};
```

Edit `src/index.ts`:

```typescript
import { requireNativeModule, EventEmitter } from 'expo-modules-core';
import type { MyNativeModuleType, BatteryEvent } from './MyNativeModule.types';

const MyNative = requireNativeModule<MyNativeModuleType>('MyNative');

// Event emitter
const emitter = new EventEmitter(MyNative);

export function getBatteryLevel(): number {
  return MyNative.getBatteryLevel();
}

export function requestPermission(): Promise<boolean> {
  return MyNative.requestPermission();
}

export function multiply(a: number, b: number): number {
  return MyNative.multiply(a, b);
}

export function addBatteryListener(
  listener: (event: BatteryEvent) => void
) {
  return emitter.addListener('onBatteryChange', listener);
}

export * from './MyNativeModule.types';
```

### Step 6: Use in React Native

```typescript
import { useEffect } from 'react';
import {
  getBatteryLevel,
  requestPermission,
  multiply,
  addBatteryListener
} from './modules/my-native-module';

export default function App() {
  useEffect(() => {
    const batteryLevel = getBatteryLevel();
    console.log('Battery:', batteryLevel);

    const subscription = addBatteryListener((event) => {
      console.log('Battery changed:', event.level);
    });

    return () => subscription.remove();
  }, []);

  const handlePermission = async () => {
    const granted = await requestPermission();
    console.log('Permission granted:', granted);
  };

  const result = multiply(6, 7);
  console.log('6 × 7 =', result);

  return <View>...</View>;
}
```

### Step 7: Test and Build

```bash
# Install module in main app
npm install ./modules/my-native-module

# Prebuild to generate native projects
npx expo prebuild --clean

# Run on iOS
npx expo run:ios

# Run on Android
npx expo run:android
```

## Guidelines

**Do:**
- Use Expo Modules API (simpler than bare React Native modules)
- Provide TypeScript types for better DX
- Handle errors gracefully with try/catch
- Test on both iOS and Android
- Document your module's API
- Version your modules properly

**Don't:**
- Don't use deprecated Native Modules API
- Don't forget to handle permissions
- Don't block the main thread with heavy operations
- Don't expose platform-specific types directly (abstract them)
- Don't forget to clean up resources (listeners, timers)

## Examples

### Integrating Native SDK

```swift
// iOS: Integrate native SDK
import ExpoModulesCore
import SomeNativeSDK

public class SDKModule: Module {
  public func definition() -> ModuleDefinition {
    Name("NativeSDK")

    OnCreate {
      SomeNativeSDK.configure(apiKey: "YOUR_API_KEY")
    }

    AsyncFunction("trackEvent") { (eventName: String, properties: [String: Any], promise: Promise) in
      SomeNativeSDK.track(event: eventName, properties: properties)
      promise.resolve(true)
    }
  }
}
```

```kotlin
// Android: Integrate native SDK
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import com.somenativesdk.SDK

class SDKModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("NativeSDK")

    OnCreate {
      SDK.configure("YOUR_API_KEY")
    }

    AsyncFunction("trackEvent") { eventName: String, properties: Map<String, Any>, promise: Promise ->
      SDK.track(eventName, properties)
      promise.resolve(true)
    }
  }
}
```

### Native View Component

```swift
// iOS: Custom native view
import ExpoModulesCore
import UIKit

class CustomView: ExpoView {
  required init(appContext: AppContext? = nil) {
    super.init(appContext: appContext)
    setupView()
  }

  func setupView() {
    backgroundColor = .systemBlue
  }

  func setColor(_ color: String) {
    backgroundColor = UIColor(hex: color)
  }
}

public class CustomViewModule: Module {
  public func definition() -> ModuleDefinition {
    Name("CustomView")

    View(CustomView.self) {
      Prop("color") { (view: CustomView, color: String) in
        view.setColor(color)
      }
    }
  }
}
```

```typescript
// React Native: Use native view
import { requireNativeViewManager } from 'expo-modules-core';
import { View, ViewProps } from 'react-native';

const NativeView = requireNativeViewManager('CustomView');

type CustomViewProps = ViewProps & {
  color?: string;
};

export function CustomView({ color, ...props }: CustomViewProps) {
  return <NativeView color={color} {...props} />;
}
```

### Platform-Specific Implementation

```typescript
// src/index.ts
import { Platform } from 'react-native';
import { requireNativeModule } from 'expo-modules-core';

const MyNative = requireNativeModule('MyNative');

export function platformSpecificFeature() {
  if (Platform.OS === 'ios') {
    return MyNative.iosSpecificMethod();
  } else if (Platform.OS === 'android') {
    return MyNative.androidSpecificMethod();
  }
  throw new Error('Platform not supported');
}
```

## Resources

- [Expo Modules API Docs](https://docs.expo.dev/modules/overview/)
- [Swift Best Practices](references/swift-best-practices.md)
- [Kotlin Best Practices](references/kotlin-best-practices.md)
- [Module API Reference](https://docs.expo.dev/modules/module-api/)

## Tools & Commands

- `npx create-expo-module@latest` - Create new module
- `npx expo prebuild` - Generate native projects
- `npx expo run:ios` - Build and run on iOS
- `npx expo run:android` - Build and run on Android

## Troubleshooting

### Module not found

**Problem**: `requireNativeModule` throws error

**Solution**:
1. Run `npx expo prebuild --clean`
2. Check `expo-module.config.json` has correct module names
3. Verify module is installed: `npm list my-native-module`
4. Clean build folders:
   ```bash
   cd ios && pod install && cd ..
   cd android && ./gradlew clean && cd ..
   ```

### Swift/Kotlin compilation errors

**Problem**: Build fails with native code errors

**Solution**:
- Check Swift/Kotlin syntax
- Verify imports are correct
- Check Xcode/Android Studio for detailed errors
- Ensure minimum deployment targets match

### TypeScript types not working

**Problem**: Autocomplete not showing module methods

**Solution**:
```bash
# Rebuild TypeScript
npm run build

# Clear metro cache
npx expo start --clear
```

---

## Notes

- Expo Modules API is easier than bare React Native's Turbo Modules
- Supports both Swift (iOS) and Kotlin (Android)
- Autolinking works automatically in Expo projects
- Can publish modules to npm for reuse
- Great for integrating native SDKs not yet in Expo SDK
