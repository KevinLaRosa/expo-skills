---
name: expo-ui-components
description: Native UI components with Expo UI - SwiftUI and Jetpack Compose primitives exposed to JavaScript for fully native interfaces
license: MIT
compatibility: "Requires: Expo SDK 50+, @expo/ui 0.2+"
---

# Expo UI Components

## Overview

Expo UI (`@expo/ui`) is a library that exposes native SwiftUI (iOS) and Jetpack Compose (Android) components directly to React Native, enabling you to build fully native interfaces without reimplementing UI in JavaScript. Instead of using JavaScript bridges, Expo UI provides direct access to platform-native components, delivering native performance, behavior, and capabilities while maintaining the React development model.

The library consists of two main modules:
- **@expo/ui/swift-ui** - SwiftUI components for iOS, macOS, and tvOS (beta)
- **@expo/ui/jetpack-compose** - Jetpack Compose components for Android (alpha)

**Current Status:**
- SwiftUI components: Beta (v0.2.0-beta.9)
- Jetpack Compose components: Alpha (breaking changes expected)
- Not available in Expo Go - requires development builds

## When to Use

**Use Expo UI when:**
- Building apps requiring truly native UI/UX that matches platform design guidelines
- Needing native performance for complex UI interactions
- Implementing platform-specific components (e.g., iOS sheets, Android chips)
- Creating apps with native accessibility requirements
- Requiring native keyboard handling and input behaviors
- Building apps where platform consistency is critical

**Avoid Expo UI when:**
- You need cross-platform UI consistency (use React Native components instead)
- Working within Expo Go constraints (development builds required)
- Building for web (not yet supported)
- API stability is critical (both modules are pre-1.0)
- You need extensive community support (ecosystem is still emerging)

## Workflow

### 1. Install Expo UI Package

```bash
npx expo install @expo/ui
```

Ensure you're using Expo SDK 50 or later. Verify your project supports development builds if not already configured.

### 2. Set Up Development Build

Since Expo UI is unavailable in Expo Go, create a development build:

```bash
npx expo prebuild
npx expo run:ios    # for iOS
npx expo run:android # for Android
```

### 3. Import Platform-Specific Components

Choose the appropriate module for your target platform:

```javascript
// For iOS/macOS/tvOS
import { Host, Button, VStack, Text } from '@expo/ui/swift-ui';

// For Android
import { Host, Button, TextInput } from '@expo/ui/jetpack-compose';
```

### 4. Wrap Components in Host Container

All Expo UI components must be wrapped in a `Host` component, which acts as a bridge between React Native and native rendering:

```javascript
import { Host, CircularProgress } from '@expo/ui/swift-ui';

function Example() {
  return (
    <Host matchContents>
      <CircularProgress />
    </Host>
  );
}
```

### 5. Use Native Layout Components

Use platform-native layout patterns instead of flexbox within Host:

```javascript
// SwiftUI - use VStack/HStack
<Host style={{ flex: 1 }}>
  <VStack spacing={8}>
    <Text>Title</Text>
    <Button onPress={handlePress}>Action</Button>
  </VStack>
</Host>

// Jetpack Compose - use Column/Row equivalents
<Host style={{ flex: 1 }}>
  {/* Use Compose layout components */}
</Host>
```

### 6. Apply Styling and Theming

Style the `Host` component with React Native styles, and use platform-specific styling for child components:

```javascript
<Host style={{ flex: 1, backgroundColor: '#f0f0f0' }}>
  <Button
    variant="bordered"
    color="#007AFF"
    onPress={handlePress}
  >
    Native Button
  </Button>
</Host>
```

Use `PlatformColor()` for system colors or hex values for custom colors.

### 7. Implement Event Handlers

Connect native component events to your React state:

```javascript
const [value, setValue] = useState('');
const [isOn, setIsOn] = useState(false);

<Host matchContents>
  <VStack spacing={12}>
    <TextField
      value={value}
      onValueChange={setValue}
      placeholder="Enter text"
    />
    <Switch
      value={isOn}
      onValueChange={setIsOn}
      variant="toggle"
    />
  </VStack>
</Host>
```

### 8. Test on Physical Devices

Test your native components on actual devices or simulators to verify native behavior:

```bash
# iOS
npx expo run:ios --device

# Android
npx expo run:android --device
```

## Guidelines

### Do

- **Do** wrap all Expo UI components in a `Host` container
- **Do** use native layout components (VStack/HStack) within SwiftUI contexts
- **Do** apply flexbox styles to the `Host` component itself for positioning
- **Do** use TypeScript to explore available props and APIs
- **Do** test on actual devices for accurate native behavior
- **Do** use `matchContents` prop on Host when the content should determine size
- **Do** maintain clear boundaries between React Native and Expo UI components
- **Do** leverage platform-specific variants (e.g., bordered buttons, wheel pickers)
- **Do** use PlatformColor() for system colors to respect dark mode
- **Do** check GitHub repository for latest component examples

### Don't

- **Don't** try to use Expo UI in Expo Go (requires development builds)
- **Don't** mix flexbox layout within SwiftUI/Compose component trees
- **Don't** expect cross-platform UI consistency (components are platform-specific)
- **Don't** rely on API stability in alpha/beta components
- **Don't** nest Host components unnecessarily
- **Don't** use web-specific styling approaches
- **Don't** assume all components work on tvOS (check platform compatibility)
- **Don't** ignore TypeScript warnings about component props
- **Don't** expect complete documentation coverage (types are primary reference)
- **Don't** use for production apps requiring extreme stability

## Examples

### SwiftUI Button with VStack Layout

```javascript
import { Host, Button, VStack, Text } from '@expo/ui/swift-ui';

function SwiftUIExample() {
  const handlePress = () => {
    console.log('Button pressed');
  };

  return (
    <Host style={{ flex: 1 }}>
      <VStack spacing={8}>
        <Text>Hello, SwiftUI!</Text>
        <Button
          variant="default"
          onPress={handlePress}
        >
          Click Me
        </Button>
      </VStack>
    </Host>
  );
}
```

### SwiftUI Form with Multiple Inputs

```javascript
import {
  Host,
  VStack,
  TextField,
  Switch,
  Slider,
  Button
} from '@expo/ui/swift-ui';
import { useState } from 'react';

function FormExample() {
  const [name, setName] = useState('');
  const [enabled, setEnabled] = useState(false);
  const [volume, setVolume] = useState(50);

  return (
    <Host style={{ flex: 1, padding: 16 }}>
      <VStack spacing={16}>
        <TextField
          value={name}
          onValueChange={setName}
          placeholder="Enter your name"
        />

        <Switch
          value={enabled}
          onValueChange={setEnabled}
          variant="toggle"
          label="Enable notifications"
        />

        <Slider
          value={volume}
          onValueChange={setVolume}
          minimumValue={0}
          maximumValue={100}
        />

        <Button onPress={() => console.log({ name, enabled, volume })}>
          Submit
        </Button>
      </VStack>
    </Host>
  );
}
```

### SwiftUI Color Picker

```javascript
import { Host, ColorPicker, VStack, Text } from '@expo/ui/swift-ui';
import { useState } from 'react';

function ColorPickerExample() {
  const [color, setColor] = useState('#FF0000');

  return (
    <Host style={{ flex: 1 }}>
      <VStack spacing={12}>
        <Text>Select a color:</Text>
        <ColorPicker
          color={color}
          onColorChange={setColor}
        />
        <Text>Selected: {color}</Text>
      </VStack>
    </Host>
  );
}
```

### Jetpack Compose Button

```javascript
import { Host, Button } from '@expo/ui/jetpack-compose';

function AndroidExample() {
  return (
    <Host style={{ flex: 1 }}>
      <Button
        variant="default"
        onPress={() => console.log('Android button pressed')}
      >
        Android Button
      </Button>
    </Host>
  );
}
```

### Jetpack Compose Chips

```javascript
import { Host, Chip } from '@expo/ui/jetpack-compose';
import { useState } from 'react';

function ChipExample() {
  const [selected, setSelected] = useState(false);

  return (
    <Host style={{ flex: 1 }}>
      <Chip
        variant="filter"
        selected={selected}
        onPress={() => setSelected(!selected)}
        label="Filter Option"
      />
    </Host>
  );
}
```

### SwiftUI List with Items

```javascript
import { Host, List } from '@expo/ui/swift-ui';

function ListExample() {
  const items = ['Item 1', 'Item 2', 'Item 3'];

  return (
    <Host style={{ flex: 1 }}>
      <List
        items={items}
        onItemSelect={(item) => console.log('Selected:', item)}
      />
    </Host>
  );
}
```

### SwiftUI Bottom Sheet

```javascript
import { Host, BottomSheet, Button, VStack } from '@expo/ui/swift-ui';
import { useState } from 'react';

function BottomSheetExample() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <Host style={{ flex: 1 }}>
      <VStack spacing={8}>
        <Button onPress={() => setIsOpen(true)}>
          Open Sheet
        </Button>

        <BottomSheet
          isOpen={isOpen}
          onClose={() => setIsOpen(false)}
        >
          <VStack spacing={12}>
            <Text>Sheet Content</Text>
            <Button onPress={() => setIsOpen(false)}>
              Close
            </Button>
          </VStack>
        </BottomSheet>
      </VStack>
    </Host>
  );
}
```

### Progress Indicators

```javascript
import {
  Host,
  VStack,
  CircularProgress,
  LinearProgress
} from '@expo/ui/swift-ui';

function ProgressExample() {
  return (
    <Host style={{ flex: 1 }}>
      <VStack spacing={16}>
        <CircularProgress value={0.7} />
        <LinearProgress value={0.5} />
      </VStack>
    </Host>
  );
}
```

## Resources

### Official Documentation
- [Expo UI Documentation](https://docs.expo.dev/versions/latest/sdk/ui/)
- [SwiftUI Components Reference](https://docs.expo.dev/versions/latest/sdk/ui/swift-ui/)
- [Jetpack Compose Components Reference](https://docs.expo.dev/versions/latest/sdk/ui/jetpack-compose/)
- [Building SwiftUI Apps with Expo UI Guide](https://docs.expo.dev/guides/expo-ui-swift-ui/)

### Package & Repository
- [NPM Package: @expo/ui](https://www.npmjs.com/package/@expo/ui)
- [GitHub Repository](https://github.com/expo/expo)
- [Native Component List Examples](https://github.com/expo/expo/tree/main/apps/native-component-list)

### Platform Documentation
- [Apple SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Android Jetpack Compose Documentation](https://developer.android.com/jetpack/compose)

## Tools & Commands

### Installation
```bash
# Install Expo UI package
npx expo install @expo/ui

# Verify installation
npm list @expo/ui
```

### Development Build
```bash
# Create development build
npx expo prebuild

# Run on iOS
npx expo run:ios

# Run on Android
npx expo run:android

# Run on specific device
npx expo run:ios --device
npx expo run:android --device
```

### Project Setup
```bash
# Create new Expo project
npx create-expo-app my-native-ui-app

# Navigate to project
cd my-native-ui-app

# Install Expo UI
npx expo install @expo/ui

# Start development server
npx expo start --dev-client
```

### Debugging
```bash
# Clear build cache
npx expo prebuild --clean

# View native logs (iOS)
npx expo run:ios --configuration Debug

# View native logs (Android)
npx expo run:android --variant debug
```

## Troubleshooting

### Host Component Not Rendering

**Problem:** SwiftUI/Compose components don't appear on screen.

**Solution:** Ensure all Expo UI components are wrapped in a `Host` component:

```javascript
// Wrong
<Button onPress={handlePress}>Click</Button>

// Correct
<Host matchContents>
  <Button onPress={handlePress}>Click</Button>
</Host>
```

### Development Build Required Error

**Problem:** "Expo UI is not available in Expo Go" error.

**Solution:** Create and run a development build:

```bash
npx expo prebuild
npx expo run:ios  # or run:android
```

### TypeScript Type Errors

**Problem:** Props not recognized or type errors.

**Solution:** Install TypeScript types and use IDE autocomplete:

```bash
npm install --save-dev @types/react @types/react-native
```

Rely on TypeScript IntelliSense to explore available props, as documentation may be incomplete.

### Components Not Working on tvOS

**Problem:** Some components fail on Apple TV.

**Solution:** Check component platform compatibility. Components like `ColorPicker`, `Slider`, and `Gauge` are iOS-only and don't support tvOS.

### Styling Not Applied

**Problem:** Styles don't work on child components.

**Solution:** Apply flexbox styles to the `Host` component, not to SwiftUI/Compose children:

```javascript
// Wrong
<Host>
  <VStack style={{ flex: 1 }}> {/* won't work */}
    <Button>Click</Button>
  </VStack>
</Host>

// Correct
<Host style={{ flex: 1 }}>
  <VStack spacing={8}>
    <Button>Click</Button>
  </VStack>
</Host>
```

### Breaking Changes After Update

**Problem:** Components break after updating @expo/ui.

**Solution:** The library is in alpha/beta and breaking changes are expected. Check:
- [Changelog](https://github.com/expo/expo/blob/main/packages/%40expo/ui/CHANGELOG.md)
- GitHub issues for migration guidance
- Pin to specific version: `npm install @expo/ui@0.2.0-beta.9`

### Layout Issues with matchContents

**Problem:** Components overlap or size incorrectly.

**Solution:** Use `matchContents` prop on Host when content should determine size:

```javascript
<Host matchContents>
  <Button>Auto-sized</Button>
</Host>
```

### Android Build Failures

**Problem:** Gradle build fails with Jetpack Compose errors.

**Solution:** Ensure your Android project uses compatible Kotlin and Compose versions:

```groovy
// android/build.gradle
buildscript {
    ext {
        kotlinVersion = '1.8.0' // or newer
    }
}
```

### Missing Component Methods

**Problem:** Expected props or methods don't exist.

**Solution:** Documentation may be incomplete. Use TypeScript to explore:

```typescript
import { Button } from '@expo/ui/swift-ui';

// Hover over Button in your IDE to see available props
<Button |  // cursor here shows all props
```

## Notes

- **Platform-Specific Development**: Expo UI embraces platform differences rather than abstracting them. Build separate UIs for iOS and Android when using these components.

- **Performance Benefits**: Native components render through UIHostingController (iOS) and Compose (Android), bypassing the JavaScript bridge for UI updates.

- **Active Development**: Both SwiftUI and Jetpack Compose modules are pre-1.0. Expect API changes and refer to TypeScript types as the primary documentation source.

- **Component Availability**: Not all SwiftUI components work on tvOS. Check individual component documentation for platform support.

- **Mixing Paradigms**: You can combine Expo UI with standard React Native components, but maintain clear boundaries using the Host component.

- **Theming Limitations**: Global theming is limited. Apply colors and styles per-component or through the Host container.

- **Web Support**: Not currently available. The library targets native platforms only (iOS, Android, macOS, tvOS).

- **Example Repository**: The most up-to-date usage examples are in the [native-component-list app](https://github.com/expo/expo/tree/main/apps/native-component-list) in the Expo monorepo.

- **Accessibility**: Native components inherit platform accessibility features automatically, providing better screen reader and assistive technology support.

- **State Management**: Use React state and props normally. Native components integrate seamlessly with React's state model.

- **Future Roadmap**: Android support is in alpha, and web support is planned. Monitor the GitHub repository for roadmap updates.
