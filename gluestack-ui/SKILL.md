---
name: gluestack-ui
description: Universal UI component library with Gluestack UI v2 - 30+ accessible, copy-paste components for React Native/Expo and React/Next.js with dark mode, NativeWind support, and no vendor lock-in
license: MIT
compatibility: "Requires: Expo SDK 50+, React Native 0.74+, React 18+, NativeWind (optional for Tailwind styling)"
---

# Gluestack UI

## Overview

Build universal UIs with Gluestack UI v2, a copy-paste component library providing 30+ accessible, customizable components that work across React Native/Expo and React/Next.js. Uses design tokens, supports dark mode, integrates with NativeWind/Tailwind, and avoids vendor lock-in through source code ownership.

**Philosophy**: Copy-paste components, modify freely, keep full control. Inspired by shadcn/ui but extended for mobile platforms.

## Version & Documentation

**This skill covers Gluestack UI v2** (current stable version as of 2026).

**Complementary Resources:**
- **This skill**: Integration patterns, workflows, troubleshooting, complete examples
- **Official docs**: https://gluestack.io/ui/docs - Latest API reference and updates
- **MCP server** (if available): Real-time component API lookup and props reference

**Use this skill for:** Copy-paste workflows, compound component structures, form validation patterns, dark mode setup, common issues.

**Use official docs/MCP for:** Latest prop definitions, new component releases, API breaking changes.

## When to Use This Skill

- Building universal apps (web + mobile with shared codebase)
- Need accessible, production-ready UI components
- Want component customization without library constraints
- Using NativeWind/Tailwind for styling
- Need dark mode support out of the box
- Building design systems with consistent tokens
- Migrating from heavy UI libraries (React Native Elements, etc.)
- Want source code ownership (no npm package dependencies)

**Not recommended when:**
- Need fully opinionated, pre-styled components without customization
- Building web-only apps (consider shadcn/ui instead)
- Prefer package-based automatic updates over copy-paste control
- Don't want to maintain component source code

## Workflow

### Step 1: Create Gluestack Project

**Option A: New Project (Recommended)**

```bash
npm create gluestack@latest

# Choose your template:
# - Expo (React Native)
# - Next.js (React Web)
# - Universal (React Native + Next.js)
```

This creates a pre-configured project with:
- GluestackUIProvider already set up
- Example components
- Design tokens configured
- TypeScript support

**Option B: Manual Installation for Existing Project**

```bash
# For Expo/React Native
npx expo install @gluestack-ui/themed @gluestack-style/react

# For React/Next.js
npm install @gluestack-ui/themed @gluestack-style/react
```

### Step 2: Configure GluestackUIProvider

Wrap your app with the provider:

```typescript
// app/_layout.tsx (Expo Router)
import { GluestackUIProvider } from '@gluestack-ui/themed';
import { config } from '@gluestack-ui/config';

export default function RootLayout() {
  return (
    <GluestackUIProvider config={config}>
      <Stack />
    </GluestackUIProvider>
  );
}
```

```typescript
// App.tsx (bare React Native)
import { GluestackUIProvider } from '@gluestack-ui/themed';
import { config } from '@gluestack-ui/config';

export default function App() {
  return (
    <GluestackUIProvider config={config}>
      {/* Your app content */}
    </GluestackUIProvider>
  );
}
```

### Step 3: Install Component via CLI

Use the CLI to copy component source code into your project:

```bash
# Add a single component
npx gluestack-ui add button

# Add multiple components
npx gluestack-ui add button input modal

# List all available components
npx gluestack-ui list

# View component categories
npx gluestack-ui --help
```

**What this does:**
- Copies component source files to `components/ui/[component]/`
- Includes all sub-components and types
- Creates index file for easy imports
- **Does NOT** add npm dependencies

### Step 4: Import and Use Components

```typescript
// Import from your local components directory
import { Button, ButtonText } from '@/components/ui/button';
import { Input, InputField } from '@/components/ui/input';

function MyScreen() {
  return (
    <View>
      <Button variant="solid" size="md">
        <ButtonText>Click Me</ButtonText>
      </Button>

      <Input>
        <InputField placeholder="Enter text..." />
      </Input>
    </View>
  );
}
```

**Key Point**: Components are imported from YOUR codebase (`@/components/ui/`), not from `@gluestack-ui/themed`. You own the source.

### Step 5: Customize Components (Optional)

Since you own the source code, modify components directly:

```typescript
// components/ui/button/index.tsx
export const Button = styled(Pressable, {
  // Modify default styles here
  backgroundColor: '$your-custom-color',
  borderRadius: '$your-radius',

  // Add custom variants
  variants: {
    customVariant: {
      special: {
        backgroundColor: '$special-color',
      },
    },
  },
});
```

### Step 6: Configure NativeWind Integration (Optional)

If using NativeWind/Tailwind CSS:

```bash
# Install NativeWind if not already installed
npm install nativewind

# Configure as per nativewind-styling skill
```

```typescript
// Use className alongside Gluestack components
import { Button, ButtonText } from '@/components/ui/button';

<Button className="mb-4">
  <ButtonText>Button with Tailwind spacing</ButtonText>
</Button>
```

### Step 7: Setup Dark Mode

Dark mode is enabled by default with GluestackUIProvider. Toggle programmatically:

```typescript
import { useColorMode } from '@gluestack-ui/themed';

function ThemeToggle() {
  const { colorMode, toggleColorMode } = useColorMode();

  return (
    <Button onPress={toggleColorMode}>
      <ButtonText>
        Current: {colorMode} (Tap to switch)
      </ButtonText>
    </Button>
  );
}
```

Configure dark mode colors in `gluestack-ui.config.ts`:

```typescript
export const config = {
  tokens: {
    colors: {
      // Light mode colors
      primary500: '#3b82f6',
      // Dark mode colors
      primary500_dark: '#60a5fa',
    },
  },
};
```

### Step 8: Customize Design Tokens

Modify `gluestack-ui.config.ts` to match your brand:

```typescript
export const config = {
  tokens: {
    colors: {
      primary500: '#your-brand-color',
      secondary500: '#your-secondary-color',
    },
    space: {
      xs: 4,
      sm: 8,
      md: 16,
      lg: 24,
    },
    fontSizes: {
      xs: 12,
      sm: 14,
      md: 16,
      lg: 18,
    },
    radii: {
      sm: 4,
      md: 8,
      lg: 12,
    },
  },
};
```

Tokens automatically apply to all components.

## Guidelines

**Do:**
- Use the CLI to add components (`npx gluestack-ui add`)
- Customize components directly in your codebase when needed
- Leverage compound components for flexible layouts
- Configure design tokens for brand consistency
- Test accessibility with screen readers (VoiceOver, TalkBack)
- Use TypeScript for type safety
- Organize components in `components/ui/` directory
- Read component source to understand implementation
- Update components manually when Gluestack releases fixes

**Don't:**
- Don't treat Gluestack as an npm dependency (it's copy-paste)
- Don't expect automatic updates (you maintain the source)
- Don't mix with other heavy UI libraries (style conflicts)
- Don't skip accessibility testing
- Don't hardcode colors (use design tokens)
- Don't forget dark mode variants
- Don't copy components manually (use CLI for proper structure)
- Don't modify `@gluestack-ui/themed` package (customize local copies)

## Examples

### Example 1: Button with Variants

```typescript
import { View } from 'react-native';
import { Button, ButtonText, ButtonIcon } from '@/components/ui/button';
import { AddIcon } from '@gluestack-ui/themed';

export function ButtonExample() {
  return (
    <View>
      {/* Solid button */}
      <Button variant="solid" size="md" onPress={() => console.log('Pressed')}>
        <ButtonText>Solid Button</ButtonText>
      </Button>

      {/* Outline button */}
      <Button variant="outline" size="md">
        <ButtonText>Outline Button</ButtonText>
      </Button>

      {/* Link button */}
      <Button variant="link">
        <ButtonText>Link Button</ButtonText>
      </Button>

      {/* Button with icon */}
      <Button variant="solid">
        <ButtonIcon as={AddIcon} />
        <ButtonText>Add Item</ButtonText>
      </Button>

      {/* Loading state */}
      <Button isDisabled>
        <ButtonText>Loading...</ButtonText>
      </Button>
    </View>
  );
}
```

### Example 2: Input with Validation

```typescript
import { useState } from 'react';
import { View } from 'react-native';
import { Input, InputField, InputSlot, InputIcon } from '@/components/ui/input';
import { FormControl, FormControlError, FormControlErrorText, FormControlLabel, FormControlLabelText } from '@/components/ui/form-control';
import { EyeIcon, EyeOffIcon } from '@gluestack-ui/themed';

export function InputExample() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');

  const validateEmail = (text: string) => {
    setEmail(text);
    if (text && !text.includes('@')) {
      setError('Invalid email format');
    } else {
      setError('');
    }
  };

  return (
    <View>
      {/* Email input with validation */}
      <FormControl isInvalid={!!error}>
        <FormControlLabel>
          <FormControlLabelText>Email</FormControlLabelText>
        </FormControlLabel>
        <Input>
          <InputField
            placeholder="your@email.com"
            value={email}
            onChangeText={validateEmail}
            keyboardType="email-address"
          />
        </Input>
        {error && (
          <FormControlError>
            <FormControlErrorText>{error}</FormControlErrorText>
          </FormControlError>
        )}
      </FormControl>

      {/* Password input with toggle */}
      <FormControl>
        <FormControlLabel>
          <FormControlLabelText>Password</FormControlLabelText>
        </FormControlLabel>
        <Input>
          <InputField
            placeholder="Enter password"
            value={password}
            onChangeText={setPassword}
            secureTextEntry={!showPassword}
          />
          <InputSlot onPress={() => setShowPassword(!showPassword)}>
            <InputIcon as={showPassword ? EyeIcon : EyeOffIcon} />
          </InputSlot>
        </Input>
      </FormControl>
    </View>
  );
}
```

### Example 3: Modal with Actions

```typescript
import { useState } from 'react';
import { Button, ButtonText } from '@/components/ui/button';
import { Modal, ModalBackdrop, ModalContent, ModalHeader, ModalCloseButton, ModalBody, ModalFooter, Heading, Text, CloseIcon, Icon } from '@gluestack-ui/themed';

export function ModalExample() {
  const [showModal, setShowModal] = useState(false);

  return (
    <>
      <Button onPress={() => setShowModal(true)}>
        <ButtonText>Open Modal</ButtonText>
      </Button>

      <Modal isOpen={showModal} onClose={() => setShowModal(false)}>
        <ModalBackdrop />
        <ModalContent>
          <ModalHeader>
            <Heading size="lg">Confirm Action</Heading>
            <ModalCloseButton>
              <Icon as={CloseIcon} />
            </ModalCloseButton>
          </ModalHeader>

          <ModalBody>
            <Text>Are you sure you want to proceed with this action?</Text>
          </ModalBody>

          <ModalFooter>
            <Button variant="outline" onPress={() => setShowModal(false)}>
              <ButtonText>Cancel</ButtonText>
            </Button>
            <Button
              onPress={() => {
                console.log('Confirmed');
                setShowModal(false);
              }}
            >
              <ButtonText>Confirm</ButtonText>
            </Button>
          </ModalFooter>
        </ModalContent>
      </Modal>
    </>
  );
}
```

### Example 4: Toast Notifications

```typescript
import { View } from 'react-native';
import { Button, ButtonText } from '@/components/ui/button';
import { useToast, Toast, ToastTitle, ToastDescription } from '@/components/ui/toast';

export function ToastExample() {
  const toast = useToast();

  const showSuccessToast = () => {
    toast.show({
      placement: 'top',
      render: ({ id }) => {
        return (
          <Toast nativeID={id} action="success" variant="solid">
            <ToastTitle>Success!</ToastTitle>
            <ToastDescription>
              Your action completed successfully.
            </ToastDescription>
          </Toast>
        );
      },
    });
  };

  const showErrorToast = () => {
    toast.show({
      placement: 'bottom',
      render: ({ id }) => {
        return (
          <Toast nativeID={id} action="error" variant="solid">
            <ToastTitle>Error</ToastTitle>
            <ToastDescription>
              Something went wrong. Please try again.
            </ToastDescription>
          </Toast>
        );
      },
    });
  };

  return (
    <View>
      <Button onPress={showSuccessToast}>
        <ButtonText>Show Success Toast</ButtonText>
      </Button>

      <Button onPress={showErrorToast} variant="outline">
        <ButtonText>Show Error Toast</ButtonText>
      </Button>
    </View>
  );
}
```

### Example 5: Checkbox with Label

```typescript
import { useState } from 'react';
import { View } from 'react-native';
import { Checkbox, CheckboxIndicator, CheckboxIcon, CheckboxLabel, CheckIcon } from '@/components/ui/checkbox';

export function CheckboxExample() {
  const [agreed, setAgreed] = useState(false);
  const [notifications, setNotifications] = useState({
    email: true,
    push: false,
    sms: false,
  });

  return (
    <View>
      {/* Simple checkbox */}
      <Checkbox value="agreed" isChecked={agreed} onChange={setAgreed}>
        <CheckboxIndicator>
          <CheckboxIcon as={CheckIcon} />
        </CheckboxIndicator>
        <CheckboxLabel>I agree to the terms and conditions</CheckboxLabel>
      </Checkbox>

      {/* Checkbox group */}
      <View>
        <Checkbox
          value="email"
          isChecked={notifications.email}
          onChange={(checked) =>
            setNotifications({ ...notifications, email: checked })
          }
        >
          <CheckboxIndicator>
            <CheckboxIcon as={CheckIcon} />
          </CheckboxIndicator>
          <CheckboxLabel>Email notifications</CheckboxLabel>
        </Checkbox>

        <Checkbox
          value="push"
          isChecked={notifications.push}
          onChange={(checked) =>
            setNotifications({ ...notifications, push: checked })
          }
        >
          <CheckboxIndicator>
            <CheckboxIcon as={CheckIcon} />
          </CheckboxIndicator>
          <CheckboxLabel>Push notifications</CheckboxLabel>
        </Checkbox>
      </View>
    </View>
  );
}
```

### Example 6: Select Dropdown

```typescript
import { useState } from 'react';
import { Select, SelectTrigger, SelectInput, SelectIcon, SelectPortal, SelectBackdrop, SelectContent, SelectDragIndicatorWrapper, SelectDragIndicator, SelectItem, ChevronDownIcon } from '@/components/ui/select';

export function SelectExample() {
  const [country, setCountry] = useState('');

  return (
    <Select selectedValue={country} onValueChange={setCountry}>
      <SelectTrigger variant="outline" size="md">
        <SelectInput placeholder="Select country" />
        <SelectIcon as={ChevronDownIcon} />
      </SelectTrigger>

      <SelectPortal>
        <SelectBackdrop />
        <SelectContent>
          <SelectDragIndicatorWrapper>
            <SelectDragIndicator />
          </SelectDragIndicatorWrapper>

          <SelectItem label="United States" value="us" />
          <SelectItem label="Canada" value="ca" />
          <SelectItem label="United Kingdom" value="uk" />
          <SelectItem label="France" value="fr" />
          <SelectItem label="Germany" value="de" />
        </SelectContent>
      </SelectPortal>
    </Select>
  );
}
```

### Example 7: Card Layout

```typescript
import { View } from 'react-native';
import { Card } from '@/components/ui/card';
import { Heading, Text } from '@gluestack-ui/themed';
import { Button, ButtonText } from '@/components/ui/button';
import { Image } from '@/components/ui/image';

export function CardExample() {
  return (
    <View>
      <Card variant="elevated" size="md">
        <Image
          source={{ uri: 'https://example.com/image.jpg' }}
          alt="Card image"
          style={{ width: '100%', height: 200 }}
        />

        <View style={{ padding: 16 }}>
          <Heading size="lg">Card Title</Heading>

          <Text size="sm" style={{ marginTop: 8, marginBottom: 16 }}>
            This is a card description with some content that explains what this
            card is about.
          </Text>

          <View style={{ flexDirection: 'row', gap: 8 }}>
            <Button size="sm" flex={1}>
              <ButtonText>Action 1</ButtonText>
            </Button>
            <Button size="sm" variant="outline" flex={1}>
              <ButtonText>Action 2</ButtonText>
            </Button>
          </View>
        </View>
      </Card>
    </View>
  );
}
```

### Example 8: Alert with Icon

```typescript
import { View } from 'react-native';
import { Alert, AlertIcon, AlertText, InfoIcon, CheckCircleIcon, AlertCircleIcon } from '@/components/ui/alert';

export function AlertExample() {
  return (
    <View>
      {/* Info alert */}
      <Alert action="info" variant="solid">
        <AlertIcon as={InfoIcon} />
        <AlertText>
          This is an informational message.
        </AlertText>
      </Alert>

      {/* Success alert */}
      <Alert action="success" variant="solid">
        <AlertIcon as={CheckCircleIcon} />
        <AlertText>
          Operation completed successfully!
        </AlertText>
      </Alert>

      {/* Error alert */}
      <Alert action="error" variant="solid">
        <AlertIcon as={AlertCircleIcon} />
        <AlertText>
          An error occurred. Please try again.
        </AlertText>
      </Alert>
    </View>
  );
}
```

## Resources

- [Forms Components Reference](references/forms-components.md) - Button, Input, Checkbox, Select, Slider, Switch, Textarea
- [Overlays Components Reference](references/overlays-components.md) - Modal, Drawer, Popover, Tooltip, AlertDialog, Menu
- [Layout Components Reference](references/layout-components.md) - Box, VStack, HStack, Center, Divider, Grid
- [Feedback Components Reference](references/feedback-components.md) - Toast, Alert, Progress, Spinner, Skeleton
- [Data Display Reference](references/data-display.md) - Avatar, Badge, Card, Table, Accordion
- [Theming & Customization Guide](references/theming-customization.md) - Design tokens, dark mode, custom themes
- [Animations Integration Guide](references/animations-integration.md) - Reanimated, Moti, animated components
- [Troubleshooting Guide](references/troubleshooting.md) - Common issues and solutions
- [Official Gluestack Documentation](https://gluestack.io/)
- [Component Reference](https://gluestack.io/ui/docs/components)
- [GitHub Repository](https://github.com/gluestack/gluestack-ui)
- [Figma UI Kit](https://www.figma.com/community/file/1210475886365758010/gluestack-ui-kit)

## Tools & Commands

- `npm create gluestack@latest` - Create new Gluestack project
- `npx gluestack-ui add [component]` - Add component source to your project
- `npx gluestack-ui add [component1] [component2]` - Add multiple components
- `npx gluestack-ui list` - List all available components
- `npx gluestack-ui update [component]` - Update component source
- `npx gluestack-ui --help` - Show all CLI commands

## Troubleshooting

### Component not found after installation

**Problem**: Imported component shows "cannot find module" error

**Solution**:
1. Ensure you ran `npx gluestack-ui add [component]`
2. Check that component exists in `components/ui/[component]/`
3. Verify import path: `@/components/ui/[component]`
4. Restart TypeScript server in your IDE
5. Check that path alias `@` is configured in `tsconfig.json`:
```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./*"]
    }
  }
}
```

### Styles not applying

**Problem**: Components render but have no styling

**Solution**:
1. Verify `GluestackUIProvider` wraps your app
2. Ensure config is passed to provider: `<GluestackUIProvider config={config}>`
3. Check that `@gluestack-ui/config` is installed
4. Restart Metro bundler: `npx expo start --clear`
5. Verify no conflicting global styles

### Dark mode not working

**Problem**: Dark mode toggle doesn't change component colors

**Solution**:
1. Ensure colors have `_dark` variants in config:
```typescript
colors: {
  primary500: '#3b82f6',      // Light mode
  primary500_dark: '#60a5fa',  // Dark mode
}
```
2. Use `useColorMode` hook to toggle: `toggleColorMode()`
3. Test on device with system dark mode enabled
4. Check GluestackUIProvider is properly configured

### TypeScript errors with imports

**Problem**: TypeScript complains about component types

**Solution**:
1. Ensure TypeScript is configured for Gluestack
2. Add types to `tsconfig.json`:
```json
{
  "compilerOptions": {
    "types": ["@gluestack-ui/themed"]
  }
}
```
3. Restart TypeScript server
4. Check that components were added via CLI (includes types)

### NativeWind conflicts

**Problem**: NativeWind className conflicting with Gluestack styles

**Solution**:
1. Configure style priority in `gluestack-ui.config.ts`
2. Use className for spacing/layout only
3. Use Gluestack design tokens for colors
4. Avoid mixing both systems on same component
5. Choose primary styling system (Gluestack OR NativeWind)

See [Troubleshooting Guide](references/troubleshooting.md) for more issues and solutions.

---

## Notes

- **Copy-paste architecture**: Components copied to your codebase, not installed as npm dependency
- **Source code ownership**: You maintain and customize component source
- **Universal**: Works on React Native (Expo) + React (Next.js) with same API
- **Accessibility-first**: ARIA support, keyboard navigation, screen reader tested
- **NativeWind compatible**: Can integrate with Tailwind CSS utilities
- **Inspired by shadcn/ui**: Same philosophy but for mobile platforms
- **30+ components**: Production-ready forms, overlays, layouts, feedback, data display
- **Design tokens**: Centralized theming with colors, spacing, typography
- **Dark mode**: Built-in with automatic and manual controls
- **TypeScript**: Full type safety and autocomplete support
- **No automatic updates**: You control when and how to update component source
- **Active development**: Regular improvements and new components added
- **Community-driven**: Open source with active GitHub discussions
