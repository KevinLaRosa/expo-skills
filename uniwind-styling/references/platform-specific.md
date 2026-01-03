# Platform-Specific Styling in Uniwind

## Overview

Uniwind provides powerful platform selectors that enable conditional styling based on the runtime platform. These selectors are resolved at runtime and automatically apply correct styles for iOS, Android, Web, and native (iOS + Android) platforms.

## Platform Selectors

### Available Selectors

Uniwind supports four platform-specific selectors:

| Selector | Target Platform | Use Case |
|----------|----------------|----------|
| `ios:` | iPhone and iPad devices | iOS-specific styling |
| `android:` | Android devices | Android-specific styling |
| `web:` | Web browsers, React Native Web | Web-specific styling |
| `native:` | Both iOS and Android | Mobile-specific (iOS + Android) |

### Runtime Resolution

Platform selectors are resolved at runtime, automatically applying correct styles based on the current execution environment. This eliminates the need for Platform.select() API calls and improves code readability.

## Basic Usage

### Simple Platform Styling

Apply platform-specific classes using `platform:utility` syntax:

```tsx
import { View, Text } from 'react-native'

const MyComponent = () => {
  return (
    <View className="ios:bg-red-500 android:bg-blue-500 web:bg-green-500">
      <Text className="ios:text-white android:text-white web:text-black">
        Platform-specific content
      </Text>
    </View>
  )
}
```

**Result:**
- iOS: Red background with white text
- Android: Blue background with white text
- Web: Green background with black text

### Native Selector

When iOS and Android share identical styles but differ from web:

```tsx
<View className="native:bg-blue-500 web:bg-gray-500">
  <Text className="native:text-white web:text-black">
    Mobile vs Web content
  </Text>
</View>
```

**Benefits:**
- Reduces code duplication
- Improves maintainability
- Clearer intent (mobile vs web)

## Platform-Specific Styling Patterns

### Colors and Backgrounds

Different color schemes per platform:

```tsx
<View className="
  ios:bg-blue-500
  android:bg-green-500
  web:bg-purple-500
">
  <Text className="
    ios:text-white
    android:text-white
    web:text-gray-900
  ">
    Platform colors
  </Text>
</View>
```

### Spacing

Platform-specific padding and margins:

```tsx
<View className="
  ios:pt-12 ios:px-6
  android:pt-6 android:px-4
  web:pt-4 web:px-8
">
  <Text>Different spacing per platform</Text>
</View>
```

**Common pattern - Safe areas:**

```tsx
<View className="
  ios:pt-12
  android:pt-6
  web:pt-4
  px-4
">
  {/* Content with platform-specific top padding */}
</View>
```

### Typography

Platform-appropriate font sizes and weights:

```tsx
<Text className="
  ios:text-lg ios:font-semibold
  android:text-base android:font-medium
  web:text-xl web:font-bold
">
  Platform typography
</Text>
```

### Borders and Shadows

Different visual effects per platform:

```tsx
<View className="
  ios:rounded-2xl ios:shadow-lg
  android:rounded-lg android:elevation-4
  web:rounded-md web:shadow-xl
  bg-white
">
  <Text>Card with platform-specific shadows</Text>
</View>
```

### Layout and Positioning

Platform-specific layout adjustments:

```tsx
<View className="
  ios:flex-row ios:justify-between
  android:flex-col android:items-start
  web:grid web:grid-cols-2
  gap-4
">
  {/* Responsive layout */}
</View>
```

## Advantages Over Platform.select()

### 1. Cleaner Syntax

**Old way (Platform.select()):**

```tsx
import { Platform, StyleSheet } from 'react-native'

const styles = StyleSheet.create({
  container: {
    backgroundColor: Platform.select({
      ios: '#ef4444',
      android: '#3b82f6',
      web: '#10b981'
    }),
    paddingTop: Platform.select({
      ios: 48,
      android: 24,
      web: 16
    })
  }
})
```

**New way (Uniwind selectors):**

```tsx
<View className="
  ios:bg-red-500 ios:pt-12
  android:bg-blue-500 android:pt-6
  web:bg-green-500 web:pt-4
">
```

### 2. Better Readability

All platform variations visible in one className:

```tsx
<Text className="
  text-base
  native:font-medium
  web:font-semibold
  ios:text-gray-900
  android:text-gray-800
  web:text-gray-700
">
  Multi-platform text
</Text>
```

### 3. Easily Combinable

Mix platform selectors with other Tailwind utilities:

```tsx
<View className="
  flex-1 p-4
  ios:bg-blue-500 ios:rounded-2xl
  android:bg-green-500 android:rounded-lg
  web:bg-purple-500 web:rounded-md
  dark:opacity-90
  sm:max-w-md
">
  {/* Platform + theme + responsive */}
</View>
```

### 4. Seamless Theme Integration

Combine platform selectors with theme variants:

```tsx
<View className="
  bg-white dark:bg-gray-900
  ios:pt-12 ios:dark:pt-14
  android:pt-6 android:dark:pt-8
  web:pt-4 web:dark:pt-6
">
  {/* Platform + theme combinations */}
</View>
```

## Platform-Specific Theme Configuration

### Global Theme Variables

Define platform-specific design tokens in `global.css`:

```css
@theme {
  /* Default values */
  --font-sans: 'System';
  --spacing-unit: 16px;
  --border-radius: 8px;

  /* iOS-specific */
  @media ios {
    --font-sans: 'SF Pro Text';
    --spacing-unit: 20px;
    --border-radius: 12px;
    --safe-area-top: 44px;
  }

  /* Android-specific */
  @media android {
    --font-sans: 'Roboto';
    --spacing-unit: 16px;
    --border-radius: 8px;
    --safe-area-top: 24px;
  }

  /* Web-specific */
  @media web {
    --font-sans: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    --spacing-unit: 16px;
    --border-radius: 6px;
    --safe-area-top: 0px;
  }
}
```

### Using Platform Variables

```tsx
<View className="pt-[var(--safe-area-top)] font-[var(--font-sans)]">
  <Text>Platform-aware spacing and fonts</Text>
</View>
```

## Responsive Design

### Breakpoints

Uniwind provides Tailwind's standard responsive breakpoints:

| Breakpoint | Minimum Width | CSS Query |
|------------|---------------|-----------|
| `sm` | 640px | `@media (min-width: 640px)` |
| `md` | 768px | `@media (min-width: 768px)` |
| `lg` | 1024px | `@media (min-width: 1024px)` |
| `xl` | 1280px | `@media (min-width: 1280px)` |
| `2xl` | 1536px | `@media (min-width: 1536px)` |

### Mobile-First Approach

Uniwind uses a mobile-first responsive system:
- Unprefixed utilities apply to all screen sizes
- Prefixed utilities activate at specified breakpoints and above

```tsx
<View className="
  p-4 sm:p-6 lg:p-8
  bg-white rounded-lg
">
  <Text className="text-base sm:text-lg lg:text-xl font-bold">
    Responsive Typography
  </Text>
</View>
```

**Result:**
- Mobile (<640px): `p-4 text-base`
- Tablet (≥640px): `p-6 text-lg`
- Desktop (≥1024px): `p-8 text-xl`

### Combining Platform and Responsive

```tsx
<View className="
  p-4 sm:p-6 lg:p-8
  ios:bg-blue-500 ios:sm:bg-blue-600
  android:bg-green-500 android:sm:bg-green-600
  web:bg-purple-500 web:sm:bg-purple-600
">
  {/* Platform-specific responsive styling */}
</View>
```

### Common Responsive Patterns

**Adaptive layouts:**

```tsx
<View className="
  flex-col sm:flex-row
  gap-4 sm:gap-6 lg:gap-8
">
  <View className="w-full sm:w-1/2 lg:w-1/3">Content 1</View>
  <View className="w-full sm:w-1/2 lg:w-1/3">Content 2</View>
</View>
```

**Visibility control:**

```tsx
<View>
  {/* Show on mobile only */}
  <View className="block sm:hidden">
    <Text>Mobile menu</Text>
  </View>

  {/* Show on tablet and above */}
  <View className="hidden sm:flex">
    <Text>Desktop navigation</Text>
  </View>
</View>
```

**Spacing adjustments:**

```tsx
<View className="
  px-4 sm:px-6 lg:px-8
  py-6 sm:py-8 lg:py-12
">
  {/* Responsive padding */}
</View>
```

### Custom Breakpoints

Define custom breakpoints in `global.css`:

```css
@theme {
  --breakpoint-sm: 640px;
  --breakpoint-md: 768px;
  --breakpoint-lg: 1024px;
  --breakpoint-xl: 1280px;
  --breakpoint-2xl: 1536px;

  /* Custom breakpoints */
  --breakpoint-xs: 480px;
  --breakpoint-tablet: 820px;
  --breakpoint-desktop: 1440px;
}
```

**Usage:**

```tsx
<View className="p-2 xs:p-4 tablet:p-6 desktop:p-8">
  {/* Custom responsive padding */}
</View>
```

## Best Practices

### 1. Use Native Selector for Mobile Consistency

When iOS and Android styles match:

```tsx
/* Good */
<View className="native:bg-blue-500 web:bg-gray-500">

/* Avoid */
<View className="ios:bg-blue-500 android:bg-blue-500 web:bg-gray-500">
```

### 2. Platform-Specific Safe Areas

Handle safe areas appropriately per platform:

```tsx
<View className="
  ios:pt-12
  android:pt-6
  web:pt-0
  px-4
">
  {/* Platform-appropriate top padding */}
</View>
```

### 3. Font Families

Use platform-native fonts for best performance:

```css
@theme {
  @media ios {
    --font-sans: 'SF Pro Text';
    --font-rounded: 'SF Pro Rounded';
  }

  @media android {
    --font-sans: 'Roboto';
    --font-mono: 'Roboto Mono';
  }

  @media web {
    --font-sans: system-ui, sans-serif;
    --font-mono: 'Courier New', monospace;
  }
}
```

### 4. Touch Target Sizes

Ensure adequate touch targets on mobile:

```tsx
<Pressable className="
  native:min-h-[44px] native:min-w-[44px]
  web:min-h-[32px] web:min-w-[32px]
  flex items-center justify-center
">
  <Text>Button</Text>
</Pressable>
```

### 5. Shadows and Elevation

Use platform-appropriate shadow styles:

```tsx
<View className="
  bg-white
  ios:shadow-lg
  android:elevation-4
  web:shadow-xl
  rounded-lg p-4
">
  {/* Platform-specific elevation */}
</View>
```

### 6. Limit Breakpoints

Maintain 3-5 breakpoints for consistency:

```tsx
/* Good - Clear breakpoints */
<View className="p-4 md:p-6 lg:p-8">

/* Avoid - Too many breakpoints */
<View className="p-2 xs:p-3 sm:p-4 md:p-5 lg:p-6 xl:p-7 2xl:p-8">
```

### 7. Semantic Platform Classes

Create reusable platform-aware components:

```tsx
// components/PlatformCard.tsx
export const PlatformCard = ({ children }) => {
  return (
    <View className="
      bg-white dark:bg-gray-800
      ios:rounded-2xl ios:shadow-lg ios:p-6
      android:rounded-lg android:elevation-4 android:p-4
      web:rounded-md web:shadow-xl web:p-8
    ">
      {children}
    </View>
  )
}
```

## Common Platform-Specific Patterns

### Navigation Headers

```tsx
<View className="
  ios:h-44 ios:pt-12
  android:h-56 android:pt-6
  web:h-16 web:pt-0
  px-4 bg-white dark:bg-gray-900
  flex-row items-end pb-2
">
  <Text className="text-xl font-bold">Screen Title</Text>
</View>
```

### Tab Bars

```tsx
<View className="
  ios:h-20 ios:pb-6
  android:h-16 android:pb-0
  web:h-14 web:pb-0
  flex-row justify-around items-center
  bg-white dark:bg-gray-900
  border-t border-gray-200 dark:border-gray-700
">
  {/* Tab items */}
</View>
```

### Cards

```tsx
<View className="
  bg-white dark:bg-gray-800
  ios:rounded-2xl ios:p-6 ios:shadow-lg
  android:rounded-lg android:p-4 android:elevation-4
  web:rounded-md web:p-8 web:shadow-xl
  mb-4
">
  <Text className="
    ios:text-lg ios:font-semibold
    android:text-base android:font-medium
    web:text-xl web:font-bold
  ">
    Card Title
  </Text>
</View>
```

### Modal Presentations

```tsx
<View className="
  ios:rounded-t-3xl ios:pt-6
  android:rounded-t-lg android:pt-4
  web:rounded-lg web:pt-8
  bg-white dark:bg-gray-900
  native:min-h-[50vh]
  web:min-h-[400px]
">
  {/* Modal content */}
</View>
```

### Input Fields

```tsx
<TextInput className="
  ios:h-44 ios:rounded-xl ios:px-4
  android:h-48 android:rounded-lg android:px-3
  web:h-40 web:rounded-md web:px-4
  bg-gray-100 dark:bg-gray-800
  text-gray-900 dark:text-white
  border border-gray-300 dark:border-gray-600
" />
```

## Platform Detection in JavaScript

While platform selectors handle most cases, sometimes you need platform logic:

```tsx
import { Platform } from 'react-native'

const MyComponent = () => {
  const isIOS = Platform.OS === 'ios'
  const isAndroid = Platform.OS === 'android'
  const isWeb = Platform.OS === 'web'

  return (
    <View className="native:bg-blue-500 web:bg-gray-500">
      {isIOS && <Text>iOS specific content</Text>}
      {isAndroid && <Text>Android specific content</Text>}
      {isWeb && <Text>Web specific content</Text>}
    </View>
  )
}
```

However, prefer platform selectors in className when possible for better performance and readability.
