# Dark Mode & Theming Guide

## Overview

NativeWind v4 provides comprehensive dark mode support with automatic system theme detection, manual theme control, and custom color configuration. This guide covers all theming capabilities from basic dark mode to advanced custom theme implementations.

## Default Dark Mode Behavior

NativeWind automatically detects the device's appearance setting (light/dark) and applies appropriate styles.

### Basic Dark Mode Syntax

```typescript
import { View, Text } from 'react-native';

export function DarkModeExample() {
  return (
    <View className="bg-white dark:bg-gray-900">
      <Text className="text-black dark:text-white">
        Automatically adapts to system theme
      </Text>
    </View>
  );
}
```

### How It Works

1. **System Detection**: NativeWind reads the device's appearance setting
2. **Automatic Switching**: When user changes system theme, styles update instantly
3. **No Configuration**: Works out of the box with `nativewind/preset`

## Manual Theme Control

Use the `useColorScheme` hook for manual theme switching:

```typescript
import { View, Text, Pressable } from 'react-native';
import { useColorScheme } from 'nativewind';

export function ThemeSwitcher() {
  const { colorScheme, setColorScheme, toggleColorScheme } = useColorScheme();

  return (
    <View className="flex-1 bg-white dark:bg-gray-900 p-4">
      <Text className="text-gray-900 dark:text-white text-xl font-bold mb-4">
        Current Theme: {colorScheme}
      </Text>

      {/* Toggle between light/dark */}
      <Pressable
        className="bg-blue-500 p-4 rounded-lg mb-2 active:opacity-80"
        onPress={toggleColorScheme}
      >
        <Text className="text-white text-center font-semibold">
          Toggle Theme
        </Text>
      </Pressable>

      {/* Set specific theme */}
      <Pressable
        className="bg-gray-200 dark:bg-gray-700 p-4 rounded-lg mb-2"
        onPress={() => setColorScheme('light')}
      >
        <Text className="text-gray-900 dark:text-white text-center">
          Force Light Mode
        </Text>
      </Pressable>

      <Pressable
        className="bg-gray-200 dark:bg-gray-700 p-4 rounded-lg mb-2"
        onPress={() => setColorScheme('dark')}
      >
        <Text className="text-gray-900 dark:text-white text-center">
          Force Dark Mode
        </Text>
      </Pressable>

      {/* Reset to system */}
      <Pressable
        className="bg-gray-200 dark:bg-gray-700 p-4 rounded-lg"
        onPress={() => setColorScheme('system')}
      >
        <Text className="text-gray-900 dark:text-white text-center">
          Use System Theme
        </Text>
      </Pressable>
    </View>
  );
}
```

### Available Methods

```typescript
const { colorScheme, setColorScheme, toggleColorScheme } = useColorScheme();

// colorScheme: 'light' | 'dark' | 'system'
// Current active theme

// setColorScheme: (theme: 'light' | 'dark' | 'system') => void
// Set specific theme

// toggleColorScheme: () => void
// Toggle between light and dark
```

## Persisting User Theme Preference

Store user theme preference to maintain across app sessions:

```typescript
import { View, Text, Pressable } from 'react-native';
import { useColorScheme } from 'nativewind';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useEffect } from 'react';

const THEME_STORAGE_KEY = '@app_theme';

export function ThemeWithPersistence() {
  const { colorScheme, setColorScheme } = useColorScheme();

  // Load saved theme on mount
  useEffect(() => {
    loadTheme();
  }, []);

  const loadTheme = async () => {
    try {
      const savedTheme = await AsyncStorage.getItem(THEME_STORAGE_KEY);
      if (savedTheme && (savedTheme === 'light' || savedTheme === 'dark' || savedTheme === 'system')) {
        setColorScheme(savedTheme as 'light' | 'dark' | 'system');
      }
    } catch (error) {
      console.error('Failed to load theme:', error);
    }
  };

  const saveAndSetTheme = async (theme: 'light' | 'dark' | 'system') => {
    try {
      await AsyncStorage.setItem(THEME_STORAGE_KEY, theme);
      setColorScheme(theme);
    } catch (error) {
      console.error('Failed to save theme:', error);
    }
  };

  return (
    <View className="flex-1 bg-white dark:bg-gray-900 p-4">
      <Text className="text-gray-900 dark:text-white text-xl mb-4">
        Theme: {colorScheme}
      </Text>

      <Pressable
        className="bg-blue-500 p-3 rounded-lg mb-2"
        onPress={() => saveAndSetTheme('light')}
      >
        <Text className="text-white text-center">Light</Text>
      </Pressable>

      <Pressable
        className="bg-gray-800 p-3 rounded-lg mb-2"
        onPress={() => saveAndSetTheme('dark')}
      >
        <Text className="text-white text-center">Dark</Text>
      </Pressable>

      <Pressable
        className="bg-gray-500 p-3 rounded-lg"
        onPress={() => saveAndSetTheme('system')}
      >
        <Text className="text-white text-center">System</Text>
      </Pressable>
    </View>
  );
}
```

## Custom Theme Colors

### Method 1: Extend Tailwind Config

Define custom colors in `tailwind.config.js`:

```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./app/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      colors: {
        // Brand colors
        brand: {
          50: '#f0f9ff',
          100: '#e0f2fe',
          200: '#bae6fd',
          300: '#7dd3fc',
          400: '#38bdf8',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
          800: '#075985',
          900: '#0c4a6e',
          950: '#082f49',
        },
        // Single accent color
        accent: '#f59e0b',
        // Semantic colors
        success: '#10b981',
        warning: '#f59e0b',
        error: '#ef4444',
        info: '#3b82f6',
      },
    },
  },
  plugins: [],
};
```

**Usage:**

```typescript
import { View, Text } from 'react-native';

export function CustomColorsExample() {
  return (
    <View className="bg-brand-50 dark:bg-brand-900 p-4">
      <Text className="text-brand-700 dark:text-brand-300 text-2xl font-bold">
        Custom Brand Colors
      </Text>

      <View className="bg-accent p-3 rounded-lg mt-4">
        <Text className="text-white font-semibold">
          Accent Color
        </Text>
      </View>

      <View className="flex-row gap-2 mt-4">
        <View className="bg-success p-2 rounded flex-1">
          <Text className="text-white text-center">Success</Text>
        </View>
        <View className="bg-warning p-2 rounded flex-1">
          <Text className="text-white text-center">Warning</Text>
        </View>
        <View className="bg-error p-2 rounded flex-1">
          <Text className="text-white text-center">Error</Text>
        </View>
      </View>
    </View>
  );
}
```

### Method 2: CSS Variables in global.css

Define colors as CSS custom properties:

```css
/* global.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    /* Light theme colors */
    --color-background: 255 255 255;
    --color-foreground: 0 0 0;
    --color-primary: 59 130 246;
    --color-secondary: 139 92 246;
    --color-accent: 245 158 11;
  }

  .dark {
    /* Dark theme colors */
    --color-background: 17 24 39;
    --color-foreground: 255 255 255;
    --color-primary: 96 165 250;
    --color-secondary: 167 139 250;
    --color-accent: 251 191 36;
  }
}
```

**Configure in tailwind.config.js:**

```javascript
module.exports = {
  theme: {
    extend: {
      colors: {
        background: 'rgb(var(--color-background))',
        foreground: 'rgb(var(--color-foreground))',
        primary: 'rgb(var(--color-primary))',
        secondary: 'rgb(var(--color-secondary))',
        accent: 'rgb(var(--color-accent))',
      },
    },
  },
};
```

**Usage:**

```typescript
<View className="bg-background">
  <Text className="text-foreground">
    Automatically uses light/dark values
  </Text>
  <View className="bg-primary p-4 rounded-lg">
    <Text className="text-white">Primary button</Text>
  </View>
</View>
```

## Complete Dark Mode Component Library

```typescript
// components/ui/Button.tsx
import { Pressable, Text } from 'react-native';

interface ButtonProps {
  onPress: () => void;
  children: string;
  variant?: 'primary' | 'secondary' | 'outline';
}

export function Button({ onPress, children, variant = 'primary' }: ButtonProps) {
  const baseClasses = "px-4 py-2 rounded-lg active:opacity-80";

  const variantClasses = {
    primary: "bg-blue-500 dark:bg-blue-600",
    secondary: "bg-gray-500 dark:bg-gray-600",
    outline: "border-2 border-blue-500 dark:border-blue-400",
  };

  const textClasses = {
    primary: "text-white",
    secondary: "text-white",
    outline: "text-blue-500 dark:text-blue-400",
  };

  return (
    <Pressable
      className={`${baseClasses} ${variantClasses[variant]}`}
      onPress={onPress}
    >
      <Text className={`font-semibold text-center ${textClasses[variant]}`}>
        {children}
      </Text>
    </Pressable>
  );
}

// components/ui/Card.tsx
import { View, Text } from 'react-native';

interface CardProps {
  title: string;
  description: string;
  children?: React.ReactNode;
}

export function Card({ title, description, children }: CardProps) {
  return (
    <View className="bg-white dark:bg-gray-800 rounded-xl p-4 shadow-lg">
      <Text className="text-xl font-bold text-gray-900 dark:text-white mb-2">
        {title}
      </Text>
      <Text className="text-gray-600 dark:text-gray-400 mb-4">
        {description}
      </Text>
      {children}
    </View>
  );
}

// components/ui/Input.tsx
import { TextInput, View, Text } from 'react-native';
import { useState } from 'react';

interface InputProps {
  label: string;
  value: string;
  onChangeText: (text: string) => void;
  placeholder?: string;
  secureTextEntry?: boolean;
}

export function Input({ label, value, onChangeText, placeholder, secureTextEntry }: InputProps) {
  const [isFocused, setIsFocused] = useState(false);

  return (
    <View className="mb-4">
      <Text className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
        {label}
      </Text>
      <TextInput
        value={value}
        onChangeText={onChangeText}
        placeholder={placeholder}
        secureTextEntry={secureTextEntry}
        onFocus={() => setIsFocused(true)}
        onBlur={() => setIsFocused(false)}
        className={`
          bg-white dark:bg-gray-800
          border-2 ${isFocused ? 'border-blue-500 dark:border-blue-400' : 'border-gray-300 dark:border-gray-600'}
          rounded-lg px-4 py-3
          text-gray-900 dark:text-white
        `}
        placeholderTextColor="#9ca3af"
      />
    </View>
  );
}
```

## Testing Dark Mode

### iOS Simulator

```bash
# Switch to dark mode
xcrun simctl ui booted appearance dark

# Switch to light mode
xcrun simctl ui booted appearance light
```

Or manually: Settings > Developer > Dark Appearance

### Android Emulator

Settings > Display > Dark theme

### Testing in Code

```typescript
import { useColorScheme } from 'nativewind';

export function ThemeDebugger() {
  const { colorScheme } = useColorScheme();

  return (
    <View className="p-4 bg-white dark:bg-gray-900">
      <Text className="text-black dark:text-white">
        Current scheme: {colorScheme}
      </Text>

      {/* Test all variants */}
      <View className="mt-4 space-y-2">
        <View className="bg-gray-100 dark:bg-gray-800 p-2 rounded">
          <Text className="text-gray-900 dark:text-white">Background test</Text>
        </View>
        <View className="border border-gray-300 dark:border-gray-600 p-2 rounded">
          <Text className="text-gray-700 dark:text-gray-300">Border test</Text>
        </View>
        <View className="bg-blue-500 dark:bg-blue-600 p-2 rounded">
          <Text className="text-white">Colored background</Text>
        </View>
      </View>
    </View>
  );
}
```

## Best Practices

### 1. Always Provide Dark Mode Variants

```typescript
// ✅ Good - explicit light and dark
<Text className="text-gray-900 dark:text-white">
  Always readable
</Text>

// ❌ Bad - only light mode
<Text className="text-gray-900">
  Invisible in dark mode
</Text>
```

### 2. Use Semantic Color Scales

```typescript
// ✅ Good - uses full gray scale
<View className="bg-gray-50 dark:bg-gray-900">
  <Text className="text-gray-900 dark:text-gray-100">Title</Text>
  <Text className="text-gray-600 dark:text-gray-400">Subtitle</Text>
</View>

// ❌ Avoid - insufficient contrast in dark mode
<View className="bg-gray-50 dark:bg-gray-800">
  <Text className="text-gray-900 dark:text-gray-800">Hard to read</Text>
</View>
```

### 3. Test Both Themes

Always test your UI in both light and dark modes before shipping.

### 4. Consider Accessibility

Ensure sufficient contrast in both themes:
- Light mode: Dark text on light backgrounds
- Dark mode: Light text on dark backgrounds
- Minimum contrast ratio: 4.5:1 for normal text, 3:1 for large text

### 5. Use Tailwind's Color Palette

Tailwind's default colors are designed to work well in both light and dark modes:

```typescript
// Recommended color pairings
<View className="bg-blue-50 dark:bg-blue-900">
  <Text className="text-blue-900 dark:text-blue-100">Blue theme</Text>
</View>

<View className="bg-green-50 dark:bg-green-900">
  <Text className="text-green-900 dark:text-green-100">Green theme</Text>
</View>

<View className="bg-purple-50 dark:bg-purple-900">
  <Text className="text-purple-900 dark:text-purple-100">Purple theme</Text>
</View>
```

## Troubleshooting

### Dark mode not switching

**Problem**: dark: classes don't activate

**Solutions**:
1. Ensure `presets: [require("nativewind/preset")]` is in tailwind.config.js
2. Don't override `darkMode` in tailwind.config.js
3. Clear Metro cache: `npx expo start --clear`
4. Test on real device or change simulator appearance

### Colors look wrong in dark mode

**Problem**: Colors don't have enough contrast

**Solutions**:
1. Use Tailwind's full color scale (50-950)
2. Pair light shades (50-100) in light mode with dark shades (800-950) in dark mode
3. Test with accessibility tools
4. Use semantic colors from your brand guidelines

### Custom colors not working

**Problem**: Custom colors defined in tailwind.config.js don't work

**Solutions**:
1. Restart Metro after changing tailwind.config.js
2. Verify color format: use hex (`'#3b82f6'`) or RGB object (`{ 500: '#3b82f6' }`)
3. Check that colors are in `theme.extend.colors`, not `theme.colors` (which overrides defaults)

## Resources

- [NativeWind Dark Mode Docs](https://www.nativewind.dev/docs/core-concepts/dark-mode)
- [Tailwind CSS Customizing Colors](https://tailwindcss.com/docs/customizing-colors)
- [AsyncStorage Documentation](https://react-native-async-storage.github.io/async-storage/)
