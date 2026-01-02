---
name: expo-native-modules
description: Create Expo modules with Swift/Kotlin, build iOS widgets, implement custom notifications, and share data with App Groups
---

# Expo Native Modules

## Overview

Build custom native functionality using Expo Modules API with Swift (iOS) and Kotlin (Android), including widgets, notifications, and App Groups.

## When to Use This Skill

- Need functionality not available in Expo SDK
- Building iOS widgets (Home Screen, Lock Screen)
- Custom notification UI (NotificationContentExtension)
- Sharing data between app and extensions (App Groups)
- Accessing native platform APIs
- Integrating native SDKs

## Workflow

### Step 1: Create Expo Module

```bash
# Create module
npx create-expo-module@latest my-module

# Or add to existing project
cd modules
npx create-expo-module@latest my-widget
```

### Step 2: Implement Swift Module

```swift
// MyWidgetModule.swift
import ExpoModulesCore

public class MyWidgetModule: Module {
  public func definition() -> ModuleDefinition {
    Name("MyWidget")

    Function("updateWidget") { (data: [String: Any]) in
      // Update widget with new data
      WidgetCenter.shared.reloadAllTimelines()
    }

    AsyncFunction("fetchWidgetData") { (promise: Promise) in
      // Fetch data for widget
      let data = ["value": 42]
      promise.resolve(data)
    }
  }
}
```

### Step 3: Build iOS Widget

```swift
// Widget/FreqWatchWidget.swift
import WidgetKit
import SwiftUI

struct FreqWatchWidget: Widget {
  let kind: String = "FreqWatchWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: Provider()) { entry in
      FreqWatchWidgetEntryView(entry: entry)
    }
    .configurationDisplayName("Trades")
    .description("View your latest trades")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct FreqWatchWidgetEntryView: View {
  var entry: Provider.Entry

  var body: some View {
    VStack {
      Text("Profit: +\(entry.profit)%")
        .font(.largeTitle)
        .foregroundColor(.green)
      Text("Last update: \(entry.date)")
        .font(.caption)
    }
  }
}
```

### Step 4: Setup App Groups

```swift
// 1. Enable App Groups in Xcode
// Target → Signing & Capabilities → + App Groups
// Add: group.com.yourapp.shared

// 2. Share data
let sharedDefaults = UserDefaults(suiteName: "group.com.yourapp.shared")
sharedDefaults?.set(tradeData, forKey: "latestTrades")

// 3. Read in widget
let sharedDefaults = UserDefaults(suiteName: "group.com.yourapp.shared")
let trades = sharedDefaults?.object(forKey: "latestTrades")
```

### Step 5: Custom Notification UI

```swift
// NotificationContentExtension/NotificationViewController.swift
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
  func didReceive(_ notification: UNNotification) {
    let content = notification.request.content

    // Custom UI
    let tradeData = content.userInfo["trade"] as? [String: Any]
    // Display rich notification
  }
}
```

### Step 6: Use in React Native

```typescript
import { requireNativeModule } from 'expo-modules-core';

const MyWidget = requireNativeModule('MyWidget');

// Update widget
await MyWidget.updateWidget({
  profit: 15.5,
  trades: 24,
});

// Fetch data
const data = await MyWidget.fetchWidgetData();
```

## Guidelines

**Do:**
- Use Expo Modules API (simpler than bare React Native)
- Test widgets on physical devices
- Use App Groups for data sharing
- Follow platform design guidelines
- Handle errors gracefully

**Don't:**
- Don't use deprecated Native Modules API
- Don't forget to request permissions
- Don't assume widgets update frequently (battery limits)
- Don't share sensitive data without encryption

## Examples

### Widget with Shared Data

```swift
// App: Save data
let encoder = JSONEncoder()
let data = try encoder.encode(trades)
let sharedDefaults = UserDefaults(suiteName: "group.com.yourapp.shared")
sharedDefaults?.set(data, forKey: "trades")
WidgetCenter.shared.reloadAllTimelines()

// Widget: Read data
let sharedDefaults = UserDefaults(suiteName: "group.com.yourapp.shared")
if let data = sharedDefaults?.data(forKey: "trades") {
  let decoder = JSONDecoder()
  let trades = try decoder.decode([Trade].self, from: data)
  // Display trades
}
```

## Resources

- [Swift Best Practices](references/swift-best-practices.md)
- [Widgets Guide](references/widgets-guide.md)
- [Custom Notifications](references/notifications-custom.md)
- [Expo Modules API](references/expo-modules-api.md)

## Tools & Commands

- `npx create-expo-module@latest` - Create module
- `npx expo prebuild` - Generate native projects
- `npx expo run:ios` - Build and run locally

---

## Notes

- Widgets are separate targets in Xcode
- App Groups required for data sharing
- Test on physical devices (simulators limited)
