---
name: kotlin-modules
description: Build performant Android modules with Kotlin for Expo using Expo Modules API with coroutines, best practices, and production-grade patterns
license: MIT
compatibility: "Requires: Android Studio, Kotlin 1.9+, Expo SDK 50+, Gradle 8+"
---

# Kotlin Modules

## Overview

Build high-performance Android modules with Kotlin for Expo apps using Expo Modules API, following production-grade patterns for coroutines, memory management, and seamless React Native integration.

## When to Use This Skill

- Building Android native modules for Expo
- Need Kotlin coroutines for async operations
- Integrating Android SDKs
- Creating custom Android views
- Need platform-specific Android functionality
- Debugging Android module issues

**When you see:**
- "Module not found" on Android
- Need Android-specific features (Bluetooth, NFC, etc.)
- Performance issues in Android modules
- Kotlin compilation errors

**Prerequisites**: Basic Kotlin knowledge, Android Studio installed, Expo project with custom dev client.

## Workflow

### Step 1: Create Expo Module with Kotlin

```bash
# Create module
npx create-expo-module@latest my-module

# Structure:
my-module/
├── android/
│   └── src/main/java/expo/modules/mymodule/
│       └── MyModuleModule.kt    # Kotlin implementation
├── ios/
├── src/
│   └── index.ts                  # JavaScript exports
└── expo-module.config.json
```

### Step 2: Implement Kotlin Module

**Basic module structure:**

```kotlin
package expo.modules.mymodule

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class MyModuleModule : Module() {
    override fun definition() = ModuleDefinition {
        // Module name (must match TypeScript import)
        Name("MyModule")

        // Synchronous function
        Function("add") { a: Int, b: Int ->
            return@Function a + b
        }

        // Async function
        AsyncFunction("fetchData") { promise: Promise ->
            // Heavy operation on background thread
            promise.resolve("Data loaded")
        }

        // Constants
        Constants(
            "PI" to 3.14159,
            "VERSION" to "1.0.0"
        )

        // Events
        Events("onDataChanged")

        // Lifecycle
        OnCreate {
            // Module initialization
        }

        OnDestroy {
            // Cleanup
        }
    }
}
```

### Step 3: Use Kotlin Coroutines for Async Operations

**Proper coroutine usage:**

```kotlin
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import kotlinx.coroutines.*

class MyModuleModule : Module() {
    // ✅ Module-scoped coroutine scope
    private val moduleScope = CoroutineScope(Dispatchers.Default + SupervisorJob())

    override fun definition() = ModuleDefinition {
        Name("MyModule")

        // ✅ Async function with coroutines
        AsyncFunction("loadData") { url: String, promise: Promise ->
            moduleScope.launch {
                try {
                    // Background work
                    val data = withContext(Dispatchers.IO) {
                        fetchFromNetwork(url)
                    }

                    // Resolve on main thread
                    withContext(Dispatchers.Main) {
                        promise.resolve(data)
                    }
                } catch (e: Exception) {
                    promise.reject("FETCH_ERROR", e.message, e)
                }
            }
        }

        // ✅ Cleanup coroutines
        OnDestroy {
            moduleScope.cancel()
        }
    }

    private suspend fun fetchFromNetwork(url: String): String {
        delay(1000)  // Simulate network
        return "Data from $url"
    }
}
```

**Avoid common coroutine mistakes:**

```kotlin
// ❌ Bad: Blocking main thread
AsyncFunction("loadData") { promise: Promise ->
    val data = fetchDataBlocking()  // Blocks UI!
    promise.resolve(data)
}

// ✅ Good: Use coroutines
AsyncFunction("loadData") { promise: Promise ->
    moduleScope.launch {
        val data = withContext(Dispatchers.IO) {
            fetchDataSuspend()
        }
        promise.resolve(data)
    }
}

// ❌ Bad: No error handling
AsyncFunction("riskyOperation") { promise: Promise ->
    moduleScope.launch {
        val result = dangerousOperation()  // Can crash!
        promise.resolve(result)
    }
}

// ✅ Good: Proper error handling
AsyncFunction("riskyOperation") { promise: Promise ->
    moduleScope.launch {
        try {
            val result = dangerousOperation()
            promise.resolve(result)
        } catch (e: Exception) {
            promise.reject("ERROR", e.message, e)
        }
    }
}
```

### Step 4: Manage Android Context and Resources

**Access Android context:**

```kotlin
class MyModuleModule : Module() {
    // ✅ Access context
    private val context
        get() = appContext.reactContext ?: throw IllegalStateException("React context not available")

    override fun definition() = ModuleDefinition {
        Name("MyModule")

        Function("getPackageName") {
            return@Function context.packageName
        }

        Function("showToast") { message: String ->
            android.widget.Toast.makeText(context, message, android.widget.Toast.LENGTH_SHORT).show()
        }

        Function("getResourceString") { resourceName: String ->
            val resourceId = context.resources.getIdentifier(resourceName, "string", context.packageName)
            return@Function context.getString(resourceId)
        }
    }
}
```

**Handle lifecycle correctly:**

```kotlin
class MyModuleModule : Module() {
    private var listener: SomeListener? = null

    override fun definition() = ModuleDefinition {
        Name("MyModule")

        // ✅ Setup in OnCreate
        OnCreate {
            listener = SomeListener().also {
                it.register(context)
            }
        }

        // ✅ Cleanup in OnDestroy
        OnDestroy {
            listener?.unregister()
            listener = null
        }

        // ✅ Activity lifecycle
        OnActivityEntersBackground {
            // Pause heavy operations
        }

        OnActivityEntersForeground {
            // Resume operations
        }
    }
}
```

### Step 5: Create Custom Android Views

**Expo View component:**

```kotlin
import expo.modules.kotlin.views.ExpoView
import android.content.Context
import android.widget.TextView

class MyCustomView(context: Context) : ExpoView(context) {
    private val textView: TextView = TextView(context).also {
        addView(it)
    }

    fun setText(text: String) {
        textView.text = text
    }

    fun setTextColor(color: Int) {
        textView.setTextColor(color)
    }
}
```

**View module definition:**

```kotlin
class MyModuleModule : Module() {
    override fun definition() = ModuleDefinition {
        Name("MyModule")

        // Define view
        View(MyCustomView::class) {
            // Props
            Prop("text") { view: MyCustomView, text: String ->
                view.setText(text)
            }

            Prop("textColor") { view: MyCustomView, color: Int ->
                view.setTextColor(color)
            }

            // Events
            Events("onPress")
        }
    }
}
```

**Use in React Native:**

```typescript
import { requireNativeViewManager } from 'expo-modules-core';
import { ViewProps } from 'react-native';

type MyCustomViewProps = ViewProps & {
  text: string;
  textColor: number;
  onPress?: () => void;
};

const NativeView = requireNativeViewManager('MyModule');

export function MyCustomView(props: MyCustomViewProps) {
  return <NativeView {...props} />;
}
```

### Step 6: Debug Kotlin Modules

**Android Studio debugging:**

```bash
# 1. Open Android project
cd android
open -a "Android Studio" .

# 2. Attach debugger
# Run → Attach Debugger to Android Process
# Select your app process

# 3. Set breakpoints in Kotlin code

# 4. Trigger code from React Native

# 5. Debugger stops at breakpoint
```

**Logging:**

```kotlin
import android.util.Log

class MyModuleModule : Module() {
    companion object {
        private const val TAG = "MyModule"
    }

    override fun definition() = ModuleDefinition {
        Function("debugFunction") { input: String ->
            Log.d(TAG, "Input: $input")  // Debug
            Log.i(TAG, "Processing...")  // Info
            Log.w(TAG, "Warning!")       // Warning
            Log.e(TAG, "Error!")         // Error

            return@Function "Processed: $input"
        }
    }
}

// View logs in Android Studio: Logcat → Filter by "MyModule"
```

**Performance profiling:**

```kotlin
Function("expensiveOperation") {
    val start = System.currentTimeMillis()

    // Your code
    val result = doHeavyWork()

    val duration = System.currentTimeMillis() - start
    Log.d(TAG, "⏱️ Operation took: ${duration}ms")

    return@Function result
}
```

### Step 7: Handle Permissions

**Request Android permissions:**

```kotlin
import expo.modules.interfaces.permissions.Permissions

class MyModuleModule : Module() {
    override fun definition() = ModuleDefinition {
        Name("MyModule")

        AsyncFunction("requestCameraPermission") { promise: Promise ->
            val permissions = appContext.permissions ?: run {
                promise.reject("NO_PERMISSIONS", "Permissions module not available")
                return@AsyncFunction
            }

            permissions.askForPermissionsWithPermissionsManager(
                arrayOf(android.Manifest.permission.CAMERA)
            ) { result ->
                if (result.isGranted) {
                    promise.resolve(true)
                } else {
                    promise.resolve(false)
                }
            }
        }
    }
}
```

## Guidelines

**Do:**
- Use coroutines for async operations (Dispatchers.IO for I/O)
- Cancel coroutines in OnDestroy
- Handle errors with try/catch
- Log with android.util.Log
- Test on physical Android devices
- Use lateinit for late initialization
- Validate inputs from JavaScript
- Clean up resources in OnDestroy

**Don't:**
- Don't block main thread
- Don't forget to cancel coroutines
- Don't use GlobalScope (use moduleScope)
- Don't forget error handling
- Don't leak Android context
- Don't use !! (force unwrap) in production
- Don't skip null checks
- Don't forget permission checks

## Examples

### Bluetooth Module

```kotlin
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager

class BluetoothModule : Module() {
    private val bluetoothAdapter: BluetoothAdapter? by lazy {
        val bluetoothManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
        bluetoothManager.adapter
    }

    override fun definition() = ModuleDefinition {
        Name("Bluetooth")

        Function("isEnabled") {
            return@Function bluetoothAdapter?.isEnabled ?: false
        }

        AsyncFunction("enable") { promise: Promise ->
            if (bluetoothAdapter?.isEnabled == true) {
                promise.resolve(true)
            } else {
                promise.reject("BT_DISABLED", "Bluetooth is disabled")
            }
        }
    }
}
```

### File System Module

```kotlin
import java.io.File

class FileSystemModule : Module() {
    override fun definition() = ModuleDefinition {
        Name("FileSystem")

        AsyncFunction("readFile") { path: String, promise: Promise ->
            moduleScope.launch {
                try {
                    val content = withContext(Dispatchers.IO) {
                        File(path).readText()
                    }
                    promise.resolve(content)
                } catch (e: Exception) {
                    promise.reject("READ_ERROR", e.message, e)
                }
            }
        }

        AsyncFunction("writeFile") { path: String, content: String, promise: Promise ->
            moduleScope.launch {
                try {
                    withContext(Dispatchers.IO) {
                        File(path).writeText(content)
                    }
                    promise.resolve(true)
                } catch (e: Exception) {
                    promise.reject("WRITE_ERROR", e.message, e)
                }
            }
        }
    }
}
```

## Resources

- [expo-native-modules Skill](../expo-native-modules/SKILL.md) - Expo Modules API general
- [Kotlin Coroutines on Android](references/kotlin-coroutines-android.md) - Android coroutines guide
- [Expo Modules API](https://docs.expo.dev/modules/overview/)
- [Kotlin Coroutines Guide](https://kotlinlang.org/docs/coroutines-guide.html)
- [Android Developers](https://developer.android.com/kotlin)

## Tools & Commands

- Android Studio → Run → Attach Debugger
- `adb logcat` - View Android logs
- `./gradlew clean` - Clean Android build
- `npx expo run:android` - Build and run

## Troubleshooting

### Module not found

**Problem**: "Cannot find native module" on Android

**Solution**:
```bash
# 1. Clean and rebuild
cd android && ./gradlew clean && cd ..
npx expo prebuild --clean
npx expo run:android

# 2. Check expo-module.config.json
{
  "android": {
    "modules": ["expo.modules.mymodule.MyModuleModule"]
  }
}
```

### Coroutine crashes

**Problem**: App crashes when using coroutines

**Solution**:
```kotlin
// ✅ Always wrap in try/catch
AsyncFunction("operation") { promise: Promise ->
    moduleScope.launch {
        try {
            val result = suspendOperation()
            promise.resolve(result)
        } catch (e: Exception) {
            Log.e(TAG, "Error", e)
            promise.reject("ERROR", e.message, e)
        }
    }
}
```

### Memory leaks

**Problem**: Module leaking memory

**Solution**:
```kotlin
// ✅ Clean up in OnDestroy
OnDestroy {
    moduleScope.cancel()  // Cancel coroutines
    listener?.unregister()  // Unregister listeners
    resources?.release()  // Release resources
}
```

---

## Notes

- Expo Modules API easier than bare React Native TurboModules
- Use Kotlin coroutines for async (cleaner than callbacks)
- Always cancel coroutines in OnDestroy
- Test on physical Android devices (emulators hide issues)
- Use Dispatchers.IO for network/disk I/O
- Use Dispatchers.Main for UI updates
- Expo Modules auto-links (no manual setup needed)
- Can integrate any Android SDK
