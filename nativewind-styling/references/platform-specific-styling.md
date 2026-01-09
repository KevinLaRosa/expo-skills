# Platform-Specific Styling

## Overview

NativeWind v4 provides platform-specific utilities to style components differently across iOS, Android, and Web. This guide covers platform variants, conditional styling, and platform-specific design considerations for cross-platform React Native apps.

## Platform Variants

NativeWind includes four platform-specific variants:

- `ios:` - iOS only
- `android:` - Android only
- `web:` - Web only
- `native:` - iOS and Android (not web)

### Basic Usage

```typescript
import { View, Text } from 'react-native';

export function PlatformExample() {
  return (
    <View className="ios:pt-4 android:pt-2 web:pt-6">
      <Text className="native:text-base web:text-lg">
        Platform-aware styling
      </Text>
    </View>
  );
}
```

## Common Platform Differences

### Safe Area Handling

iOS and Android handle safe areas differently:

```typescript
import { View, Text } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';

export function SafeAreaPlatformExample() {
  return (
    // iOS: Accounts for notch and home indicator
    // Android: Status bar and navigation bar
    <SafeAreaView className="flex-1 ios:bg-white android:bg-gray-50 web:bg-gray-100">
      {/* Additional top padding on iOS for status bar */}
      <View className="ios:pt-2 android:pt-1 web:pt-0">
        <Text className="text-xl font-bold">Platform Safe Areas</Text>
      </View>
    </SafeAreaView>
  );
}
```

### Shadows and Elevation

iOS uses shadows, Android uses elevation:

```typescript
import { View, Text } from 'react-native';

export function ShadowExample() {
  return (
    <View className="
      bg-white rounded-lg p-4
      ios:shadow-lg
      android:elevation-4
      web:shadow-xl
    ">
      <Text>Platform-optimized shadows</Text>
    </View>
  );
}
```

**Shadow utilities:**

```typescript
// iOS shadow classes (no effect on Android)
className="ios:shadow-sm"    // Small shadow
className="ios:shadow"       // Default shadow
className="ios:shadow-md"    // Medium shadow
className="ios:shadow-lg"    // Large shadow
className="ios:shadow-xl"    // Extra large shadow
className="ios:shadow-2xl"   // 2XL shadow

// Android elevation (no effect on iOS)
className="android:elevation-1"  // Minimal elevation
className="android:elevation-2"  // Small elevation
className="android:elevation-4"  // Medium elevation
className="android:elevation-8"  // High elevation

// Web shadows work as normal Tailwind
className="web:shadow-lg"
```

### Typography

Platform-specific font rendering:

```typescript
import { View, Text } from 'react-native';

export function TypographyExample() {
  return (
    <View className="p-4">
      {/* iOS uses SF Pro, Android uses Roboto */}
      <Text className="
        text-lg
        ios:font-['SF-Pro-Text']
        android:font-['Roboto']
        web:font-sans
      ">
        Platform-native fonts
      </Text>

      {/* Font weights may render differently */}
      <Text className="
        ios:font-semibold
        android:font-bold
        web:font-semibold
      ">
        Adjusted font weights
      </Text>

      {/* Line height adjustments */}
      <Text className="
        ios:leading-tight
        android:leading-normal
        web:leading-relaxed
      ">
        Platform-specific line heights ensure readability
      </Text>
    </View>
  );
}
```

### Borders

Hairline borders on iOS:

```typescript
import { View, Text } from 'react-native';

export function BorderExample() {
  return (
    <View className="
      ios:border-[0.5px]
      android:border
      web:border
      border-gray-300
    ">
      <Text>iOS uses hairline border (0.5px)</Text>
    </View>
  );
}
```

### Padding and Spacing

Account for different navigation and status bar heights:

```typescript
import { View, Text } from 'react-native';

export function HeaderExample() {
  return (
    <View className="
      ios:pt-12
      android:pt-8
      web:pt-4
      px-4
      bg-white
    ">
      <Text className="text-2xl font-bold">Header</Text>
    </View>
  );
}
```

## Web-Only Features

### Hover States

Hover only works on web (requires pointer device):

```typescript
import { Pressable, Text } from 'react-native';

export function HoverExample() {
  return (
    <Pressable className="
      bg-blue-500 p-4 rounded-lg
      web:hover:bg-blue-600
      web:transition-colors web:duration-200
      active:opacity-80
    ">
      <Text className="text-white text-center">
        Hover effect on web only
      </Text>
    </Pressable>
  );
}
```

### Focus States

```typescript
import { TextInput } from 'react-native';

export function FocusExample() {
  return (
    <TextInput
      className="
        border-2 border-gray-300 rounded-lg px-4 py-2
        web:focus:border-blue-500
        web:focus:ring-2 web:focus:ring-blue-200
        web:outline-none
      "
      placeholder="Focus effect on web"
    />
  );
}
```

### Cursor

```typescript
<Pressable className="
  web:cursor-pointer
  web:hover:opacity-80
">
  <Text>Clickable (cursor changes on web)</Text>
</Pressable>

<TextInput className="
  web:cursor-text
  border border-gray-300 p-2 rounded
" />
```

### Scroll Behavior

```typescript
import { ScrollView } from 'react-native';

export function ScrollExample() {
  return (
    <ScrollView className="
      flex-1
      web:scroll-smooth
      web:snap-y web:snap-mandatory
    ">
      <View className="h-screen web:snap-start bg-blue-500" />
      <View className="h-screen web:snap-start bg-green-500" />
      <View className="h-screen web:snap-start bg-purple-500" />
    </ScrollView>
  );
}
```

## Platform-Specific Components

### Status Bar

```typescript
import { View, StatusBar, Platform } from 'react-native';

export function StatusBarExample() {
  return (
    <View className="flex-1">
      <StatusBar
        barStyle={Platform.OS === 'ios' ? 'dark-content' : 'light-content'}
        backgroundColor={Platform.OS === 'android' ? '#1f2937' : undefined}
      />

      <View className="
        ios:bg-white
        android:bg-gray-800
        web:bg-gray-50
        flex-1
      ">
        <Text>Platform-specific status bar</Text>
      </View>
    </View>
  );
}
```

### Navigation

```typescript
import { View, Text } from 'react-native';

export function NavBar() {
  return (
    <View className="
      ios:h-20 ios:pt-12
      android:h-14 android:pt-2
      web:h-16 web:pt-4
      px-4
      bg-white ios:bg-opacity-95
      ios:border-b ios:border-gray-200
      android:elevation-4
      web:shadow-md
    ">
      <Text className="text-lg font-bold">
        Platform Navigation
      </Text>
    </View>
  );
}
```

### Tab Bar

```typescript
import { View, Text, Pressable } from 'react-native';

export function TabBar() {
  return (
    <View className="
      flex-row
      ios:h-20 ios:pb-6
      android:h-16
      web:h-14
      bg-white
      ios:border-t ios:border-gray-200
      android:elevation-8
      web:shadow-top
    ">
      <Pressable className="flex-1 items-center justify-center">
        <Text className="ios:text-sm android:text-xs web:text-base">Home</Text>
      </Pressable>
      <Pressable className="flex-1 items-center justify-center">
        <Text className="ios:text-sm android:text-xs web:text-base">Profile</Text>
      </Pressable>
    </View>
  );
}
```

## Combining Platform and Other Variants

You can combine platform variants with responsive breakpoints and dark mode:

```typescript
import { View, Text } from 'react-native';

export function CombinedVariants() {
  return (
    <View className="
      p-4
      ios:pt-8 ios:dark:pt-12
      android:pt-4 android:dark:pt-6
      web:pt-2 web:dark:pt-4
      bg-white dark:bg-gray-900
      ios:sm:pt-12
      android:sm:pt-8
    ">
      <Text className="
        text-gray-900 dark:text-white
        ios:text-base ios:sm:text-lg
        android:text-sm android:sm:text-base
        web:text-lg web:sm:text-xl
      ">
        Platform + Responsive + Dark Mode
      </Text>
    </View>
  );
}
```

## Platform Detection in Code

For complex platform logic, use React Native's Platform API:

```typescript
import { View, Text, Platform } from 'react-native';

export function PlatformDetection() {
  return (
    <View className="p-4">
      <Text className="text-lg font-bold mb-2">
        Platform: {Platform.OS}
      </Text>

      {Platform.OS === 'ios' && (
        <Text className="text-blue-500">iOS-specific content</Text>
      )}

      {Platform.OS === 'android' && (
        <Text className="text-green-500">Android-specific content</Text>
      )}

      {Platform.OS === 'web' && (
        <Text className="text-purple-500">Web-specific content</Text>
      )}

      {/* Platform.select */}
      <Text className={Platform.select({
        ios: 'text-base',
        android: 'text-sm',
        web: 'text-lg',
        default: 'text-base',
      })}>
        Platform.select example
      </Text>
    </View>
  );
}
```

## Platform-Specific Layouts

### Card Component

```typescript
import { View, Text, Pressable } from 'react-native';

interface CardProps {
  title: string;
  description: string;
  onPress: () => void;
}

export function PlatformCard({ title, description, onPress }: CardProps) {
  return (
    <Pressable
      onPress={onPress}
      className="
        bg-white dark:bg-gray-800
        rounded-lg
        p-4
        mb-4
        ios:shadow-md
        android:elevation-2
        web:shadow-lg web:hover:shadow-xl
        web:transition-shadow web:duration-200
        active:opacity-90
      "
    >
      <Text className="
        text-lg font-bold
        text-gray-900 dark:text-white
        mb-2
        ios:tracking-tight
        android:tracking-normal
      ">
        {title}
      </Text>
      <Text className="
        text-gray-600 dark:text-gray-400
        ios:text-sm ios:leading-snug
        android:text-xs android:leading-normal
        web:text-base web:leading-relaxed
      ">
        {description}
      </Text>
    </Pressable>
  );
}
```

### Button Component

```typescript
import { Pressable, Text } from 'react-native';

interface ButtonProps {
  children: string;
  onPress: () => void;
  variant?: 'primary' | 'secondary';
}

export function PlatformButton({ children, onPress, variant = 'primary' }: ButtonProps) {
  return (
    <Pressable
      onPress={onPress}
      className={`
        px-6 py-3 rounded-lg
        ${variant === 'primary'
          ? 'bg-blue-500 ios:bg-blue-600 android:bg-blue-700'
          : 'bg-gray-500'
        }
        ios:shadow-sm
        android:elevation-2
        web:hover:opacity-90
        web:transition-opacity
        active:opacity-80
      `}
    >
      <Text className="
        text-white text-center font-semibold
        ios:text-base ios:tracking-tight
        android:text-sm android:tracking-normal android:uppercase
        web:text-lg
      ">
        {children}
      </Text>
    </Pressable>
  );
}
```

### Input Component

```typescript
import { View, Text, TextInput } from 'react-native';

interface InputProps {
  label: string;
  value: string;
  onChangeText: (text: string) => void;
  placeholder?: string;
}

export function PlatformInput({ label, value, onChangeText, placeholder }: InputProps) {
  return (
    <View className="mb-4">
      <Text className="
        text-gray-700 dark:text-gray-300
        mb-2
        ios:text-sm ios:font-semibold
        android:text-xs android:font-bold android:uppercase
        web:text-base web:font-medium
      ">
        {label}
      </Text>
      <TextInput
        value={value}
        onChangeText={onChangeText}
        placeholder={placeholder}
        placeholderTextColor="#9ca3af"
        className="
          bg-white dark:bg-gray-800
          border border-gray-300 dark:border-gray-600
          rounded-lg
          px-4
          ios:py-3 ios:text-base
          android:py-2 android:text-sm
          web:py-3 web:text-lg
          text-gray-900 dark:text-white
          web:focus:border-blue-500
          web:focus:ring-2 web:focus:ring-blue-200
          web:outline-none
        "
      />
    </View>
  );
}
```

## Testing Platform-Specific Styles

### iOS Simulator

```bash
# Run on iOS
npx expo run:ios

# Or specific device
npx expo run:ios --device "iPhone 15 Pro"
```

### Android Emulator

```bash
# Run on Android
npx expo run:android

# Or specific device
npx expo run:android --device "Pixel_7_API_34"
```

### Web

```bash
# Run on web
npx expo start --web

# Or
npm run web
```

### Testing All Platforms

```bash
# Build for all platforms
npx expo build:ios
npx expo build:android
npx expo build:web
```

## Best Practices

### 1. Test on All Target Platforms

Always test your app on iOS, Android, and web (if applicable) to ensure styles render correctly.

### 2. Respect Platform Guidelines

Follow Apple's Human Interface Guidelines (iOS) and Material Design (Android):

```typescript
// iOS: Rounded corners, subtle shadows
<View className="ios:rounded-xl ios:shadow-sm" />

// Android: Elevation, material ripple effects
<View className="android:rounded-lg android:elevation-4" />
```

### 3. Avoid Overusing Platform Variants

Only use platform variants when necessary. Most styles should work across all platforms:

```typescript
// ✅ Good - only differs where needed
<View className="p-4 ios:shadow-lg android:elevation-4">

// ❌ Bad - unnecessarily platform-specific
<View className="ios:p-4 android:p-4 web:p-4">
```

### 4. Use Native-First Approach

Leverage `native:` for iOS+Android shared styles:

```typescript
// ✅ Good - native: for iOS+Android
<Text className="native:text-base web:text-lg">

// ❌ Verbose - repeating for ios and android
<Text className="ios:text-base android:text-base web:text-lg">
```

### 5. Consider Accessibility

Ensure touch targets are adequate on mobile:

```typescript
<Pressable className="
  native:p-4 native:min-h-[44px]
  web:p-2 web:min-h-[32px]
">
  <Text>Accessible touch target</Text>
</Pressable>
```

## Common Patterns

### Modal Presentation

```typescript
import { View, Text, Modal, Pressable } from 'react-native';

export function PlatformModal({ visible, onClose, children }) {
  return (
    <Modal
      visible={visible}
      animationType={Platform.OS === 'ios' ? 'slide' : 'fade'}
      transparent={true}
    >
      <View className="flex-1 justify-end ios:justify-center bg-black/50">
        <View className="
          bg-white dark:bg-gray-900
          ios:rounded-t-3xl ios:h-3/4
          android:rounded-t-2xl android:h-4/5
          web:rounded-lg web:h-auto web:max-w-lg web:mx-auto web:my-8
          p-6
        ">
          {children}
          <Pressable
            onPress={onClose}
            className="
              mt-4 p-4 rounded-lg
              bg-gray-200 dark:bg-gray-700
            "
          >
            <Text className="text-center font-semibold">Close</Text>
          </Pressable>
        </View>
      </View>
    </Modal>
  );
}
```

### List Separator

```typescript
import { View } from 'react-native';

export function ListSeparator() {
  return (
    <View className="
      ios:h-[0.5px] ios:bg-gray-200 ios:ml-4
      android:h-[1px] android:bg-gray-300
      web:h-[1px] web:bg-gray-200 web:mx-4
    " />
  );
}
```

## Resources

- [React Native Platform Docs](https://reactnative.dev/docs/platform)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Material Design Guidelines](https://m3.material.io/)
- [NativeWind Platform Variants](https://www.nativewind.dev/docs/core-concepts/differences)
