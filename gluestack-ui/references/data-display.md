# Data Display Components Reference

Comprehensive guide to data display components in Gluestack UI v2. These components present information in structured, visually appealing formats.

## Avatar

User profile image component with fallback support.

### Basic Usage

```typescript
import { Avatar, AvatarFallbackText, AvatarImage } from '@/components/ui/avatar';

<Avatar>
  <AvatarFallbackText>John Doe</AvatarFallbackText>
  <AvatarImage
    source={{ uri: 'https://example.com/avatar.jpg' }}
  />
</Avatar>
```

### Avatar Sizes

```typescript
<HStack space="md" alignItems="center">
  <Avatar size="xs">
    <AvatarFallbackText>JD</AvatarFallbackText>
  </Avatar>
  <Avatar size="sm">
    <AvatarFallbackText>JD</AvatarFallbackText>
  </Avatar>
  <Avatar size="md">
    <AvatarFallbackText>JD</AvatarFallbackText>
  </Avatar>
  <Avatar size="lg">
    <AvatarFallbackText>JD</AvatarFallbackText>
  </Avatar>
  <Avatar size="xl">
    <AvatarFallbackText>JD</AvatarFallbackText>
  </Avatar>
  <Avatar size="2xl">
    <AvatarFallbackText>JD</AvatarFallbackText>
  </Avatar>
</HStack>
```

### Avatar with Badge

```typescript
import { Avatar, AvatarFallbackText, AvatarImage, AvatarBadge } from '@/components/ui/avatar';

<Avatar>
  <AvatarFallbackText>John Doe</AvatarFallbackText>
  <AvatarImage source={{ uri: avatarUrl }} />
  <AvatarBadge bg="$green500" />
</Avatar>
```

### Avatar Group

```typescript
import { AvatarGroup } from '@/components/ui/avatar';

<AvatarGroup>
  <Avatar>
    <AvatarFallbackText>John Doe</AvatarFallbackText>
    <AvatarImage source={{ uri: 'avatar1.jpg' }} />
  </Avatar>
  <Avatar>
    <AvatarFallbackText>Jane Smith</AvatarFallbackText>
    <AvatarImage source={{ uri: 'avatar2.jpg' }} />
  </Avatar>
  <Avatar>
    <AvatarFallbackText>Bob Johnson</AvatarFallbackText>
    <AvatarImage source={{ uri: 'avatar3.jpg' }} />
  </Avatar>
</AvatarGroup>
```

### Avatar Group with Max Count

```typescript
<AvatarGroup max={3}>
  {users.map((user) => (
    <Avatar key={user.id}>
      <AvatarFallbackText>{user.name}</AvatarFallbackText>
      <AvatarImage source={{ uri: user.avatar }} />
    </Avatar>
  ))}
</AvatarGroup>

// Shows first 3 avatars and "+X more" indicator
```

### Custom Fallback

```typescript
<Avatar bg="$blue500">
  <AvatarFallbackText color="$white">JD</AvatarFallbackText>
</Avatar>

<Avatar>
  <Icon as={UserIcon} color="$gray500" />
</Avatar>
```

### Avatar with Status

```typescript
<Box position="relative">
  <Avatar size="xl">
    <AvatarFallbackText>John Doe</AvatarFallbackText>
    <AvatarImage source={{ uri: avatarUrl }} />
  </Avatar>
  <Box
    position="absolute"
    bottom={0}
    right={0}
    bg="$green500"
    borderRadius="$full"
    width={16}
    height={16}
    borderWidth={2}
    borderColor="$white"
  />
</Box>
```

## Badge

Small count or status indicator.

### Basic Usage

```typescript
import { Badge, BadgeText, BadgeIcon } from '@/components/ui/badge';

<Badge>
  <BadgeText>New</BadgeText>
</Badge>
```

### Badge Variants

```typescript
// Solid (default)
<Badge variant="solid" action="info">
  <BadgeText>Info</BadgeText>
</Badge>

// Outline
<Badge variant="outline" action="success">
  <BadgeText>Success</BadgeText>
</Badge>

// Subtle
<Badge variant="subtle" action="warning">
  <BadgeText>Warning</BadgeText>
</Badge>
```

### Badge Actions (Colors)

```typescript
<HStack space="sm">
  <Badge action="info"><BadgeText>Info</BadgeText></Badge>
  <Badge action="success"><BadgeText>Success</BadgeText></Badge>
  <Badge action="warning"><BadgeText>Warning</BadgeText></Badge>
  <Badge action="error"><BadgeText>Error</BadgeText></Badge>
  <Badge action="muted"><BadgeText>Muted</BadgeText></Badge>
</HStack>
```

### Badge Sizes

```typescript
<HStack space="sm" alignItems="center">
  <Badge size="sm"><BadgeText>Small</BadgeText></Badge>
  <Badge size="md"><BadgeText>Medium</BadgeText></Badge>
  <Badge size="lg"><BadgeText>Large</BadgeText></Badge>
</HStack>
```

### Badge with Icon

```typescript
import { CheckIcon } from '@gluestack-ui/themed';

<Badge action="success">
  <BadgeIcon as={CheckIcon} mr="$1" />
  <BadgeText>Verified</BadgeText>
</Badge>
```

### Notification Badge

```typescript
<Box position="relative">
  <Button>
    <ButtonIcon as={BellIcon} />
  </Button>
  <Badge
    position="absolute"
    top={-8}
    right={-8}
    variant="solid"
    action="error"
    borderRadius="$full"
    minWidth={20}
    height={20}
    alignItems="center"
    justifyContent="center"
  >
    <BadgeText fontSize={10}>5</BadgeText>
  </Badge>
</Box>
```

### Status Badge

```typescript
<HStack space="sm" alignItems="center">
  <Badge variant="solid" action="success" borderRadius="$full" px="$2">
    <BadgeText>Active</BadgeText>
  </Badge>
  <Badge variant="solid" action="muted" borderRadius="$full" px="$2">
    <BadgeText>Inactive</BadgeText>
  </Badge>
  <Badge variant="solid" action="warning" borderRadius="$full" px="$2">
    <BadgeText>Pending</BadgeText>
  </Badge>
</HStack>
```

## Card

Container component for related content.

### Basic Usage

```typescript
import {
  Card,
  CardHeader,
  CardBody,
  CardFooter,
} from '@/components/ui/card';

<Card>
  <CardHeader>
    <Heading size="md">Card Title</Heading>
  </CardHeader>
  <CardBody>
    <Text>Card content goes here</Text>
  </CardBody>
  <CardFooter>
    <Button><ButtonText>Action</ButtonText></Button>
  </CardFooter>
</Card>
```

### Card Variants

```typescript
// Elevated (default) - with shadow
<Card variant="elevated">
  <CardBody>
    <Text>Elevated card with shadow</Text>
  </CardBody>
</Card>

// Outline - with border
<Card variant="outline">
  <CardBody>
    <Text>Card with border</Text>
  </CardBody>
</Card>

// Filled - with background
<Card variant="filled">
  <CardBody>
    <Text>Card with filled background</Text>
  </CardBody>
</Card>
```

### Card with Image

```typescript
<Card maxWidth={350}>
  <Image
    source={{ uri: 'https://example.com/image.jpg' }}
    height={200}
    width="100%"
    borderTopLeftRadius="$lg"
    borderTopRightRadius="$lg"
  />
  <CardBody>
    <VStack space="sm">
      <Heading size="md">Beautiful Landscape</Heading>
      <Text color="$gray600">
        A stunning view of mountains at sunset
      </Text>
    </VStack>
  </CardBody>
  <CardFooter>
    <Button>
      <ButtonText>View Details</ButtonText>
    </Button>
  </CardFooter>
</Card>
```

### Product Card

```typescript
<Card maxWidth={300}>
  <Image
    source={{ uri: productImage }}
    height={200}
    width="100%"
    borderTopLeftRadius="$lg"
    borderTopRightRadius="$lg"
  />
  <CardBody>
    <VStack space="sm">
      <HStack justifyContent="space-between" alignItems="center">
        <Heading size="md">Product Name</Heading>
        <Badge action="success">
          <BadgeText>New</BadgeText>
        </Badge>
      </HStack>
      <Text color="$gray600" numberOfLines={2}>
        Product description goes here
      </Text>
      <HStack justifyContent="space-between" alignItems="center">
        <Heading size="lg" color="$blue600">$99.99</Heading>
        <HStack space="xs" alignItems="center">
          <Icon as={StarIcon} size="sm" color="$yellow500" />
          <Text size="sm">4.5 (120)</Text>
        </HStack>
      </HStack>
    </VStack>
  </CardBody>
  <CardFooter>
    <Button width="$full">
      <ButtonText>Add to Cart</ButtonText>
    </Button>
  </CardFooter>
</Card>
```

### User Profile Card

```typescript
<Card>
  <CardBody>
    <VStack space="md" alignItems="center">
      <Avatar size="2xl">
        <AvatarFallbackText>John Doe</AvatarFallbackText>
        <AvatarImage source={{ uri: avatarUrl }} />
      </Avatar>
      <VStack space="xs" alignItems="center">
        <Heading size="lg">John Doe</Heading>
        <Text color="$gray600">Senior Developer</Text>
      </VStack>
      <HStack space="lg">
        <VStack alignItems="center">
          <Heading size="md">1.2K</Heading>
          <Text size="sm" color="$gray600">Followers</Text>
        </VStack>
        <VStack alignItems="center">
          <Heading size="md">345</Heading>
          <Text size="sm" color="$gray600">Following</Text>
        </VStack>
      </HStack>
      <HStack space="sm" width="$full">
        <Button flex={1}>
          <ButtonText>Follow</ButtonText>
        </Button>
        <Button flex={1} variant="outline">
          <ButtonText>Message</ButtonText>
        </Button>
      </HStack>
    </VStack>
  </CardBody>
</Card>
```

### Horizontal Card

```typescript
<Card flexDirection="row">
  <Image
    source={{ uri: imageUrl }}
    width={120}
    height="100%"
    borderTopLeftRadius="$lg"
    borderBottomLeftRadius="$lg"
  />
  <CardBody flex={1}>
    <VStack space="sm" justifyContent="space-between" height="100%">
      <VStack space="xs">
        <Heading size="md">Article Title</Heading>
        <Text color="$gray600" numberOfLines={2}>
          Brief description of the article content
        </Text>
      </VStack>
      <Text size="sm" color="$gray500">5 min read</Text>
    </VStack>
  </CardBody>
</Card>
```

## Table

Data table component for structured information.

### Basic Usage

```typescript
import {
  Table,
  TableHeader,
  TableBody,
  TableHead,
  TableRow,
  TableData,
} from '@/components/ui/table';

<Table>
  <TableHeader>
    <TableRow>
      <TableHead>Name</TableHead>
      <TableHead>Email</TableHead>
      <TableHead>Role</TableHead>
    </TableRow>
  </TableHeader>
  <TableBody>
    <TableRow>
      <TableData>John Doe</TableData>
      <TableData>john@example.com</TableData>
      <TableData>Admin</TableData>
    </TableRow>
    <TableRow>
      <TableData>Jane Smith</TableData>
      <TableData>jane@example.com</TableData>
      <TableData>User</TableData>
    </TableRow>
  </TableBody>
</Table>
```

### Striped Table

```typescript
<Table variant="striped">
  <TableHeader>
    <TableRow>
      <TableHead>Product</TableHead>
      <TableHead>Price</TableHead>
      <TableHead>Stock</TableHead>
    </TableRow>
  </TableHeader>
  <TableBody>
    {products.map((product) => (
      <TableRow key={product.id}>
        <TableData>{product.name}</TableData>
        <TableData>${product.price}</TableData>
        <TableData>{product.stock}</TableData>
      </TableRow>
    ))}
  </TableBody>
</Table>
```

### Table with Actions

```typescript
<Table>
  <TableHeader>
    <TableRow>
      <TableHead>Name</TableHead>
      <TableHead>Status</TableHead>
      <TableHead>Actions</TableHead>
    </TableRow>
  </TableHeader>
  <TableBody>
    {users.map((user) => (
      <TableRow key={user.id}>
        <TableData>
          <HStack space="sm" alignItems="center">
            <Avatar size="sm">
              <AvatarFallbackText>{user.name}</AvatarFallbackText>
            </Avatar>
            <Text>{user.name}</Text>
          </HStack>
        </TableData>
        <TableData>
          <Badge action={user.active ? 'success' : 'muted'}>
            <BadgeText>{user.active ? 'Active' : 'Inactive'}</BadgeText>
          </Badge>
        </TableData>
        <TableData>
          <HStack space="xs">
            <Button size="sm" variant="link">
              <Icon as={EditIcon} />
            </Button>
            <Button size="sm" variant="link">
              <Icon as={TrashIcon} color="$red600" />
            </Button>
          </HStack>
        </TableData>
      </TableRow>
    ))}
  </TableBody>
</Table>
```

### Responsive Table (ScrollView)

```typescript
<ScrollView horizontal>
  <Table minWidth={800}>
    <TableHeader>
      <TableRow>
        <TableHead>ID</TableHead>
        <TableHead>Name</TableHead>
        <TableHead>Email</TableHead>
        <TableHead>Phone</TableHead>
        <TableHead>Address</TableHead>
        <TableHead>Actions</TableHead>
      </TableRow>
    </TableHeader>
    <TableBody>
      {/* table rows */}
    </TableBody>
  </Table>
</ScrollView>
```

## Accordion

Collapsible content panels.

### Basic Usage

```typescript
import {
  Accordion,
  AccordionItem,
  AccordionTrigger,
  AccordionTriggerText,
  AccordionContent,
  AccordionContentText,
  AccordionIcon,
} from '@/components/ui/accordion';
import { ChevronDownIcon } from '@gluestack-ui/themed';

<Accordion>
  <AccordionItem value="item-1">
    <AccordionTrigger>
      <AccordionTriggerText>What is Gluestack UI?</AccordionTriggerText>
      <AccordionIcon as={ChevronDownIcon} />
    </AccordionTrigger>
    <AccordionContent>
      <AccordionContentText>
        Gluestack UI is a universal component library for React Native and React.
      </AccordionContentText>
    </AccordionContent>
  </AccordionItem>

  <AccordionItem value="item-2">
    <AccordionTrigger>
      <AccordionTriggerText>How do I install it?</AccordionTriggerText>
      <AccordionIcon as={ChevronDownIcon} />
    </AccordionTrigger>
    <AccordionContent>
      <AccordionContentText>
        Run: npx gluestack-ui add [component-name]
      </AccordionContentText>
    </AccordionContent>
  </AccordionItem>
</Accordion>
```

### Single Expand Accordion

```typescript
<Accordion type="single" collapsible>
  <AccordionItem value="item-1">
    <AccordionTrigger>
      <AccordionTriggerText>Section 1</AccordionTriggerText>
      <AccordionIcon as={ChevronDownIcon} />
    </AccordionTrigger>
    <AccordionContent>
      <AccordionContentText>Content for section 1</AccordionContentText>
    </AccordionContent>
  </AccordionItem>

  <AccordionItem value="item-2">
    <AccordionTrigger>
      <AccordionTriggerText>Section 2</AccordionTriggerText>
      <AccordionIcon as={ChevronDownIcon} />
    </AccordionTrigger>
    <AccordionContent>
      <AccordionContentText>Content for section 2</AccordionContentText>
    </AccordionContent>
  </AccordionItem>
</Accordion>
```

### Multiple Expand Accordion

```typescript
<Accordion type="multiple">
  {/* Multiple items can be expanded simultaneously */}
  <AccordionItem value="item-1">
    <AccordionTrigger>
      <AccordionTriggerText>Section 1</AccordionTriggerText>
      <AccordionIcon as={ChevronDownIcon} />
    </AccordionTrigger>
    <AccordionContent>
      <AccordionContentText>Content 1</AccordionContentText>
    </AccordionContent>
  </AccordionItem>

  <AccordionItem value="item-2">
    <AccordionTrigger>
      <AccordionTriggerText>Section 2</AccordionTriggerText>
      <AccordionIcon as={ChevronDownIcon} />
    </AccordionTrigger>
    <AccordionContent>
      <AccordionContentText>Content 2</AccordionContentText>
    </AccordionContent>
  </AccordionItem>
</Accordion>
```

### FAQ Accordion

```typescript
const faqs = [
  {
    question: 'What payment methods do you accept?',
    answer: 'We accept all major credit cards, PayPal, and bank transfers.',
  },
  {
    question: 'How long does shipping take?',
    answer: 'Standard shipping takes 5-7 business days. Express shipping is 2-3 days.',
  },
  {
    question: 'What is your return policy?',
    answer: '30-day money-back guarantee on all products.',
  },
];

<Accordion type="single" collapsible>
  {faqs.map((faq, index) => (
    <AccordionItem key={index} value={`faq-${index}`}>
      <AccordionTrigger>
        <AccordionTriggerText>{faq.question}</AccordionTriggerText>
        <AccordionIcon as={ChevronDownIcon} />
      </AccordionTrigger>
      <AccordionContent>
        <AccordionContentText>{faq.answer}</AccordionContentText>
      </AccordionContent>
    </AccordionItem>
  ))}
</Accordion>
```

### Nested Accordion

```typescript
<Accordion>
  <AccordionItem value="parent-1">
    <AccordionTrigger>
      <AccordionTriggerText>Parent Item</AccordionTriggerText>
      <AccordionIcon as={ChevronDownIcon} />
    </AccordionTrigger>
    <AccordionContent>
      <Accordion>
        <AccordionItem value="child-1">
          <AccordionTrigger>
            <AccordionTriggerText>Child Item 1</AccordionTriggerText>
            <AccordionIcon as={ChevronDownIcon} />
          </AccordionTrigger>
          <AccordionContent>
            <AccordionContentText>Nested content</AccordionContentText>
          </AccordionContent>
        </AccordionItem>
      </Accordion>
    </AccordionContent>
  </AccordionItem>
</Accordion>
```

## Best Practices

**Data Display Components:**
- Use Avatar for user representation with fallback text
- Use Badge for counts, status, and labels
- Use Card to group related content
- Use Table for structured tabular data
- Use Accordion for collapsible FAQ or settings
- Keep card content focused and scannable
- Use appropriate avatar sizes for context
- Show loading states for async data
- Implement pagination for large tables
- Use proper semantic HTML on web

**Performance:**
- Virtualize long lists (use FlatList, not Table)
- Lazy load images in cards
- Memoize table rows for large datasets
- Avoid deep nesting in accordions
- Use keys properly in mapped components
- Optimize avatar images (size, format)

**Accessibility:**
- Provide meaningful fallback text for avatars
- Use descriptive badge labels
- Ensure table headers are properly marked
- Make accordion triggers keyboard accessible
- Ensure sufficient color contrast
- Provide alt text for card images
- Test with screen readers
