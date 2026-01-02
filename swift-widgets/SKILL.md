---
name: swift-widgets
description: Build performant iOS widgets with SwiftUI and WidgetKit for Expo apps using expo-apple-targets with production-grade patterns and optimization
license: MIT
compatibility: "Requires: Xcode 16+, macOS 15+, expo-apple-targets, SwiftUI, WidgetKit knowledge"
---

# Swift Widgets

## Overview

Build high-performance iOS widgets using SwiftUI and WidgetKit for Expo apps with expo-apple-targets, following production-grade patterns for optimization, memory management, and seamless React Native integration.

## When to Use This Skill

- Building iOS Home Screen widgets for Expo app
- Creating Lock Screen widgets (iOS 16+)
- Implementing StandBy mode widgets (iOS 17+)
- Need performant widget updates without battery drain
- Sharing data between app and widgets via App Groups
- Debugging widget performance issues
- Optimizing widget memory usage

**When you see:**
- "Widget not updating"
- "Widget using too much memory"
- "Widget draining battery"
- "Widget timeline issues"

**Prerequisites**: Use `expo-apple-targets` skill first to setup widgets infrastructure.

## Workflow

### Step 1: Design Widget Timeline Strategy

Choose timeline update strategy based on data freshness needs:

**Static Timeline** (best battery):
```swift
// Update once, never refresh
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    let entry = SimpleEntry(date: Date(), data: loadData())
    let timeline = Timeline(entries: [entry], policy: .never)
    completion(timeline)
}
```

**Scheduled Timeline** (moderate battery):
```swift
// Update every 15 minutes
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    let currentDate = Date()
    let entries = (0..<4).map { offset in
        let entryDate = Calendar.current.date(byAdding: .minute, value: offset * 15, to: currentDate)!
        return SimpleEntry(date: entryDate, data: loadData())
    }
    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
}
```

**Dynamic Timeline** (heavy battery):
```swift
// Update after each entry expires
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    let entry = SimpleEntry(date: Date(), data: loadData())
    let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
    let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
    completion(timeline)
}
```

### Step 2: Optimize SwiftUI View Performance

**Use efficient view patterns:**

```swift
import SwiftUI
import WidgetKit

struct TradingWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        // ✅ Good: Flat hierarchy, no unnecessary containers
        ZStack {
            ContainerRelativeShape()
                .fill(.background.tertiary)

            VStack(alignment: .leading, spacing: 8) {
                // ✅ Good: Static text, no formatters in body
                Text(entry.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                // ✅ Good: Preformatted text from Entry
                Text(entry.formattedProfit)
                    .font(.largeTitle)
                    .foregroundStyle(entry.profitColor)
            }
            .padding()
        }
    }
}
```

**Avoid performance pitfalls:**

```swift
// ❌ Bad: Deep view hierarchy
VStack {
    HStack {
        VStack {
            HStack {
                Text("Data")  // Too nested
            }
        }
    }
}

// ✅ Good: Flat hierarchy
VStack(spacing: 4) {
    Text("Title").font(.headline)
    Text("Value").font(.largeTitle)
}

// ❌ Bad: Heavy computation in view body
var body: some View {
    Text(formatCurrency(entry.profit))  // Computed every render
}

// ✅ Good: Precompute in Entry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let formattedProfit: String  // Formatted once
}
```

### Step 3: Implement Efficient Data Loading

**Load data from App Groups:**

```swift
import Foundation

extension UserDefaults {
    static let shared = UserDefaults(suiteName: "group.com.yourapp.shared")!
}

struct Provider: TimelineProvider {
    func loadWidgetData() -> WidgetData? {
        // ✅ Good: Simple, fast data loading
        guard let data = UserDefaults.shared.data(forKey: "widgetData"),
              let widgetData = try? JSONDecoder().decode(WidgetData.self, from: data) else {
            return nil
        }
        return widgetData
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // ✅ Good: Quick load, no network requests
        let data = loadWidgetData() ?? WidgetData.placeholder
        let entry = SimpleEntry(date: Date(), data: data)

        // ✅ Good: Simple timeline policy
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}
```

**Avoid heavy operations:**

```swift
// ❌ Bad: Network request in widget
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    URLSession.shared.dataTask(with: url) { data, _, _ in
        // DON'T do network requests in widgets!
    }
}

// ❌ Bad: Heavy computation
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    let entries = heavyDataProcessing()  // Kills battery
}

// ✅ Good: Read pre-processed data
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    let data = UserDefaults.shared.object(forKey: "processedData")
}
```

### Step 4: Manage Memory Efficiently

**Keep Entry lightweight:**

```swift
// ✅ Good: Minimal data in Entry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let profit: Double
    let profitText: String  // Preformatted
    let color: Color        // Precomputed
}

// ❌ Bad: Heavy data in Entry
struct BadEntry: TimelineEntry {
    let date: Date
    let allTrades: [Trade]           // Too much data
    let historicalData: [DataPoint]   // Unnecessary
    let images: [UIImage]             // Memory hog
}
```

**Limit timeline entries:**

```swift
// ✅ Good: Limited entries
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    let entries = (0..<5).map { offset in  // Only 5 entries
        createEntry(for: offset)
    }
    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
}

// ❌ Bad: Too many entries
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    let entries = (0..<100).map { offset in  // 100 entries = memory waste
        createEntry(for: offset)
    }
}
```

### Step 5: Update Widgets from React Native

**From Expo app, trigger widget refresh:**

```typescript
// In your React Native app
import { ExtensionStorage } from '@bacons/apple-targets';

// Update widget data
const storage = new ExtensionStorage('group.com.yourapp.shared');

async function updateWidget(tradeData: TradeData) {
  // Save data to App Group
  await storage.set('widgetData', JSON.stringify(tradeData));

  // Reload widget timeline
  ExtensionStorage.reloadWidget();
}

// Call when data changes
useEffect(() => {
  if (newTrade) {
    updateWidget({
      profit: newTrade.profit,
      timestamp: Date.now(),
    });
  }
}, [newTrade]);
```

### Step 6: Debug Widget Performance

**Use Xcode Instruments:**

```bash
# Profile widget in Xcode
# 1. Select widget scheme
# 2. Product → Profile (Cmd+I)
# 3. Choose "Time Profiler" or "Allocations"
# 4. Look for hot paths in timeline generation
```

**Common issues and fixes:**

```swift
// Issue: Widget timeline taking too long
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    // ✅ Profile this code path
    let start = Date()

    let data = loadData()
    let entry = SimpleEntry(date: Date(), data: data)
    let timeline = Timeline(entries: [entry], policy: .atEnd)

    let duration = Date().timeIntervalSince(start)
    print("Timeline generation took: \(duration)s")  // Should be < 0.1s

    completion(timeline)
}
```

### Step 7: Handle Widget Families

**Support multiple widget sizes:**

```swift
import WidgetKit
import SwiftUI

struct TradingWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "TradingWidget", provider: Provider()) { entry in
            TradingWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Trading Stats")
        .description("View your trading performance")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryRectangular  // Lock Screen
        ])
    }
}

struct TradingWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .accessoryRectangular:
            LockScreenWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}
```

## Guidelines

**Do:**
- Keep timeline provider code fast (<100ms)
- Precompute and preformat data in Entry struct
- Use flat view hierarchies (avoid deep nesting)
- Limit number of timeline entries (5-10 max)
- Use App Groups for data sharing
- Test on real devices (simulators miss performance issues)
- Profile with Instruments regularly
- Follow Apple's widget design guidelines

**Don't:**
- Don't make network requests in widgets
- Don't perform heavy computations in timeline provider
- Don't store large data in timeline entries
- Don't use complex animations (not supported)
- Don't update too frequently (battery drain)
- Don't use @State or @StateObject (widgets are stateless)
- Don't use gestures (limited tap support only)
- Don't ignore memory warnings

## Examples

### Trading Widget with Color Coding

```swift
struct TradingEntry: TimelineEntry {
    let date: Date
    let profit: Double

    var profitText: String {
        String(format: "%+.2f%%", profit)
    }

    var profitColor: Color {
        profit >= 0 ? .green : .red
    }
}

struct TradingWidgetView: View {
    var entry: TradingEntry

    var body: some View {
        VStack(spacing: 8) {
            Text("Profit")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(entry.profitText)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(entry.profitColor)
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}
```

### Lock Screen Widget (iOS 16+)

```swift
struct LockScreenWidget: View {
    var entry: TradingEntry

    var body: some View {
        // Lock screen widgets are simpler
        HStack(spacing: 4) {
            Image(systemName: entry.profit >= 0 ? "arrow.up" : "arrow.down")
            Text(entry.profitText)
                .font(.system(.body, design: .rounded))
        }
    }
}
```

### Deep Link to App

```swift
struct TradingWidgetView: View {
    var entry: TradingEntry

    var body: some View {
        VStack {
            Text(entry.profitText)
        }
        .containerBackground(.fill.tertiary, for: .widget)
        .widgetURL(URL(string: "myapp://trades")!)  // Deep link
    }
}
```

## Resources

- [expo-apple-targets Skill](../expo-apple-targets/SKILL.md) - Setup widgets infrastructure
- [SwiftUI Performance Patterns](references/axiom-swiftui-performance.md) - Performance optimization (Axiom)
- [Apple WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [Widget Design Guidelines](https://developer.apple.com/design/human-interface-guidelines/widgets)
- [WWDC Widget Videos](https://developer.apple.com/videos/play/wwdc2024/10075/)

## Tools & Commands

- Xcode Instruments → Time Profiler
- Xcode Instruments → Allocations
- `ExtensionStorage.reloadWidget()` - Reload from React Native
- Widget simulator: Long-press app icon → Edit Home Screen

## Troubleshooting

### Widget not updating

**Problem**: Widget shows stale data

**Solution**:
```swift
// 1. Check timeline policy
let timeline = Timeline(entries: entries, policy: .atEnd)  // Forces refresh

// 2. Reload from React Native
ExtensionStorage.reloadWidget()

// 3. Check App Group data
let data = UserDefaults.shared.data(forKey: "widgetData")
print("Widget data: \(String(describing: data))")
```

### Widget using too much memory

**Problem**: Widget killed by system

**Solution**:
```swift
// 1. Reduce Entry size
struct Entry: TimelineEntry {
    let date: Date
    let value: Double  // ✅ Simple types only
    // Remove: let largeArray: [Data]  ❌
}

// 2. Limit timeline entries
let entries = (0..<5).map { ... }  // ✅ Max 5-10 entries
```

### Widget timeline slow

**Problem**: Timeline generation takes >1 second

**Solution**:
```swift
// Profile and optimize
func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    // ✅ Use cached data
    let data = UserDefaults.shared.object(forKey: "cachedData")

    // ✅ Avoid heavy computation
    let entry = SimpleEntry(date: Date(), value: data.value)

    completion(Timeline(entries: [entry], policy: .atEnd))
}
```

---

## Notes

- Widgets are stateless - rebuild on every timeline entry
- Timeline provider must return quickly (<1 second)
- System limits widget update frequency (battery optimization)
- Use App Groups for data sharing with main app
- Lock Screen widgets (iOS 16+) have size constraints
- StandBy mode (iOS 17+) requires specific layouts
- Test on physical devices (simulators don't show real performance)
- Follow SwiftUI performance patterns from Axiom for complex widgets
- Use `@Environment(\.widgetFamily)` to adapt to widget size
