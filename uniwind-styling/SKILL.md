---
name: uniwind-styling
description: Style React Native components with Uniwind - the fastest Tailwind CSS bindings with compile-time processing and zero re-renders
license: MIT
compatibility: "Requires: Expo SDK 50+, tailwindcss@next (v4 beta), uniwind package"
---

# Uniwind Styling

## Overview

Implement Tailwind CSS styling in React Native using Uniwind, the fastest Tailwind bindings with compile-time CSS processing, zero runtime overhead, and full support for themes, platform variants, and custom CSS.

## When to Use This Skill

- Setting up a new Expo project with Tailwind CSS styling
- Migrating from NativeWind v3 to Uniwind
- Need compile-time CSS processing for maximum performance
- Want zero re-renders on style updates
- Building apps with light/dark themes or custom theme systems
- Need platform-specific styles (iOS, Android, web)

## Workflow

### Step 1: Install Uniwind

```bash
# Install Uniwind and Tailwind CSS v4
npm install uniwind tailwindcss@next

# Install peer dependencies
npm install react-native-reanimated react-native-safe-area-context
```

### Step 2: Configure Metro Bundler

Edit `metro.config.js`:

```javascript
const { getDefaultConfig } = require('expo/metro-config');
const { withUniwind } = require('uniwind/metro');

const config = getDefaultConfig(__dirname);

module.exports = withUniwind(config, {
  // Optional: customize Uniwind behavior
  input: './global.css',
});
```

### Step 3: Create Global CSS

Create `global.css` at project root:

```css
@import 'tailwindcss';

/* Custom theme (optional) */
@theme {
  --color-primary: #3b82f6;
  --color-secondary: #8b5cf6;

  /* Custom spacing */
  --spacing-xs: 0.25rem;
  --spacing-sm: 0.5rem;
}

/* Custom CSS classes */
.card {
  @apply bg-white dark:bg-gray-800 rounded-lg p-4 shadow-md;
}

.btn-primary {
  @apply bg-primary text-white px-4 py-2 rounded-lg font-semibold;
  @apply active:opacity-80;
}
```

### Step 4: Configure App Entry

Update `app/_layout.tsx` or `App.tsx`:

```typescript
import './global.css';
import { Uniwind } from 'uniwind';

export default function RootLayout() {
  return (
    <Uniwind
      theme="system" // 'light' | 'dark' | 'system'
      onThemeChange={(theme) => console.log('Theme changed:', theme)}
    >
      {/* Your app content */}
      <Stack />
    </Uniwind>
  );
}
```

### Step 5: Use Tailwind Classes

```typescript
import { View, Text, Pressable } from 'react-native';

export function MyComponent() {
  return (
    <View className="flex-1 bg-gray-50 dark:bg-gray-900 p-4">
      <Text className="text-2xl font-bold text-gray-900 dark:text-white mb-4">
        Hello Uniwind
      </Text>

      <Pressable className="btn-primary active:scale-95">
        <Text className="text-white font-semibold">Press Me</Text>
      </Pressable>

      {/* Platform-specific styles */}
      <View className="ios:pt-4 android:pt-2 web:pt-6">
        <Text className="native:text-base web:text-lg">
          Platform-specific text
        </Text>
      </View>
    </View>
  );
}
```

### Step 6: Theme System

```typescript
import { useUniwind } from 'uniwind';

export function ThemeToggle() {
  const { theme, setTheme } = useUniwind();

  return (
    <Pressable
      className="p-2 rounded-lg bg-gray-200 dark:bg-gray-700"
      onPress={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
    >
      <Text className="text-gray-900 dark:text-white">
        {theme === 'dark' ? '🌙' : '☀️'}
      </Text>
    </Pressable>
  );
}
```

### Step 7: Custom Themes (Advanced)

```typescript
import { Uniwind } from 'uniwind';

// Define custom themes
const themes = {
  ocean: {
    '--color-primary': '#0ea5e9',
    '--color-secondary': '#06b6d4',
    '--color-background': '#f0f9ff',
  },
  sunset: {
    '--color-primary': '#f97316',
    '--color-secondary': '#fb923c',
    '--color-background': '#fff7ed',
  },
};

export default function App() {
  const [customTheme, setCustomTheme] = useState('ocean');

  return (
    <Uniwind
      theme="light"
      customTheme={themes[customTheme]}
    >
      {/* Your app */}
    </Uniwind>
  );
}
```

## Guidelines

**Do:**
- Use compile-time CSS classes for best performance
- Leverage `light-dark()` function for theme-aware colors
- Use platform selectors (`ios:`, `android:`, `web:`) for platform-specific styles
- Define custom classes in `global.css` for reusable patterns
- Use `withUniwind()` HOC for third-party components

**Don't:**
- Don't mix inline styles with className (choose one approach)
- Don't use NativeWind v3 and Uniwind together (migrate completely)
- Don't forget to import `global.css` in your app entry
- Don't use deprecated `tw` prop (use `className`)
- Avoid runtime style calculations (use CSS variables instead)

## Examples

### Responsive Design

```typescript
<View className="w-full sm:w-1/2 md:w-1/3 lg:w-1/4">
  <Text className="text-sm sm:text-base md:text-lg lg:text-xl">
    Responsive text
  </Text>
</View>
```

### Gradients

```typescript
<View className="bg-gradient-to-r from-purple-500 to-pink-500 p-4">
  <Text className="text-white font-bold">Gradient Background</Text>
</View>
```

### Safe Area

```typescript
<View className="flex-1 p-safe bg-white dark:bg-black">
  <Text className="mt-safe-top">Content with safe area</Text>
</View>
```

### Custom CSS Classes

```typescript
// In global.css
.glass-card {
  @apply bg-white/80 dark:bg-gray-900/80;
  @apply backdrop-blur-lg;
  @apply border border-gray-200 dark:border-gray-700;
  @apply rounded-2xl p-4 shadow-lg;
}

// In component
<View className="glass-card">
  <Text>Glass morphism effect</Text>
</View>
```

### Third-Party Components

```typescript
import { LinearGradient } from 'expo-linear-gradient';
import { withUniwind } from 'uniwind';

const StyledGradient = withUniwind(LinearGradient, {
  colorsClassName: 'colors',
});

<StyledGradient
  className="flex-1"
  colorsClassName="from-blue-500 to-purple-500"
>
  <Text>Styled third-party component</Text>
</StyledGradient>
```

## Resources

- [Uniwind Full Documentation](references/uniwind-full-docs.md)
- [Theme System Guide](references/theme-system.md)
- [Platform-Specific Styling](references/platform-specific.md)
- [Migration from NativeWind](references/migration-nativewind.md)
- [Official Docs](https://docs.uniwind.dev/)

## Tools & Commands

- `npx tailwindcss --help` - Tailwind CSS CLI
- `npx expo start --clear` - Clear Metro cache after config changes

## Troubleshooting

### Styles not applying

**Problem**: Classes not working after installation

**Solution**:
1. Ensure `global.css` is imported in app entry
2. Clear Metro cache: `npx expo start --clear`
3. Verify Metro config has `withUniwind()`

### Theme not switching

**Problem**: Dark mode not activating

**Solution**:
```typescript
// Ensure Uniwind wrapper is at root
import { Uniwind } from 'uniwind';

<Uniwind theme="system"> {/* or "dark" */}
  <YourApp />
</Uniwind>
```

### TypeScript errors

**Problem**: `className` prop not recognized

**Solution**: Add to `global.d.ts`:
```typescript
import 'uniwind/types';
```

---

## Notes

- Uniwind requires Tailwind CSS v4 (currently in beta)
- Compile-time processing = zero runtime overhead
- Compatible with Expo Go (free version)
- Pro version offers C++ engine with Reanimated 4 support
