---
name: nativewind-styling
description: Style React Native apps with NativeWind v4 - official Tailwind CSS integration with className prop, dark mode support, responsive design, and platform-specific styling for Expo and React Native
license: MIT
compatibility: "Requires: Expo SDK 50+, React Native 0.74+, Tailwind CSS 3.4.17+, react-native-reanimated ~3.17.4, react-native-safe-area-context 5.4.0"
---

# NativeWind Styling

## Overview

Style React Native components using NativeWind v4, the official Tailwind CSS integration that enables styling with the className prop. Supports dark mode, responsive design, platform-specific styling, and full Tailwind CSS utility compatibility for Expo and React Native.

**Alternative**: Use `uniwind-styling` skill if you need Tailwind CSS 4 support and faster compile-time performance.

## When to Use This Skill

- Setting up NativeWind v4 in a new or existing Expo/React Native project
- Need official NativeWind implementation with broad ecosystem support
- Want Tailwind CSS 3.4.x compatibility and familiar Tailwind workflow
- Building apps with light/dark mode support
- Need responsive design with breakpoints (sm, md, lg, xl, 2xl)
- Require platform-specific styling (iOS, Android, Web)
- Migrating from older NativeWind versions (v2/v3)
- Working with NativeWind-compatible UI libraries (NativeWindUI, shadcn/ui for RN)

**Not recommended when:**
- Need Tailwind CSS 4 support (use `uniwind-styling` instead)
- Need maximum compile-time performance (Uniwind is 2.5x faster)
- Want zero re-renders on style updates (use `unistyles-styling`)

## Workflow

### Step 1: Install NativeWind and Dependencies

```bash
# Install NativeWind
npm install nativewind

# Install required peer dependencies
npm install react-native-reanimated@~3.17.4 react-native-safe-area-context@5.4.0

# Install Tailwind CSS and Prettier plugin (dev dependencies)
npm install --save-dev tailwindcss@^3.4.17 prettier-plugin-tailwindcss@^0.5.11
```

**Note**: NativeWind v4 requires these exact peer dependency versions for proper functionality.

### Step 2: Initialize Tailwind CSS

```bash
npx tailwindcss init
```

Configure `tailwind.config.js`:

```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  // Add paths to all component files
  content: [
    "./App.{js,jsx,ts,tsx}",
    "./app/**/*.{js,jsx,ts,tsx}",
    "./components/**/*.{js,jsx,ts,tsx}",
    "./screens/**/*.{js,jsx,ts,tsx}",
  ],
  // IMPORTANT: Add NativeWind preset
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      // Add custom colors, spacing, fonts, etc.
      colors: {
        primary: '#3b82f6',
        secondary: '#8b5cf6',
      },
    },
  },
  plugins: [],
}
```

**Important**: The `nativewind/preset` enables platform-specific variants and proper React Native compatibility.

### Step 3: Create Global CSS File

Create `global.css` at your project root:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

**Optional**: Add custom CSS classes:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Custom component classes */
@layer components {
  .card {
    @apply bg-white dark:bg-gray-800 rounded-lg p-4 shadow-md;
  }

  .btn-primary {
    @apply bg-blue-500 text-white px-4 py-2 rounded-lg font-semibold active:opacity-80;
  }
}
```

### Step 4: Configure Babel

Update `babel.config.js`:

```javascript
module.exports = function (api) {
  api.cache(true);
  return {
    presets: [
      // IMPORTANT: Set jsxImportSource to "nativewind"
      ["babel-preset-expo", { jsxImportSource: "nativewind" }]
    ],
    plugins: [
      // Add NativeWind Babel plugin
      "nativewind/babel",
      // Reanimated plugin must be last
      "react-native-reanimated/plugin",
    ],
  };
};
```

**Critical**: The `jsxImportSource: "nativewind"` setting enables className prop support on all React Native components.

### Step 5: Configure Metro Bundler

Update `metro.config.js`:

```javascript
const { getDefaultConfig } = require("expo/metro-config");
const { withNativeWind } = require('nativewind/metro');

const config = getDefaultConfig(__dirname);

module.exports = withNativeWind(config, {
  input: './global.css',
});
```

**Important**: `withNativeWind` must be the final wrapper. Don't modify the config after calling it.

**For web support in app.json**, add:

```json
{
  "expo": {
    "web": {
      "bundler": "metro"
    }
  }
}
```

### Step 6: Import Global CSS

In your root app file (`app/_layout.tsx` or `App.tsx`):

```typescript
import "../global.css";

export default function RootLayout() {
  return (
    <Stack>
      {/* Your app content */}
    </Stack>
  );
}
```

**For Expo Router**: Import in `app/_layout.tsx`
**For bare React Native**: Import in `App.tsx`

### Step 7: Add TypeScript Support (Optional)

Create `nativewind-env.d.ts` at project root:

```typescript
/// <reference types="nativewind/types" />
```

This provides TypeScript autocomplete for className prop and prevents type errors.

**Restart Metro** after all configuration:

```bash
npx expo start --clear
```

## Guidelines

**Do:**
- Use `className` prop for styling (NativeWind's primary API)
- Provide both light and dark styles: `text-black dark:text-white`
- Clear Metro cache after configuration changes: `npx expo start --clear`
- Use platform-specific variants: `ios:pt-4 android:pt-2 web:pt-6`
- Import `global.css` in your root app file
- Use Prettier plugin for automatic class sorting
- Declare all conditional styles rather than applying them dynamically
- Group related utility classes together for readability
- Use arbitrary values when needed: `w-[37px]`, `text-[#1da1f2]`

**Don't:**
- Don't mix `className` and `style` props (choose one approach per component)
- Don't forget to add `jsxImportSource: "nativewind"` to Babel preset
- Don't apply color classes to View components (use Text instead - React Native limitation)
- Don't modify Metro config after calling `withNativeWind` (must be final wrapper)
- Don't expect hot reload to work with new className styles (requires cache clear)
- Don't use web-only Tailwind features (hover, group-hover) without understanding they only work on web
- Don't remove `presets: [require("nativewind/preset")]` from tailwind.config.js
- Avoid applying styles dynamically with string interpolation (`className={`text-${color}`}`)

## Examples

### Example 1: Basic Styling

```typescript
import { View, Text, Pressable } from 'react-native';

export function BasicExample() {
  return (
    <View className="flex-1 bg-white dark:bg-gray-900 p-4">
      <Text className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
        Hello NativeWind
      </Text>
      <Pressable className="bg-blue-500 px-4 py-2 rounded-lg active:opacity-80">
        <Text className="text-white font-semibold text-center">
          Press Me
        </Text>
      </Pressable>
    </View>
  );
}
```

### Example 2: Responsive Design

```typescript
import { View, Text } from 'react-native';

export function ResponsiveExample() {
  return (
    <View className="flex-1 p-4">
      {/* Container adapts to screen size */}
      <View className="w-full sm:w-1/2 md:w-1/3 lg:w-1/4">
        <Text className="text-sm sm:text-base md:text-lg lg:text-xl">
          Responsive text that scales with breakpoints
        </Text>
      </View>

      {/* Grid layout with responsive columns */}
      <View className="flex-row flex-wrap">
        <View className="w-full sm:w-1/2 lg:w-1/3 p-2">
          <Text>Item 1</Text>
        </View>
        <View className="w-full sm:w-1/2 lg:w-1/3 p-2">
          <Text>Item 2</Text>
        </View>
        <View className="w-full sm:w-1/2 lg:w-1/3 p-2">
          <Text>Item 3</Text>
        </View>
      </View>
    </View>
  );
}
```

### Example 3: Platform-Specific Styling

```typescript
import { View, Text } from 'react-native';

export function PlatformExample() {
  return (
    <View className="flex-1">
      {/* Different padding per platform */}
      <View className="ios:pt-4 android:pt-2 web:pt-6">
        <Text className="native:text-base web:text-lg">
          Platform-aware text sizing
        </Text>
      </View>

      {/* iOS-specific shadow, Android elevation alternative */}
      <View className="ios:shadow-lg android:elevation-4 bg-white rounded-lg p-4">
        <Text>Platform-optimized shadows</Text>
      </View>

      {/* Web-only hover effects */}
      <View className="bg-blue-500 p-4 web:hover:bg-blue-600">
        <Text className="text-white">Hover effect (web only)</Text>
      </View>
    </View>
  );
}
```

### Example 4: Dark Mode with Manual Control

```typescript
import { View, Text, Pressable } from 'react-native';
import { useColorScheme } from 'nativewind';

export function ThemeToggle() {
  const { colorScheme, setColorScheme } = useColorScheme();

  const toggleTheme = () => {
    setColorScheme(colorScheme === 'dark' ? 'light' : 'dark');
  };

  return (
    <View className="flex-1 bg-white dark:bg-gray-900 p-4">
      <Text className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
        Current theme: {colorScheme}
      </Text>

      <Pressable
        className="p-4 rounded-lg bg-gray-200 dark:bg-gray-700 active:opacity-80"
        onPress={toggleTheme}
      >
        <Text className="text-center text-gray-900 dark:text-white font-semibold">
          {colorScheme === 'dark' ? '🌙 Switch to Light' : '☀️ Switch to Dark'}
        </Text>
      </Pressable>
    </View>
  );
}
```

### Example 5: Custom Theme Colors

```typescript
// In tailwind.config.js
module.exports = {
  content: ["./app/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          100: '#dbeafe',
          500: '#3b82f6',
          600: '#2563eb',
          900: '#1e3a8a',
        },
        accent: '#f59e0b',
      },
    },
  },
};

// In component
import { View, Text } from 'react-native';

export function CustomColorsExample() {
  return (
    <View className="bg-primary-50 dark:bg-primary-900 p-4">
      <Text className="text-primary-600 dark:text-primary-100 text-xl font-bold">
        Custom Brand Colors
      </Text>
      <View className="bg-accent p-2 rounded mt-2">
        <Text className="text-white">Accent Color</Text>
      </View>
    </View>
  );
}
```

### Example 6: Safe Area Insets

```typescript
import { View, Text } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

export function SafeAreaExample() {
  return (
    <SafeAreaView className="flex-1 bg-white dark:bg-black">
      {/* Content respects safe area automatically */}
      <View className="px-4 py-2">
        <Text className="text-2xl font-bold text-gray-900 dark:text-white">
          Safe Area Content
        </Text>
        <Text className="text-gray-600 dark:text-gray-400 mt-2">
          This content automatically respects notches, status bars, and home indicators
        </Text>
      </View>

      {/* Fine-tune with utility classes */}
      <View className="px-4 pt-safe pb-safe">
        <Text>Manual safe area padding control</Text>
      </View>
    </SafeAreaView>
  );
}
```

## Resources

- [Dark Mode & Theming Guide](references/dark-mode-theming.md) - Complete guide to dark mode, custom themes, and manual control
- [Responsive Design & Breakpoints](references/responsive-breakpoints.md) - Responsive patterns, breakpoints, mobile-first approach
- [Platform-Specific Styling](references/platform-specific-styling.md) - iOS/Android/Web differences, platform variants
- [Troubleshooting Guide](references/troubleshooting-guide.md) - Common errors, solutions, debugging tips
- [Official NativeWind Documentation](https://www.nativewind.dev/)
- [NativeWind v4 Installation](https://www.nativewind.dev/docs/getting-started/installation)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)

## Tools & Commands

- `npx tailwindcss init` - Initialize Tailwind CSS configuration
- `npx expo start --clear` - Clear Metro cache after config changes
- `npx tailwindcss -i ./global.css -o ./output.css` - Verify Tailwind compilation
- `npm install --save-dev prettier-plugin-tailwindcss` - Auto-sort className utilities

## Troubleshooting

### className styles not applying

**Problem**: Styles not visible after adding className prop

**Solution**:
1. Verify `global.css` is imported in root app file (`app/_layout.tsx` or `App.tsx`)
2. Clear Metro cache: `npx expo start --clear`
3. Check that `nativewind/babel` plugin is in `babel.config.js`
4. Ensure `jsxImportSource: "nativewind"` is set in Babel preset
5. Verify Tailwind compilation: `npx tailwindcss -i ./global.css -o ./output.css` and check output.css
6. Confirm content paths in `tailwind.config.js` include all component files

### Hot reload not working with new styles

**Problem**: Adding new className styles requires multiple refreshes or app restarts

**Solution**: This is a known NativeWind limitation. Either:
- Restart Metro with cache clear: `npx expo start --clear`
- Refresh the app multiple times (Cmd+R on iOS simulator, R+R on Android)
- Accept this limitation during development (styles work correctly in production builds)

### TypeScript className errors

**Problem**: TypeScript complains "Property 'className' does not exist"

**Solution**: Create `nativewind-env.d.ts` at project root:

```typescript
/// <reference types="nativewind/types" />
```

Then restart your TypeScript server in your IDE.

### Colors not working on View components

**Problem**: `className="text-blue-500"` on View doesn't render any color

**Solution**: React Native Views don't support text color properties. Move color classes to Text elements:

```typescript
// ❌ Wrong - View doesn't support text colors
<View className="text-blue-500">
  <Text>Content</Text>
</View>

// ✅ Correct - Apply color to Text
<View className="bg-blue-500">
  <Text className="text-white">Content</Text>
</View>
```

### Dark mode not switching

**Problem**: Dark mode classes (`dark:*`) don't activate when device theme changes

**Solution**:
1. Don't override `darkMode` in `tailwind.config.js` (NativeWind manages it automatically)
2. Ensure `presets: [require("nativewind/preset")]` is in your Tailwind config
3. For manual dark mode control, use the `useColorScheme` hook (see Example 4)
4. Test on a real device or change simulator appearance (Settings > Appearance)

For more detailed troubleshooting, see [Troubleshooting Guide](references/troubleshooting-guide.md).

---

## Notes

- NativeWind v4 uses Tailwind CSS 3.4.x (not compatible with Tailwind CSS 4)
- For Tailwind CSS 4 support, use `uniwind-styling` skill instead
- Uniwind is 2.5x faster with compile-time processing, but NativeWind has broader ecosystem support
- Metro cache clearing is frequently needed during setup and development
- Web-only features (hover, focus-visible, group-hover) only work on web platform
- React Native styling limitations apply (no text color on View, no CSS cascade)
- Compatible with Expo Go (unlike some alternatives requiring custom dev clients)
- Works with popular UI libraries: NativeWindUI, shadcn/ui for React Native
- Production builds are optimized and don't have the hot reload limitations of development
