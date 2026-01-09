# Responsive Design & Breakpoints

## Overview

NativeWind v4 brings responsive design to React Native with Tailwind CSS breakpoints. This guide covers mobile-first responsive patterns, custom breakpoints, and best practices for building adaptive UIs across phone, tablet, and web platforms.

## Default Breakpoints

NativeWind uses Tailwind CSS's default breakpoint system:

```javascript
// Default breakpoints (from NativeWind preset)
{
  'sm': '640px',   // Small tablets, large phones (landscape)
  'md': '768px',   // Tablets
  'lg': '1024px',  // Laptops, desktops
  'xl': '1280px',  // Large desktops
  '2xl': '1536px', // Extra large screens
}
```

## Mobile-First Approach

NativeWind follows Tailwind's mobile-first philosophy: unprefixed utilities apply to all screen sizes, then use breakpoints to override for larger screens.

```typescript
import { View, Text } from 'react-native';

export function MobileFirstExample() {
  return (
    // Mobile: full width
    // Tablet (sm): 1/2 width
    // Desktop (lg): 1/3 width
    <View className="w-full sm:w-1/2 lg:w-1/3">
      <Text className="text-sm sm:text-base lg:text-lg">
        Scales up from mobile
      </Text>
    </View>
  );
}
```

**How it works:**
1. `w-full` applies to all screen sizes (mobile default)
2. `sm:w-1/2` overrides at 640px and above
3. `lg:w-1/3` overrides at 1024px and above

## Responsive Width & Height

### Container Widths

```typescript
import { View, Text, ScrollView } from 'react-native';

export function ResponsiveContainers() {
  return (
    <ScrollView className="flex-1">
      {/* Full width on mobile, constrained on larger screens */}
      <View className="w-full sm:w-11/12 md:w-3/4 lg:w-2/3 xl:w-1/2 mx-auto p-4">
        <Text className="text-lg font-bold">
          Responsive Container
        </Text>
        <Text className="text-gray-600 mt-2">
          This container adapts to screen size
        </Text>
      </View>

      {/* Max-width approach */}
      <View className="w-full max-w-screen-sm md:max-w-screen-md lg:max-w-screen-lg mx-auto p-4">
        <Text>Max-width container</Text>
      </View>
    </ScrollView>
  );
}
```

### Grid Layouts

```typescript
import { View, Text } from 'react-native';

export function ResponsiveGrid() {
  const items = Array.from({ length: 12 }, (_, i) => i + 1);

  return (
    <View className="flex-1 p-4">
      <View className="flex-row flex-wrap -mx-2">
        {items.map((item) => (
          <View
            key={item}
            // Mobile: 1 column (full width)
            // Small: 2 columns (1/2 width)
            // Medium: 3 columns (1/3 width)
            // Large: 4 columns (1/4 width)
            className="w-full sm:w-1/2 md:w-1/3 lg:w-1/4 p-2"
          >
            <View className="bg-blue-500 p-4 rounded-lg">
              <Text className="text-white text-center">Item {item}</Text>
            </View>
          </View>
        ))}
      </View>
    </View>
  );
}
```

## Responsive Text

### Text Size

```typescript
import { View, Text } from 'react-native';

export function ResponsiveText() {
  return (
    <View className="p-4">
      {/* Heading */}
      <Text className="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold mb-4">
        Responsive Heading
      </Text>

      {/* Body text */}
      <Text className="text-sm sm:text-base md:text-lg leading-relaxed">
        This paragraph text scales appropriately for different screen sizes,
        ensuring optimal readability across devices.
      </Text>

      {/* Caption */}
      <Text className="text-xs sm:text-sm text-gray-600 mt-2">
        Small caption text
      </Text>
    </View>
  );
}
```

### Line Height & Letter Spacing

```typescript
<Text className="
  text-base sm:text-lg md:text-xl
  leading-normal sm:leading-relaxed md:leading-loose
  tracking-tight sm:tracking-normal
">
  Responsive typography with adjustable spacing
</Text>
```

## Responsive Spacing

### Padding & Margin

```typescript
import { View, Text } from 'react-native';

export function ResponsiveSpacing() {
  return (
    <View className="
      p-4 sm:p-6 md:p-8 lg:p-12
      mx-auto
    ">
      <Text className="
        mb-2 sm:mb-4 md:mb-6
        text-lg sm:text-xl md:text-2xl
      ">
        Responsive spacing
      </Text>

      {/* Gap between flex items */}
      <View className="flex-row gap-2 sm:gap-4 md:gap-6">
        <View className="flex-1 bg-blue-500 p-2 sm:p-3 md:p-4">
          <Text className="text-white">Item 1</Text>
        </View>
        <View className="flex-1 bg-blue-500 p-2 sm:p-3 md:p-4">
          <Text className="text-white">Item 2</Text>
        </View>
      </View>
    </View>
  );
}
```

## Responsive Visibility

Show or hide elements at specific breakpoints:

```typescript
import { View, Text } from 'react-native';

export function ResponsiveVisibility() {
  return (
    <View className="flex-1 p-4">
      {/* Hidden on mobile, visible on sm and up */}
      <View className="hidden sm:block bg-blue-500 p-4 rounded-lg mb-4">
        <Text className="text-white">Visible on tablets and larger</Text>
      </View>

      {/* Visible on mobile, hidden on md and up */}
      <View className="block md:hidden bg-green-500 p-4 rounded-lg mb-4">
        <Text className="text-white">Mobile-only content</Text>
      </View>

      {/* Visible only on large screens */}
      <View className="hidden lg:block bg-purple-500 p-4 rounded-lg">
        <Text className="text-white">Desktop-only sidebar</Text>
      </View>
    </View>
  );
}
```

## Responsive Layouts

### Sidebar Layout

```typescript
import { View, Text, ScrollView } from 'react-native';

export function ResponsiveSidebarLayout() {
  return (
    <View className="flex-1">
      <ScrollView className="flex-1">
        <View className="flex-row">
          {/* Sidebar - full width on mobile, fixed width on desktop */}
          <View className="
            w-full md:w-64
            bg-gray-100 dark:bg-gray-800
            p-4
            md:border-r md:border-gray-200 dark:md:border-gray-700
          ">
            <Text className="font-bold text-lg mb-4">Sidebar</Text>
            <Text>Navigation items...</Text>
          </View>

          {/* Main content */}
          <View className="flex-1 p-4">
            <Text className="text-2xl font-bold mb-4">Main Content</Text>
            <Text>Your content here...</Text>
          </View>
        </View>
      </ScrollView>
    </View>
  );
}
```

### Card Grid with Responsive Columns

```typescript
import { View, Text, ScrollView } from 'react-native';

export function ResponsiveCardGrid() {
  const cards = Array.from({ length: 8 }, (_, i) => ({
    id: i + 1,
    title: `Card ${i + 1}`,
    description: 'Card description text',
  }));

  return (
    <ScrollView className="flex-1 bg-gray-50 dark:bg-gray-900">
      <View className="p-4">
        <View className="flex-row flex-wrap -mx-2">
          {cards.map((card) => (
            <View
              key={card.id}
              className="
                w-full sm:w-1/2 lg:w-1/3 xl:w-1/4
                p-2
              "
            >
              <View className="
                bg-white dark:bg-gray-800
                rounded-xl shadow-lg
                p-4 sm:p-6
                h-full
              ">
                <Text className="
                  text-lg sm:text-xl font-bold
                  text-gray-900 dark:text-white
                  mb-2
                ">
                  {card.title}
                </Text>
                <Text className="
                  text-sm sm:text-base
                  text-gray-600 dark:text-gray-400
                ">
                  {card.description}
                </Text>
              </View>
            </View>
          ))}
        </View>
      </View>
    </ScrollView>
  );
}
```

## Custom Breakpoints

Customize breakpoints in `tailwind.config.js`:

```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./app/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],
  theme: {
    screens: {
      // Override default breakpoints
      'sm': '640px',
      'md': '768px',
      'lg': '1024px',
      'xl': '1280px',
      '2xl': '1536px',

      // Add custom breakpoints
      'tablet': '640px',
      'laptop': '1024px',
      'desktop': '1280px',

      // Min-width queries
      'xs': '475px',

      // Max-width queries (use sparingly)
      'max-sm': { 'max': '639px' },
      'max-md': { 'max': '767px' },
    },
  },
};
```

**Usage:**

```typescript
<View className="w-full tablet:w-1/2 laptop:w-1/3 desktop:w-1/4">
  <Text>Custom breakpoints</Text>
</View>
```

## Arbitrary Values

Use arbitrary values for precise responsive control:

```typescript
import { View, Text } from 'react-native';

export function ArbitraryResponsive() {
  return (
    <View className="
      w-[90%] sm:w-[600px] md:w-[750px] lg:w-[900px]
      mx-auto
    ">
      <Text className="text-[14px] sm:text-[16px] md:text-[18px]">
        Precise responsive sizes
      </Text>

      <View className="
        p-[12px] sm:p-[16px] md:p-[24px]
        gap-[8px] sm:gap-[12px] md:gap-[16px]
      ">
        <Text>Content with arbitrary spacing</Text>
      </View>
    </View>
  );
}
```

## Responsive Images

```typescript
import { View, Image } from 'react-native';

export function ResponsiveImage() {
  return (
    <View className="p-4">
      {/* Responsive image container */}
      <View className="
        w-full sm:w-3/4 md:w-1/2 lg:w-1/3
        mx-auto
      ">
        <Image
          source={{ uri: 'https://example.com/image.jpg' }}
          className="
            w-full
            h-48 sm:h-64 md:h-80
            rounded-lg
          "
          resizeMode="cover"
        />
      </View>

      {/* Aspect ratio maintained */}
      <View className="
        w-full sm:w-3/4 md:w-1/2
        aspect-square sm:aspect-video
        mx-auto mt-4
      ">
        <Image
          source={{ uri: 'https://example.com/image.jpg' }}
          className="w-full h-full rounded-lg"
          resizeMode="cover"
        />
      </View>
    </View>
  );
}
```

## Responsive Forms

```typescript
import { View, Text, TextInput, Pressable } from 'react-native';

export function ResponsiveForm() {
  return (
    <View className="
      w-full sm:w-3/4 md:w-2/3 lg:w-1/2
      mx-auto
      p-4 sm:p-6 md:p-8
    ">
      <Text className="
        text-2xl sm:text-3xl font-bold
        text-gray-900 dark:text-white
        mb-4 sm:mb-6
      ">
        Contact Form
      </Text>

      {/* Form fields */}
      <View className="space-y-4">
        <View>
          <Text className="
            text-sm sm:text-base font-medium
            text-gray-700 dark:text-gray-300
            mb-2
          ">
            Name
          </Text>
          <TextInput
            className="
              bg-white dark:bg-gray-800
              border border-gray-300 dark:border-gray-600
              rounded-lg
              px-3 sm:px-4
              py-2 sm:py-3
              text-base sm:text-lg
              text-gray-900 dark:text-white
            "
            placeholder="Your name"
            placeholderTextColor="#9ca3af"
          />
        </View>

        <View>
          <Text className="
            text-sm sm:text-base font-medium
            text-gray-700 dark:text-gray-300
            mb-2
          ">
            Email
          </Text>
          <TextInput
            className="
              bg-white dark:bg-gray-800
              border border-gray-300 dark:border-gray-600
              rounded-lg
              px-3 sm:px-4
              py-2 sm:py-3
              text-base sm:text-lg
              text-gray-900 dark:text-white
            "
            placeholder="your@email.com"
            placeholderTextColor="#9ca3af"
            keyboardType="email-address"
          />
        </View>

        <Pressable className="
          bg-blue-500 active:bg-blue-600
          rounded-lg
          px-4 sm:px-6
          py-3 sm:py-4
          mt-2
        ">
          <Text className="
            text-white text-center font-semibold
            text-base sm:text-lg
          ">
            Submit
          </Text>
        </Pressable>
      </View>
    </View>
  );
}
```

## Performance Considerations

### Avoid Layout Thrashing

```typescript
// ✅ Good - classes defined statically
<View className="w-full sm:w-1/2 md:w-1/3">
  <Text>Static responsive classes</Text>
</View>

// ❌ Bad - dynamic class generation
const screenSize = useScreenSize();
<View className={`w-${screenSize === 'sm' ? '1/2' : 'full'}`}>
  <Text>Dynamic classes (avoid)</Text>
</View>
```

### Use FlatList for Long Lists

```typescript
import { FlatList, View, Text } from 'react-native';

export function ResponsiveList() {
  const data = Array.from({ length: 100 }, (_, i) => ({ id: i, title: `Item ${i}` }));

  return (
    <FlatList
      data={data}
      numColumns={1} // You can't dynamically change numColumns
      renderItem={({ item }) => (
        <View className="w-full sm:w-1/2 md:w-1/3 p-2">
          <View className="bg-white dark:bg-gray-800 p-4 rounded-lg">
            <Text className="text-gray-900 dark:text-white">{item.title}</Text>
          </View>
        </View>
      )}
      keyExtractor={(item) => item.id.toString()}
      contentContainerClassName="flex-row flex-wrap"
    />
  );
}
```

## Testing Responsive Layouts

### React Native

React Native doesn't have true media queries - breakpoints are based on window dimensions. Test on:

1. **Physical devices**: iPhone, iPad, Android phones/tablets
2. **Simulators**: Various device sizes
3. **Responsive testing**: Resize window on web

### Getting Screen Dimensions

```typescript
import { Dimensions, View, Text } from 'react-native';
import { useState, useEffect } from 'react';

export function ScreenInfo() {
  const [dimensions, setDimensions] = useState(Dimensions.get('window'));

  useEffect(() => {
    const subscription = Dimensions.addEventListener('change', ({ window }) => {
      setDimensions(window);
    });

    return () => subscription?.remove();
  }, []);

  return (
    <View className="p-4 bg-gray-100 dark:bg-gray-800">
      <Text className="text-gray-900 dark:text-white font-mono">
        Width: {dimensions.width.toFixed(0)}px
      </Text>
      <Text className="text-gray-900 dark:text-white font-mono">
        Height: {dimensions.height.toFixed(0)}px
      </Text>
    </View>
  );
}
```

## Best Practices

### 1. Start Mobile-First

Design for mobile, then enhance for larger screens:

```typescript
// ✅ Good - mobile first
<View className="w-full sm:w-1/2 lg:w-1/3">

// ❌ Bad - desktop first
<View className="w-1/3 lg:w-1/2 sm:w-full">
```

### 2. Use Consistent Breakpoint Increments

```typescript
// ✅ Good - logical progression
<Text className="text-sm sm:text-base md:text-lg lg:text-xl">

// ❌ Confusing - skips sizes
<Text className="text-xs md:text-2xl">
```

### 3. Test on Real Devices

Simulators don't perfectly represent real-world usage. Test on:
- Small phones (iPhone SE, older Android devices)
- Large phones (iPhone Pro Max, Android flagship)
- Tablets (iPad, Android tablets)
- Web browsers (desktop and mobile)

### 4. Consider Touch Targets

Ensure interactive elements are large enough on mobile:

```typescript
// ✅ Good - adequate touch target
<Pressable className="p-4 sm:p-3 md:p-2">

// ❌ Bad - too small on mobile
<Pressable className="p-1 sm:p-3 md:p-4">
```

### 5. Use Gap Instead of Negative Margins

```typescript
// ✅ Good - gap utility
<View className="flex-row gap-4">

// ❌ Avoid - negative margins for spacing
<View className="flex-row -mx-2">
  <View className="px-2">
```

## Resources

- [NativeWind Responsive Design Docs](https://www.nativewind.dev/docs/core-concepts/responsive-design)
- [Tailwind CSS Responsive Design](https://tailwindcss.com/docs/responsive-design)
- [Tailwind CSS Screens Configuration](https://tailwindcss.com/docs/screens)
- [React Native Dimensions API](https://reactnative.dev/docs/dimensions)
