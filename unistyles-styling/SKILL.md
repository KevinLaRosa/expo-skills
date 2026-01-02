---
name: unistyles-styling
description: Style React Native apps with Unistyles - a high-performance StyleSheet superset with themes, variants, breakpoints, and zero re-renders without Tailwind
license: MIT
compatibility: "Requires: React Native 0.78+, New Architecture enabled, Expo SDK 53+, iOS 15+, Android 7+"
---

# Unistyles Styling

## Overview

Style React Native components with Unistyles 3.0, a C++-powered StyleSheet superset that provides themes, variants, breakpoints, and 100% cross-platform compatibility without re-renders—no Tailwind required.

## When to Use This Skill

- Want themes without Tailwind CSS
- Need 100% style sharing across iOS, Android, and Web
- Require high-performance styling with zero re-renders
- Building apps with responsive breakpoints
- Using New Architecture (required)
- Prefer StyleSheet API over utility classes
- Need variant-based component styling

**Alternative**: Use `uniwind-styling` skill if you prefer Tailwind CSS approach.

## Workflow

### Step 1: Install Unistyles

```bash
# Install dependencies
yarn add react-native-unistyles react-native-nitro-modules react-native-edge-to-edge

# Or with npm
npm install react-native-unistyles react-native-nitro-modules react-native-edge-to-edge
```

**Requirements**:
- React Native 0.78.0+
- New Architecture enabled (mandatory)
- Expo SDK 53+ (if using Expo)

### Step 2: Configure Babel

Edit `babel.config.js`:

```javascript
module.exports = {
  presets: ['module:@react-native/babel-preset'],
  plugins: [
    ['react-native-unistyles/plugin', {
      root: 'src'  // or 'app' for Expo Router
    }],
    // other plugins...
  ],
};
```

### Step 3: Define Themes and Breakpoints

Create `unistyles.ts` in your project root:

```typescript
import { StyleSheet } from 'react-native-unistyles';

// Define themes
const lightTheme = {
  colors: {
    primary: '#007AFF',
    background: '#FFFFFF',
    text: '#000000',
    secondary: '#8E8E93',
    error: '#FF3B30',
  },
  spacing: (multiplier: number) => multiplier * 8,
  radius: {
    sm: 4,
    md: 8,
    lg: 16,
  },
} as const;

const darkTheme = {
  colors: {
    primary: '#0A84FF',
    background: '#000000',
    text: '#FFFFFF',
    secondary: '#8E8E93',
    error: '#FF453A',
  },
  spacing: (multiplier: number) => multiplier * 8,
  radius: {
    sm: 4,
    md: 8,
    lg: 16,
  },
} as const;

// Define breakpoints (one MUST be 0)
const breakpoints = {
  xs: 0,      // Required zero breakpoint
  sm: 300,
  md: 500,
  lg: 800,
  xl: 1200,
} as const;

// Configure Unistyles
StyleSheet.configure({
  themes: {
    light: lightTheme,
    dark: darkTheme,
  },
  breakpoints,
  settings: {
    adaptiveThemes: true,  // Auto-switch based on device color scheme
  },
});

// TypeScript setup for autocomplete
type AppThemes = {
  light: typeof lightTheme;
  dark: typeof darkTheme;
};

type AppBreakpoints = typeof breakpoints;

declare module 'react-native-unistyles' {
  export interface UnistylesThemes extends AppThemes {}
  export interface UnistylesBreakpoints extends AppBreakpoints {}
}

export { lightTheme, darkTheme };
```

### Step 4: Import Configuration in App Entry

Edit `App.tsx` or `app/_layout.tsx`:

```typescript
import './unistyles';  // Import before any components
import { View, Text } from 'react-native';

export default function App() {
  return <View>...</View>;
}
```

### Step 5: Create Stylesheets

**Static StyleSheet** (no theme dependency):
```typescript
import { StyleSheet } from 'react-native-unistyles';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    backgroundColor: '#FFFFFF',
  },
});
```

**Themable StyleSheet**:
```typescript
const styles = StyleSheet.create(theme => ({
  container: {
    flex: 1,
    padding: theme.spacing(2),
    backgroundColor: theme.colors.background,
  },
  text: {
    color: theme.colors.text,
    fontSize: 16,
  },
}));
```

**With Mini Runtime** (theme + device info):
```typescript
const styles = StyleSheet.create((theme, rt) => ({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
    paddingTop: rt.insets.top,  // Safe area
    paddingBottom: rt.insets.bottom,
  },
  landscapeOnly: {
    display: rt.isLandscape ? 'flex' : 'none',
  },
}));
```

### Step 6: Use Styles in Components

```typescript
import { View, Text } from 'react-native';
import { StyleSheet } from 'react-native-unistyles';

export function MyComponent() {
  return (
    <View style={styles.container}>
      <Text style={styles.text}>Hello Unistyles</Text>
    </View>
  );
}

const styles = StyleSheet.create(theme => ({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
  },
  text: {
    color: theme.colors.text,
  },
}));
```

### Step 7: Switch Themes at Runtime

```typescript
import { UnistylesRuntime } from 'react-native-unistyles';
import { Pressable, Text } from 'react-native';

export function ThemeToggle() {
  const toggleTheme = () => {
    const current = UnistylesRuntime.themeName;
    UnistylesRuntime.setTheme(current === 'dark' ? 'light' : 'dark');
  };

  return (
    <Pressable onPress={toggleTheme} style={styles.button}>
      <Text>Toggle Theme</Text>
    </Pressable>
  );
}
```

## Guidelines

**Do:**
- Use themes for colors, spacing, and design tokens
- Leverage variants for component variations
- Use breakpoints for responsive design
- Access `rt` (runtime) for device metadata
- Merge styles with array syntax: `[styles.a, styles.b]`
- Use `withUnistyles` HOC for automatic re-rendering
- Keep themes with identical structure

**Don't:**
- Don't spread Unistyles objects: `{ ...styles.a, ...styles.b }` (loses C++ state)
- Don't use with Old Architecture (New Architecture required)
- Don't forget zero breakpoint (required for cascading)
- Don't use Expo Go (requires custom native code)
- Don't mix `adaptiveThemes: true` with `initialTheme` (mutually exclusive)
- Don't use `useUnistyles` hook in React Native components (causes re-renders)

## Examples

### Responsive Design with Breakpoints

```typescript
const styles = StyleSheet.create(theme => ({
  container: {
    padding: {
      xs: theme.spacing(1),
      sm: theme.spacing(2),
      md: theme.spacing(3),
      lg: theme.spacing(4),
    },
    backgroundColor: {
      xs: theme.colors.background,
      md: theme.colors.secondary,
    },
  },
}));
```

### Media Queries for Precise Control

```typescript
import { StyleSheet, mq } from 'react-native-unistyles';

const styles = StyleSheet.create(theme => ({
  container: {
    backgroundColor: {
      [mq.only.width(0, 400)]: theme.colors.primary,     // 0-399px
      [mq.only.width(400, 800)]: theme.colors.secondary, // 400-799px
      [mq.width(800)]: theme.colors.background,          // 800px+
    },
  },
}));
```

### Variants for Component Variations

```typescript
const styles = StyleSheet.create(theme => ({
  button: {
    padding: theme.spacing(2),
    borderRadius: theme.radius.md,
    variants: {
      size: {
        small: {
          padding: theme.spacing(1),
          minWidth: 80,
        },
        medium: {
          padding: theme.spacing(2),
          minWidth: 120,
        },
        large: {
          padding: theme.spacing(3),
          minWidth: 160,
        },
      },
      color: {
        primary: {
          backgroundColor: theme.colors.primary,
        },
        secondary: {
          backgroundColor: theme.colors.secondary,
        },
      },
      outlined: {
        true: {
          backgroundColor: 'transparent',
          borderWidth: 1,
          borderColor: theme.colors.primary,
        },
      },
    },
  },
}));

// Use in component
export function Button({ size, color, outlined }) {
  styles.useVariants({ size, color, outlined });
  return <Pressable style={styles.button}>...</Pressable>;
}
```

### Compound Variants

```typescript
const styles = StyleSheet.create(theme => ({
  button: {
    variants: {
      size: {
        small: { fontSize: 12 },
        large: { fontSize: 18 },
      },
      outlined: {
        true: { borderWidth: 1 },
      },
    },
    compoundVariants: [
      {
        // When BOTH outlined=true AND size=large
        outlined: true,
        size: 'large',
        styles: {
          borderWidth: 2,  // Override with thicker border
        },
      },
    ],
  },
}));
```

### Dynamic Functions

```typescript
const styles = StyleSheet.create(theme => ({
  container: (maxWidth: number, isHighlighted: boolean) => ({
    backgroundColor: isHighlighted
      ? theme.colors.primary
      : theme.colors.background,
    maxWidth,
    borderRadius: theme.radius.md,
  }),
}));

// Use in component
<View style={styles.container(300, true)} />
```

### Safe Area Insets

```typescript
const styles = StyleSheet.create((theme, rt) => ({
  container: {
    flex: 1,
    paddingTop: rt.insets.top,        // Top safe area
    paddingBottom: rt.insets.bottom,  // Bottom safe area
    paddingLeft: rt.insets.left,
    paddingRight: rt.insets.right,
  },
  withKeyboard: {
    paddingBottom: rt.insets.ime,  // Keyboard inset
  },
}));
```

### Web-Specific Styles

```typescript
const styles = StyleSheet.create(theme => ({
  container: {
    flex: 1,
    _web: {
      display: 'grid',
      gridTemplateColumns: 'repeat(3, 1fr)',
      gap: 16,
      _hover: {
        backgroundColor: theme.colors.secondary,
      },
      _active: {
        opacity: 0.8,
      },
    },
  },
}));
```

### Conditional Display Components

```typescript
import { Display, Hide, mq } from 'react-native-unistyles';

// Show only on mobile
<Display mq={mq.only.width(0, 768)}>
  <MobileMenu />
</Display>

// Hide on mobile
<Hide mq={mq.only.width(0, 768)}>
  <DesktopMenu />
</Hide>
```

### Scoped Themes

```typescript
import { ScopedTheme } from 'react-native-unistyles';

// Force dark theme for specific component
<ScopedTheme name="dark">
  <DarkOnlyComponent />
</ScopedTheme>

// Invert adaptive theme
<ScopedTheme invertedAdaptive>
  <InvertedComponent />
</ScopedTheme>
```

### Type-Safe Variant Props

```typescript
import { UnistylesVariants } from 'react-native-unistyles';

const styles = StyleSheet.create(theme => ({
  button: {
    variants: {
      size: {
        small: { padding: 8 },
        large: { padding: 16 },
      },
      color: {
        primary: { backgroundColor: theme.colors.primary },
        secondary: { backgroundColor: theme.colors.secondary },
      },
    },
  },
}));

// Auto-infer variant types
type ButtonProps = UnistylesVariants<typeof styles>;

const Button: React.FC<ButtonProps> = ({ size, color }) => {
  styles.useVariants({ size, color });
  return <Pressable style={styles.button}>...</Pressable>;
};
```

### Reanimated Integration

```typescript
import { useAnimatedTheme } from 'react-native-unistyles/reanimated';
import Animated, { useAnimatedStyle } from 'react-native-reanimated';

export const AnimatedComponent = () => {
  const theme = useAnimatedTheme();

  const animatedStyle = useAnimatedStyle(() => ({
    backgroundColor: theme.value.colors.background,
  }));

  return <Animated.View style={animatedStyle} />;
};
```

## Resources

- [Unistyles Full Documentation](https://www.unistyl.es/llms-full.txt)
- [Official Docs](https://unistyl.es/)
- [GitHub](https://github.com/jpudysz/react-native-unistyles)
- [Migration from v2 to v3](https://unistyl.es/migration)

## Tools & Commands

- `npx expo prebuild --clean` - Regenerate native projects after install
- `npx expo start --clear` - Clear Metro cache after config changes

## Troubleshooting

### Styles not applying

**Problem**: Styles not working after installation

**Solution**:
1. Ensure `react-native-unistyles/plugin` is in `babel.config.js`
2. Import `unistyles.ts` in app entry point
3. Clear Metro cache: `npx expo start --clear`
4. Verify New Architecture is enabled

### New Architecture not enabled

**Problem**: "New Architecture required" error

**Solution**:
For Expo:
```json
// app.json
{
  "expo": {
    "plugins": [
      [
        "expo-build-properties",
        {
          "ios": { "newArchEnabled": true },
          "android": { "newArchEnabled": true }
        }
      ]
    ]
  }
}
```

Then: `npx expo prebuild --clean`

### Theme not switching

**Problem**: Theme doesn't change on toggle

**Solution**:
```typescript
// Check if adaptive themes is interfering
UnistylesRuntime.setAdaptiveThemes(false);  // Disable auto-switching
UnistylesRuntime.setTheme('dark');          // Manual control
```

### TypeScript errors on theme

**Problem**: Theme properties not autocompleting

**Solution**:
Add module declaration in `unistyles.ts`:
```typescript
declare module 'react-native-unistyles' {
  export interface UnistylesThemes {
    light: typeof lightTheme;
    dark: typeof darkTheme;
  }
  export interface UnistylesBreakpoints extends typeof breakpoints {}
}
```

### Breakpoint errors

**Problem**: "Breakpoint must include zero" error

**Solution**:
```typescript
// ❌ Wrong - no zero breakpoint
const breakpoints = { sm: 300, md: 500 };

// ✅ Correct - includes zero
const breakpoints = { xs: 0, sm: 300, md: 500 };
```

---

## Notes

- Unistyles uses C++ for zero re-renders (updates ShadowTree directly)
- Requires New Architecture (no Old Architecture support)
- Not compatible with Expo Go (needs custom native code)
- Babel plugin auto-disables in Jest (mocks provided)
- Shares up to 100% of styles across iOS, Android, and Web
- Performance-focused: no context, no hooks overhead
- Alternative to Tailwind-based solutions (use `uniwind-styling` for Tailwind)
