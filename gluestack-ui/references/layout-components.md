# Layout Components Reference

Comprehensive guide to layout components in Gluestack UI v2. These components help organize and structure your UI with flexbox-based layouts.

## Box

Universal container component with flexbox properties.

### Basic Usage

```typescript
import { Box } from '@/components/ui/box';

<Box p="$4" bg="$blue500" borderRadius="$md">
  <Text color="$white">This is a box</Text>
</Box>
```

### Flexbox Container

```typescript
// Row layout (default)
<Box flexDirection="row" alignItems="center" justifyContent="space-between">
  <Text>Left</Text>
  <Text>Right</Text>
</Box>

// Column layout
<Box flexDirection="column" gap="$4">
  <Text>Item 1</Text>
  <Text>Item 2</Text>
  <Text>Item 3</Text>
</Box>
```

### Spacing

```typescript
// Padding
<Box p="$4">Padding all sides</Box>
<Box px="$4" py="$2">Horizontal and vertical padding</Box>
<Box pt="$4" pb="$2" pl="$3" pr="$3">Individual sides</Box>

// Margin
<Box m="$4">Margin all sides</Box>
<Box mx="$4" my="$2">Horizontal and vertical margin</Box>
<Box mt="$4" mb="$2" ml="$3" mr="$3">Individual sides</Box>

// Gap (for flex children)
<Box flexDirection="row" gap="$4">
  <Text>Item 1</Text>
  <Text>Item 2</Text>
</Box>
```

### Sizing

```typescript
// Fixed size
<Box width={200} height={100} bg="$blue500" />

// Percentage
<Box width="100%" height={100} bg="$blue500" />

// Design tokens
<Box width="$full" height="$32" bg="$blue500" />

// Min/Max sizing
<Box minWidth={200} maxWidth={400} minHeight={100} maxHeight={300}>
  <Text>Constrained box</Text>
</Box>
```

### Colors and Borders

```typescript
// Background color
<Box bg="$blue500" p="$4">
  <Text color="$white">Colored background</Text>
</Box>

// Borders
<Box borderWidth="$1" borderColor="$gray300" borderRadius="$md" p="$4">
  <Text>Box with border</Text>
</Box>

// Individual border sides
<Box
  borderTopWidth="$2"
  borderTopColor="$blue500"
  borderBottomWidth="$1"
  borderBottomColor="$gray300"
  p="$4"
>
  <Text>Custom borders</Text>
</Box>

// Border radius
<Box borderRadius="$none">No radius</Box>
<Box borderRadius="$sm">Small radius</Box>
<Box borderRadius="$md">Medium radius</Box>
<Box borderRadius="$lg">Large radius</Box>
<Box borderRadius="$full">Full radius (circle/pill)</Box>
```

### Shadows

```typescript
// Shadow depths
<Box shadowColor="$black" shadowOpacity={0.1} shadowRadius="$sm" shadowOffset={{width: 0, height: 2}}>
  <Text>Box with shadow</Text>
</Box>

// Using elevation (Android)
<Box elevation={3} p="$4">
  <Text>Box with elevation</Text>
</Box>
```

### Positioning

```typescript
// Relative positioning
<Box position="relative" width={200} height={200} bg="$gray100">
  <Box position="absolute" top={10} left={10} bg="$blue500" p="$2">
    <Text color="$white">Absolute</Text>
  </Box>
</Box>

// Z-index
<Box position="relative" zIndex={10}>
  <Text>Higher z-index</Text>
</Box>
```

### Responsive Props

```typescript
<Box
  p="$4"
  width={{
    base: '100%',
    sm: '80%',
    md: '60%',
    lg: '40%',
  }}
  bg={{
    base: '$blue500',
    md: '$green500',
  }}
>
  <Text>Responsive box</Text>
</Box>
```

## VStack

Vertical stack component with automatic spacing.

### Basic Usage

```typescript
import { VStack } from '@/components/ui/vstack';

<VStack space="md">
  <Text>Item 1</Text>
  <Text>Item 2</Text>
  <Text>Item 3</Text>
</VStack>
```

### Spacing Options

```typescript
<VStack space="xs"><Text>Extra small spacing</Text></VStack>
<VStack space="sm"><Text>Small spacing</Text></VStack>
<VStack space="md"><Text>Medium spacing</Text></VStack>
<VStack space="lg"><Text>Large spacing</Text></VStack>
<VStack space="xl"><Text>Extra large spacing</Text></VStack>
```

### Alignment

```typescript
// Horizontal alignment (cross-axis)
<VStack space="md" alignItems="flex-start">
  <Text>Aligned left</Text>
  <Text>Aligned left</Text>
</VStack>

<VStack space="md" alignItems="center">
  <Text>Centered</Text>
  <Text>Centered</Text>
</VStack>

<VStack space="md" alignItems="flex-end">
  <Text>Aligned right</Text>
  <Text>Aligned right</Text>
</VStack>

// Vertical alignment (main-axis)
<VStack space="md" justifyContent="center" height={400}>
  <Text>Vertically centered</Text>
</VStack>

<VStack space="md" justifyContent="space-between" height={400}>
  <Text>Top</Text>
  <Text>Bottom</Text>
</VStack>
```

### Reversed Order

```typescript
<VStack space="md" reversed>
  <Text>Item 1 (displays last)</Text>
  <Text>Item 2 (displays middle)</Text>
  <Text>Item 3 (displays first)</Text>
</VStack>
```

### Form Layout Example

```typescript
<VStack space="lg" p="$4">
  <FormControl>
    <FormControlLabel>
      <FormControlLabelText>Name</FormControlLabelText>
    </FormControlLabel>
    <Input>
      <InputField placeholder="Enter name" />
    </Input>
  </FormControl>

  <FormControl>
    <FormControlLabel>
      <FormControlLabelText>Email</FormControlLabelText>
    </FormControlLabel>
    <Input>
      <InputField placeholder="Enter email" />
    </Input>
  </FormControl>

  <Button>
    <ButtonText>Submit</ButtonText>
  </Button>
</VStack>
```

## HStack

Horizontal stack component with automatic spacing.

### Basic Usage

```typescript
import { HStack } from '@/components/ui/hstack';

<HStack space="md">
  <Text>Item 1</Text>
  <Text>Item 2</Text>
  <Text>Item 3</Text>
</HStack>
```

### Spacing Options

```typescript
<HStack space="xs"><Text>Extra small</Text><Text>spacing</Text></HStack>
<HStack space="sm"><Text>Small</Text><Text>spacing</Text></HStack>
<HStack space="md"><Text>Medium</Text><Text>spacing</Text></HStack>
<HStack space="lg"><Text>Large</Text><Text>spacing</Text></HStack>
<HStack space="xl"><Text>Extra large</Text><Text>spacing</Text></HStack>
```

### Alignment

```typescript
// Vertical alignment (cross-axis)
<HStack space="md" alignItems="flex-start">
  <Text>Top aligned</Text>
  <Text fontSize="$2xl">Top aligned</Text>
</HStack>

<HStack space="md" alignItems="center">
  <Text>Center aligned</Text>
  <Text fontSize="$2xl">Center aligned</Text>
</HStack>

<HStack space="md" alignItems="flex-end">
  <Text>Bottom aligned</Text>
  <Text fontSize="$2xl">Bottom aligned</Text>
</HStack>

// Horizontal alignment (main-axis)
<HStack space="md" justifyContent="space-between" width="$full">
  <Text>Left</Text>
  <Text>Right</Text>
</HStack>
```

### Button Group Example

```typescript
<HStack space="sm">
  <Button variant="solid">
    <ButtonText>Save</ButtonText>
  </Button>
  <Button variant="outline">
    <ButtonText>Cancel</ButtonText>
  </Button>
  <Button variant="link">
    <ButtonText>Reset</ButtonText>
  </Button>
</HStack>
```

### Icon with Text Example

```typescript
<HStack space="sm" alignItems="center">
  <Icon as={InfoIcon} size="xl" color="$blue500" />
  <VStack>
    <Heading size="sm">Information</Heading>
    <Text size="sm" color="$gray600">Additional context here</Text>
  </VStack>
</HStack>
```

### Navigation Bar Example

```typescript
<HStack
  space="md"
  justifyContent="space-between"
  alignItems="center"
  p="$4"
  bg="$white"
  borderBottomWidth="$1"
  borderBottomColor="$gray200"
>
  <Button variant="link">
    <Icon as={MenuIcon} />
  </Button>
  <Heading size="md">App Title</Heading>
  <Button variant="link">
    <Icon as={SettingsIcon} />
  </Button>
</HStack>
```

## Center

Component for centering content both horizontally and vertically.

### Basic Usage

```typescript
import { Center } from '@/components/ui/center';

<Center height={200} bg="$gray100">
  <Text>Centered content</Text>
</Center>
```

### Full Screen Center

```typescript
<Center flex={1}>
  <VStack space="md" alignItems="center">
    <Spinner size="large" />
    <Text>Loading...</Text>
  </VStack>
</Center>
```

### Empty State Example

```typescript
<Center flex={1} p="$4">
  <VStack space="lg" alignItems="center" maxWidth={300}>
    <Icon as={InboxIcon} size="4xl" color="$gray400" />
    <VStack space="sm" alignItems="center">
      <Heading size="lg">No Items</Heading>
      <Text textAlign="center" color="$gray600">
        You don't have any items yet. Create your first one to get started.
      </Text>
    </VStack>
    <Button>
      <ButtonText>Create Item</ButtonText>
    </Button>
  </VStack>
</Center>
```

### Card with Centered Content

```typescript
<Box borderWidth="$1" borderColor="$gray200" borderRadius="$lg" p="$6">
  <Center>
    <VStack space="md" alignItems="center">
      <Avatar size="xl" />
      <Heading>John Doe</Heading>
      <Text color="$gray600">john@example.com</Text>
      <Button size="sm">
        <ButtonText>Edit Profile</ButtonText>
      </Button>
    </VStack>
  </Center>
</Box>
```

## Divider

Visual separator component for dividing content.

### Basic Usage

```typescript
import { Divider } from '@/components/ui/divider';

<VStack space="md">
  <Text>Section 1</Text>
  <Divider />
  <Text>Section 2</Text>
</VStack>
```

### Vertical Divider

```typescript
<HStack space="md" height={100}>
  <Text>Left</Text>
  <Divider orientation="vertical" />
  <Text>Right</Text>
</HStack>
```

### Styled Divider

```typescript
// Thick divider
<Divider thickness={2} />

// Colored divider
<Divider bg="$blue500" />

// Dashed divider
<Divider borderStyle="dashed" />

// With margin
<Divider my="$4" />
```

### Divider in Menu

```typescript
<VStack space="xs">
  <Button variant="link"><ButtonText>Edit</ButtonText></Button>
  <Button variant="link"><ButtonText>Duplicate</ButtonText></Button>
  <Divider my="$2" />
  <Button variant="link"><ButtonText color="$red600">Delete</ButtonText></Button>
</VStack>
```

## Grid

Grid layout component for responsive layouts.

### Basic Grid

```typescript
import { Grid, GridItem } from '@/components/ui/grid';

<Grid columns={3} gap="$4">
  <GridItem><Box bg="$blue500" p="$4"><Text color="$white">1</Text></Box></GridItem>
  <GridItem><Box bg="$blue500" p="$4"><Text color="$white">2</Text></Box></GridItem>
  <GridItem><Box bg="$blue500" p="$4"><Text color="$white">3</Text></Box></GridItem>
  <GridItem><Box bg="$blue500" p="$4"><Text color="$white">4</Text></Box></GridItem>
  <GridItem><Box bg="$blue500" p="$4"><Text color="$white">5</Text></Box></GridItem>
  <GridItem><Box bg="$blue500" p="$4"><Text color="$white">6</Text></Box></GridItem>
</Grid>
```

### Responsive Grid

```typescript
<Grid
  columns={{
    base: 1,
    sm: 2,
    md: 3,
    lg: 4,
  }}
  gap="$4"
>
  {items.map((item) => (
    <GridItem key={item.id}>
      <Card>
        <CardBody>
          <Text>{item.title}</Text>
        </CardBody>
      </Card>
    </GridItem>
  ))}
</Grid>
```

### Grid with Column Span

```typescript
<Grid columns={3} gap="$4">
  <GridItem colSpan={3}>
    <Box bg="$blue500" p="$4"><Text color="$white">Full width header</Text></Box>
  </GridItem>
  <GridItem colSpan={2}>
    <Box bg="$green500" p="$4"><Text color="$white">Main content</Text></Box>
  </GridItem>
  <GridItem colSpan={1}>
    <Box bg="$yellow500" p="$4"><Text color="$white">Sidebar</Text></Box>
  </GridItem>
  <GridItem colSpan={3}>
    <Box bg="$red500" p="$4"><Text color="$white">Footer</Text></Box>
  </GridItem>
</Grid>
```

### Image Gallery Grid

```typescript
<Grid columns={3} gap="$2">
  {images.map((image) => (
    <GridItem key={image.id}>
      <Box aspectRatio={1} bg="$gray200" borderRadius="$md" overflow="hidden">
        <Image source={{ uri: image.url }} style={{ width: '100%', height: '100%' }} />
      </Box>
    </GridItem>
  ))}
</Grid>
```

## Common Layout Patterns

### Card with Actions

```typescript
<Box
  borderWidth="$1"
  borderColor="$gray200"
  borderRadius="$lg"
  overflow="hidden"
>
  <VStack space="md">
    <Box p="$4">
      <VStack space="sm">
        <Heading size="md">Card Title</Heading>
        <Text color="$gray600">Card description goes here</Text>
      </VStack>
    </Box>
    <Divider />
    <Box p="$4">
      <HStack space="sm" justifyContent="flex-end">
        <Button variant="outline" size="sm">
          <ButtonText>Cancel</ButtonText>
        </Button>
        <Button size="sm">
          <ButtonText>Confirm</ButtonText>
        </Button>
      </HStack>
    </Box>
  </VStack>
</Box>
```

### List Item

```typescript
<Box
  borderBottomWidth="$1"
  borderBottomColor="$gray200"
  py="$3"
>
  <HStack space="md" alignItems="center" justifyContent="space-between">
    <HStack space="md" alignItems="center" flex={1}>
      <Avatar size="md" />
      <VStack flex={1}>
        <Heading size="sm">John Doe</Heading>
        <Text size="sm" color="$gray600">Last seen 2 hours ago</Text>
      </VStack>
    </HStack>
    <Icon as={ChevronRightIcon} color="$gray400" />
  </HStack>
</Box>
```

### Stats Grid

```typescript
<Grid columns={2} gap="$4">
  {[
    { label: 'Users', value: '1,234', icon: UsersIcon },
    { label: 'Revenue', value: '$5,678', icon: DollarIcon },
    { label: 'Orders', value: '890', icon: ShoppingIcon },
    { label: 'Growth', value: '+12%', icon: TrendingUpIcon },
  ].map((stat) => (
    <GridItem key={stat.label}>
      <Box
        bg="$white"
        borderWidth="$1"
        borderColor="$gray200"
        borderRadius="$lg"
        p="$4"
      >
        <VStack space="sm">
          <Icon as={stat.icon} size="xl" color="$blue500" />
          <Text size="2xl" fontWeight="$bold">{stat.value}</Text>
          <Text size="sm" color="$gray600">{stat.label}</Text>
        </VStack>
      </Box>
    </GridItem>
  ))}
</Grid>
```

## Best Practices

**Layout Components:**
- Use Box for generic containers with flexbox
- Use VStack/HStack for stacked layouts with consistent spacing
- Use Center for centering content
- Use Divider to separate sections
- Use Grid for responsive grid layouts
- Keep nesting shallow for better performance
- Use design tokens for consistent spacing
- Test responsive layouts on multiple screen sizes

**Performance:**
- Avoid excessive nesting of layout components
- Use FlatList for long scrollable lists instead of VStack
- Memoize complex layout calculations
- Use absolute positioning sparingly
- Avoid inline styles when possible

**Accessibility:**
- Maintain logical reading order
- Ensure sufficient touch target sizes (minimum 44x44)
- Use semantic HTML elements on web
- Test keyboard navigation
- Ensure color contrast in layouts
