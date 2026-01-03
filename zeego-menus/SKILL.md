---
name: zeego-menus
description: Native menus with Zeego - beautiful dropdown and context menus for iOS, Android, and Web with a unified API
license: MIT
compatibility: "Requires: React Native 0.76+, Expo SDK 52+, zeego 3.0+, react-native-ios-context-menu 3.1.0, @react-native-menu/menu 1.2.2"
---

# Zeego Menus

## Overview

Zeego provides beautiful, native menus for React Native and Web with a unified cross-platform API, using Radix UI on web and native components on iOS/Android.

## When to Use This Skill

- Implementing dropdown menus for actions and options
- Adding context menus with long-press or right-click
- Building cross-platform menus with native performance
- Creating checkable menu items (checkboxes or radio groups)
- Supporting submenus and nested menu structures
- Displaying icons, images, and rich content in menus
- Integrating accessible menu patterns with Expo/React Native

## Workflow

### Step 1: Install Zeego and Platform Dependencies

Install the core package and platform-specific peer dependencies:

```bash
# Install Zeego
npm install zeego

# Install peer dependencies (use --legacy-peer-deps with npm)
npm install react-native-ios-context-menu@3.1.0 react-native-ios-utilities@5.1.2 @react-native-menu/menu@1.2.2
```

For Expo projects, rebuild the development client:

```bash
npx expo run:ios -d
npx expo start --dev-client
```

### Step 2: Import Menu Components

Import dropdown or context menu components in your screen/component:

```typescript
import * as DropdownMenu from 'zeego/dropdown-menu';
// or
import * as ContextMenu from 'zeego/context-menu';
```

### Step 3: Create Basic Dropdown Menu

Build a simple dropdown menu with items:

```typescript
export function MyDropdownMenu() {
  return (
    <DropdownMenu.Root>
      <DropdownMenu.Trigger>
        <Pressable>
          <Text>Open Menu</Text>
        </Pressable>
      </DropdownMenu.Trigger>

      <DropdownMenu.Content>
        <DropdownMenu.Item key="edit" onSelect={() => console.log('Edit')}>
          <DropdownMenu.ItemTitle>Edit</DropdownMenu.ItemTitle>
        </DropdownMenu.Item>

        <DropdownMenu.Item key="delete" destructive onSelect={() => console.log('Delete')}>
          <DropdownMenu.ItemTitle>Delete</DropdownMenu.ItemTitle>
        </DropdownMenu.Item>
      </DropdownMenu.Content>
    </DropdownMenu.Root>
  );
}
```

### Step 4: Add Context Menu with Long-Press

Create a context menu that appears on long-press (mobile) or right-click (web):

```typescript
export function MyContextMenu({ children }) {
  return (
    <ContextMenu.Root>
      <ContextMenu.Trigger action="longPress">
        {children}
      </ContextMenu.Trigger>

      <ContextMenu.Content>
        <ContextMenu.Item key="share" onSelect={() => console.log('Share')}>
          <ContextMenu.ItemTitle>Share</ContextMenu.ItemTitle>
        </ContextMenu.Item>

        <ContextMenu.Item key="copy" onSelect={() => console.log('Copy')}>
          <ContextMenu.ItemTitle>Copy Link</ContextMenu.ItemTitle>
        </ContextMenu.Item>
      </ContextMenu.Content>
    </ContextMenu.Root>
  );
}
```

### Step 5: Add Icons and Visual Elements

Enhance menu items with platform-specific icons and images:

```typescript
<DropdownMenu.Item key="settings">
  <DropdownMenu.ItemIcon
    ios={{ name: 'gear', pointSize: 18 }}
    androidIconName="ic_menu_manage"
  >
    {/* Web: JSX icon component */}
    <SettingsIcon />
  </DropdownMenu.ItemIcon>
  <DropdownMenu.ItemTitle>Settings</DropdownMenu.ItemTitle>
  <DropdownMenu.ItemSubtitle>Configure app</DropdownMenu.ItemSubtitle>
</DropdownMenu.Item>

<DropdownMenu.Item key="profile">
  <DropdownMenu.ItemImage
    source={{ uri: 'https://example.com/avatar.jpg' }}
    width={32}
    height={32}
    resizeMode="cover"
  />
  <DropdownMenu.ItemTitle>Profile</DropdownMenu.ItemTitle>
</DropdownMenu.Item>
```

### Step 6: Implement Checkable Items

Add checkbox items with state management:

```typescript
export function CheckboxMenuExample() {
  const [notifications, setNotifications] = useState<'on' | 'off'>('on');

  return (
    <DropdownMenu.Root>
      <DropdownMenu.Trigger>
        <Pressable><Text>Preferences</Text></Pressable>
      </DropdownMenu.Trigger>

      <DropdownMenu.Content>
        <DropdownMenu.CheckboxItem
          key="notifications"
          value={notifications}
          onValueChange={(next) => setNotifications(next as 'on' | 'off')}
        >
          <DropdownMenu.ItemIndicator>
            <CheckIcon />
          </DropdownMenu.ItemIndicator>
          <DropdownMenu.ItemTitle>Enable Notifications</DropdownMenu.ItemTitle>
        </DropdownMenu.CheckboxItem>
      </DropdownMenu.Content>
    </DropdownMenu.Root>
  );
}
```

### Step 7: Create Radio Groups for Single Selection

Implement radio button groups within menus:

```typescript
export function RadioMenuExample() {
  const [theme, setTheme] = useState('light');

  return (
    <DropdownMenu.Root>
      <DropdownMenu.Trigger>
        <Pressable><Text>Theme: {theme}</Text></Pressable>
      </DropdownMenu.Trigger>

      <DropdownMenu.Content>
        <DropdownMenu.Label>Choose Theme</DropdownMenu.Label>

        <DropdownMenu.RadioGroup value={theme} onValueChange={setTheme}>
          <DropdownMenu.RadioItem key="light" value="light">
            <DropdownMenu.ItemIndicator>
              <DotIcon />
            </DropdownMenu.ItemIndicator>
            <DropdownMenu.ItemTitle>Light</DropdownMenu.ItemTitle>
          </DropdownMenu.RadioItem>

          <DropdownMenu.RadioItem key="dark" value="dark">
            <DropdownMenu.ItemIndicator>
              <DotIcon />
            </DropdownMenu.ItemIndicator>
            <DropdownMenu.ItemTitle>Dark</DropdownMenu.ItemTitle>
          </DropdownMenu.RadioItem>

          <DropdownMenu.RadioItem key="system" value="system">
            <DropdownMenu.ItemIndicator>
              <DotIcon />
            </DropdownMenu.ItemIndicator>
            <DropdownMenu.ItemTitle>System</DropdownMenu.ItemTitle>
          </DropdownMenu.RadioItem>
        </DropdownMenu.RadioGroup>
      </DropdownMenu.Content>
    </DropdownMenu.Root>
  );
}
```

### Step 8: Build Submenus

Create nested menu structures with submenus:

```typescript
<DropdownMenu.Root>
  <DropdownMenu.Trigger>
    <Pressable><Text>File</Text></Pressable>
  </DropdownMenu.Trigger>

  <DropdownMenu.Content>
    <DropdownMenu.Item key="new">
      <DropdownMenu.ItemTitle>New</DropdownMenu.ItemTitle>
    </DropdownMenu.Item>

    <DropdownMenu.Sub>
      <DropdownMenu.SubTrigger key="export">
        <DropdownMenu.ItemTitle>Export</DropdownMenu.ItemTitle>
      </DropdownMenu.SubTrigger>

      <DropdownMenu.SubContent>
        <DropdownMenu.Item key="pdf">
          <DropdownMenu.ItemTitle>Export as PDF</DropdownMenu.ItemTitle>
        </DropdownMenu.Item>
        <DropdownMenu.Item key="image">
          <DropdownMenu.ItemTitle>Export as Image</DropdownMenu.ItemTitle>
        </DropdownMenu.Item>
      </DropdownMenu.SubContent>
    </DropdownMenu.Sub>

    <DropdownMenu.Separator />

    <DropdownMenu.Item key="quit" destructive>
      <DropdownMenu.ItemTitle>Quit</DropdownMenu.ItemTitle>
    </DropdownMenu.Item>
  </DropdownMenu.Content>
</DropdownMenu.Root>
```

### Step 9: Organize with Groups and Labels

Structure complex menus with groups and labels:

```typescript
<DropdownMenu.Content>
  <DropdownMenu.Group>
    <DropdownMenu.Label>Account</DropdownMenu.Label>
    <DropdownMenu.Item key="profile">
      <DropdownMenu.ItemTitle>Profile</DropdownMenu.ItemTitle>
    </DropdownMenu.Item>
    <DropdownMenu.Item key="settings">
      <DropdownMenu.ItemTitle>Settings</DropdownMenu.ItemTitle>
    </DropdownMenu.Item>
  </DropdownMenu.Group>

  <DropdownMenu.Separator />

  <DropdownMenu.Group>
    <DropdownMenu.Label>Help</DropdownMenu.Label>
    <DropdownMenu.Item key="docs">
      <DropdownMenu.ItemTitle>Documentation</DropdownMenu.ItemTitle>
    </DropdownMenu.Item>
    <DropdownMenu.Item key="support">
      <DropdownMenu.ItemTitle>Support</DropdownMenu.ItemTitle>
    </DropdownMenu.Item>
  </DropdownMenu.Group>
</DropdownMenu.Content>
```

### Step 10: Create Custom Styled Components

Use the `create()` function to wrap custom components with consistent styling:

```typescript
// Create reusable styled components
export const StyledMenuItem = DropdownMenu.create(
  (props) => (
    <DropdownMenu.Item
      {...props}
      style={{
        height: 44,
        paddingHorizontal: 12,
      }}
    />
  ),
  'Item'
);

export const StyledItemTitle = DropdownMenu.create(
  ({ children, ...props }) => (
    <DropdownMenu.ItemTitle {...props}>
      <Text style={{ fontSize: 16, fontWeight: '500' }}>
        {children}
      </Text>
    </DropdownMenu.ItemTitle>
  ),
  'ItemTitle'
);

// Use in your menus
<DropdownMenu.Content>
  <StyledMenuItem key="action">
    <StyledItemTitle>Custom Styled Action</StyledItemTitle>
  </StyledMenuItem>
</DropdownMenu.Content>
```

## Guidelines

**Do:**
- Always provide a unique `key` prop for each menu item
- Use `ItemTitle` for text content in items (React Native requires separate Text components)
- Leverage platform-specific features like SF Symbols on iOS
- Use `destructive` prop for dangerous actions (shows in red on iOS)
- Implement `disabled` state for unavailable actions
- Use `Separator` and `Group` to organize complex menus
- Add `textValue` prop when using React elements instead of strings in ItemTitle
- Use `asChild` prop on Trigger to avoid extra wrapper views
- Implement `onOpenChange` callbacks for menu state tracking
- Use CheckboxItem for toggleable options and RadioGroup for mutually exclusive choices

**Don't:**
- Don't forget to install platform-specific peer dependencies
- Don't use StyleSheet.create() for web styling (use inline styles or className)
- Don't skip the `create()` wrapper for custom components on native platforms
- Don't rely on ItemImage or ItemSubtitle on Android (not supported)
- Don't use Separator or Arrow on native platforms (web-only)
- Don't forget to rebuild development client after installing Zeego
- Don't use `action="press"` on Trigger if you want long-press behavior
- Don't pass boolean values to CheckboxItem value prop (use "on" | "off" | "mixed")
- Don't forget to provide both iOS and Android icon specifications
- Don't mix checkbox and radio patterns in the same group

## Examples

### Example 1: Dropdown Menu with Icons and Actions

```typescript
import * as DropdownMenu from 'zeego/dropdown-menu';
import { Pressable, Text } from 'react-native';

export function DocumentMenu() {
  const handleEdit = () => console.log('Edit document');
  const handleShare = () => console.log('Share document');
  const handleDelete = () => console.log('Delete document');

  return (
    <DropdownMenu.Root>
      <DropdownMenu.Trigger>
        <Pressable style={{ padding: 8 }}>
          <Text>•••</Text>
        </Pressable>
      </DropdownMenu.Trigger>

      <DropdownMenu.Content>
        <DropdownMenu.Item key="edit" onSelect={handleEdit}>
          <DropdownMenu.ItemIcon
            ios={{ name: 'pencil', pointSize: 18 }}
            androidIconName="ic_menu_edit"
          />
          <DropdownMenu.ItemTitle>Edit</DropdownMenu.ItemTitle>
        </DropdownMenu.Item>

        <DropdownMenu.Item key="share" onSelect={handleShare}>
          <DropdownMenu.ItemIcon
            ios={{ name: 'square.and.arrow.up', pointSize: 18 }}
            androidIconName="ic_menu_share"
          />
          <DropdownMenu.ItemTitle>Share</DropdownMenu.ItemTitle>
        </DropdownMenu.Item>

        <DropdownMenu.Separator />

        <DropdownMenu.Item
          key="delete"
          destructive
          onSelect={handleDelete}
        >
          <DropdownMenu.ItemIcon
            ios={{ name: 'trash', pointSize: 18 }}
            androidIconName="ic_menu_delete"
          />
          <DropdownMenu.ItemTitle>Delete</DropdownMenu.ItemTitle>
        </DropdownMenu.Item>
      </DropdownMenu.Content>
    </DropdownMenu.Root>
  );
}
```

### Example 2: Context Menu with Preview (iOS)

```typescript
import * as ContextMenu from 'zeego/context-menu';
import { View, Image, Text } from 'react-native';

export function ImageWithContextMenu({ imageUrl, title }) {
  return (
    <ContextMenu.Root>
      <ContextMenu.Trigger action="longPress">
        <View style={{ padding: 16 }}>
          <Image
            source={{ uri: imageUrl }}
            style={{ width: 200, height: 200, borderRadius: 8 }}
          />
          <Text style={{ marginTop: 8 }}>{title}</Text>
        </View>
      </ContextMenu.Trigger>

      <ContextMenu.Preview
        preferredCommitStyle="pop"
        backgroundColor="#fff"
        borderRadius={12}
      >
        <View style={{ padding: 20 }}>
          <Image
            source={{ uri: imageUrl }}
            style={{ width: 300, height: 300 }}
          />
        </View>
      </ContextMenu.Preview>

      <ContextMenu.Content>
        <ContextMenu.Item key="save" onSelect={() => console.log('Save')}>
          <ContextMenu.ItemIcon ios={{ name: 'square.and.arrow.down' }} />
          <ContextMenu.ItemTitle>Save to Photos</ContextMenu.ItemTitle>
        </ContextMenu.Item>

        <ContextMenu.Item key="share" onSelect={() => console.log('Share')}>
          <ContextMenu.ItemIcon ios={{ name: 'square.and.arrow.up' }} />
          <ContextMenu.ItemTitle>Share</ContextMenu.ItemTitle>
        </ContextMenu.Item>

        <ContextMenu.Item key="copy" onSelect={() => console.log('Copy')}>
          <ContextMenu.ItemIcon ios={{ name: 'doc.on.doc' }} />
          <ContextMenu.ItemTitle>Copy Image</ContextMenu.ItemTitle>
        </ContextMenu.Item>
      </ContextMenu.Content>
    </ContextMenu.Root>
  );
}
```

### Example 3: Settings Menu with Checkboxes and Radio Groups

```typescript
import * as DropdownMenu from 'zeego/dropdown-menu';
import { useState } from 'react';
import { Pressable, Text, View } from 'react-native';

export function SettingsMenu() {
  const [notifications, setNotifications] = useState<'on' | 'off'>('on');
  const [autoSave, setAutoSave] = useState<'on' | 'off'>('off');
  const [quality, setQuality] = useState('high');

  return (
    <DropdownMenu.Root>
      <DropdownMenu.Trigger>
        <Pressable style={{ padding: 12, backgroundColor: '#007AFF', borderRadius: 8 }}>
          <Text style={{ color: 'white' }}>Settings</Text>
        </Pressable>
      </DropdownMenu.Trigger>

      <DropdownMenu.Content>
        <DropdownMenu.Group>
          <DropdownMenu.Label>Preferences</DropdownMenu.Label>

          <DropdownMenu.CheckboxItem
            key="notifications"
            value={notifications}
            onValueChange={(next) => setNotifications(next as 'on' | 'off')}
          >
            <DropdownMenu.ItemIndicator>
              <View style={{ width: 16, height: 16, backgroundColor: '#007AFF' }} />
            </DropdownMenu.ItemIndicator>
            <DropdownMenu.ItemTitle>Enable Notifications</DropdownMenu.ItemTitle>
          </DropdownMenu.CheckboxItem>

          <DropdownMenu.CheckboxItem
            key="autosave"
            value={autoSave}
            onValueChange={(next) => setAutoSave(next as 'on' | 'off')}
          >
            <DropdownMenu.ItemIndicator>
              <View style={{ width: 16, height: 16, backgroundColor: '#007AFF' }} />
            </DropdownMenu.ItemIndicator>
            <DropdownMenu.ItemTitle>Auto-Save</DropdownMenu.ItemTitle>
          </DropdownMenu.CheckboxItem>
        </DropdownMenu.Group>

        <DropdownMenu.Separator />

        <DropdownMenu.Group>
          <DropdownMenu.Label>Video Quality</DropdownMenu.Label>

          <DropdownMenu.RadioGroup value={quality} onValueChange={setQuality}>
            <DropdownMenu.RadioItem key="low" value="low">
              <DropdownMenu.ItemIndicator>
                <View style={{ width: 8, height: 8, borderRadius: 4, backgroundColor: '#007AFF' }} />
              </DropdownMenu.ItemIndicator>
              <DropdownMenu.ItemTitle>Low (480p)</DropdownMenu.ItemTitle>
            </DropdownMenu.RadioItem>

            <DropdownMenu.RadioItem key="medium" value="medium">
              <DropdownMenu.ItemIndicator>
                <View style={{ width: 8, height: 8, borderRadius: 4, backgroundColor: '#007AFF' }} />
              </DropdownMenu.ItemIndicator>
              <DropdownMenu.ItemTitle>Medium (720p)</DropdownMenu.ItemTitle>
            </DropdownMenu.RadioItem>

            <DropdownMenu.RadioItem key="high" value="high">
              <DropdownMenu.ItemIndicator>
                <View style={{ width: 8, height: 8, borderRadius: 4, backgroundColor: '#007AFF' }} />
              </DropdownMenu.ItemIndicator>
              <DropdownMenu.ItemTitle>High (1080p)</DropdownMenu.ItemTitle>
            </DropdownMenu.RadioItem>
          </DropdownMenu.RadioGroup>
        </DropdownMenu.Group>
      </DropdownMenu.Content>
    </DropdownMenu.Root>
  );
}
```

### Example 4: Multi-Level Submenu Navigation

```typescript
import * as DropdownMenu from 'zeego/dropdown-menu';
import { Pressable, Text } from 'react-native';

export function NavigationMenu() {
  return (
    <DropdownMenu.Root>
      <DropdownMenu.Trigger>
        <Pressable style={{ padding: 12 }}>
          <Text>Menu</Text>
        </Pressable>
      </DropdownMenu.Trigger>

      <DropdownMenu.Content>
        <DropdownMenu.Item key="home" onSelect={() => console.log('Home')}>
          <DropdownMenu.ItemTitle>Home</DropdownMenu.ItemTitle>
        </DropdownMenu.Item>

        <DropdownMenu.Sub>
          <DropdownMenu.SubTrigger key="products">
            <DropdownMenu.ItemTitle>Products</DropdownMenu.ItemTitle>
          </DropdownMenu.SubTrigger>

          <DropdownMenu.SubContent>
            <DropdownMenu.Item key="electronics">
              <DropdownMenu.ItemTitle>Electronics</DropdownMenu.ItemTitle>
            </DropdownMenu.Item>

            <DropdownMenu.Sub>
              <DropdownMenu.SubTrigger key="clothing">
                <DropdownMenu.ItemTitle>Clothing</DropdownMenu.ItemTitle>
              </DropdownMenu.SubTrigger>

              <DropdownMenu.SubContent>
                <DropdownMenu.Item key="mens">
                  <DropdownMenu.ItemTitle>Men's</DropdownMenu.ItemTitle>
                </DropdownMenu.Item>
                <DropdownMenu.Item key="womens">
                  <DropdownMenu.ItemTitle>Women's</DropdownMenu.ItemTitle>
                </DropdownMenu.Item>
                <DropdownMenu.Item key="kids">
                  <DropdownMenu.ItemTitle>Kids</DropdownMenu.ItemTitle>
                </DropdownMenu.Item>
              </DropdownMenu.SubContent>
            </DropdownMenu.Sub>

            <DropdownMenu.Item key="home-goods">
              <DropdownMenu.ItemTitle>Home Goods</DropdownMenu.ItemTitle>
            </DropdownMenu.Item>
          </DropdownMenu.SubContent>
        </DropdownMenu.Sub>

        <DropdownMenu.Item key="about">
          <DropdownMenu.ItemTitle>About</DropdownMenu.ItemTitle>
        </DropdownMenu.Item>

        <DropdownMenu.Item key="contact">
          <DropdownMenu.ItemTitle>Contact</DropdownMenu.ItemTitle>
        </DropdownMenu.Item>
      </DropdownMenu.Content>
    </DropdownMenu.Root>
  );
}
```

### Example 5: TypeScript-Safe Menu with Full Type Annotations

```typescript
import * as DropdownMenu from 'zeego/dropdown-menu';
import { Pressable, Text, View } from 'react-native';
import { useState } from 'react';

type MenuAction = 'copy' | 'paste' | 'cut' | 'delete';
type MenuValue = 'on' | 'off';

interface MenuProps {
  onAction: (action: MenuAction) => void;
}

export function TypeSafeMenu({ onAction }: MenuProps) {
  const [lineNumbers, setLineNumbers] = useState<MenuValue>('on');
  const [wordWrap, setWordWrap] = useState<MenuValue>('off');

  const handleMenuAction = (action: MenuAction) => {
    return () => onAction(action);
  };

  return (
    <DropdownMenu.Root>
      <DropdownMenu.Trigger asChild>
        <Pressable style={{ padding: 8 }}>
          <Text>Edit</Text>
        </Pressable>
      </DropdownMenu.Trigger>

      <DropdownMenu.Content
        side="bottom"
        align="start"
        sideOffset={4}
      >
        <DropdownMenu.Group>
          <DropdownMenu.Item
            key="copy"
            onSelect={handleMenuAction('copy')}
          >
            <DropdownMenu.ItemTitle>Copy</DropdownMenu.ItemTitle>
            <DropdownMenu.ItemSubtitle>⌘C</DropdownMenu.ItemSubtitle>
          </DropdownMenu.Item>

          <DropdownMenu.Item
            key="paste"
            onSelect={handleMenuAction('paste')}
          >
            <DropdownMenu.ItemTitle>Paste</DropdownMenu.ItemTitle>
            <DropdownMenu.ItemSubtitle>⌘V</DropdownMenu.ItemSubtitle>
          </DropdownMenu.Item>

          <DropdownMenu.Item
            key="cut"
            onSelect={handleMenuAction('cut')}
          >
            <DropdownMenu.ItemTitle>Cut</DropdownMenu.ItemTitle>
            <DropdownMenu.ItemSubtitle>⌘X</DropdownMenu.ItemSubtitle>
          </DropdownMenu.Item>
        </DropdownMenu.Group>

        <DropdownMenu.Separator />

        <DropdownMenu.Group>
          <DropdownMenu.Label>View Options</DropdownMenu.Label>

          <DropdownMenu.CheckboxItem
            key="line-numbers"
            value={lineNumbers}
            onValueChange={(next, prev) => {
              console.log(`Line numbers: ${prev} -> ${next}`);
              setLineNumbers(next as MenuValue);
            }}
          >
            <DropdownMenu.ItemIndicator>
              <View style={{ width: 16, height: 16, backgroundColor: '#34C759' }} />
            </DropdownMenu.ItemIndicator>
            <DropdownMenu.ItemTitle>Show Line Numbers</DropdownMenu.ItemTitle>
          </DropdownMenu.CheckboxItem>

          <DropdownMenu.CheckboxItem
            key="word-wrap"
            value={wordWrap}
            onValueChange={(next, prev) => {
              console.log(`Word wrap: ${prev} -> ${next}`);
              setWordWrap(next as MenuValue);
            }}
          >
            <DropdownMenu.ItemIndicator>
              <View style={{ width: 16, height: 16, backgroundColor: '#34C759' }} />
            </DropdownMenu.ItemIndicator>
            <DropdownMenu.ItemTitle>Word Wrap</DropdownMenu.ItemTitle>
          </DropdownMenu.CheckboxItem>
        </DropdownMenu.Group>

        <DropdownMenu.Separator />

        <DropdownMenu.Item
          key="delete"
          destructive
          onSelect={handleMenuAction('delete')}
        >
          <DropdownMenu.ItemTitle>Delete</DropdownMenu.ItemTitle>
        </DropdownMenu.Item>
      </DropdownMenu.Content>
    </DropdownMenu.Root>
  );
}
```

## Resources

- [Zeego Documentation](https://zeego.dev/)
- [Zeego GitHub Repository](https://github.com/nandorojo/zeego)
- [Getting Started Guide](https://zeego.dev/start)
- [Dropdown Menu API](https://zeego.dev/components/dropdown-menu)
- [Context Menu API](https://zeego.dev/components/context-menu)
- [Radix UI Dropdown Menu](https://www.radix-ui.com/primitives/docs/components/dropdown-menu)
- [Radix UI Context Menu](https://www.radix-ui.com/primitives/docs/components/context-menu)
- [SF Symbols Browser](https://developer.apple.com/sf-symbols/)
- [React Native Menu (Android)](https://github.com/react-native-menu/menu)

## Tools & Commands

- `npm install zeego` - Install Zeego package
- `npm install react-native-ios-context-menu@3.1.0 react-native-ios-utilities@5.1.2 @react-native-menu/menu@1.2.2 --legacy-peer-deps` - Install peer dependencies
- `npx expo run:ios -d` - Rebuild iOS development client
- `npx expo run:android -d` - Rebuild Android development client
- `npx expo start --dev-client` - Start Expo with development client
- `pod install` - Install iOS CocoaPods (vanilla React Native)
- `DropdownMenu.create(component, 'PrimitiveName')` - Wrap custom components for native compatibility

## Troubleshooting

### Menu not appearing on iOS/Android

**Problem**: Menu components work on web but not on native platforms

**Solution**: Ensure peer dependencies are installed correctly and rebuild the development client with `npx expo run:ios -d`. Verify you're not using Expo Go (Zeego requires custom development client).

### Custom components not working on native

**Problem**: Styled components render on web but crash or don't work on iOS/Android

**Solution**: Wrap custom components with `DropdownMenu.create()` or `ContextMenu.create()`, passing the component and primitive name:
```typescript
const CustomItem = DropdownMenu.create(
  (props) => <DropdownMenu.Item {...props} style={{ height: 44 }} />,
  'Item'
);
```

### Type errors with CheckboxItem value

**Problem**: TypeScript errors when setting checkbox values with boolean

**Solution**: Use `'on' | 'off' | 'mixed'` instead of boolean values:
```typescript
const [checked, setChecked] = useState<'on' | 'off'>('on');
// Not: const [checked, setChecked] = useState(true);
```

### Icons not displaying on iOS

**Problem**: Menu items show no icons on iOS even when specified

**Solution**: Verify SF Symbol names are correct using Apple's SF Symbols app. Ensure the symbol is available in your iOS version:
```typescript
<DropdownMenu.ItemIcon
  ios={{
    name: 'gear', // Verify this symbol name
    pointSize: 18,
    weight: 'semibold'
  }}
/>
```

### Android menu styling issues

**Problem**: Menu appears unstyled or different from iOS/Web

**Solution**: Android uses system native menus with limited styling. Some features like ItemImage and ItemSubtitle are not supported. Use platform-specific rendering when needed:
```typescript
import { Platform } from 'react-native';

{Platform.OS !== 'android' && (
  <DropdownMenu.ItemImage source={{ uri: avatarUrl }} />
)}
```

### Peer dependency version conflicts

**Problem**: npm install fails with peer dependency errors

**Solution**: Use `--legacy-peer-deps` flag with npm:
```bash
npm install --legacy-peer-deps
```
Or use yarn/pnpm which handle peer dependencies more flexibly.

### Menu position incorrect on web

**Problem**: Dropdown or context menu appears in wrong position

**Solution**: Use Content positioning props to control placement:
```typescript
<DropdownMenu.Content
  side="bottom"        // 'top' | 'right' | 'bottom' | 'left'
  align="start"        // 'start' | 'center' | 'end'
  sideOffset={4}       // Gap from trigger
  alignOffset={0}      // Offset along align axis
  avoidCollisions={true}
/>
```

### RadioGroup not updating selection

**Problem**: Radio items don't show selected state

**Solution**: Ensure RadioGroup has `value` and `onValueChange` props, and RadioItem has ItemIndicator:
```typescript
<DropdownMenu.RadioGroup value={selected} onValueChange={setSelected}>
  <DropdownMenu.RadioItem value="option1">
    <DropdownMenu.ItemIndicator>
      <DotIcon />
    </DropdownMenu.ItemIndicator>
    <DropdownMenu.ItemTitle>Option 1</DropdownMenu.ItemTitle>
  </DropdownMenu.RadioItem>
</DropdownMenu.RadioGroup>
```

### Solito/Next.js integration errors

**Problem**: Build fails in Next.js monorepo

**Solution**: Add `zeego` to `transpilePackages` in `next.config.js`:
```javascript
module.exports = {
  transpilePackages: ['zeego', 'react-native', /* other packages */],
};
```

---

## Notes

- Zeego uses native menu implementations on iOS (UIMenu) and Android (androidx.appcompat.widget.PopupMenu) for optimal performance and platform consistency
- The `create()` function is essential for custom component styling on native platforms - without it, custom components won't render correctly
- CheckboxItem values are `'on' | 'off' | 'mixed'` not boolean - this matches native platform conventions
- ItemImage and ItemSubtitle are not available on Android due to platform limitations
- Separator and Arrow are web-only components (use groups for visual organization on native)
- SF Symbols on iOS support extensive customization (color, weight, scale, point size)
- Context menus support custom previews on iOS for rich interactive experiences
- The `asChild` prop on Trigger prevents adding extra wrapper views (useful for performance)
- onValueChange callbacks receive both next and previous values: `(next, prev) => void`
- Destructive prop makes items appear in red on iOS (platform convention for dangerous actions)
- Menu state can be controlled with `onOpenChange` callbacks for advanced use cases
- Zeego follows Radix UI patterns closely - Radix documentation is helpful for web-specific features
- Expo requires custom development client (not compatible with Expo Go)
- For Expo SDK 49 or earlier, additional configuration via `expo-build-properties` may be needed
