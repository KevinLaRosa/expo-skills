---
name: expo-apple-targets
description: Create iOS widgets, notification extensions, WatchKit apps, and other Apple targets using expo-apple-targets with continuous native generation
license: MIT
compatibility: "Requires: Xcode 16+, macOS 15+ (Sequoia), Expo SDK 53+, CocoaPods 1.16.2+, Ruby 3.2.0+"
---

# Expo Apple Targets

## Overview

Build iOS widgets, notification extensions, WatchKit apps, App Clips and other Apple targets using expo-apple-targets by Evan Bacon, keeping code outside /ios with continuous native generation.

## When to Use This Skill

- Building iOS widgets (Home Screen, Lock Screen, StandBy)
- Custom notification UI (NotificationContentExtension)
- WatchKit apps (Apple Watch)
- App Clips (lightweight app experiences)
- Share extensions, Safari extensions
- Sharing data between app and extensions via App Groups

## Workflow

### Step 1: Install expo-apple-targets

```bash
# Install the plugin
npx expo install @bacons/apple-targets

# Add to app.json plugins
{
  "expo": {
    "plugins": ["@bacons/apple-targets"],
    "ios": {
      "appleTeamId": "YOUR_TEAM_ID"
    }
  }
}
```

**Requirements:**
- Expo SDK 53+
- Xcode 16+ (macOS 15 Sequoia)
- CocoaPods 1.16.2+ (Ruby 3.2.0)

### Step 2: Create a Target

```bash
# Interactive target creation
npx create-target

# Or specify type directly
npx create-target widget
npx create-target notification-content
npx create-target watch
```

This creates `/targets/{name}/` directory with:
- `expo-target.config.js` - Target configuration
- `index.swift` - Entry point
- `assets/` - Resources (images, etc.)

### Step 3: Configure Target

Edit `targets/my-widget/expo-target.config.js`:

```javascript
module.exports = {
  type: "widget",
  name: "FreqWatchWidget",
  displayName: "Trades Widget",
  colors: {
    $accent: "#F09458"
  },
  frameworks: ["SwiftUI", "WidgetKit"],
  deploymentTarget: "17.0",

  // App Groups for data sharing
  entitlements: {
    "com.apple.security.application-groups": [
      "group.com.yourapp.shared"
    ]
  }
}
```

### Step 4: Implement Widget in SwiftUI

Edit `targets/my-widget/index.swift`:

```swift
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

struct Provider: TimelineProvider {
  func placeholder(in context: Context) -> SimpleEntry {
    SimpleEntry(date: Date(), profit: 0.0)
  }

  func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
    let entry = SimpleEntry(date: Date(), profit: loadProfitFromAppGroup())
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    let entry = SimpleEntry(date: Date(), profit: loadProfitFromAppGroup())
    let timeline = Timeline(entries: [entry], policy: .atEnd)
    completion(timeline)
  }

  func loadProfitFromAppGroup() -> Double {
    let sharedDefaults = UserDefaults(suiteName: "group.com.yourapp.shared")
    return sharedDefaults?.double(forKey: "currentProfit") ?? 0.0
  }
}

struct SimpleEntry: TimelineEntry {
  let date: Date
  let profit: Double
}

struct FreqWatchWidgetEntryView: View {
  var entry: Provider.Entry

  var body: some View {
    VStack {
      Text("Profit")
        .font(.caption)
        .foregroundColor(.secondary)
      Text("+\(entry.profit, specifier: "%.2f")%")
        .font(.largeTitle)
        .bold()
        .foregroundColor(entry.profit >= 0 ? .green : .red)
    }
    .containerBackground(.fill.tertiary, for: .widget)
  }
}
```

### Step 5: Share Data via App Groups

In your React Native app:

```typescript
import { ExtensionStorage } from '@bacons/apple-targets';

// Setup App Group
const storage = new ExtensionStorage('group.com.yourapp.shared');

// Save data
storage.set('currentProfit', 15.42);

// Reload widget
ExtensionStorage.reloadWidget();
```

### Step 6: Shared Code Between Targets

Create `targets/_shared/` for code used by multiple targets:

```
targets/
├── _shared/
│   ├── Models.swift         # Shared data models
│   └── Extensions.swift     # Shared utilities
├── my-widget/
│   ├── expo-target.config.js
│   └── index.swift
└── notification-extension/
    ├── expo-target.config.js
    └── index.swift
```

Files in `_shared/` are automatically linked to all targets.

### Step 7: Prebuild and Develop

```bash
# Generate native project
npx expo prebuild -p ios --clean

# Open in Xcode
open ios/*.xcworkspace
```

In Xcode:
- Find your targets in `expo:targets/{name}/` folder
- Edit SwiftUI code with live previews
- Select target scheme to build/test

## Guidelines

**Do:**
- Use App Groups for data sharing between app and widgets
- Test widgets on physical devices (simulators limited)
- Use `ExtensionStorage` API for easy data sharing
- Put shared code in `targets/_shared/`
- Use SwiftUI for modern widget development
- Follow Apple's widget best practices (small data, quick updates)

**Don't:**
- Don't edit files outside `expo:targets/` in Xcode (will be overwritten)
- Don't expect widgets to update frequently (battery constraints)
- Don't put large data in UserDefaults (use lightweight data)
- Don't forget to run `npx expo prebuild --clean` after config changes
- Don't manually sign sub-targets (use EAS Build)

## Examples

### Notification Content Extension

`targets/notification-content/expo-target.config.js`:
```javascript
module.exports = {
  type: "notification-content",
  name: "TradeNotification",
  displayName: "Trade Alerts",
  frameworks: ["UserNotifications", "UserNotificationsUI"],
  deploymentTarget: "15.0"
}
```

`targets/notification-content/index.swift`:
```swift
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
  @IBOutlet var titleLabel: UILabel?
  @IBOutlet var profitLabel: UILabel?

  func didReceive(_ notification: UNNotification) {
    let content = notification.request.content

    if let trade = content.userInfo["trade"] as? [String: Any],
       let profit = trade["profit"] as? Double {
      titleLabel?.text = "New Trade"
      profitLabel?.text = String(format: "+%.2f%%", profit)
      profitLabel?.textColor = profit >= 0 ? .systemGreen : .systemRed
    }
  }
}
```

### WatchKit App

```bash
npx create-target watch
```

`targets/watch-app/expo-target.config.js`:
```javascript
module.exports = {
  type: "watch",
  name: "FreqWatchApp",
  displayName: "FreqWatch",
  frameworks: ["SwiftUI", "WatchKit"],
  deploymentTarget: "9.0"
}
```

### Dynamic Configuration with Function

```javascript
module.exports = ({ config }) => ({
  type: "widget",
  name: "MyWidget",
  // Inherit entitlements from main app
  entitlements: {
    ...config.ios.entitlements,
    "com.apple.security.application-groups": ["group.com.yourapp.shared"]
  }
});
```

## Resources

- [expo-apple-targets Docs](https://github.com/EvanBacon/expo-apple-targets)
- [Apple Widget Guidelines](https://developer.apple.com/design/human-interface-guidelines/widgets)
- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [App Groups Guide](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)

## Tools & Commands

- `npx create-target` - Create new Apple target
- `npx expo prebuild -p ios --clean` - Generate Xcode project
- `xcrun simctl --set previews delete all` - Clear SwiftUI preview cache
- `ExtensionStorage.reloadWidget()` - Reload widget timelines

## Troubleshooting

### Widget not appearing on iOS 18+

**Problem**: Widget doesn't show in widget gallery

**Solution**: Long-press the app icon → "Edit Home Screen" → tap "+" → find your app

### Changes not reflecting

**Problem**: Code changes don't appear after rebuild

**Solution**:
```bash
# Clean prebuild
npx expo prebuild -p ios --clean

# Clear Xcode cache
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Clear SwiftUI previews
xcrun simctl --set previews delete all
```

### App Group not working

**Problem**: Widget can't read shared data

**Solution**:
1. Check App Group ID matches exactly in both main app and target
2. Verify entitlements in `expo-target.config.js`
3. Check Xcode Signing & Capabilities has App Groups enabled
4. Ensure `ios.appleTeamId` is set in `app.json`

### Prebuild fails

**Problem**: `npx expo prebuild` errors

**Solution**:
- Update CocoaPods: `sudo gem install cocoapods`
- Check Ruby version: `ruby --version` (need 3.2.0+)
- Verify Xcode 16+ installed
- Check `expo-target.config.js` syntax

---

## Notes

- expo-apple-targets is experimental (by Evan Bacon)
- Requires Expo SDK 53+ and Xcode 16+
- EAS Build handles code signing automatically
- Changes to config require `npx expo prebuild --clean`
- Files outside `expo:targets/` in Xcode will be overwritten
- Use continuous native generation workflow (never manually edit /ios)
