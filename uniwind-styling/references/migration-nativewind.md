# Migration Guide: NativeWind to Uniwind

## Overview

Migrating from NativeWind to Uniwind is a straightforward process that should take no more than a few minutes. This guide covers all differences, breaking changes, and step-by-step migration instructions.

## Key Differences

### 1. Tailwind Version Support

**NativeWind:** Supports Tailwind CSS v3
**Uniwind:** Supports Tailwind CSS v4 only

**Action Required:** Upgrade Tailwind CSS to version 4 before migrating.

```bash
bun add tailwindcss@latest
# or
npm install tailwindcss@latest
```

### 2. Default rem Value

**NativeWind:** Uses 14px as default rem unit
**Uniwind:** Uses 16px as default rem unit (Tailwind 4 standard)

**Impact:** Spacing and sizing classes will render slightly larger.

**Migration path:** If you need to maintain 14px rem value:

```css
@theme {
  --default-font-size: 14px;
}
```

### 3. Theme Configuration

**NativeWind:** Themes configured in JavaScript (`tailwind.config.js`)
**Uniwind:** Themes configured in CSS files using `@theme` directive

**Before (NativeWind):**

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: '#3b82f6',
        secondary: '#64748b'
      }
    }
  }
}
```

**After (Uniwind):**

```css
/* global.css */
@theme {
  --color-primary: #3b82f6;
  --color-secondary: #64748b;
}
```

**Action Required:** Delete `tailwind.config.js` and move theme configuration to CSS.

### 4. ThemeProvider

**NativeWind:** Requires `<ThemeProvider>` wrapper for theme switching
**Uniwind:** No ThemeProvider needed - automatic theme management

**Before (NativeWind):**

```tsx
import { ThemeProvider } from 'nativewind'

export default function App() {
  return (
    <ThemeProvider value="light">
      <YourApp />
    </ThemeProvider>
  )
}
```

**After (Uniwind):**

```tsx
// No wrapper needed
export default function App() {
  return <YourApp />
}
```

**Action Required:** Remove NativeWind's ThemeProvider. Keep React Navigation's ThemeProvider if using it.

### 5. Component Styling API

**NativeWind:** Uses `cssInterop` for third-party component styling
**Uniwind:** Uses `withUniwind` HOC

**Before (NativeWind):**

```tsx
import { cssInterop } from 'nativewind'
import { SafeAreaView } from 'react-native-safe-area-context'

cssInterop(SafeAreaView, {
  className: 'style'
})
```

**After (Uniwind):**

```tsx
import { withUniwind } from 'uniwind'
import { SafeAreaView } from 'react-native-safe-area-context'

const StyledSafeAreaView = withUniwind(SafeAreaView)
```

**Action Required:** Replace all `cssInterop` calls with `withUniwind`.

### 6. Theme Variables Helper

**NativeWind:** Uses `vars()` helper function
**Uniwind:** Uses CSS `@variant` directives

**Before (NativeWind):**

```javascript
// Using vars() helper
vars({
  '--color-primary': 'blue'
})
```

**After (Uniwind):**

```css
@theme {
  @variant custom-theme {
    --color-primary: #3b82f6;
  }
}
```

**Action Required:** Convert `vars()` calls to `@variant` CSS directives.

### 7. Font Configuration

**NativeWind:** Supports font family fallbacks
**Uniwind:** Requires single font file per variant (no fallbacks)

**Before (NativeWind):**

```javascript
module.exports = {
  theme: {
    fontFamily: {
      sans: ['Helvetica', 'Arial', 'sans-serif']
    }
  }
}
```

**After (Uniwind):**

```css
@theme {
  --font-sans: 'Helvetica';
}
```

**Action Required:** Use single font per family; remove fallback arrays.

## Breaking Changes

### Configuration Changes

1. **Babel preset removal**
   - Remove `'nativewind/babel'` from `babel.config.js`

2. **Metro configuration**
   - Replace NativeWind metro config with `withUniwindConfig`

3. **Type definitions**
   - Delete `nativewind.d.ts` type definition file

4. **Global CSS imports**
   - Update to Tailwind 4 import syntax

### API Changes

1. **cssInterop → withUniwind**
   - All component wrapping uses new HOC pattern

2. **ThemeProvider removed**
   - No provider component needed

3. **vars() → @variant**
   - Theme variables move to CSS

4. **tailwind.config.js removed**
   - All configuration in CSS using `@theme`

### Style Changes

1. **Default rem value**
   - Spacing changes from 14px to 16px base

2. **Font families**
   - No fallback fonts supported

## Step-by-Step Migration

### Step 1: Install Uniwind

Follow the Uniwind quickstart guide:

```bash
bun add uniwind tailwindcss
```

### Step 2: Remove NativeWind Babel Preset

Edit `babel.config.js`:

**Before:**

```javascript
module.exports = {
  presets: [
    'nativewind/babel',
    // other presets
  ]
}
```

**After:**

```javascript
module.exports = {
  presets: [
    // Remove 'nativewind/babel'
    // Keep other presets
  ]
}
```

### Step 3: Update Metro Configuration

Edit `metro.config.js`:

**Before (NativeWind):**

```javascript
const { withNativeWind } = require('nativewind/metro');

module.exports = withNativeWind(config, {
  input: './global.css'
});
```

**After (Uniwind):**

```javascript
const { getDefaultConfig } = require('expo/metro-config');
const { withUniwindConfig } = require('uniwind/metro');

const config = getDefaultConfig(__dirname);

module.exports = withUniwindConfig(config, {
  cssEntryFile: './global.css',
  dtsFile: './uniwind-types.d.ts'
});
```

### Step 4: Update Global CSS Imports

Edit `global.css`:

**Before (NativeWind):**

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

**After (Uniwind):**

```css
@import 'tailwindcss';
@import 'uniwind';
```

### Step 5: Delete NativeWind Type Definitions

Remove the `nativewind.d.ts` file from your project.

### Step 6: Convert CSS to Tailwind 4 Syntax

Migrate theme configuration to `@theme` syntax:

**Before (NativeWind - tailwind.config.js):**

```javascript
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: '#3b82f6',
        secondary: '#64748b'
      },
      spacing: {
        '128': '32rem'
      }
    }
  }
}
```

**After (Uniwind - global.css):**

```css
@theme {
  --color-primary: #3b82f6;
  --color-secondary: #64748b;
  --spacing-128: 32rem;
}
```

### Step 7: Move Theme Variables to CSS

Convert `vars()` calls to `@variant` directives:

**Before (NativeWind):**

```javascript
import { vars } from 'nativewind'

vars({
  '--color-primary-light': '#60a5fa',
  '--color-primary-dark': '#1e40af'
})
```

**After (Uniwind):**

```css
@theme {
  @variant light {
    --color-primary: #60a5fa;
  }

  @variant dark {
    --color-primary: #1e40af;
  }
}
```

### Step 8: Delete tailwind.config.js

Remove the entire `tailwind.config.js` file. All configuration is now in CSS.

```bash
rm tailwind.config.js
```

### Step 9: Migrate Font Families

Update font configuration to single files:

**Before (NativeWind):**

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    fontFamily: {
      sans: ['Helvetica', 'Arial', 'sans-serif'],
      serif: ['Georgia', 'serif']
    }
  }
}
```

**After (Uniwind):**

```css
@theme {
  --font-sans: 'Helvetica';
  --font-serif: 'Georgia';
}
```

### Step 10: Customize rem Value (Optional)

If you need to maintain NativeWind's 14px default:

```css
@theme {
  --default-font-size: 14px;
}
```

### Step 11: Remove NativeWind ThemeProvider

Edit your root component:

**Before (NativeWind):**

```tsx
import { ThemeProvider } from 'nativewind'
import { NavigationContainer } from '@react-navigation/native'

export default function App() {
  return (
    <ThemeProvider value={colorScheme}>
      <NavigationContainer>
        {/* app content */}
      </NavigationContainer>
    </ThemeProvider>
  )
}
```

**After (Uniwind):**

```tsx
import { NavigationContainer } from '@react-navigation/native'

export default function App() {
  return (
    <NavigationContainer>
      {/* app content */}
    </NavigationContainer>
  )
}
```

**Important:** Keep React Navigation's ThemeProvider if you're using it.

### Step 12: Replace cssInterop with withUniwind

Update all component styling wrappers:

**Before (NativeWind):**

```tsx
import { cssInterop } from 'nativewind'
import { SafeAreaView } from 'react-native-safe-area-context'
import LinearGradient from 'react-native-linear-gradient'

cssInterop(SafeAreaView, {
  className: 'style'
})

cssInterop(LinearGradient, {
  className: 'style',
  colors: 'colors'
})
```

**After (Uniwind):**

```tsx
import { withUniwind } from 'uniwind'
import { SafeAreaView } from 'react-native-safe-area-context'
import LinearGradient from 'react-native-linear-gradient'

export const StyledSafeAreaView = withUniwind(SafeAreaView)

export const StyledLinearGradient = withUniwind(LinearGradient, {
  colors: {
    fromClassName: 'colorsClassName',
    styleProperty: 'colors'
  }
})
```

### Step 13: Safe Area Utilities (Optional)

If using safe area utilities, integrate SafeAreaListener:

```tsx
import { SafeAreaListener } from 'uniwind'

export default function App() {
  return (
    <>
      <SafeAreaListener />
      <YourApp />
    </>
  )
}
```

### Step 14: Update Animated ClassNames (Optional)

If using Reanimated, update to new syntax:

**Before (NativeWind):**

```tsx
import Animated from 'react-native-reanimated'

<Animated.View className={animatedClassName} />
```

**After (Uniwind):**

```tsx
import Animated from 'react-native-reanimated'
import { withUniwind } from 'uniwind'

const AnimatedView = withUniwind(Animated.View)

<AnimatedView className={animatedClassName} />
```

### Step 15: className Deduplication (Optional)

Use `tailwind-merge` for className deduplication:

```bash
bun add tailwind-merge
```

```tsx
import { twMerge } from 'tailwind-merge'

<View className={twMerge('p-4', 'p-6')}>
  {/* Results in p-6 */}
</View>
```

## Migration Checklist

Use this checklist to ensure complete migration:

- [ ] Install Uniwind and Tailwind CSS v4
- [ ] Remove NativeWind Babel preset
- [ ] Update Metro configuration with `withUniwindConfig`
- [ ] Update global CSS imports to Tailwind 4 syntax
- [ ] Delete `nativewind.d.ts`
- [ ] Convert theme configuration to `@theme` syntax
- [ ] Move theme variables from `vars()` to `@variant`
- [ ] Delete `tailwind.config.js`
- [ ] Update font families (remove fallbacks)
- [ ] Customize rem value if needed (14px → 16px)
- [ ] Remove NativeWind's ThemeProvider
- [ ] Replace all `cssInterop` with `withUniwind`
- [ ] Add SafeAreaListener if needed
- [ ] Update animated className syntax if using Reanimated
- [ ] Install and use `tailwind-merge` for className deduplication
- [ ] Test app on iOS, Android, and Web
- [ ] Verify theme switching works
- [ ] Check responsive breakpoints
- [ ] Validate platform-specific styles

## Benefits of Switching to Uniwind

### 1. Performance Improvements

**Compile-time processing:** Styles generated at build time, not runtime
- Faster app startup
- Reduced runtime overhead
- Smaller bundle sizes with tree-shaking

**Zero re-renders:** Stable style references prevent unnecessary renders
- Improved component performance
- Better app responsiveness
- Reduced CPU usage

### 2. Simplified Configuration

**No tailwind.config.js:** All configuration in CSS
- Fewer files to manage
- Easier theme updates
- Better co-location of styles

**No ThemeProvider:** Automatic theme management
- Cleaner component tree
- Simpler setup
- Less boilerplate

### 3. Better Developer Experience

**Tailwind 4 features:** Latest Tailwind capabilities
- Modern CSS features
- Improved @theme syntax
- Better IDE support

**withUniwind HOC:** Clearer API than cssInterop
- Type-safe component wrapping
- Explicit prop mapping
- Better documentation

### 4. Enhanced Theming

**CSS-based themes:** More flexible and powerful
- Runtime CSS variable updates
- Platform-specific theme values
- Better dark mode support

**updateCSSVariables:** Dynamic theme changes
- No need for context providers
- Instant theme switching
- Granular control

### 5. Improved Maintainability

**Single source of truth:** All styles in CSS
- Easier to audit
- Better version control
- Simpler refactoring

**Clear migration path:** Well-documented upgrade process
- Community support
- Active development
- Regular updates

## Common Migration Issues

### Issue 1: Spacing Looks Different

**Problem:** Elements appear larger after migration
**Cause:** rem base changed from 14px to 16px
**Solution:** Add to `global.css`:

```css
@theme {
  --default-font-size: 14px;
}
```

### Issue 2: Fonts Not Loading

**Problem:** Custom fonts don't display
**Cause:** Font fallbacks not supported
**Solution:** Use single font per family:

```css
@theme {
  --font-custom: 'MyCustomFont';
}
```

### Issue 3: Third-Party Components Not Styling

**Problem:** Library components don't accept className
**Cause:** Need to wrap with `withUniwind`
**Solution:**

```tsx
import { withUniwind } from 'uniwind'
import { CustomComponent } from 'third-party-lib'

const StyledCustomComponent = withUniwind(CustomComponent)
```

### Issue 4: Theme Not Switching

**Problem:** Dark mode doesn't activate
**Cause:** Missing theme variant definitions
**Solution:** Define in `global.css`:

```css
@theme {
  --color-background: #ffffff;

  @media (prefers-color-scheme: dark) {
    --color-background: #000000;
  }
}
```

### Issue 5: TypeScript Errors

**Problem:** className prop not recognized
**Cause:** Missing or outdated type definitions
**Solution:** Ensure `dtsFile` configured in metro.config.js:

```javascript
module.exports = withUniwindConfig(config, {
  cssEntryFile: './global.css',
  dtsFile: './uniwind-types.d.ts'
});
```

## Support and Resources

### Getting Help

If you encounter issues during migration:

1. **Check documentation:** https://docs.uniwind.dev/
2. **GitHub issues:** Open issue at uni-stack/uniwind
3. **Discussions:** Join GitHub discussions
4. **Community:** Discord/Slack communities

### Reporting Missing Features

If you're using NativeWind features not available in Uniwind:

1. Check if feature exists in Uniwind docs
2. Open GitHub issue describing the feature
3. Provide use case and examples
4. Monitor issue for updates

### Timeline

The migration process typically takes:
- **Simple apps:** 10-15 minutes
- **Medium apps:** 30-45 minutes
- **Large apps:** 1-2 hours

Most time spent on:
- Converting theme configuration
- Replacing cssInterop with withUniwind
- Testing across platforms

## Conclusion

Migrating from NativeWind to Uniwind provides significant performance improvements and a better developer experience. The process is straightforward, well-documented, and typically takes only a few minutes for most projects.

Key advantages:
- Faster runtime performance
- Simpler configuration
- Better Tailwind 4 support
- Enhanced theming capabilities
- Active development and community

Follow the 15-step migration guide, use the checklist, and refer to this document when issues arise. The Uniwind community is ready to help with any migration challenges.
