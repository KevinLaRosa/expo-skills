# SwiftUI Performance Optimization

> Source: [Axiom - SwiftUI Performance](https://charleswiltgen.github.io/Axiom/skills/ui-design/swiftui-performance)

## Overview
This skill addresses performance issues in SwiftUI applications using Instruments 26's SwiftUI Instrument. The core principle is: "Ensure your view bodies update quickly and only when needed."

## When to Use This Skill
Apply this skill when experiencing:
- Reduced app responsiveness (hitches, hangs, delayed scrolling)
- Animation pauses or frame drops
- Poor scrolling performance
- SwiftUI identified as the bottleneck via profiling
- Excessive view updates despite unchanged data
- Need to trace cause-and-effect of updates

## Key Problems & Solutions

### Problem 1: Long View Body Updates
**Issue**: Individual view bodies exceed frame deadline (slow CPU operations)

**Common expensive operations**:
- Creating formatters within view bodies
- Complex calculations
- Image processing
- File I/O operations

**Solution pattern**: Move expensive work to the model layer and cache results

**Example - Wrong approach**:
```swift
var distance: String {
    let formatter = MeasurementFormatter() // Expensive!
    return formatter.string(from: measurement)
}
```

**Example - Correct approach**:
```swift
@Observable
class LocationFinder {
    private let formatter = MeasurementFormatter() // Created once
    private var distanceCache: [ID: String] = [:]

    func distanceString(for id: ID) -> String {
        distanceCache[id] ?? "Unknown"  // Fast lookup
    }
}
```

### Problem 2: Unnecessary View Updates
**Issue**: Many rapid updates accumulate, missing frame deadlines even with fast individual updates

**Root cause**: Whole-collection dependencies trigger view recomputation

**Solution**: Use granular view model patterns and per-item dependencies

**Example - Wrong approach**:
```swift
func isFavorite(_ landmark: Landmark) -> Bool {
    favoritesCollection.landmarks.contains(landmark) // Array dependency
}
```

**Example - Correct approach**:
```swift
@Observable
class LandmarkViewModel {
    var isFavorite: Bool = false
}
// Tapping button updates only that view model → one view body runs
```

## SwiftUI Instrument (Instruments 26)

### Track Lanes
- **Update Groups**: Groups of synchronized updates
- **Long View Body Updates**: View bodies exceeding frame deadline
- **Long Representable Updates**: SwiftUI rendering delays
- **Other Long Updates**: Additional performance issues

### Color Coding
- Red: Investigate immediately
- Orange: Secondary priority
- Gray: Minor concerns

### Cause & Effect Graph
Visualizes data flow to identify why views update, helping trace dependency chains back to source.

## iOS 26 Framework Improvements
- 6x faster list loading (macOS, 100k+ items)
- 16x faster list updates
- Reduced dropped frames during scrolling
- Nested ScrollView lazy loading optimization

## Decision-Making Framework

For production issues: Use a 30-minute diagnostic protocol to profile before guessing. Profiling time cost is often less than shipping with wrong fixes.

## Related Skills
- **swiftui-debugging**: For view update failures or preview crashes
- **performance-profiling**: For non-SwiftUI performance issues (memory, CPU, network)

## Resources
WWDC 2025-306: "Optimize SwiftUI performance with Instruments"
