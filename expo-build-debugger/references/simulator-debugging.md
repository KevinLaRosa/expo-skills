# Simulator and Emulator Debugging Reference

## Overview

This guide covers debugging React Native and Expo applications on iOS Simulator and Android Emulator, including setup, debugging tools, common workflows, and troubleshooting techniques.

## iOS Simulator Debugging

### Building for iOS Simulator

#### Configuration

To build for iOS Simulator with EAS Build, modify your `eas.json` file:

```json
{
  "build": {
    "simulator": {
      "ios": {
        "simulator": true
      }
    },
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "ios": {
        "simulator": true
      }
    }
  }
}
```

#### Building and Installing

**Build the app:**
```bash
eas build -p ios --profile simulator
```

**Install on simulator:**

After build completes, the CLI will prompt to download and install automatically. Press `Y` to proceed.

Alternatively, use the `eas build:run` command:
```bash
# View available builds and select one to install
eas build:run -p ios

# Install the latest build directly
eas build:run -p ios --latest
```

The `eas build:run` command shows:
- Build IDs
- Timestamps
- Version numbers
- Git commit information

#### Post-Installation

After installation, your app appears on the simulator home screen. For development builds:

```bash
# Start the development server
npx expo start

# Or start with specific options
npx expo start --dev-client
```

### Xcode Debugging Tools

#### Opening Your Project in Xcode

For native debugging capabilities, generate and open the iOS project:

```bash
# Generate native iOS code
npx expo prebuild -p ios

# Open in Xcode
open ios/YourApp.xcworkspace
```

**Important:** Always open the `.xcworkspace` file, not the `.xcodeproj` file, when using CocoaPods.

#### LLDB Debugger

Xcode includes LLDB (Low-Level Debugger) for native code debugging.

**Setting Breakpoints:**
1. Open your native files in Xcode
2. Click on the line number where you want to pause
3. Run your app with `Cmd + R`
4. When breakpoint hits, use the debug console

**LLDB Commands:**
```bash
# Continue execution
(lldb) continue

# Step over
(lldb) next

# Step into
(lldb) step

# Print variable value
(lldb) po variableName

# Print expression
(lldb) expr variableName = newValue
```

#### View Hierarchy Debugger

Debug your app's view structure visually:

1. Run your app in Xcode
2. Click the "Debug View Hierarchy" button (or `Cmd + Shift + D`)
3. Explore the 3D view of your app's view hierarchy
4. Inspect view properties, constraints, and layout

**Use Cases:**
- Identifying layout issues
- Finding hidden or overlapping views
- Debugging Auto Layout constraints
- Inspecting view properties

#### Memory Graph Debugger

Detect memory leaks and analyze memory usage:

1. Run your app in Xcode
2. Click the "Debug Memory Graph" button
3. Look for purple exclamation marks (memory leaks)
4. Inspect object retention cycles

#### Instruments

Xcode Instruments provides advanced profiling tools:

```bash
# Launch Instruments
Product > Profile (Cmd + I)
```

**Useful Instruments:**
- **Time Profiler**: Identify performance bottlenecks
- **Allocations**: Track memory allocations
- **Leaks**: Detect memory leaks
- **Network**: Monitor network activity
- **Energy Log**: Analyze battery usage

### Console and Logs

#### Viewing Logs in Xcode

1. Open Xcode
2. Go to `Window > Devices and Simulators`
3. Select your simulator
4. Click "Open Console" to view system logs

#### Console.app

macOS Console app provides comprehensive logging:

1. Open Console.app (`/Applications/Utilities/Console.app`)
2. Select your simulator from the device list
3. Filter logs by process name or search terms

**Filtering Tips:**
- Filter by process: `process:YourAppName`
- Filter by subsystem: `subsystem:com.yourcompany.yourapp`
- Combine filters: `process:YourAppName AND error`

#### Command Line Logs

```bash
# View simulator logs
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "YourApp"'

# View logs with specific level
xcrun simctl spawn booted log stream --level debug

# Save logs to file
xcrun simctl spawn booted log stream > simulator.log
```

### React Native Debugging

#### React DevTools

```bash
# Install React DevTools
npm install -g react-devtools

# Launch React DevTools
react-devtools
```

Connect to your app by shaking the device (`Cmd + D` in simulator) and selecting "Toggle Element Inspector".

#### Flipper

Flipper provides a comprehensive debugging platform:

```bash
# Install Flipper
brew install --cask flipper

# Launch Flipper
open -a Flipper
```

**Flipper Features:**
- Layout Inspector
- Network Inspector
- Databases
- Shared Preferences
- Crash Reporter
- React DevTools integration

#### Chrome DevTools

For JavaScript debugging:

1. Shake device (`Cmd + D`)
2. Select "Debug JS Remotely"
3. Opens Chrome tab with DevTools

**Available in DevTools:**
- Console
- Sources (breakpoints, step debugging)
- Network tab
- Performance profiling

### Performance Profiling

#### React Native Performance Monitor

```bash
# Show performance monitor
# In simulator: Cmd + D > Show Perf Monitor
```

Displays:
- RAM usage
- JavaScript thread frame rate
- UI thread frame rate
- Views count

#### Xcode Performance Tools

**Measure App Launch Time:**
1. Edit scheme (`Cmd + <`)
2. Select "Run" > "Arguments"
3. Add environment variable: `DYLD_PRINT_STATISTICS` = `1`
4. Run app and check console for launch time breakdown

**Profile with Time Profiler:**
1. `Product > Profile` (`Cmd + I`)
2. Select "Time Profiler"
3. Record while using your app
4. Analyze call tree to find bottlenecks

### Simulator Management

#### Managing Simulators

```bash
# List all simulators
xcrun simctl list

# Create new simulator
xcrun simctl create "iPhone 15 Pro" "iPhone 15 Pro" "iOS17.0"

# Boot simulator
xcrun simctl boot "iPhone 15 Pro"

# Shutdown simulator
xcrun simctl shutdown "iPhone 15 Pro"

# Delete simulator
xcrun simctl delete "iPhone 15 Pro"

# Erase simulator data
xcrun simctl erase "iPhone 15 Pro"
```

#### Installing Apps

```bash
# Install app on booted simulator
xcrun simctl install booted /path/to/YourApp.app

# Uninstall app
xcrun simctl uninstall booted com.yourcompany.yourapp

# Launch app
xcrun simctl launch booted com.yourcompany.yourapp
```

#### Simulator Settings

```bash
# Set location
xcrun simctl location booted set 37.7749,-122.4194

# Enable/disable keyboard
defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool true

# Reset all simulators
xcrun simctl erase all
```

## Android Emulator Debugging

### Building for Android Emulator

#### Configuration

Android builds for emulators work the same as device builds. For internal testing:

```json
{
  "build": {
    "preview": {
      "android": {
        "buildType": "apk"
      }
    },
    "development": {
      "developmentClient": true,
      "android": {
        "buildType": "apk",
        "gradleCommand": ":app:assembleDebug"
      }
    }
  }
}
```

**Note:** Use APK format for easier installation on emulators. AAB files require Google Play Store.

#### Installing on Emulator

```bash
# Build for Android
eas build -p android --profile preview

# Install on running emulator
adb install /path/to/app.apk

# Or use EAS CLI (if available)
eas build:run -p android --latest
```

### Android Studio Debugging

#### Opening Your Project in Android Studio

```bash
# Generate native Android code
npx expo prebuild -p android

# Open in Android Studio
open -a "Android Studio" android/
```

#### Native Debugger

**Setting Breakpoints:**
1. Open your native Java/Kotlin files in Android Studio
2. Click on the gutter next to the line number
3. Run in debug mode (`Shift + F9`)

**Debugging Controls:**
- `F8`: Step over
- `F7`: Step into
- `Shift + F8`: Step out
- `F9`: Resume program
- `Cmd + F8`: Toggle breakpoint

#### Layout Inspector

Visualize and debug your app's view hierarchy:

1. Run your app
2. `Tools > Layout Inspector`
3. Select your device and process
4. Explore the view hierarchy tree

**Features:**
- 3D visualization of views
- Property inspection
- Live updates
- Screenshot comparison

#### Profiler

Android Studio Profiler provides real-time performance data:

1. Run your app
2. `View > Tool Windows > Profiler`

**Available Profilers:**
- **CPU**: Identify CPU-intensive operations
- **Memory**: Track memory allocations and detect leaks
- **Network**: Monitor network requests
- **Energy**: Analyze battery consumption

### Logcat

#### Viewing Logs in Android Studio

1. Open Android Studio
2. `View > Tool Windows > Logcat`
3. Filter by package name, log level, or search terms

#### Command Line Logs

```bash
# View all logs
adb logcat

# Filter by tag
adb logcat -s "ReactNativeJS"

# Filter by priority (V, D, I, W, E, F)
adb logcat *:E

# Filter by package
adb logcat | grep "com.yourapp"

# Clear logs
adb logcat -c

# Save logs to file
adb logcat > android.log

# View logs with colors
adb logcat -v color
```

#### Common Log Tags

```bash
# React Native JavaScript logs
adb logcat ReactNativeJS:V *:S

# React Native errors
adb logcat ReactNative:V *:S

# Native crashes
adb logcat AndroidRuntime:E *:S

# Network requests
adb logcat OkHttp:D *:S
```

### React Native Debugging

#### Metro Bundler

The Metro bundler runs automatically with:

```bash
npx expo start

# Or for production mode
npx expo start --no-dev --minify
```

**Dev Menu on Emulator:**
- `Cmd + M` (macOS)
- `Ctrl + M` (Windows/Linux)
- Shake device

**Dev Menu Options:**
- Reload: `R` twice quickly
- Debug JS Remotely
- Toggle Element Inspector
- Show Perf Monitor
- Enable Hot Reloading
- Enable Fast Refresh

#### React DevTools

```bash
# Install and launch React DevTools
npm install -g react-devtools
react-devtools
```

Connect via Dev Menu > "Toggle Element Inspector"

#### Flipper

Same as iOS setup. Flipper provides cross-platform debugging:

**Android-Specific Plugins:**
- SharedPreferences viewer
- SQLite database inspector
- Crash reporter
- Network inspector

### Performance Profiling

#### Performance Monitor

Enable via Dev Menu > "Show Perf Monitor"

Shows:
- RAM usage
- JavaScript FPS
- UI FPS
- View count

#### Systrace

For advanced profiling:

```bash
# Record systrace
npx react-native start-systrace

# Stop recording (after a few seconds)
# Ctrl + C

# Open the generated trace file in Chrome
# Navigate to chrome://tracing
```

#### Android Profiler

Use Android Studio's built-in profiler for detailed analysis:

1. Run app in debug mode
2. Open Profiler window
3. Record CPU, Memory, or Network activity
4. Analyze results

### ADB (Android Debug Bridge)

#### Essential ADB Commands

```bash
# List connected devices
adb devices

# Install APK
adb install /path/to/app.apk

# Uninstall app
adb uninstall com.yourapp

# Start app
adb shell am start -n com.yourapp/.MainActivity

# Stop app
adb shell am force-stop com.yourapp

# Clear app data
adb shell pm clear com.yourapp

# Screenshot
adb exec-out screencap -p > screenshot.png

# Record screen
adb shell screenrecord /sdcard/demo.mp4

# Pull recorded video
adb pull /sdcard/demo.mp4
```

#### Network Debugging

```bash
# View network statistics
adb shell dumpsys netstats

# Monitor network traffic
adb shell dumpsys connectivity

# Port forwarding
adb reverse tcp:8081 tcp:8081
```

#### File System

```bash
# Access shell
adb shell

# List files
adb shell ls /sdcard/

# Push file to device
adb push local.txt /sdcard/

# Pull file from device
adb pull /sdcard/remote.txt

# View app files
adb shell run-as com.yourapp
```

## Common Debugging Workflows

### Debugging Runtime Errors

#### Stack Trace Analysis

When errors occur, examine the stack trace:

**In Metro:**
```
ERROR Error: Something went wrong
  at functionName (file.js:123:45)
  at anotherFunction (file.js:67:89)
```

**Best Practices:**
- Read error messages carefully
- Follow the stack trace to the source
- Check line numbers in your source code

#### Isolation Technique

Systematic approach to finding bugs:

1. Identify when the app last worked correctly
2. Review recent changes
3. Apply changes piece by piece
4. Test after each change
5. Identify the problematic change

#### Using Breakpoints

**In Chrome DevTools:**
1. Open Sources tab
2. Find your file
3. Click line number to set breakpoint
4. Trigger the code path
5. Inspect variables in Scope panel

**In React Native Debugger:**
1. Enable debugging
2. Set breakpoint in source
3. Step through code
4. Inspect state and props

### Debugging Layout Issues

#### Element Inspector

**Enable Inspector:**
- Simulator: `Cmd + D` > "Toggle Element Inspector"
- Emulator: `Cmd + M` > "Toggle Element Inspector"

**Features:**
- Tap any element to inspect
- View style properties
- See computed layout
- Identify component hierarchy

#### View Hierarchy Tools

**iOS (Xcode):**
1. Run in Xcode
2. Debug View Hierarchy (`Cmd + Shift + D`)
3. Rotate and inspect 3D view

**Android (Layout Inspector):**
1. Run in Android Studio
2. Tools > Layout Inspector
3. Explore view tree and properties

### Debugging Network Issues

#### Network Inspector (Flipper)

1. Install Flipper
2. Connect your app
3. Open Network plugin
4. Monitor all requests/responses

**Features:**
- Request/response headers
- Request/response body
- Timing information
- Mock responses

#### Chrome DevTools Network Tab

1. Enable remote debugging
2. Open Chrome DevTools
3. Navigate to Network tab
4. Monitor fetch/XHR requests

#### Logging Network Requests

```javascript
// Add request interceptor
const originalFetch = global.fetch;
global.fetch = (url, options) => {
  console.log('Fetch:', url, options);
  return originalFetch(url, options);
};
```

### Debugging Performance Issues

#### Performance Monitor

Enable and watch for:
- Low FPS (< 60) indicates performance issues
- High RAM usage
- Increasing view count

#### Profiling Strategy

1. **Identify the problem:**
   - Use Performance Monitor
   - Note which screens/actions are slow

2. **Profile with tools:**
   - iOS: Xcode Instruments (Time Profiler)
   - Android: Android Profiler (CPU)

3. **Common culprits:**
   - Unnecessary re-renders
   - Large lists without virtualization
   - Heavy computations on UI thread
   - Unoptimized images

4. **Optimize:**
   - Use React.memo for expensive components
   - Implement FlatList for long lists
   - Move heavy work to background
   - Optimize images

### Debugging Crashes

#### Crash Logs

**iOS:**
```bash
# View crash logs in Console.app
# Or in Xcode: Window > Devices and Simulators > View Device Logs

# Symbolicate crash logs
atos -o YourApp.app/YourApp -l 0x100000000 0x123456
```

**Android:**
```bash
# View crash logs
adb logcat AndroidRuntime:E *:S

# View tombstones
adb shell ls /data/tombstones/
```

#### Native Crash Debugging

**iOS (LLDB):**
1. Enable zombie objects for memory issues
2. Run with debugger attached
3. Examine crash in Xcode

**Android (Android Studio):**
1. Run in debug mode
2. Crash will pause in debugger
3. Examine stack trace and variables

## Troubleshooting Common Issues

### Simulator Won't Boot

**iOS:**
```bash
# Shutdown all simulators
xcrun simctl shutdown all

# Erase problematic simulator
xcrun simctl erase "iPhone 15 Pro"

# Restart your Mac if issue persists
```

**Android:**
```bash
# Wipe emulator data
emulator -avd YourEmulator -wipe-data

# Or delete and recreate emulator in AVD Manager
```

### App Won't Install

**iOS:**
```bash
# Reset simulator
xcrun simctl erase all

# Check build architecture matches simulator
# Simulator builds need x86_64 or arm64 for Apple Silicon
```

**Android:**
```bash
# Check for conflicting signatures
adb uninstall com.yourapp

# Reinstall
adb install -r /path/to/app.apk

# Clear package manager data
adb shell pm clear com.android.vending
```

### Debugger Won't Connect

**General:**
```bash
# Check Metro bundler is running
npx expo start

# Check device is connected
adb devices  # Android
xcrun simctl list | grep Booted  # iOS

# Restart Metro
# Kill Metro process and restart
```

**iOS Specific:**
```bash
# Reset Metro cache
npx expo start --clear

# Check firewall settings
# System Preferences > Security & Privacy > Firewall
```

**Android Specific:**
```bash
# Reverse port forwarding
adb reverse tcp:8081 tcp:8081

# Check ADB connection
adb kill-server
adb start-server
```

### Hot Reload Not Working

**Solutions:**
1. Check Fast Refresh is enabled in Dev Menu
2. Restart Metro bundler with `--reset-cache`
3. Check file is being saved correctly
4. Ensure no syntax errors in code
5. Try full reload: `RR` in Metro or Dev Menu > Reload

### Slow Performance on Simulator

**iOS:**
```bash
# Use Release configuration for better performance
# Edit scheme > Run > Build Configuration > Release

# Close other applications
# Free up system resources
```

**Android:**
```bash
# Enable hardware acceleration
# AVD Manager > Edit emulator > Graphics: Hardware

# Allocate more RAM
# AVD Manager > Edit emulator > Advanced Settings

# Use x86/x86_64 system images (faster)
```

### Network Requests Failing

**Check:**
1. CORS configuration on server
2. Network permissions in app configuration
3. Metro proxy settings
4. SSL certificates (use HTTP for dev if needed)

**iOS Specific:**
```xml
<!-- Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

**Android Specific:**
```xml
<!-- AndroidManifest.xml -->
<application
  android:usesCleartextTraffic="true">
```

### Production-Like Testing

To reproduce production errors locally:

```bash
# Run in production mode
npx expo start --no-dev --minify

# Or build release version
# iOS
npx expo run:ios --configuration Release

# Android
npx expo run:android --variant release
```

## Additional Resources

### Official Documentation
- [Expo Debugging Guide](https://docs.expo.dev/debugging/runtime-issues/)
- [React Native Debugging](https://reactnative.dev/docs/debugging)
- [iOS Simulator Guide](https://docs.expo.dev/workflow/ios-simulator/)
- [Android Emulator Guide](https://docs.expo.dev/workflow/android-studio-emulator/)

### Tools
- [Flipper](https://fbflipper.com/)
- [React DevTools](https://github.com/facebook/react/tree/main/packages/react-devtools)
- [Reactotron](https://github.com/infinitered/reactotron)
- [Sentry](https://sentry.io/) (Production error tracking)
- [BugSnag](https://www.bugsnag.com/) (Crash reporting)

### Best Practices
1. Always test on simulators/emulators before physical devices
2. Use production mode testing before releases
3. Keep simulator/emulator OS versions updated
4. Clear cache and data when debugging strange issues
5. Use breakpoints over console.log for complex debugging
6. Profile performance regularly during development
7. Test on multiple simulator/emulator configurations
8. Keep debugging tools (Xcode, Android Studio) updated
