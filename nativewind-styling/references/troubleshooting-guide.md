# NativeWind Troubleshooting Guide

## Overview

This comprehensive guide covers common issues, errors, and solutions when working with NativeWind v4. Each problem includes symptoms, root causes, and step-by-step solutions.

## Installation & Setup Issues

### 1. className Prop Not Working

**Symptoms:**
- TypeScript error: "Property 'className' does not exist on type"
- Styles not applying to components
- No visual changes when adding className

**Root Causes:**
- Missing `jsxImportSource: "nativewind"` in Babel config
- Babel plugin not loaded
- TypeScript types not configured

**Solutions:**

**Step 1**: Verify Babel configuration in `babel.config.js`:

```javascript
module.exports = function (api) {
  api.cache(true);
  return {
    presets: [
      ["babel-preset-expo", { jsxImportSource: "nativewind" }]  // ✅ Must include this
    ],
    plugins: [
      "nativewind/babel",  // ✅ Must include this
      "react-native-reanimated/plugin",  // Must be last
    ],
  };
};
```

**Step 2**: Create TypeScript types file `nativewind-env.d.ts`:

```typescript
/// <reference types="nativewind/types" />
```

**Step 3**: Restart Metro and clear cache:

```bash
npx expo start --clear
```

**Step 4**: Restart TypeScript server in VS Code:
- Cmd+Shift+P (Mac) or Ctrl+Shift+P (Windows)
- Type "TypeScript: Restart TS Server"

---

### 2. Styles Not Applying

**Symptoms:**
- className prop accepted but no visual changes
- Components render with default styles
- Tailwind classes have no effect

**Root Causes:**
- global.css not imported
- Metro bundler not configured
- Tailwind content paths incorrect
- Metro cache stale

**Solutions:**

**Step 1**: Verify `global.css` import in root file:

```typescript
// In app/_layout.tsx or App.tsx
import "../global.css";  // ✅ Must be at the top
```

**Step 2**: Check `global.css` content:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

**Step 3**: Verify Metro configuration in `metro.config.js`:

```javascript
const { getDefaultConfig } = require("expo/metro-config");
const { withNativeWind } = require('nativewind/metro');

const config = getDefaultConfig(__dirname);

module.exports = withNativeWind(config, {
  input: './global.css',  // ✅ Correct path to global.css
});
```

**Step 4**: Check Tailwind content paths in `tailwind.config.js`:

```javascript
module.exports = {
  content: [
    "./App.{js,jsx,ts,tsx}",
    "./app/**/*.{js,jsx,ts,tsx}",        // ✅ Expo Router
    "./components/**/*.{js,jsx,ts,tsx}", // ✅ Components folder
    "./screens/**/*.{js,jsx,ts,tsx}",    // ✅ Screens folder if you have one
  ],
  presets: [require("nativewind/preset")],  // ✅ Required
};
```

**Step 5**: Clear Metro cache and rebuild:

```bash
npx expo start --clear
# Or
rm -rf node_modules/.cache
npx expo start
```

---

### 3. Hot Reload Not Working

**Symptoms:**
- New className styles don't appear immediately
- Need to refresh multiple times
- Styles only apply after full restart

**Root Cause:**
- NativeWind limitation with Metro bundler hot reload

**Solutions:**

**Option 1**: Clear cache and restart (most reliable):

```bash
npx expo start --clear
```

**Option 2**: Force refresh:
- iOS Simulator: Cmd+R
- Android Emulator: R+R (press R twice)

**Option 3**: Accept the limitation:
- This is a known NativeWind v4 issue
- Production builds work correctly
- Only affects development experience

**Workaround**: Use static class names during development rather than frequently adding new classes.

---

## Configuration Issues

### 4. NativeWind Preset Not Working

**Symptoms:**
- Platform variants (ios:, android:, web:) not working
- Dark mode classes not applying
- Custom classes missing

**Root Cause:**
- Missing or incorrect preset in tailwind.config.js

**Solution:**

```javascript
module.exports = {
  content: ["./app/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],  // ✅ Must include this
  theme: {
    extend: {
      // Your customizations here
    },
  },
};
```

**Don't override** `presets` array - add your customizations to `theme.extend`.

---

### 5. Metro Configuration Errors

**Symptoms:**
- Error: "Cannot find module 'nativewind/metro'"
- Metro bundler fails to start
- Build errors related to CSS

**Root Cause:**
- NativeWind not installed
- Incorrect Metro config syntax

**Solutions:**

**Step 1**: Verify NativeWind installation:

```bash
npm list nativewind
# Should show version 4.x.x

# If not installed or wrong version:
npm install nativewind@latest
```

**Step 2**: Correct Metro config format:

```javascript
const { getDefaultConfig } = require("expo/metro-config");
const { withNativeWind } = require('nativewind/metro');

const config = getDefaultConfig(__dirname);

// ✅ Correct - withNativeWind as wrapper
module.exports = withNativeWind(config, {
  input: './global.css',
});

// ❌ Wrong - Don't modify config after wrapping
// config.someProperty = value;  // This will break
```

**Important**: `withNativeWind` must be the last wrapper. Don't modify config after wrapping.

---

### 6. Babel Configuration Errors

**Symptoms:**
- Error: "Cannot find module 'nativewind/babel'"
- JSX transform errors
- className not recognized

**Root Cause:**
- Missing Babel plugin
- Plugin order incorrect

**Solution:**

```javascript
module.exports = function (api) {
  api.cache(true);
  return {
    presets: [
      ["babel-preset-expo", { jsxImportSource: "nativewind" }]
    ],
    plugins: [
      "nativewind/babel",  // ✅ Before reanimated plugin
      "react-native-reanimated/plugin",  // ✅ Must be last
    ],
  };
};
```

**Key Points:**
- `jsxImportSource: "nativewind"` is required in babel-preset-expo
- `nativewind/babel` must come before `react-native-reanimated/plugin`
- Reanimated plugin must always be last

---

## Styling Issues

### 7. Colors Not Working on View

**Symptoms:**
- Text color classes have no effect on View components
- `text-blue-500` doesn't change View color

**Root Cause:**
- React Native limitation - Views don't support text colors

**Solution:**

```typescript
// ❌ Wrong - View doesn't support text colors
<View className="text-blue-500">
  <Text>Content</Text>
</View>

// ✅ Correct - Apply colors to appropriate elements
<View className="bg-blue-500">
  <Text className="text-white">Content</Text>
</View>
```

**Remember:**
- Use `bg-*` for View backgrounds
- Use `text-*` for Text components
- Use `border-*` for borders

---

### 8. Dark Mode Not Switching

**Symptoms:**
- dark: classes don't activate
- Theme doesn't change with system settings
- Manual theme switching doesn't work

**Root Causes:**
- Preset not configured
- darkMode setting overridden
- useColorScheme not imported correctly

**Solutions:**

**Step 1**: Verify tailwind.config.js has preset:

```javascript
module.exports = {
  presets: [require("nativewind/preset")],  // ✅ Required for dark mode
  // Don't override darkMode setting - let NativeWind handle it
};
```

**Step 2**: For manual dark mode control:

```typescript
import { useColorScheme } from 'nativewind';  // ✅ From nativewind, not react-native

export function Component() {
  const { colorScheme, setColorScheme } = useColorScheme();

  return (
    <View className="bg-white dark:bg-gray-900">
      <Text className="text-black dark:text-white">
        Current: {colorScheme}
      </Text>
    </View>
  );
}
```

**Step 3**: Test on real device or change simulator appearance:
- iOS: Settings > Developer > Dark Appearance
- Android: Settings > Display > Dark theme

---

### 9. Responsive Breakpoints Not Working

**Symptoms:**
- sm:, md:, lg: variants have no effect
- Layout doesn't change at different screen sizes

**Root Cause:**
- Testing on same device size
- Content paths don't include files with breakpoint classes

**Solutions:**

**Step 1**: Test on multiple device sizes:

```bash
# iOS - different simulators
npx expo run:ios --device "iPhone SE"  # Small
npx expo run:ios --device "iPhone 15 Pro Max"  # Large
npx expo run:ios --device "iPad Pro"  # Tablet

# Android
npx expo run:android --device "Pixel_4"  # Small
npx expo run:android --device "Pixel_Tablet"  # Large
```

**Step 2**: Verify content paths include component files:

```javascript
// tailwind.config.js
module.exports = {
  content: [
    "./App.{js,jsx,ts,tsx}",
    "./app/**/*.{js,jsx,ts,tsx}",
    "./components/**/*.{js,jsx,ts,tsx}",  // ✅ Include all folders
  ],
};
```

**Step 3**: Verify breakpoints are defined:

```javascript
// Default breakpoints (from NativeWind preset)
screens: {
  'sm': '640px',
  'md': '768px',
  'lg': '1024px',
  'xl': '1280px',
  '2xl': '1536px',
}
```

---

### 10. Custom Colors Not Applying

**Symptoms:**
- Custom colors defined in tailwind.config.js don't work
- Only default Tailwind colors work

**Root Causes:**
- Colors in wrong section
- Metro cache not cleared after config change
- Color format incorrect

**Solutions:**

**Step 1**: Add custom colors to `theme.extend`:

```javascript
module.exports = {
  content: ["./app/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {  // ✅ Use extend to keep default colors
      colors: {
        primary: '#3b82f6',
        secondary: {
          50: '#f0f9ff',
          500: '#0ea5e9',
          900: '#0c4a6e',
        },
      },
    },
  },
};
```

**Step 2**: Restart Metro with cache clear:

```bash
npx expo start --clear
```

**Step 3**: Use the custom colors:

```typescript
<View className="bg-primary">
  <Text className="text-secondary-500">Custom colors</Text>
</View>
```

---

## Build & Deployment Issues

### 11. Web Build Fails

**Symptoms:**
- Error during web build
- CSS not loading on web
- Metro config errors for web

**Root Cause:**
- app.json not configured for Metro on web

**Solution:**

Add to `app.json`:

```json
{
  "expo": {
    "web": {
      "bundler": "metro"
    }
  }
}
```

**Then rebuild:**

```bash
npx expo start --web --clear
```

---

### 12. iOS Build Errors

**Symptoms:**
- Build fails on iOS with NativeWind errors
- Pod install issues

**Solutions:**

**Step 1**: Clear Pods cache:

```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

**Step 2**: Clean build folder:

```bash
cd ios
xcodebuild clean
cd ..
```

**Step 3**: Rebuild:

```bash
npx expo run:ios --clear
```

---

### 13. Android Build Errors

**Symptoms:**
- Gradle build fails
- JVM heap errors
- Metro bundler issues

**Solutions:**

**Step 1**: Increase JVM heap size in `android/gradle.properties`:

```properties
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=512m
```

**Step 2**: Clean Gradle cache:

```bash
cd android
./gradlew clean
cd ..
```

**Step 3**: Clear Metro cache and rebuild:

```bash
npx expo start --clear
npx expo run:android
```

---

## Performance Issues

### 14. Slow Initial Load

**Symptoms:**
- App takes long to load on first launch
- White screen for several seconds

**Root Cause:**
- Large CSS bundle
- Many Tailwind classes

**Solutions:**

**Step 1**: Minimize unused classes by tightening content paths:

```javascript
// tailwind.config.js
module.exports = {
  content: [
    "./app/**/*.{js,jsx,ts,tsx}",  // Only scan necessary directories
    "./components/**/*.{js,jsx,ts,tsx}",
    // Don't include node_modules or other large directories
  ],
};
```

**Step 2**: Use production builds for testing:

```bash
npx expo build:ios --release-channel production
npx expo build:android --release-channel production
```

**Step 3**: Consider code splitting for web:

```javascript
// For Expo Router - automatic code splitting
// No configuration needed
```

---

### 15. App Size Too Large

**Symptoms:**
- APK/IPA file size is large
- Slow downloads
- App store warnings

**Root Cause:**
- All Tailwind utilities included
- No tree-shaking

**Solution:**

**NativeWind includes tree-shaking automatically**. Ensure you're building for production:

```bash
# iOS production build
npx expo build:ios --release-channel production

# Android production build
npx expo build:android --release-channel production

# Or use EAS Build
eas build --platform ios --profile production
eas build --platform android --profile production
```

---

## TypeScript Issues

### 16. TypeScript Errors with className

**Symptoms:**
- Error: "Type 'string' is not assignable to type 'StyleProp<ViewStyle>'"
- className prop type errors

**Root Cause:**
- TypeScript types not loaded

**Solution:**

Create `nativewind-env.d.ts` at project root:

```typescript
/// <reference types="nativewind/types" />
```

Then restart TypeScript server.

---

### 17. Custom Colors TypeScript Errors

**Symptoms:**
- TypeScript doesn't recognize custom colors
- Autocomplete missing for custom colors

**Root Cause:**
- TypeScript doesn't know about custom colors in tailwind.config.js

**Solution:**

NativeWind v4 should automatically infer types. If not working:

**Step 1**: Ensure `nativewind-env.d.ts` exists:

```typescript
/// <reference types="nativewind/types" />
```

**Step 2**: Restart TypeScript server

**Step 3**: If still not working, use arbitrary values:

```typescript
<View className="bg-[#3b82f6]">  // Fallback for custom colors
```

---

## Integration Issues

### 18. Conflicts with Other Styling Libraries

**Symptoms:**
- Styles conflict with other libraries
- Unexpected styling behavior

**Root Cause:**
- Multiple styling systems competing

**Solution:**

**Choose one styling approach**:

```typescript
// ✅ Good - consistent NativeWind usage
<View className="p-4 bg-blue-500">
  <Text className="text-white">NativeWind</Text>
</View>

// ❌ Avoid - mixing styling approaches
<View className="p-4" style={{ backgroundColor: 'blue' }}>
  <Text style={{ color: 'white' }}>Mixed</Text>
</View>
```

If you must mix, use `className` for layout and `style` for dynamic values:

```typescript
<View className="p-4 rounded-lg">
  <View style={{ opacity: animatedValue }} />
</View>
```

---

### 19. Issues with React Navigation

**Symptoms:**
- Navigation styles not applying
- Header styling issues

**Solution:**

Use `className` on navigation components:

```typescript
import { Stack } from 'expo-router';

<Stack.Screen
  options={{
    headerStyle: {
      backgroundColor: '#1f2937',  // Use style for native props
    },
    headerTintColor: '#fff',
  }}
/>

// For custom headers, use className:
<Stack.Screen
  options={{
    header: () => (
      <View className="bg-gray-800 pt-12 pb-4 px-4">
        <Text className="text-white text-xl font-bold">Custom Header</Text>
      </View>
    ),
  }}
/>
```

---

## Debug Techniques

### 20. Debugging Styles

**Technique 1**: Visual debugging with borders:

```typescript
<View className="border-2 border-red-500">
  <Text>Debug this</Text>
</View>
```

**Technique 2**: Log color scheme:

```typescript
import { useColorScheme } from 'nativewind';

const { colorScheme } = useColorScheme();
console.log('Current scheme:', colorScheme);
```

**Technique 3**: Verify Tailwind compilation:

```bash
npx tailwindcss -i ./global.css -o ./output.css
cat output.css  # Check generated CSS
```

**Technique 4**: Use React DevTools:

```bash
npm install -g react-devtools
react-devtools
```

Then inspect components and their props.

---

## Getting Help

### Check Official Resources

1. **NativeWind Documentation**: https://www.nativewind.dev/
2. **GitHub Issues**: https://github.com/nativewind/nativewind/issues
3. **Discord Community**: Join NativeWind Discord
4. **Stack Overflow**: Tag [nativewind]

### When Asking for Help

Include:
1. NativeWind version: `npm list nativewind`
2. Expo SDK version: Check package.json
3. Platform (iOS/Android/Web)
4. Minimal reproduction code
5. Error messages (full stack trace)
6. Config files (babel.config.js, metro.config.js, tailwind.config.js)

---

## Quick Reference Checklist

When encountering issues, verify:

- [ ] `global.css` imported in root file
- [ ] `jsxImportSource: "nativewind"` in babel.config.js
- [ ] `nativewind/babel` plugin in babel.config.js
- [ ] `withNativeWind` wrapping Metro config
- [ ] `presets: [require("nativewind/preset")]` in tailwind.config.js
- [ ] Content paths include all component files
- [ ] Metro cache cleared: `npx expo start --clear`
- [ ] TypeScript server restarted
- [ ] Testing on correct platform/device
- [ ] Using latest NativeWind version (4.x.x)
