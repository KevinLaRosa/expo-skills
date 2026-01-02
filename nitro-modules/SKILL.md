---
name: nitro-modules
description: Build ultra-fast native modules and views with Nitro - type-safe C++/Swift/Kotlin bindings that outperform Expo Modules and TurboModules by 15-60x
license: MIT
compatibility: "Requires: React Native 0.71+, Xcode (iOS), Android Studio, react-native-nitro-modules package"
---

# Nitro Modules

## Overview

Build extremely fast native modules using Nitro, a framework by Margelo that creates type-safe native bindings from TypeScript interfaces with zero runtime overhead, outperforming Expo Modules and TurboModules by 15-60x.

## When to Use This Skill

- Need maximum performance for native modules (15-60x faster than Expo Modules)
- Building performance-critical features (database, image processing, crypto)
- Want type-safe C++/Swift/Kotlin code generated from TypeScript
- Need first-class Swift/Kotlin support without Objective-C/Java
- Building libraries for distribution (react-native-nitro-sqlite, etc.)
- Require direct JSI bindings with zero overhead

**Alternative**: Use `expo-native-modules` skill for simpler use cases where Expo Modules performance is sufficient.

## Workflow

### Step 1: Install Nitro Modules

```bash
# Install core package
npm install react-native-nitro-modules

# iOS
cd ios && pod install && cd ..

# Verify installation
npx nitro-codegen --version
```

**Requirements**:
- React Native 0.71+
- New Architecture recommended (but not required)
- Xcode for iOS
- Android Studio for Android

### Step 2: Create Nitro Module Package

```bash
# Create new module
mkdir my-nitro-module
cd my-nitro-module
npm init -y

# Install dependencies
npm install react-native-nitro-modules
npm install --save-dev nitro-codegen typescript
```

Create package structure:
```
my-nitro-module/
├── src/
│   └── specs/
│       └── MyModule.nitro.ts      # TypeScript spec
├── ios/                           # Swift implementation
├── android/                       # Kotlin implementation
├── cpp/                           # C++ (optional)
├── nitrogen/                      # Generated code (auto)
└── package.json
```

### Step 3: Define TypeScript Spec

Create `src/specs/MyModule.nitro.ts`:

```typescript
import { HybridObject } from 'react-native-nitro-modules';

/**
 * A Nitro module for math operations
 */
export interface MyModule extends HybridObject {
  /**
   * Add two numbers
   */
  add(a: number, b: number): number;

  /**
   * Get battery level (async)
   */
  getBatteryLevel(): Promise<number>;

  /**
   * Subscribe to battery changes
   */
  onBatteryChange(callback: (level: number) => void): void;
}
```

**HybridObject** = Native object with lifecycle management, type-safe, and passable between JS/native.

### Step 4: Generate Native Bindings

Run **Nitrogen** code generator:

```bash
npx nitro-codegen --platform ios
npx nitro-codegen --platform android
```

This generates:
- `nitrogen/generated/ios/` - Swift protocols
- `nitrogen/generated/android/` - Kotlin interfaces
- `nitrogen/generated/shared/` - C++ bindings

### Step 5: Implement in Swift (iOS)

Create `ios/MyModule.swift`:

```swift
import NitroModules

class MyModule: HybridMyModuleSpec {
  // Hybrid object base
  var hybridContext = margelo.nitro.HybridContext()

  // Memory management
  var memorySize: Int {
    return getSizeOf(self)
  }

  // Implement methods
  func add(a: Double, b: Double) -> Double {
    return a + b
  }

  func getBatteryLevel() throws -> Promise<Double> {
    return Promise.async {
      UIDevice.current.isBatteryMonitoringEnabled = true
      return Double(UIDevice.current.batteryLevel)
    }
  }

  func onBatteryChange(callback: @escaping (Double) -> Void) throws {
    // Setup battery monitoring
    NotificationCenter.default.addObserver(
      forName: UIDevice.batteryLevelDidChangeNotification,
      object: nil,
      queue: .main
    ) { _ in
      let level = Double(UIDevice.current.batteryLevel)
      callback(level)
    }
  }
}
```

### Step 6: Implement in Kotlin (Android)

Create `android/src/main/java/com/mymodule/MyModule.kt`:

```kotlin
package com.mymodule

import com.margelo.nitro.core.*

class MyModule : HybridMyModuleSpec() {
  override val hybridContext = HybridContext()

  override val memorySize: Long
    get() = 0L

  override fun add(a: Double, b: Double): Double {
    return a + b
  }

  override fun getBatteryLevel(): Promise<Double> {
    return Promise.async {
      val batteryManager = context.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
      val level = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
      level.toDouble()
    }
  }

  override fun onBatteryChange(callback: (Double) -> Unit) {
    // Battery monitoring setup
    val filter = IntentFilter(Intent.ACTION_BATTERY_CHANGED)
    context.registerReceiver(object : BroadcastReceiver() {
      override fun onReceive(context: Context, intent: Intent) {
        val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
        callback(level.toDouble())
      }
    }, filter)
  }
}
```

### Step 7: Create JavaScript Module

Create `src/index.ts`:

```typescript
import { NitroModules } from 'react-native-nitro-modules';
import type { MyModule } from './specs/MyModule.nitro';

export const MyNitroModule = NitroModules.createHybridObject<MyModule>('MyModule');

export function add(a: number, b: number): number {
  return MyNitroModule.add(a, b);
}

export async function getBatteryLevel(): Promise<number> {
  return MyNitroModule.getBatteryLevel();
}

export function onBatteryChange(callback: (level: number) => void): void {
  MyNitroModule.onBatteryChange(callback);
}
```

### Step 8: Use in React Native

```typescript
import { add, getBatteryLevel, onBatteryChange } from 'my-nitro-module';

export default function App() {
  const result = add(5, 3);  // 8 (synchronous, ultra-fast)

  const checkBattery = async () => {
    const level = await getBatteryLevel();
    console.log('Battery:', level);
  };

  useEffect(() => {
    onBatteryChange((level) => {
      console.log('Battery changed:', level);
    });
  }, []);

  return <View>...</View>;
}
```

## Guidelines

**Do:**
- Use Nitro for performance-critical modules (image processing, crypto, DB)
- Define comprehensive TypeScript specs (single source of truth)
- Run `nitro-codegen` after spec changes
- Use `Promise.async` for async operations
- Leverage HybridObjects for stateful native objects
- Test on both iOS and Android
- Document your native implementations

**Don't:**
- Don't use for simple modules (Expo Modules is easier)
- Don't forget to run codegen after TypeScript changes
- Don't mix Nitro and Expo Modules in same package (choose one)
- Don't skip memory management (implement `memorySize`)
- Don't block UI thread with heavy sync operations
- Don't expose platform-specific types directly (abstract them)

## Examples

### Hybrid Object with State

```typescript
// TypeScript spec
export interface Counter extends HybridObject {
  readonly count: number;
  increment(): void;
  reset(): void;
}
```

```swift
// Swift implementation
class Counter: HybridCounterSpec {
  var hybridContext = margelo.nitro.HybridContext()
  var memorySize: Int { getSizeOf(self) }

  private var _count: Double = 0

  var count: Double {
    return _count
  }

  func increment() {
    _count += 1
  }

  func reset() {
    _count = 0
  }
}
```

### Image Processing Module

```typescript
// TypeScript spec
export interface ImageProcessor extends HybridObject {
  /**
   * Resize image synchronously (ultra-fast)
   */
  resize(imagePath: string, width: number, height: number): string;

  /**
   * Apply filter asynchronously
   */
  applyFilter(imagePath: string, filter: 'blur' | 'grayscale'): Promise<string>;
}
```

### Native View Component

Nitro also supports **Nitro Views** for custom native UI components:

```typescript
// TypeScript spec
export interface CustomSlider extends HybridObject {
  value: number;
  minimumValue: number;
  maximumValue: number;
  onValueChange: (value: number) => void;
}
```

```swift
// Swift UIView implementation
class CustomSliderView: UISlider, HybridCustomSliderSpec {
  var hybridContext = margelo.nitro.HybridContext()
  var memorySize: Int { getSizeOf(self) }

  var value: Double {
    get { Double(super.value) }
    set { super.value = Float(newValue) }
  }

  // Implement other properties and callbacks
}
```

### C++ Implementation (Cross-Platform)

```cpp
// C++ implementation (shared iOS + Android)
#include "HybridMyModuleSpec.hpp"

class MyModule : public HybridMyModuleSpec {
public:
  double add(double a, double b) override {
    return a + b;
  }

  std::shared_ptr<Promise<double>> getBatteryLevel() override {
    return Promise<double>::async([=]() {
      // Platform-specific battery code
      return 0.85;
    });
  }

  size_t getExternalMemorySize() override {
    return sizeof(this);
  }
};
```

## Resources

- [Nitro Official Docs](https://nitro.margelo.com/)
- [Nitro GitHub](https://github.com/margelo/nitro)
- [Nitrogen Codegen](https://github.com/margelo/nitro/tree/main/packages/nitrogen)
- [Nitro Benchmarks](https://github.com/margelo/nitro-benchmarks)
- [Example: Nitro SQLite](https://github.com/margelo/react-native-nitro-sqlite)

## Tools & Commands

- `npx nitro-codegen --platform ios` - Generate iOS bindings
- `npx nitro-codegen --platform android` - Generate Android bindings
- `npx nitro-codegen --platform all` - Generate all platforms
- `npx nitro-codegen --help` - View all options

## Troubleshooting

### Codegen fails

**Problem**: `nitro-codegen` throws errors

**Solution**:
1. Check TypeScript spec syntax
2. Ensure HybridObject import is correct
3. Verify `react-native-nitro-modules` is installed
4. Check file naming: `*.nitro.ts`

### Swift/Kotlin compilation errors

**Problem**: Native code doesn't compile after codegen

**Solution**:
- Run `pod install` after iOS codegen
- Check generated protocols in `nitrogen/generated/`
- Ensure class implements all protocol methods
- Verify `hybridContext` and `memorySize` are implemented

### Module not found at runtime

**Problem**: `createHybridObject()` throws "Module not found"

**Solution**:
```typescript
// Ensure module name matches spec
NitroModules.createHybridObject<MyModule>('MyModule')  // Must match class name
```

### Performance not as expected

**Problem**: Module not faster than Expo Modules

**Solution**:
- Use synchronous methods when possible (avoid Promise overhead)
- Profile with Nitro Benchmarks
- Check if using New Architecture (recommended)
- Ensure C++ implementation for maximum speed

---

## Notes

- Nitro Modules are **15-60x faster** than Expo Modules in benchmarks
- Direct Swift-to-C++ interop (no Objective-C bridge)
- Direct Kotlin-to-C++ interop (no Java bridge)
- Type-safe: TypeScript → C++/Swift/Kotlin
- Zero runtime overhead (compile-time code generation)
- Used in production by Margelo (react-native-nitro-sqlite, etc.)
- Best for performance-critical modules
- Use Expo Modules for simpler, less performance-sensitive modules
