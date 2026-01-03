# Uniwind Theme System Reference

## Overview

Uniwind implements a powerful theming system using CSS variables and React context, enabling light/dark modes, custom themes, and dynamic theme switching without ThemeProvider wrappers.

## Core Theming Concepts

### CSS-Based Theming
Unlike NativeWind which uses JavaScript configuration, Uniwind manages themes entirely through CSS files using Tailwind 4's `@theme` directive and CSS variables. This approach:

- Eliminates need for `tailwind.config.js`
- Enables runtime theme updates
- Simplifies theme management
- Improves performance with compile-time processing

### No ThemeProvider Required
Uniwind doesn't require wrapping your app in a ThemeProvider to switch themes. Theme management is handled automatically through CSS variables and the `useUniwind` hook.

## Light and Dark Themes

### Basic Theme Configuration

Configure themes in your `global.css` file:

```css
@import 'tailwindcss';
@import 'uniwind';

@theme {
  /* Light mode colors (default) */
  --color-background: #ffffff;
  --color-foreground: #000000;
  --color-primary: #3b82f6;
  --color-secondary: #64748b;

  /* Dark mode colors */
  @media (prefers-color-scheme: dark) {
    --color-background: #000000;
    --color-foreground: #ffffff;
    --color-primary: #60a5fa;
    --color-secondary: #94a3b8;
  }
}
```

### Using Theme Variables in Components

Apply theme-aware classes using the `dark:` variant:

```tsx
<View className="bg-white dark:bg-gray-900">
  <Text className="text-gray-900 dark:text-white">
    Theme-aware text
  </Text>
</View>
```

### Accessing Current Theme

Use the `useUniwind` hook to access theme state:

```tsx
import { useUniwind } from 'uniwind'

const MyComponent = () => {
  const { theme, hasAdaptiveThemes } = useUniwind()

  return (
    <View>
      <Text>Current theme: {theme}</Text>
      <Text>System theme: {hasAdaptiveThemes ? 'Yes' : 'No'}</Text>
    </View>
  )
}
```

**Return values:**
- `theme`: Current theme identifier ("light", "dark", "system", or custom)
- `hasAdaptiveThemes`: Whether app follows device system preference

## Custom Theme Configuration

### Creating Custom Themes

Define custom themes beyond light and dark in `global.css`:

```css
@theme {
  /* Base theme variables */
  --color-background: #ffffff;
  --color-foreground: #000000;

  /* Custom theme: Ocean */
  @variant ocean {
    --color-background: #0c4a6e;
    --color-foreground: #e0f2fe;
    --color-primary: #0ea5e9;
    --color-accent: #06b6d4;
  }

  /* Custom theme: Sunset */
  @variant sunset {
    --color-background: #7c2d12;
    --color-foreground: #fed7aa;
    --color-primary: #f97316;
    --color-accent: #fb923c;
  }
}
```

### Using Custom Theme Variants

Apply custom theme styles using variant syntax:

```tsx
<View className="bg-background ocean:bg-sky-900 sunset:bg-orange-900">
  <Text className="text-foreground">
    Multi-theme component
  </Text>
</View>
```

## Theme Switching

### Dynamic CSS Variable Updates

Use the `updateCSSVariables` function to update theme variables at runtime:

```tsx
import { updateCSSVariables } from 'uniwind'

const switchToOceanTheme = () => {
  updateCSSVariables('ocean', {
    '--color-background': '#0c4a6e',
    '--color-foreground': '#e0f2fe',
    '--color-primary': '#0ea5e9'
  })
}
```

### Accessing CSS Variables in JavaScript

Use `useCSSVariable` hook for dynamic values:

```tsx
import { useCSSVariable } from 'uniwind'

const MyComponent = () => {
  const primaryColor = useCSSVariable('--color-primary')
  const backgroundColor = useCSSVariable('--color-background')

  // Use in calculations, animations, etc.
  console.log('Primary color:', primaryColor)

  return <View>{/* component */}</View>
}
```

**Features:**
- Automatic updates when theme changes
- Real-time value access
- Type-safe with proper configuration

## Color Schemes

### Defining Color Palettes

Create comprehensive color systems in `@theme`:

```css
@theme {
  /* Grayscale */
  --color-gray-50: #f9fafb;
  --color-gray-100: #f3f4f6;
  --color-gray-200: #e5e7eb;
  --color-gray-300: #d1d5db;
  --color-gray-400: #9ca3af;
  --color-gray-500: #6b7280;
  --color-gray-600: #4b5563;
  --color-gray-700: #374151;
  --color-gray-800: #1f2937;
  --color-gray-900: #111827;
  --color-gray-950: #030712;

  /* Primary palette */
  --color-blue-50: #eff6ff;
  --color-blue-500: #3b82f6;
  --color-blue-900: #1e3a8a;

  /* Semantic colors */
  --color-success: #10b981;
  --color-warning: #f59e0b;
  --color-error: #ef4444;
  --color-info: #3b82f6;

  /* Dark mode overrides */
  @media (prefers-color-scheme: dark) {
    --color-success: #34d399;
    --color-warning: #fbbf24;
    --color-error: #f87171;
    --color-info: #60a5fa;
  }
}
```

### Using Color Variables

```tsx
<View className="bg-gray-50 dark:bg-gray-950">
  <Text className="text-blue-500 dark:text-blue-400">Primary text</Text>
  <Text className="text-success">Success message</Text>
  <Text className="text-error">Error message</Text>
</View>
```

## Typography System

### Font Configuration

Define typography scale in `@theme`:

```css
@theme {
  /* Font families */
  --font-sans: 'System';
  --font-serif: 'Georgia';
  --font-mono: 'Courier';

  /* Font sizes */
  --text-xs: 12px;
  --text-sm: 14px;
  --text-base: 16px;
  --text-lg: 18px;
  --text-xl: 20px;
  --text-2xl: 24px;
  --text-3xl: 30px;
  --text-4xl: 36px;

  /* Font weights */
  --font-light: 300;
  --font-normal: 400;
  --font-medium: 500;
  --font-semibold: 600;
  --font-bold: 700;

  /* Line heights */
  --leading-tight: 1.25;
  --leading-normal: 1.5;
  --leading-relaxed: 1.75;

  /* Letter spacing */
  --tracking-tight: -0.05em;
  --tracking-normal: 0em;
  --tracking-wide: 0.05em;
}
```

### Typography Usage

```tsx
<View>
  <Text className="font-sans text-4xl font-bold leading-tight">
    Heading
  </Text>
  <Text className="font-sans text-base font-normal leading-normal">
    Body text with normal spacing
  </Text>
  <Text className="font-mono text-sm tracking-wide">
    Monospace code
  </Text>
</View>
```

### Platform-Specific Fonts

Configure different fonts per platform:

```css
@theme {
  /* Default font */
  --font-sans: 'System';

  /* iOS-specific */
  @media ios {
    --font-sans: 'SF Pro Text';
  }

  /* Android-specific */
  @media android {
    --font-sans: 'Roboto';
  }

  /* Web-specific */
  @media web {
    --font-sans: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  }
}
```

## Theme Best Practices

### 1. Semantic Naming
Use semantic variable names for better maintainability:

```css
/* Good */
--color-background: #ffffff;
--color-foreground: #000000;
--color-primary: #3b82f6;
--color-danger: #ef4444;

/* Avoid */
--color-1: #ffffff;
--blue: #3b82f6;
```

### 2. Consistent Color Scales
Maintain consistent scales (50-950) for all color families:

```css
--color-blue-50: #eff6ff;
--color-blue-100: #dbeafe;
/* ... */
--color-blue-900: #1e3a8a;
--color-blue-950: #172554;
```

### 3. Dark Mode Considerations
Always define dark mode variants for better UX:

```css
@theme {
  --color-card: #ffffff;
  --color-card-border: #e5e7eb;

  @media (prefers-color-scheme: dark) {
    --color-card: #1f2937;
    --color-card-border: #374151;
  }
}
```

### 4. Component-Level Theming
Create component-specific variables:

```css
@theme {
  /* Button */
  --button-bg: var(--color-primary);
  --button-text: #ffffff;
  --button-radius: 8px;

  /* Card */
  --card-bg: var(--color-background);
  --card-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  --card-padding: 16px;

  /* Input */
  --input-border: var(--color-gray-300);
  --input-focus: var(--color-primary);
}
```

### 5. Theme Switching Performance
Use `updateCSSVariables` for runtime updates:

```tsx
const themes = {
  light: {
    '--color-background': '#ffffff',
    '--color-foreground': '#000000'
  },
  dark: {
    '--color-background': '#000000',
    '--color-foreground': '#ffffff'
  },
  ocean: {
    '--color-background': '#0c4a6e',
    '--color-foreground': '#e0f2fe'
  }
}

const switchTheme = (themeName: keyof typeof themes) => {
  updateCSSVariables(themeName, themes[themeName])
}
```

## Advanced Theming

### Global CSS Variables
Access and modify global CSS in your styles:

```css
@import 'tailwindcss';
@import 'uniwind';

/* Global styles */
* {
  margin: 0;
  padding: 0;
}

/* Theme configuration */
@theme {
  /* Your theme variables */
}
```

### Style Based on Themes
Different approaches for theme-aware styling:

1. **CSS variants:** `dark:bg-gray-900`
2. **Custom variants:** `ocean:bg-sky-900`
3. **CSS variables:** `bg-[var(--color-background)]`
4. **JavaScript access:** `useCSSVariable('--color-primary')`

## Common Patterns

### Theme Toggle Button

```tsx
import { useUniwind } from 'uniwind'
import { updateCSSVariables } from 'uniwind'

const ThemeToggle = () => {
  const { theme } = useUniwind()

  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light'
    updateCSSVariables(newTheme, {
      // CSS variable updates
    })
  }

  return (
    <Pressable
      onPress={toggleTheme}
      className="p-4 bg-gray-100 dark:bg-gray-800 rounded-lg"
    >
      <Text className="text-gray-900 dark:text-white">
        {theme === 'light' ? '🌙' : '☀️'}
      </Text>
    </Pressable>
  )
}
```

### Themed Card Component

```tsx
const ThemedCard = ({ children }) => {
  return (
    <View className="bg-white dark:bg-gray-800 p-4 rounded-lg shadow-lg">
      <View className="border-l-4 border-primary dark:border-primary-light pl-3">
        {children}
      </View>
    </View>
  )
}
```

### System Theme Detection

```tsx
import { useUniwind } from 'uniwind'

const SystemThemeIndicator = () => {
  const { hasAdaptiveThemes } = useUniwind()

  return (
    <Text className="text-sm text-gray-600 dark:text-gray-400">
      {hasAdaptiveThemes
        ? 'Following system theme'
        : 'Using manual theme'}
    </Text>
  )
}
```
