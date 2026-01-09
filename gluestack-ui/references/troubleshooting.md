# Troubleshooting Reference

Common issues and solutions when working with Gluestack UI v2.

## Installation Issues

### Component Not Found After Installation

**Problem**: Component imports fail after running `npx gluestack-ui add [component]`.

**Symptoms**:
```
Error: Cannot find module '@/components/ui/button'
```

**Solution**:
```bash
# 1. Verify component was installed
ls components/ui/button/

# 2. Check if path alias is configured
# tsconfig.json or jsconfig.json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./*"]
    }
  }
}

# 3. For Expo, ensure Metro is configured
# metro.config.js
const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

module.exports = config;

# 4. Restart development server
npm start -- --reset-cache
```

### CLI Command Fails

**Problem**: `npx gluestack-ui add` command doesn't work.

**Symptoms**:
```
Command not found: gluestack-ui
```

**Solution**:
```bash
# Use full npx command
npx --yes @gluestack-ui/cli@latest add button

# Or install CLI globally
npm install -g @gluestack-ui/cli
gluestack-ui add button

# If still failing, manually copy component from docs
# https://gluestack.io/ui/docs/components/button
```

### TypeScript Errors After Installation

**Problem**: TypeScript complains about component props.

**Symptoms**:
```
Type '{ children: string; }' is missing the following properties from type...
```

**Solution**:
```bash
# 1. Ensure @gluestack-ui/themed is installed
npm install @gluestack-ui/themed @gluestack-style/react

# 2. Add proper TypeScript config
# tsconfig.json
{
  "compilerOptions": {
    "jsx": "react-native",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "esModuleInterop": true
  }
}

# 3. Restart TypeScript server in IDE
# VS Code: Cmd+Shift+P → "TypeScript: Restart TS Server"
```

## Styling Issues

### Styles Not Applying

**Problem**: Component styles don't render as expected.

**Symptoms**:
- Design tokens like `$primary500` show as text
- Background colors not working
- Spacing props ignored

**Solution**:
```typescript
// 1. Verify GluestackUIProvider is wrapping your app
// app/_layout.tsx
import { GluestackUIProvider } from '@/components/ui/gluestack-ui-provider';

export default function RootLayout() {
  return (
    <GluestackUIProvider mode="light">
      {/* Your app */}
    </GluestackUIProvider>
  );
}

// 2. Check if design token syntax is correct
<Box bg="$blue500">  {/* Correct */}
<Box bg="blue500">   {/* Wrong - missing $ */}

// 3. Ensure component was copied correctly via CLI
npx gluestack-ui add box --force  // Re-install component
```

### Dark Mode Not Working

**Problem**: Components don't adapt to dark mode.

**Symptoms**:
- `_dark` props ignored
- Colors don't change in dark mode
- useColorMode hook returns wrong value

**Solution**:
```typescript
// 1. Verify mode prop is set correctly
import { useColorScheme } from 'react-native';
import { GluestackUIProvider } from '@/components/ui/gluestack-ui-provider';

export default function App() {
  const colorScheme = useColorScheme();

  return (
    <GluestackUIProvider mode={colorScheme === 'dark' ? 'dark' : 'light'}>
      {/* app */}
    </GluestackUIProvider>
  );
}

// 2. Use _dark prop correctly
<Box
  bg="$white"
  _dark={{ bg: '$gray900' }}  // Correct
>
  <Text>Content</Text>
</Box>

// 3. Check component theme configuration
// components/ui/gluestack-ui-provider/index.tsx
// Ensure dark mode variants are defined
```

### NativeWind Conflicts

**Problem**: NativeWind classes conflict with Gluestack styles.

**Symptoms**:
- Styles overriding each other
- Inconsistent styling
- className prop not working

**Solution**:
```typescript
// 1. Use className and Gluestack props together carefully
<Box className="flex flex-row" bg="$white">  {/* Works */}
  <Text className="text-lg" color="$gray900">Text</Text>
</Box>

// 2. Configure Tailwind to avoid conflicts
// tailwind.config.js
module.exports = {
  content: ['./app/**/*.{js,jsx,ts,tsx}'],
  theme: {
    extend: {
      // Use custom prefix to avoid conflicts
    },
  },
};

// 3. Prefer one approach consistently
// Either use Gluestack tokens OR Tailwind classes, not both heavily mixed
```

## Component-Specific Issues

### Modal Not Showing

**Problem**: Modal component doesn't appear on screen.

**Symptoms**:
- Modal backdrop doesn't show
- Content invisible
- isOpen prop seems to not work

**Solution**:
```typescript
// 1. Ensure Modal structure is complete
<Modal isOpen={showModal} onClose={() => setShowModal(false)}>
  <ModalBackdrop />  {/* Required */}
  <ModalContent>     {/* Required */}
    <ModalHeader>
      <Heading>Title</Heading>
    </ModalHeader>
    <ModalBody>
      <Text>Content</Text>
    </ModalBody>
  </ModalContent>
</Modal>

// 2. Check z-index issues
<Modal isOpen={showModal} onClose={close}>
  <ModalBackdrop />
  <ModalContent zIndex={9999}>  {/* Increase z-index */}
    {/* content */}
  </ModalContent>
</Modal>

// 3. Verify no parent components have overflow: hidden
<View style={{ overflow: 'visible' }}>  {/* Don't use 'hidden' */}
  <Modal>...</Modal>
</View>
```

### Toast Not Appearing

**Problem**: Toast notifications don't show.

**Symptoms**:
- `toast.show()` called but nothing appears
- Toast renders but immediately disappears
- Multiple toasts not queuing

**Solution**:
```typescript
// 1. Ensure ToastProvider is configured
// app/_layout.tsx
import { GluestackUIProvider } from '@/components/ui/gluestack-ui-provider';

export default function RootLayout() {
  return (
    <GluestackUIProvider>
      {/* This includes ToastProvider */}
      {children}
    </GluestackUIProvider>
  );
}

// 2. Use correct toast.show() structure
import { useToast } from '@/components/ui/toast';

const toast = useToast();

toast.show({
  placement: 'top',
  duration: 3000,  // Add duration
  render: ({ id }) => (
    <Toast nativeID={`toast-${id}`} action="success">  {/* nativeID required */}
      <ToastTitle>Success</ToastTitle>
    </Toast>
  ),
});

// 3. Check if toast container is being covered
// Adjust placement or z-index
toast.show({
  placement: 'top',  // Try different placements
  // ...
});
```

### Select Dropdown Not Opening

**Problem**: Select component doesn't show options when clicked.

**Symptoms**:
- Click on Select trigger does nothing
- Options list doesn't render
- Portal not working

**Solution**:
```typescript
// 1. Ensure complete Select structure
<Select>
  <SelectTrigger>
    <SelectInput placeholder="Select" />
    <SelectIcon as={ChevronDownIcon} />
  </SelectTrigger>
  <SelectPortal>              {/* Required */}
    <SelectBackdrop />        {/* Required */}
    <SelectContent>           {/* Required */}
      <SelectDragIndicatorWrapper>
        <SelectDragIndicator />
      </SelectDragIndicatorWrapper>
      <SelectItem label="Option 1" value="1" />
      <SelectItem label="Option 2" value="2" />
    </SelectContent>
  </SelectPortal>
</Select>

// 2. For React Native, ensure no parent Views have overflow: hidden
<View style={{ overflow: 'visible' }}>
  <Select>...</Select>
</View>

// 3. On web, check if portal root exists
// In your HTML
<div id="portal-root"></div>
```

### Input Not Receiving Focus

**Problem**: Input field doesn't focus when tapped.

**Symptoms**:
- Keyboard doesn't appear
- Cursor doesn't show
- onFocus not called

**Solution**:
```typescript
// 1. Use InputField, not Input for text input
<Input>
  <InputField  {/* This is the actual input */}
    placeholder="Enter text"
    onFocus={() => console.log('focused')}
  />
</Input>

// 2. Check if Input is disabled
<Input isDisabled={false}>  {/* Ensure not disabled */}
  <InputField />
</Input>

// 3. Verify no parent Touchable is capturing touches
<View>  {/* Don't wrap in TouchableOpacity */}
  <Input>
    <InputField />
  </Input>
</View>

// 4. Manually trigger focus if needed
const inputRef = useRef<TextInput>(null);

<Input>
  <InputField ref={inputRef} />
</Input>

<Button onPress={() => inputRef.current?.focus()}>
  <ButtonText>Focus Input</ButtonText>
</Button>
```

## Performance Issues

### Slow Rendering

**Problem**: App feels sluggish when using Gluestack components.

**Symptoms**:
- UI freezes when scrolling
- Animations lag
- High CPU usage

**Solution**:
```typescript
// 1. Use FlatList for long lists, not VStack
// Bad
<VStack space="md">
  {items.map((item) => <ItemCard key={item.id} {...item} />)}
</VStack>

// Good
<FlatList
  data={items}
  renderItem={({ item }) => <ItemCard {...item} />}
  keyExtractor={(item) => item.id}
/>

// 2. Memoize expensive components
const MemoizedCard = React.memo(Card);

// 3. Avoid inline functions
// Bad
<Button onPress={() => handleClick(item.id)}>
  <ButtonText>Click</ButtonText>
</Button>

// Good
const handlePress = useCallback(() => {
  handleClick(item.id);
}, [item.id]);

<Button onPress={handlePress}>
  <ButtonText>Click</ButtonText>
</Button>

// 4. Use production build for testing
npx expo start --no-dev --minify
```

### Large Bundle Size

**Problem**: App bundle size is too large with Gluestack UI.

**Symptoms**:
- Slow initial load
- Large download size
- Long build times

**Solution**:
```bash
# 1. Only install components you need
npx gluestack-ui add button input  # Don't install all components

# 2. Analyze bundle size
npx expo export --dev
npx react-native-bundle-visualizer

# 3. Enable Hermes (React Native)
# android/app/build.gradle
project.ext.react = [
    enableHermes: true
]

# 4. Use code splitting on web
# next.config.js (for Next.js)
module.exports = {
  experimental: {
    optimizePackageImports: ['@gluestack-ui/themed'],
  },
};
```

## Platform-Specific Issues

### Web: Styles Not Working

**Problem**: Components don't render correctly on web.

**Solution**:
```bash
# 1. Ensure web dependencies are installed
npm install react-native-web react-dom

# 2. Configure Next.js (if using)
# next.config.js
const { withExpo } = require('@expo/next-adapter');

module.exports = withExpo({
  transpilePackages: [
    'react-native',
    '@gluestack-ui/themed',
    '@gluestack-style/react',
  ],
});

# 3. Add CSS reset
# _app.tsx or _layout.tsx
import '@gluestack-ui/themed/build/style.css';
```

### iOS: Text Input Keyboard Issues

**Problem**: Keyboard behaves unexpectedly on iOS.

**Solution**:
```typescript
// 1. Use KeyboardAvoidingView
import { KeyboardAvoidingView, Platform } from 'react-native';

<KeyboardAvoidingView
  behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
  style={{ flex: 1 }}
>
  <Input>
    <InputField />
  </Input>
</KeyboardAvoidingView>

// 2. Configure keyboard type properly
<Input>
  <InputField
    keyboardType="email-address"
    autoCapitalize="none"
    autoCorrect={false}
  />
</Input>
```

### Android: Modal/Overlay Issues

**Problem**: Modals or overlays have rendering issues on Android.

**Solution**:
```typescript
// 1. Enable software rendering for specific views
<Modal
  isOpen={showModal}
  onClose={close}
  // Add renderToHardwareTextureAndroid
  renderToHardwareTextureAndroid
>
  {/* content */}
</Modal>

// 2. Check Android API level compatibility
// Ensure targetSdkVersion in build.gradle is up to date

// 3. Use elevation instead of shadow on Android
<Box
  elevation={5}  // Android
  shadowColor="$black"  // iOS
  shadowOpacity={0.1}
  shadowRadius={4}
>
  {/* content */}
</Box>
```

## Migration Issues

### Migrating from v1 to v2

**Problem**: Components break after upgrading from Gluestack UI v1.

**Solution**:
```bash
# 1. Uninstall v1 packages
npm uninstall @gluestack-ui/config @gluestack-ui/themed-native-base

# 2. Install v2
npm install @gluestack-ui/themed@latest @gluestack-style/react

# 3. Re-add components via CLI
npx gluestack-ui add button input card  # etc.

# 4. Update imports
# Old (v1)
import { Button } from '@gluestack-ui/themed';

# New (v2)
import { Button, ButtonText } from '@/components/ui/button';

# 5. Update component usage (v2 uses compound components)
# Old
<Button>Click Me</Button>

# New
<Button>
  <ButtonText>Click Me</ButtonText>
</Button>
```

### Migrating from NativeBase

**Problem**: Replacing NativeBase with Gluestack UI.

**Solution**:
```typescript
// Component mapping
// NativeBase → Gluestack UI

// Button
<NB.Button>Text</NB.Button>
→
<Button><ButtonText>Text</ButtonText></Button>

// Input
<NB.Input placeholder="..." />
→
<Input><InputField placeholder="..." /></Input>

// VStack/HStack (similar)
<NB.VStack space={4}>...</NB.VStack>
→
<VStack space="md">...</VStack>

// Box (similar)
<NB.Box bg="primary.500">...</NB.Box>
→
<Box bg="$primary500">...</Box>

// Use design tokens with $ prefix in Gluestack
```

## Getting Help

### Enable Debug Mode

```typescript
// Add debug logging
import { GluestackUIProvider } from '@/components/ui/gluestack-ui-provider';

<GluestackUIProvider mode="light" colorMode="light">
  {/* App */}
</GluestackUIProvider>
```

### Check Component Source

```bash
# Components are in your codebase (copy-paste architecture)
cat components/ui/button/index.tsx

# You can modify directly to debug or customize
```

### Report Issues

1. **GitHub Issues**: https://github.com/gluestack/gluestack-ui/issues
2. **Discord Community**: https://discord.gg/gluestack
3. **Documentation**: https://gluestack.io/ui/docs

### Useful Debugging Commands

```bash
# Clear Metro cache
npm start -- --reset-cache

# Clear Expo cache
npx expo start --clear

# Rebuild native modules
cd ios && pod install && cd ..
cd android && ./gradlew clean && cd ..

# Check TypeScript errors
npx tsc --noEmit

# Verify installed packages
npm list @gluestack-ui/themed
```

## Common Pitfalls

1. **Forgetting $ prefix** in design tokens: `bg="$blue500"` not `bg="blue500"`
2. **Missing compound components**: `<Button><ButtonText>` not just `<Button>`
3. **Not wrapping with GluestackUIProvider**: Required at app root
4. **Using package imports instead of local**: Import from `@/components/ui/` not npm
5. **Mixing Gluestack and other UI libs**: Can cause style conflicts
6. **Not re-installing after updates**: Run `npx gluestack-ui add [component] --force`
7. **Forgetting Modal structure**: Need ModalBackdrop + ModalContent
8. **Overflow hidden on parents**: Prevents portals (Modal, Select) from rendering
9. **Not testing on all platforms**: Web, iOS, Android can behave differently
10. **Hardcoding styles**: Use design tokens for consistency and theme support
