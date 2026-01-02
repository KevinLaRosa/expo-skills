---
name: swift-debugging
description: Debug Swift code in Expo projects using Xcode, LLDB, Instruments for performance profiling, and memory leak detection with environment-first diagnostics
license: MIT
compatibility: "Requires: Xcode 16+, macOS 15+, Expo project with custom dev client, Swift debugging knowledge"
---

# Swift Debugging

## Overview

Debug Swift code in Expo projects using Xcode debugging tools, LLDB, Instruments for profiling, and systematic approaches to diagnose build failures, runtime crashes, and performance issues.

## When to Use This Skill

- Swift code crashes in Expo modules or widgets
- Build failures with cryptic Swift errors
- Memory leaks in Swift modules
- Performance issues in native code
- Debugging widgets that won't load
- "BUILD FAILED" with Swift compilation errors
- Expo Modules API integration issues

**When you see:**
- "BUILD FAILED" in Xcode
- "Signal SIGABRT" or "EXC_BAD_ACCESS"
- Widget not appearing
- Memory warnings
- Slow module performance

**Prerequisites**: Basic Swift knowledge, Xcode installed, custom Expo dev client (not Expo Go).

## Workflow

### Step 1: Environment-First Diagnostics

**Before debugging code, check environment:**

```bash
# 1. Check Xcode version
xcodebuild -version  # Should be 16.0+

# 2. Check Ruby/CocoaPods
ruby --version      # Should be 3.2.0+
pod --version       # Should be 1.16.2+

# 3. Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# 4. Clean Expo build
cd ios && rm -rf Pods/ Podfile.lock && cd ..
npx expo prebuild --clean

# 5. Reinstall pods
cd ios && pod install && cd ..
```

### Step 2: Debug Build Failures

**"BUILD FAILED" systematic approach:**

```bash
# 1. Read error carefully (scroll up for root cause)
# Swift errors often appear earlier in log

# 2. Clean build folder
# Xcode → Product → Clean Build Folder (Cmd+Shift+K)

# 3. Check for common issues:

# Issue: Module not found
# Solution: Check expo-module.config.json
{
  "ios": {
    "modules": ["MyModule"]  // Must match class name
  }
}

# Issue: Swift version mismatch
# Solution: Check Podfile.lock and update

# Issue: CocoaPods dependency conflict
# Solution:
cd ios
pod deintegrate
pod install

# Issue: Xcode cache corrupted
# Solution:
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

**Common Swift build errors:**

```swift
// Error: "Cannot find 'X' in scope"
// Cause: Missing import
import ExpoModulesCore  // ✅ Add missing import

// Error: "Type 'X' does not conform to protocol 'Y'"
// Cause: Missing protocol methods
class MyModule: Module {
    func definition() -> ModuleDefinition {  // ✅ Implement required methods
        Name("MyModule")
    }
}

// Error: "Ambiguous use of 'X'"
// Cause: Name conflict
import Foundation  // ✅ Fully qualify: Foundation.Date
```

### Step 3: Debug Runtime Crashes with LLDB

**Set breakpoints in Xcode:**

```swift
// In your Swift module
public class MyModule: Module {
    public func definition() -> ModuleDefinition {
        Function("doSomething") { (value: Int) -> String in
            // Set breakpoint here (click line number in Xcode)
            print("Debug: value = \(value)")  // ✅ Add debug prints

            // Code that crashes
            return "Result: \(value)"
        }
    }
}
```

**LLDB commands:**

```lldb
# When app crashes, LLDB console appears

# Print variable
(lldb) po value
# Output: 42

# Print expression
(lldb) po value * 2
# Output: 84

# Continue execution
(lldb) continue

# Step over
(lldb) next

# Step into
(lldb) step

# Print backtrace
(lldb) bt

# Print all local variables
(lldb) frame variable
```

**Handle Swift optionals in debugger:**

```swift
func debugOptional(value: Int?) -> String {
    // Set breakpoint here
    if let unwrapped = value {
        return "Value: \(unwrapped)"
    } else {
        return "Nil"
    }
}

// In LLDB:
(lldb) po value
# Output: nil or Optional(42)

(lldb) po value!  // Force unwrap (careful!)
# Output: 42 or crash
```

### Step 4: Debug Memory Leaks with Instruments

**Use Instruments to find memory leaks:**

```bash
# 1. Product → Profile (Cmd+I)
# 2. Choose "Leaks" template
# 3. Run app and exercise features
# 4. Look for red leak markers
```

**Common Swift memory leaks in Expo:**

```swift
// ❌ Retain cycle with closure
class MyModule: Module {
    var callback: (() -> Void)?

    func setup() {
        callback = {
            self.doSomething()  // Captures self strongly
        }
    }
}

// ✅ Fix with weak self
class MyModule: Module {
    var callback: (() -> Void)?

    func setup() {
        callback = { [weak self] in
            self?.doSomething()
        }
    }
}

// ❌ Delegate retain cycle
class MyModule: Module {
    var delegate: MyDelegate?  // Strong reference
}

// ✅ Fix with weak delegate
class MyModule: Module {
    weak var delegate: MyDelegate?  // Weak reference
}
```

**Debug with Allocations instrument:**

```bash
# 1. Product → Profile → Allocations
# 2. Run app
# 3. Mark Generation (bottom toolbar)
# 4. Exercise feature
# 5. Mark Generation again
# 6. Look for growth between generations
# 7. Drill down into allocations
```

### Step 5: Profile Performance with Time Profiler

**Find performance bottlenecks:**

```bash
# 1. Product → Profile → Time Profiler
# 2. Run app
# 3. Record (red button)
# 4. Exercise slow feature
# 5. Stop recording
# 6. Look at "Heaviest Stack Trace"
# 7. Double-click to see source code
```

**Optimize hot paths:**

```swift
// Instruments shows this function is slow
func processData() -> [String] {
    // ❌ Bad: O(n²) complexity
    var results: [String] = []
    for i in 0..<items.count {
        for j in 0..<items.count {
            results.append(items[i] + items[j])
        }
    }
    return results
}

// ✅ Good: Optimized
func processData() -> [String] {
    // Use more efficient algorithm
    items.map { $0 + "suffix" }
}
```

**Profile Expo Modules API calls:**

```swift
public func definition() -> ModuleDefinition {
    Function("expensiveOperation") { () -> String in
        let start = Date()

        // Your code here
        let result = doHeavyWork()

        let duration = Date().timeIntervalSince(start)
        print("⏱️ Operation took: \(duration)s")  // Profile timing

        return result
    }
}
```

### Step 6: Debug Widget Issues

**Widget not appearing:**

```bash
# 1. Check widget target builds
# Xcode → Select widget scheme → Build

# 2. Check widget in simulator
# Long-press app icon → Edit Home Screen → + → Find widget

# 3. Check console for widget errors
# Xcode → Debug → Open System Log (Cmd+/)
# Filter: "widget"
```

**Widget showing placeholder:**

```swift
// Check placeholder implementation
func placeholder(in context: Context) -> SimpleEntry {
    // ✅ Return valid data, not nil
    SimpleEntry(date: Date(), value: "Placeholder")
}

// Check timeline provider
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    // ✅ Always call completion
    let entry = SimpleEntry(date: Date(), value: loadData() ?? "Default")
    let timeline = Timeline(entries: [entry], policy: .atEnd)
    completion(timeline)

    // ❌ Don't forget to call completion!
}
```

### Step 7: Debug Expo Modules API Integration

**Module not found in React Native:**

```typescript
// Error: "Cannot find native module 'MyModule'"

// 1. Check Swift class name matches
// ios/MyModule.swift
public class MyModule: Module {  // ✅ Name must match
    public func definition() -> ModuleDefinition {
        Name("MyModule")  // ✅ Must match exactly
    }
}

// 2. Check it's registered
// Should auto-register with Expo Modules API

// 3. Rebuild
npx expo prebuild --clean
npx expo run:ios
```

**Method crashes from JS:**

```swift
// Add defensive checks
Function("divide") { (a: Double, b: Double) throws -> Double in
    // ✅ Validate input
    guard b != 0 else {
        throw Exception(name: "DivisionByZero", description: "Cannot divide by zero")
    }
    return a / b
}
```

## Guidelines

**Do:**
- Clean build folder first (Cmd+Shift+K)
- Read full error messages (scroll up for root cause)
- Use breakpoints instead of print debugging
- Profile before optimizing (don't guess)
- Use Instruments regularly (leaks, allocations, time profiler)
- Test on physical devices (simulators hide issues)
- Use weak self in closures
- Validate inputs in Expo Modules functions

**Don't:**
- Don't ignore warnings (future errors)
- Don't skip cleaning derived data
- Don't force unwrap (!) in production
- Don't guess at performance issues (profile!)
- Don't create retain cycles
- Don't skip error handling
- Don't debug in Expo Go (use custom dev client)
- Don't commit with breakpoints enabled

## Examples

### Debug Retain Cycle

```swift
// Find with Instruments → Leaks
class MyModule: Module {
    var timer: Timer?

    func startTimer() {
        // ❌ Retain cycle
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.tick()  // Captures self
        }
    }

    // ✅ Fix
    func startTimerFixed() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    deinit {
        print("✅ MyModule deallocated")  // Should print when done
        timer?.invalidate()
    }
}
```

### Profile Performance

```swift
// Use Time Profiler to find this is slow
func loadUsers() -> [User] {
    // ❌ Slow: Loading too much data
    return database.fetchAll()
}

// ✅ Fix: Load efficiently
func loadUsers() -> [User] {
    return database.fetch(limit: 100, offset: 0)
}
```

### Debug Exception

```swift
Function("parseJSON") { (jsonString: String) throws -> [String: Any] in
    // ✅ Good error handling
    guard let data = jsonString.data(using: .utf8) else {
        throw Exception(
            name: "InvalidString",
            description: "Cannot convert string to UTF8"
        )
    }

    do {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return json ?? [:]
    } catch {
        throw Exception(
            name: "JSONParseError",
            description: "Invalid JSON: \(error.localizedDescription)"
        )
    }
}
```

## Resources

- [swift-widgets Skill](../swift-widgets/SKILL.md) - Widget-specific debugging
- [expo-native-modules Skill](../expo-native-modules/SKILL.md) - Expo Modules API
- [Xcode Debugging (Axiom)](https://github.com/CharlesWiltgen/Axiom/tree/main/xcode-debugging) - Environment-first diagnostics
- [LLDB Documentation](https://lldb.llvm.org/use/tutorial.html)
- [Instruments User Guide](https://developer.apple.com/documentation/instruments)

## Tools & Commands

- Xcode → Product → Clean Build Folder (Cmd+Shift+K)
- Xcode → Product → Profile (Cmd+I)
- Xcode → Debug → Open System Log (Cmd+/)
- `rm -rf ~/Library/Developer/Xcode/DerivedData/*` - Clean cache
- `lldb` commands: po, bt, next, step, continue

## Troubleshooting

### Cannot set breakpoint

**Problem**: Breakpoint shows dotted line, won't hit

**Solution**:
```bash
# 1. Build with Debug configuration
# Edit Scheme → Run → Build Configuration → Debug

# 2. Disable optimization
# Build Settings → Swift Compiler - Code Generation → Optimization Level → No Optimization

# 3. Clean and rebuild
```

### Memory graph debugger not showing leaks

**Problem**: Debug Memory Graph shows no issues

**Solution**:
Use Instruments → Leaks instead (more accurate):
```bash
Product → Profile → Leaks
```

### LLDB shows optimized out

**Problem**: `(lldb) po variable` shows "optimized out"

**Solution**:
```bash
# Build Settings → Swift Compiler - Code Generation
# Optimization Level → No Optimization [-Onone]
```

---

## Notes

- Always clean build folder first (Cmd+Shift+K)
- Xcode 16+ required for latest Swift features
- Use Instruments on physical devices (more accurate than simulator)
- LLDB is powerful - learn basic commands
- Environment issues cause 80% of "weird" build errors
- Expo Modules API uses ExpoModulesCore (check imports)
- Widgets need separate debugging (system log)
- Memory leaks often in closures - use [weak self]
- Reference Axiom's xcode-debugging for environment-first approach
