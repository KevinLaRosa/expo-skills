# Theming and Customization Reference

Comprehensive guide to theming and customization in Gluestack UI v2. Learn how to customize design tokens, implement dark mode, and create custom themes.

## Design Tokens

Design tokens are the core building blocks of Gluestack UI's theming system. They provide consistent values for colors, spacing, typography, and more.

### Color Tokens

```typescript
// Using color tokens in components
<Box bg="$primary500">
  <Text color="$white">Primary colored box</Text>
</Box>

// Common color scales (50-900)
<Box bg="$blue50">Lightest blue</Box>
<Box bg="$blue500">Medium blue</Box>
<Box bg="$blue900">Darkest blue</Box>

// Semantic colors
<Box bg="$success">Success background</Box>
<Box bg="$error">Error background</Box>
<Box bg="$warning">Warning background</Box>
<Box bg="$info">Info background</Box>
```

### Available Color Scales

```typescript
// Grayscale
$gray50, $gray100, $gray200, $gray300, $gray400, $gray500,
$gray600, $gray700, $gray800, $gray900

// Primary colors
$blue50 → $blue900
$green50 → $green900
$red50 → $red900
$yellow50 → $yellow900
$purple50 → $purple900
$pink50 → $pink900
$indigo50 → $indigo900
$teal50 → $teal900
$orange50 → $orange900

// Special colors
$white, $black
$transparent
```

### Spacing Tokens

```typescript
// Spacing scale (0-20)
<Box p="$0">No padding</Box>
<Box p="$1">4px padding</Box>
<Box p="$2">8px padding</Box>
<Box p="$4">16px padding</Box>
<Box p="$8">32px padding</Box>
<Box p="$16">64px padding</Box>

// Special spacing
<Box p="$px">1px</Box>
<Box p="$full">100%</Box>

// Directional spacing
<Box px="$4" py="$2">Horizontal and vertical</Box>
<Box pt="$4" pb="$2" pl="$3" pr="$3">All sides</Box>
```

### Typography Tokens

```typescript
// Font sizes
<Text fontSize="$xs">Extra small (12px)</Text>
<Text fontSize="$sm">Small (14px)</Text>
<Text fontSize="$md">Medium (16px)</Text>
<Text fontSize="$lg">Large (18px)</Text>
<Text fontSize="$xl">Extra large (20px)</Text>
<Text fontSize="$2xl">2X large (24px)</Text>
<Text fontSize="$3xl">3X large (30px)</Text>
<Text fontSize="$4xl">4X large (36px)</Text>
<Text fontSize="$5xl">5X large (48px)</Text>

// Font weights
<Text fontWeight="$light">Light (300)</Text>
<Text fontWeight="$normal">Normal (400)</Text>
<Text fontWeight="$medium">Medium (500)</Text>
<Text fontWeight="$semibold">Semibold (600)</Text>
<Text fontWeight="$bold">Bold (700)</Text>

// Line heights
<Text lineHeight="$xs">Tight</Text>
<Text lineHeight="$sm">Snug</Text>
<Text lineHeight="$md">Normal</Text>
<Text lineHeight="$lg">Relaxed</Text>
<Text lineHeight="$xl">Loose</Text>
```

### Border Radius Tokens

```typescript
<Box borderRadius="$none">No radius (0)</Box>
<Box borderRadius="$xs">2px</Box>
<Box borderRadius="$sm">4px</Box>
<Box borderRadius="$md">6px</Box>
<Box borderRadius="$lg">8px</Box>
<Box borderRadius="$xl">12px</Box>
<Box borderRadius="$2xl">16px</Box>
<Box borderRadius="$3xl">24px</Box>
<Box borderRadius="$full">9999px (circle/pill)</Box>
```

### Shadow Tokens

```typescript
<Box shadowColor="$black" shadowOffset={{width: 0, height: 1}} shadowOpacity={0.1} shadowRadius="$sm">
  <Text>Small shadow</Text>
</Box>

<Box shadowColor="$black" shadowOffset={{width: 0, height: 2}} shadowOpacity={0.15} shadowRadius="$md">
  <Text>Medium shadow</Text>
</Box>

<Box shadowColor="$black" shadowOffset={{width: 0, height: 4}} shadowOpacity={0.2} shadowRadius="$lg">
  <Text>Large shadow</Text>
</Box>
```

## Dark Mode

Gluestack UI provides built-in dark mode support with automatic system detection.

### Enable Dark Mode

```typescript
// app/_layout.tsx or App.tsx
import { GluestackUIProvider } from '@/components/ui/gluestack-ui-provider';
import { useColorScheme } from 'react-native';

export default function RootLayout() {
  const colorScheme = useColorScheme();

  return (
    <GluestackUIProvider mode={colorScheme === 'dark' ? 'dark' : 'light'}>
      {/* Your app */}
    </GluestackUIProvider>
  );
}
```

### Manual Dark Mode Toggle

```typescript
import { useState } from 'react';
import { GluestackUIProvider } from '@/components/ui/gluestack-ui-provider';

function App() {
  const [colorMode, setColorMode] = useState<'light' | 'dark'>('light');

  const toggleColorMode = () => {
    setColorMode((prev) => (prev === 'light' ? 'dark' : 'light'));
  };

  return (
    <GluestackUIProvider mode={colorMode}>
      <YourApp toggleColorMode={toggleColorMode} />
    </GluestackUIProvider>
  );
}
```

### Dark Mode with Storage Persistence

```typescript
import { useEffect, useState } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { GluestackUIProvider } from '@/components/ui/gluestack-ui-provider';

function App() {
  const [colorMode, setColorMode] = useState<'light' | 'dark'>('light');

  useEffect(() => {
    // Load saved preference
    AsyncStorage.getItem('colorMode').then((saved) => {
      if (saved) setColorMode(saved as 'light' | 'dark');
    });
  }, []);

  const toggleColorMode = async () => {
    const newMode = colorMode === 'light' ? 'dark' : 'light';
    setColorMode(newMode);
    await AsyncStorage.setItem('colorMode', newMode);
  };

  return (
    <GluestackUIProvider mode={colorMode}>
      <YourApp toggleColorMode={toggleColorMode} />
    </GluestackUIProvider>
  );
}
```

### Dark Mode Aware Components

```typescript
// Using _dark prop for dark mode specific styles
<Box
  bg="$white"
  _dark={{
    bg: '$gray900',
  }}
>
  <Text
    color="$gray900"
    _dark={{
      color: '$white',
    }}
  >
    This text adapts to dark mode
  </Text>
</Box>
```

### useColorMode Hook

```typescript
import { useColorMode } from '@/components/ui/gluestack-ui-provider';

function ThemeToggle() {
  const { colorMode, toggleColorMode } = useColorMode();

  return (
    <Button onPress={toggleColorMode}>
      <ButtonIcon as={colorMode === 'dark' ? SunIcon : MoonIcon} />
      <ButtonText>{colorMode === 'dark' ? 'Light Mode' : 'Dark Mode'}</ButtonText>
    </Button>
  );
}
```

## Custom Theme Configuration

### Create Custom Config

```typescript
// config/gluestack-ui.config.ts
import { createConfig } from '@gluestack-ui/themed';

export const config = createConfig({
  tokens: {
    colors: {
      // Override default colors
      primary0: '#E6F2FF',
      primary50: '#CCE5FF',
      primary100: '#99CCFF',
      primary200: '#66B2FF',
      primary300: '#3399FF',
      primary400: '#007FFF',
      primary500: '#0066CC', // Your brand primary
      primary600: '#0052A3',
      primary700: '#003D7A',
      primary800: '#002952',
      primary900: '#001429',

      // Add custom colors
      brand: '#FF6B6B',
      brandLight: '#FFE5E5',
      brandDark: '#CC5656',
    },
    space: {
      // Customize spacing
      xs: 4,
      sm: 8,
      md: 16,
      lg: 24,
      xl: 32,
      '2xl': 48,
    },
    fontSizes: {
      // Customize font sizes
      xs: 12,
      sm: 14,
      md: 16,
      lg: 18,
      xl: 20,
      '2xl': 24,
      '3xl': 30,
      '4xl': 36,
    },
    fonts: {
      // Custom fonts
      heading: 'Inter-Bold',
      body: 'Inter-Regular',
      mono: 'Menlo',
    },
  },
  globalStyle: {
    // Global styles
    body: {
      bg: '$backgroundLight0',
      _dark: {
        bg: '$backgroundDark950',
      },
    },
  },
});

export type Config = typeof config;

declare module '@gluestack-ui/themed' {
  interface ICustomConfig extends Config {}
}
```

### Use Custom Config

```typescript
// app/_layout.tsx
import { GluestackUIProvider } from '@/components/ui/gluestack-ui-provider';
import { config } from '@/config/gluestack-ui.config';

export default function RootLayout() {
  return (
    <GluestackUIProvider config={config}>
      {/* Your app */}
    </GluestackUIProvider>
  );
}
```

## Component-Level Customization

### Override Component Styles

```typescript
// Customize Button component
<Button
  bg="$brand"
  borderRadius="$full"
  px="$8"
  py="$4"
  _hover={{
    bg: '$brandDark',
  }}
  _pressed={{
    bg: '$brandDark',
    opacity: 0.8,
  }}
>
  <ButtonText fontWeight="$bold" fontSize="$lg">
    Custom Button
  </ButtonText>
</Button>
```

### Create Styled Component Variants

```typescript
// components/ui/custom-button.tsx
import { styled } from '@gluestack-style/react';
import { Button } from '@/components/ui/button';

export const CustomButton = styled(Button, {
  bg: '$brand',
  borderRadius: '$full',
  px: '$8',
  py: '$4',

  variants: {
    size: {
      sm: {
        px: '$4',
        py: '$2',
      },
      md: {
        px: '$6',
        py: '$3',
      },
      lg: {
        px: '$8',
        py: '$4',
      },
    },
    variant: {
      solid: {
        bg: '$brand',
      },
      outline: {
        bg: '$transparent',
        borderWidth: '$2',
        borderColor: '$brand',
      },
      ghost: {
        bg: '$transparent',
      },
    },
  },

  defaultVariants: {
    size: 'md',
    variant: 'solid',
  },

  _hover: {
    opacity: 0.8,
  },

  _pressed: {
    opacity: 0.6,
  },
});

// Usage
<CustomButton variant="outline" size="lg">
  <ButtonText>Custom Styled Button</ButtonText>
</CustomButton>
```

### Create Reusable Theme Components

```typescript
// components/themed/Card.tsx
import { Box } from '@/components/ui/box';
import { styled } from '@gluestack-style/react';

export const ThemedCard = styled(Box, {
  bg: '$white',
  borderRadius: '$lg',
  p: '$4',
  borderWidth: '$1',
  borderColor: '$gray200',

  _dark: {
    bg: '$gray900',
    borderColor: '$gray800',
  },

  variants: {
    elevated: {
      true: {
        shadowColor: '$black',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
        elevation: 3,
      },
    },
  },
});

// Usage
<ThemedCard elevated>
  <Text>Themed card content</Text>
</ThemedCard>
```

## NativeWind Integration

Gluestack UI works seamlessly with NativeWind for Tailwind CSS utility classes.

### Setup NativeWind with Gluestack

```bash
# Install NativeWind
npm install nativewind
npm install --save-dev tailwindcss
```

```javascript
// tailwind.config.js
module.exports = {
  content: ['./app/**/*.{js,jsx,ts,tsx}', './components/**/*.{js,jsx,ts,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#E6F2FF',
          500: '#0066CC',
          900: '#001429',
        },
      },
    },
  },
  plugins: [],
};
```

### Use NativeWind with Gluestack Components

```typescript
import { Box } from '@/components/ui/box';

// Mix Gluestack tokens with Tailwind classes
<Box className="flex flex-row items-center justify-between p-4 bg-white dark:bg-gray-900">
  <Text className="text-lg font-bold text-gray-900 dark:text-white">
    Hybrid styling
  </Text>
</Box>
```

## Brand Guidelines Implementation

### Create Brand Theme

```typescript
// config/brand-theme.ts
export const brandTheme = {
  colors: {
    primary: '#FF6B6B',
    secondary: '#4ECDC4',
    accent: '#FFE66D',
    neutral: {
      50: '#F9FAFB',
      100: '#F3F4F6',
      500: '#6B7280',
      900: '#111827',
    },
  },
  typography: {
    fontFamily: {
      heading: 'Poppins-Bold',
      body: 'Inter-Regular',
    },
    fontSize: {
      xs: 12,
      sm: 14,
      base: 16,
      lg: 18,
      xl: 20,
      '2xl': 24,
    },
  },
  spacing: {
    unit: 8, // Base unit for spacing
  },
  borderRadius: {
    sm: 4,
    md: 8,
    lg: 12,
    full: 9999,
  },
};
```

### Apply Brand Theme

```typescript
// Use brand theme in config
import { createConfig } from '@gluestack-ui/themed';
import { brandTheme } from './brand-theme';

export const config = createConfig({
  tokens: {
    colors: {
      primary500: brandTheme.colors.primary,
      secondary500: brandTheme.colors.secondary,
      accent500: brandTheme.colors.accent,
      ...Object.entries(brandTheme.colors.neutral).reduce(
        (acc, [key, value]) => ({
          ...acc,
          [`neutral${key}`]: value,
        }),
        {}
      ),
    },
    fonts: brandTheme.typography.fontFamily,
    fontSizes: brandTheme.typography.fontSize,
    radii: brandTheme.borderRadius,
  },
});
```

## Advanced Customization Patterns

### Theme Context

```typescript
// contexts/ThemeContext.tsx
import { createContext, useContext, useState } from 'react';

interface ThemeContextType {
  primaryColor: string;
  setPrimaryColor: (color: string) => void;
  borderRadius: 'sharp' | 'rounded' | 'pill';
  setBorderRadius: (radius: 'sharp' | 'rounded' | 'pill') => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [primaryColor, setPrimaryColor] = useState('#0066CC');
  const [borderRadius, setBorderRadius] = useState<'sharp' | 'rounded' | 'pill'>('rounded');

  return (
    <ThemeContext.Provider
      value={{ primaryColor, setPrimaryColor, borderRadius, setBorderRadius }}
    >
      {children}
    </ThemeContext.Provider>
  );
}

export const useTheme = () => {
  const context = useContext(ThemeContext);
  if (!context) throw new Error('useTheme must be used within ThemeProvider');
  return context;
};
```

### Dynamic Theme Switching

```typescript
function ThemeCustomizer() {
  const { primaryColor, setPrimaryColor, borderRadius, setBorderRadius } = useTheme();

  return (
    <VStack space="lg" p="$4">
      <FormControl>
        <FormControlLabel>
          <FormControlLabelText>Primary Color</FormControlLabelText>
        </FormControlLabel>
        <Input>
          <InputField
            value={primaryColor}
            onChangeText={setPrimaryColor}
            placeholder="#0066CC"
          />
        </Input>
      </FormControl>

      <FormControl>
        <FormControlLabel>
          <FormControlLabelText>Border Radius</FormControlLabelText>
        </FormControlLabel>
        <Select
          selectedValue={borderRadius}
          onValueChange={(value) => setBorderRadius(value as any)}
        >
          <SelectTrigger>
            <SelectInput />
          </SelectTrigger>
          <SelectPortal>
            <SelectBackdrop />
            <SelectContent>
              <SelectItem label="Sharp" value="sharp" />
              <SelectItem label="Rounded" value="rounded" />
              <SelectItem label="Pill" value="pill" />
            </SelectContent>
          </SelectPortal>
        </Select>
      </FormControl>
    </VStack>
  );
}
```

## Best Practices

**Theming:**
- Use design tokens consistently across the app
- Create a centralized theme configuration
- Document your custom tokens and colors
- Test themes in both light and dark modes
- Use semantic color names (primary, success, error)
- Keep color scales consistent (50-900)
- Use responsive design tokens
- Version your theme configurations

**Dark Mode:**
- Always test components in both modes
- Use `_dark` prop for dark mode specific styles
- Ensure sufficient contrast in both modes
- Use system preference as default
- Persist user's color mode preference
- Provide manual toggle for user control
- Test with accessibility tools

**Customization:**
- Start with default theme and customize incrementally
- Keep customizations minimal and purposeful
- Document custom component variants
- Use TypeScript for type-safe theming
- Create reusable styled components
- Avoid inline styles when possible
- Use design tokens over hardcoded values
- Test customizations across platforms (iOS, Android, Web)

**Performance:**
- Minimize theme recalculations
- Memoize theme-dependent components
- Avoid deeply nested styled components
- Use CSS variables for dynamic theming on web
- Cache theme configurations
- Lazy load theme assets
