# Uniwind - Complete Documentation Reference

**Version:** 1.0.0+
**Official Docs:** https://docs.uniwind.dev/

## Overview

Uniwind is **the fastest Tailwind bindings for React Native**, enabling developers to use Tailwind CSS utility classes directly in React Native applications with optimal performance through compile-time CSS processing and zero re-renders architecture.

## Core Concepts

### Compile-Time Processing
Uniwind processes Tailwind classes at build time, converting them to React Native-compatible style objects. This eliminates runtime overhead and delivers optimal performance compared to alternatives like NativeWind.

### Zero Re-renders Philosophy
The library maintains stable style references, preventing unnecessary component re-renders when styles are applied. This architectural approach significantly improves app responsiveness and performance.

### CSS-First Configuration
Unlike traditional React Native styling, Uniwind uses CSS files for theme configuration instead of JavaScript config files. This approach aligns with Tailwind 4's new architecture and simplifies theme management.

## Installation and Setup

### Quick Installation

```bash
# Using bun (recommended)
bun add uniwind tailwindcss

# Using npm
npm install uniwind tailwindcss

# Using yarn
yarn add uniwind tailwindcss
```

Uniwind supports:
- Expo projects
- Bare React Native
- Vite setups

### Create Global CSS File

Create a `global.css` file at your project root:

```css
@import 'tailwindcss';
@import 'uniwind';
```

**CRITICAL:** The location of `global.css` determines your app root. Tailwind automatically scans for class names starting from this location.

### Import CSS in Your App

Add to your main component file (`App.tsx`):

```tsx
import './global.css'

export const App = () => {
  // Your app code
}
```

**WARNING:** Do NOT import in root `index.ts` - this prevents hot reload functionality and requires full app restarts on changes.

### Configure Metro Bundler

For Expo projects, modify `metro.config.js`:

```javascript
const { getDefaultConfig } = require('expo/metro-config');
const { withUniwindConfig } = require('uniwind/metro');

const config = getDefaultConfig(__dirname);

module.exports = withUniwindConfig(config, {
  cssEntryFile: './src/global.css',
  dtsFile: './src/uniwind-types.d.ts'
});
```

**CRITICAL:** `withUniwindConfig` must be the outermost wrapper in your Metro config. If using other wrappers, ensure Uniwind wraps them all.

### Optional: IDE Support

Configure Tailwind IntelliSense in VSCode/Cursor by adding to `settings.json`:

```json
{
  "tailwindCSS.classAttributes": [
    "className",
    "class",
    "contentContainerClassName"
  ],
  "tailwindCSS.classFunctions": ["useResolveClassNames"]
}
```

## Utility Classes

Uniwind provides comprehensive Tailwind class support including:

- **Spacing:** padding, margin, gap utilities
- **Typography:** font families, sizes, weights, line heights
- **Colors:** background, text, border colors with full palette
- **Sizing:** width, height, min/max dimensions
- **Flexbox:** flex direction, alignment, justification, wrapping
- **Grid:** grid templates, gaps, auto-flow
- **Borders:** radius, width, style, colors
- **Shadows:** elevation and shadow effects
- **Effects:** opacity, transforms, transitions
- **Layout:** position, display, overflow

### Supported Components

**React Native Built-in:**
- Text, View, ScrollView
- FlatList, SectionList
- Image, ImageBackground
- Button, Pressable
- Modal, ActivityIndicator
- Switch, TextInput
- TouchableOpacity, TouchableWithoutFeedback

**Third-party Libraries:**
Integration patterns provided for external component systems via `withUniwind` HOC.

## Basic Usage

Apply Tailwind classes via the `className` prop:

```tsx
import { View, Text } from 'react-native'

export const MyComponent = () => {
  return (
    <View className="flex-1 bg-white p-4">
      <Text className="text-xl font-bold text-gray-900">
        Hello Uniwind!
      </Text>
    </View>
  )
}
```

## API Reference

### Hooks

#### useUniwind

Access current theme name and adaptive theme status with automatic re-renders on theme changes.

```tsx
import { useUniwind } from 'uniwind'

const MyComponent = () => {
  const { theme, hasAdaptiveThemes } = useUniwind()

  // theme: "light" | "dark" | "system" | custom theme name
  // hasAdaptiveThemes: boolean - follows device system preference

  return (
    <View>
      <Text>Current theme: {theme}</Text>
    </View>
  )
}
```

**Use cases:**
- Display current theme name in UI
- Check adaptive theme status
- Conditional rendering based on theme
- Execute side effects during theme changes
- Analytics/logging

**Note:** For styling, prefer theme-based className variants like `dark:bg-gray-900`.

#### useResolveClassNames

Convert Tailwind class names to React Native style objects at runtime.

```tsx
import { useResolveClassNames } from 'uniwind'

const MyComponent = () => {
  const styles = useResolveClassNames('bg-red-500 p-4 rounded-lg')

  return <View style={styles}>Content</View>
}
```

**When to use:**
- Working with libraries that only accept `style` props
- Configuring react-navigation themes
- Dynamic style generation
- Legacy code requiring style objects

**Performance note:** Runtime processing is slightly less performant than compile-time resolution. Prefer `className` when possible.

**Example with react-navigation:**

```tsx
const headerStyle = useResolveClassNames('bg-blue-500')
const cardStyle = useResolveClassNames('bg-white dark:bg-gray-900')

<NavigationContainer theme={theme}>
  <Stack.Navigator screenOptions={{ headerStyle, cardStyle }}>
    {/* screens */}
  </Stack.Navigator>
</NavigationContainer>
```

#### useCSSVariable

Access CSS variable values in JavaScript with automatic theme updates.

```tsx
import { useCSSVariable } from 'uniwind'

const MyComponent = () => {
  const primaryColor = useCSSVariable('--color-primary')

  // Use in JavaScript logic, calculations, etc.
  return <View>{/* component */}</View>
}
```

### Higher-Order Components

#### withUniwind

Wrap React Native components to add `className` prop support for third-party libraries.

```tsx
import { withUniwind } from 'uniwind'
import { SafeAreaView } from 'react-native-safe-area-context'

const StyledSafeAreaView = withUniwind(SafeAreaView)

// Now supports className
<StyledSafeAreaView className="flex-1 bg-background">
  {/* content */}
</StyledSafeAreaView>
```

**Automatic prop mapping:**

| Original Prop | Mapped Prop | Usage |
|---|---|---|
| `style` | `className` | Standard styling |
| `color` | `colorClassName` | Color application |
| `backgroundColor` | `backgroundColorClassName` | Background colors |
| `borderColor` | `borderColorClassName` | Border colors |
| `tintColor` | `tintColorClassName` | Tint colors |

**Custom prop mapping:**

```tsx
export const StyledPath = withUniwind(Path, {
  stroke: {
    fromClassName: 'strokeClassName',
    styleProperty: 'accentColor'
  }
})

<StyledPath strokeClassName="accent-red-500 dark:accent-blue-100" />
```

**Best practices:**
1. Create reusable components in separate files
2. Define wrappers at module level (not inside components)
3. Export for app-wide use

```tsx
// components/styled.ts
export const StyledSafeAreaView = withUniwind(SafeAreaView)
export const StyledKeyboardAwareScrollView = withUniwind(KeyboardAwareScrollView)
```

### CSS Functions

The CSS Parser enables writing custom CSS classes alongside Tailwind in your React Native app, extending beyond standard utilities.

## Performance Benefits

Uniwind delivers "cutting-edge performance" through:

1. **Compile-time processing:** Styles generated during build, not runtime
2. **Stable references:** Prevents unnecessary re-renders
3. **Optimized bundles:** Only used styles included
4. **Zero runtime overhead:** No style calculations during app execution
5. **Tree-shaking:** Unused utilities automatically removed

## Pro Version

An advanced Pro tier offers enhanced performance features and capabilities.
**Details:** uniwind.dev/pricing

## Community & Support

- **GitHub:** uni-stack/uniwind
- **Discussions:** GitHub discussions forum
- **Issues:** GitHub issue tracker
- **Professional services:** CodeMask for custom implementation

## Next Steps

1. Explore theming system for light/dark modes
2. Learn platform-specific styling patterns
3. Implement responsive breakpoints
4. Review component-specific className support
5. Check migration guide if coming from NativeWind
