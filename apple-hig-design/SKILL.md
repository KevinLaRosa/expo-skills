---
name: apple-hig-design
description: Design iOS, iPadOS, macOS, watchOS, and tvOS apps following Apple's Human Interface Guidelines for native-feeling experiences with proper components, layouts, and accessibility
license: MIT
compatibility: "Requires: Basic understanding of iOS design patterns, access to SF Symbols app (optional)"
---

# Apple HIG Design

## Overview

Follow Apple's Human Interface Guidelines (HIG) to create apps that feel native, accessible, and consistent with the Apple ecosystem across all platforms.

## When to Use This Skill

- Designing new iOS/iPadOS/macOS/watchOS/tvOS app interfaces
- Making design decisions for navigation patterns, controls, or layouts
- Ensuring accessibility compliance (VoiceOver, Dynamic Type, color contrast)
- Choosing typography, colors, or SF Symbols
- When design feels "off" or doesn't match native iOS apps
- Implementing Dark Mode properly
- Reviewing designs for Apple App Store submission

## Workflow

### Step 1: Understand Core Design Principles

**Three Pillars of iOS Design:**

1. **Clarity** - Text is legible, icons are precise, functionality is obvious
   - Use system fonts (SF Pro, SF Rounded, SF Mono, New York)
   - Ensure 44pt minimum touch targets
   - Maintain contrast ratios (4.5:1 for text, 3:1 for large text)

2. **Deference** - UI helps people understand and interact with content
   - Blur backgrounds, translucency effects
   - Full-screen layouts that minimize chrome
   - Subtle animations that provide context

3. **Depth** - Visual layers and motion convey hierarchy
   - Realistic shadows and elevation
   - Parallax effects
   - Contextual transitions

### Step 2: Choose Navigation Pattern

**iOS Navigation Patterns:**

**Tab Bar** (Most common):
- 2-5 tabs for top-level navigation
- Current tab highlighted
- Icons + labels (required on iPhone)
- Use for: Instagram, Twitter, App Store

**Navigation Bar** (Hierarchical):
- Back button, title, trailing buttons
- Large title on top-level screens
- Inline title when scrolling
- Use for: Settings, Mail, Files

**Split View** (iPad):
- Sidebar + detail view
- Persistent navigation on iPad landscape
- Use for: Mail, Notes, Files

**Modal Sheets**:
- Pull-to-dismiss gesture
- Handle at top (iOS 15+)
- `.sheet()`, `.fullScreenCover()` in SwiftUI
- Use for: Creating content, forms, self-contained tasks

### Step 3: Use System Components

**Typography:**
```swift
// SwiftUI - Always use Dynamic Type
Text("Headline")
    .font(.headline)

Text("Body")
    .font(.body)

Text("Caption")
    .font(.caption)
```

**SF Symbols** (5000+ icons):
- Use `Image(systemName: "star.fill")`
- Automatic weight, size, and color matching
- Multicolor, hierarchical, palette rendering modes
- Download SF Symbols app for browsing

**Buttons:**
```swift
// Filled (primary action)
Button("Continue") { }
    .buttonStyle(.borderedProminent)

// Bordered (secondary action)
Button("Cancel") { }
    .buttonStyle(.bordered)

// Plain (tertiary action)
Button("Skip") { }
    .buttonStyle(.plain)
```

**Lists:**
```swift
List {
    Section("Header") {
        Text("Row 1")
        Text("Row 2")
    }
}
.listStyle(.insetGrouped)  // iOS default
```

### Step 4: Apply Color and Materials

**System Colors (adaptive for Dark Mode):**
```swift
// Semantic colors (preferred)
Color.primary          // Label text
Color.secondary        // Secondary label text
Color.accentColor      // User's accent color
Color(uiColor: .systemBackground)
Color(uiColor: .secondarySystemBackground)

// Dynamic colors
Color(uiColor: .label)
Color(uiColor: .systemGray)
```

**Materials (blur + vibrancy):**
```swift
.background(.ultraThinMaterial)
.background(.thinMaterial)
.background(.regularMaterial)
.background(.thickMaterial)
```

**Custom Colors (must adapt to Dark Mode):**
```swift
Color("CustomBlue")  // Define in Asset Catalog with Light/Dark variants
```

### Step 5: Implement Proper Layouts

**Safe Areas:**
```swift
// Respect safe areas by default
VStack {
    Text("Content")
}
.padding()  // Adds 16pt padding

// Edge-to-edge when needed
Image("hero")
    .resizable()
    .ignoresSafeArea()
```

**Margins and Spacing:**
- **Standard margin**: 16pt from edges
- **Inter-element spacing**: 8pt, 12pt, 16pt (multiples of 4)
- **Minimum touch target**: 44pt × 44pt

**Adaptive Layouts (iPad):**
```swift
HStack {
    // Sidebar on iPad, bottom sheet on iPhone
}
.frame(minWidth: 320, idealWidth: 375, maxWidth: .infinity)
```

### Step 6: Support Accessibility

**Dynamic Type:**
```swift
// ✅ Scales automatically
Text("Hello")
    .font(.body)

// ❌ Fixed size
Text("Hello")
    .font(.system(size: 17))
```

**VoiceOver Labels:**
```swift
Button(action: dismiss) {
    Image(systemName: "xmark")
}
.accessibilityLabel("Close")

Image("logo")
    .accessibilityHidden(true)  // Decorative image
```

**Color Contrast:**
- 4.5:1 for body text (WCAG AA)
- 3:1 for large text (24pt+)
- Test with Xcode Accessibility Inspector

**Reduce Motion:**
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

if reduceMotion {
    // Use fade instead of slide
    withAnimation(.easeInOut) { }
} else {
    withAnimation(.spring()) { }
}
```

### Step 7: Implement Dark Mode

**Automatic Support:**
```swift
// Use semantic colors - they adapt automatically
Color.primary
Color.secondary
Color(uiColor: .systemBackground)
```

**Custom Colors:**
- Define in Asset Catalog with "Any Appearance" and "Dark" variants
- Or use adaptive `Color(light:dark:)` initializer

**Test Dark Mode:**
- Xcode preview: `.preferredColorScheme(.dark)`
- Simulator: Settings → Developer → Dark Appearance
- Never assume background is white or black

### Step 8: Add Motion and Feedback

**Haptic Feedback:**
```swift
import UIKit

// Impact
let impact = UIImpactFeedbackGenerator(style: .medium)
impact.impactOccurred()

// Selection
let selection = UISelectionFeedbackGenerator()
selection.selectionChanged()

// Notification
let notification = UINotificationFeedbackGenerator()
notification.notificationOccurred(.success)
```

**Animations:**
```swift
// Standard spring (feels native)
withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
    isExpanded.toggle()
}

// Smooth easeInOut
withAnimation(.easeInOut(duration: 0.2)) {
    opacity = 1.0
}
```

## Guidelines

**Do:**
- Use system fonts and SF Symbols for consistency
- Respect safe areas (notch, home indicator, Dynamic Island)
- Support Dynamic Type (accessibility)
- Test in Dark Mode from the start
- Use semantic colors (`.primary`, `.secondary`)
- Follow platform conventions (swipe to delete, pull to refresh)
- Provide haptic feedback for important interactions
- Use 44pt minimum touch targets
- Test with VoiceOver enabled
- Use standard navigation patterns (tab bar, nav bar)
- Embrace full-screen layouts with minimal chrome

**Don't:**
- Don't use Android Material Design patterns (FAB, snackbars, etc.)
- Don't hardcode colors - use adaptive Asset Catalog colors
- Don't ignore safe areas (content under notch)
- Don't use fixed font sizes (breaks accessibility)
- Don't create custom controls when system controls exist
- Don't use low-contrast colors (test with Accessibility Inspector)
- Don't forget to test on iPhone SE (small screen) and iPad
- Don't override system gestures (swipe back, swipe between tabs)
- Don't use more than 5 tab bar items
- Don't forget to add `accessibilityLabel` to icon-only buttons

## Examples

### Example 1: Settings-Style List

```swift
import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Notifications", isOn: $notificationsEnabled)

                    NavigationLink("Account") {
                        AccountView()
                    }

                    NavigationLink("Privacy") {
                        PrivacyView()
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
```

### Example 2: Card with Material Background

```swift
import SwiftUI

struct CardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundStyle(.blue)
                    .font(.title2)

                Text("Notification")
                    .font(.headline)
            }

            Text("Your order has been delivered")
                .font(.body)
                .foregroundStyle(.secondary)

            Button("View Details") { }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding()
    }
}
```

### Example 3: Adaptive Color

```swift
import SwiftUI

struct AdaptiveColorView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Semantic colors (preferred)
            Text("Primary Text")
                .foregroundStyle(.primary)

            Text("Secondary Text")
                .foregroundStyle(.secondary)

            // Custom adaptive color (define in Assets.xcassets)
            Rectangle()
                .fill(Color("BrandColor"))  // Auto adapts to Dark Mode
                .frame(height: 100)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
    }
}
```

### Example 4: Accessibility with Dynamic Type

```swift
import SwiftUI

struct AccessibleTextView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Large Title")
                .font(.largeTitle)

            Text("This text automatically scales based on user's preferred text size in Settings → Accessibility → Display & Text Size")
                .font(.body)

            // For custom layouts that need to adapt
            ViewThatFits {
                HStack {
                    Text("Name:")
                    TextField("Enter name", text: .constant(""))
                }

                VStack(alignment: .leading) {
                    Text("Name:")
                    TextField("Enter name", text: .constant(""))
                }
            }
        }
        .padding()
    }
}
```

### Example 5: Modal Sheet with Handle

```swift
import SwiftUI

struct ContentView: View {
    @State private var showSheet = false

    var body: some View {
        Button("Show Sheet") {
            showSheet = true
        }
        .sheet(isPresented: $showSheet) {
            SheetContent()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

struct SheetContent: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Text("Item 1")
                Text("Item 2")
            }
            .navigationTitle("Sheet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
```

## Resources

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SF Symbols App](https://developer.apple.com/sf-symbols/) (Download from Apple)
- [Apple Design Resources](https://developer.apple.com/design/resources/) (Figma, Sketch, Adobe XD kits)
- [WWDC Design Sessions](https://developer.apple.com/videos/design/)
- [Xcode Accessibility Inspector](https://developer.apple.com/library/archive/documentation/Accessibility/Conceptual/AccessibilityMacOSX/OSXAXTestingApps.html)

## Tools & Commands

- **SF Symbols App** - Browse 5000+ system icons
- **Xcode Previews** - Test Light/Dark Mode: `.preferredColorScheme(.dark)`
- **Accessibility Inspector** - Xcode → Open Developer Tool → Accessibility Inspector
- **Color Contrast Checker** - [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- **Simulator** - Settings → Accessibility to test Dynamic Type, VoiceOver, Reduce Motion

## Troubleshooting

### Content cuts off with large Dynamic Type

**Problem**: Text truncates or UI breaks with accessibility text sizes

**Solution**:
```swift
// Use ViewThatFits for adaptive layouts
ViewThatFits {
    HStack { /* Horizontal layout */ }
    VStack { /* Vertical layout */ }
}

// Or allow multiline
Text("Long text")
    .fixedSize(horizontal: false, vertical: true)
```

### Dark Mode colors look wrong

**Problem**: Custom colors don't adapt to Dark Mode

**Solution**:
1. Define colors in Asset Catalog with Light/Dark variants
2. Use semantic colors: `.primary`, `.secondary`, `Color(uiColor: .systemBackground)`
3. Never hardcode `Color.white` or `Color.black`

### Safe area issues

**Problem**: Content hidden under notch or home indicator

**Solution**:
```swift
// Respect safe areas (default behavior)
VStack {
    Content()
}
.padding()  // Adds safe area padding

// Only ignore for full-bleed images
Image("hero")
    .ignoresSafeArea()
```

### App rejected for accessibility

**Problem**: App Store rejection for accessibility issues

**Solution**:
1. Add `accessibilityLabel` to all icon-only buttons
2. Ensure 4.5:1 contrast ratio for text
3. Test with VoiceOver enabled
4. Support Dynamic Type (use `.font(.body)` not `.font(.system(size: 17))`)
5. Provide text alternatives for images
