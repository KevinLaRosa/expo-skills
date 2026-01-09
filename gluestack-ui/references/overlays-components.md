# Overlay Components Reference

Comprehensive guide to overlay components in Gluestack UI v2. These components render above the main content for dialogs, menus, popovers, and tooltips.

## Modal

Full-screen or centered dialog component for focused user interactions.

### Basic Usage

```typescript
import {
  Modal,
  ModalBackdrop,
  ModalContent,
  ModalHeader,
  ModalCloseButton,
  ModalBody,
  ModalFooter,
} from '@/components/ui/modal';
import { Button, ButtonText } from '@/components/ui/button';
import { CloseIcon } from '@gluestack-ui/themed';

const [showModal, setShowModal] = useState(false);

<>
  <Button onPress={() => setShowModal(true)}>
    <ButtonText>Open Modal</ButtonText>
  </Button>

  <Modal isOpen={showModal} onClose={() => setShowModal(false)}>
    <ModalBackdrop />
    <ModalContent>
      <ModalHeader>
        <Heading size="lg">Modal Title</Heading>
        <ModalCloseButton>
          <Icon as={CloseIcon} />
        </ModalCloseButton>
      </ModalHeader>
      <ModalBody>
        <Text>This is the modal content.</Text>
      </ModalBody>
      <ModalFooter>
        <Button variant="outline" onPress={() => setShowModal(false)}>
          <ButtonText>Cancel</ButtonText>
        </Button>
        <Button onPress={() => setShowModal(false)}>
          <ButtonText>Confirm</ButtonText>
        </Button>
      </ModalFooter>
    </ModalContent>
  </Modal>
</>
```

### Modal Sizes

```typescript
// Small modal
<Modal isOpen={showModal} onClose={() => setShowModal(false)} size="sm">
  <ModalBackdrop />
  <ModalContent>
    {/* content */}
  </ModalContent>
</Modal>

// Medium (default)
<Modal isOpen={showModal} onClose={() => setShowModal(false)} size="md">
  {/* content */}
</Modal>

// Large
<Modal isOpen={showModal} onClose={() => setShowModal(false)} size="lg">
  {/* content */}
</Modal>

// Full screen
<Modal isOpen={showModal} onClose={() => setShowModal(false)} size="full">
  {/* content */}
</Modal>
```

### Form in Modal

```typescript
const [email, setEmail] = useState('');
const [password, setPassword] = useState('');

<Modal isOpen={showModal} onClose={() => setShowModal(false)}>
  <ModalBackdrop />
  <ModalContent>
    <ModalHeader>
      <Heading>Sign In</Heading>
      <ModalCloseButton>
        <Icon as={CloseIcon} />
      </ModalCloseButton>
    </ModalHeader>
    <ModalBody>
      <VStack space="md">
        <FormControl>
          <FormControlLabel>
            <FormControlLabelText>Email</FormControlLabelText>
          </FormControlLabel>
          <Input>
            <InputField
              placeholder="your@email.com"
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
            />
          </Input>
        </FormControl>
        <FormControl>
          <FormControlLabel>
            <FormControlLabelText>Password</FormControlLabelText>
          </FormControlLabel>
          <Input>
            <InputField
              placeholder="Password"
              value={password}
              onChangeText={setPassword}
              secureTextEntry
            />
          </Input>
        </FormControl>
      </VStack>
    </ModalBody>
    <ModalFooter>
      <Button onPress={handleSignIn}>
        <ButtonText>Sign In</ButtonText>
      </Button>
    </ModalFooter>
  </ModalContent>
</Modal>
```

### Nested Modals

```typescript
const [showFirstModal, setShowFirstModal] = useState(false);
const [showSecondModal, setShowSecondModal] = useState(false);

<Modal isOpen={showFirstModal} onClose={() => setShowFirstModal(false)}>
  <ModalBackdrop />
  <ModalContent>
    <ModalHeader><Heading>First Modal</Heading></ModalHeader>
    <ModalBody>
      <Button onPress={() => setShowSecondModal(true)}>
        <ButtonText>Open Second Modal</ButtonText>
      </Button>
    </ModalBody>
  </ModalContent>

  <Modal isOpen={showSecondModal} onClose={() => setShowSecondModal(false)}>
    <ModalBackdrop />
    <ModalContent>
      <ModalHeader><Heading>Second Modal</Heading></ModalHeader>
      <ModalBody><Text>Nested modal content</Text></ModalBody>
    </ModalContent>
  </Modal>
</Modal>
```

### Prevent Close on Backdrop

```typescript
<Modal
  isOpen={showModal}
  onClose={() => setShowModal(false)}
  closeOnOverlayClick={false}
>
  <ModalBackdrop />
  <ModalContent>
    {/* content */}
  </ModalContent>
</Modal>
```

## Drawer

Slide-in panel component from edge of screen.

### Basic Usage

```typescript
import {
  Drawer,
  DrawerBackdrop,
  DrawerContent,
  DrawerHeader,
  DrawerCloseButton,
  DrawerBody,
  DrawerFooter,
} from '@/components/ui/drawer';

const [showDrawer, setShowDrawer] = useState(false);

<>
  <Button onPress={() => setShowDrawer(true)}>
    <ButtonText>Open Drawer</ButtonText>
  </Button>

  <Drawer isOpen={showDrawer} onClose={() => setShowDrawer(false)}>
    <DrawerBackdrop />
    <DrawerContent>
      <DrawerHeader>
        <Heading>Drawer Title</Heading>
        <DrawerCloseButton>
          <Icon as={CloseIcon} />
        </DrawerCloseButton>
      </DrawerHeader>
      <DrawerBody>
        <Text>Drawer content goes here</Text>
      </DrawerBody>
      <DrawerFooter>
        <Button onPress={() => setShowDrawer(false)}>
          <ButtonText>Close</ButtonText>
        </Button>
      </DrawerFooter>
    </DrawerContent>
  </Drawer>
</>
```

### Drawer Positions

```typescript
// Right side (default)
<Drawer isOpen={showDrawer} onClose={close} placement="right">
  <DrawerBackdrop />
  <DrawerContent>
    {/* content */}
  </DrawerContent>
</Drawer>

// Left side
<Drawer isOpen={showDrawer} onClose={close} placement="left">
  {/* content */}
</Drawer>

// Bottom
<Drawer isOpen={showDrawer} onClose={close} placement="bottom">
  {/* content */}
</Drawer>

// Top
<Drawer isOpen={showDrawer} onClose={close} placement="top">
  {/* content */}
</Drawer>
```

### Navigation Drawer

```typescript
<Drawer isOpen={showDrawer} onClose={() => setShowDrawer(false)}>
  <DrawerBackdrop />
  <DrawerContent>
    <DrawerHeader>
      <Heading>Navigation</Heading>
      <DrawerCloseButton>
        <Icon as={CloseIcon} />
      </DrawerCloseButton>
    </DrawerHeader>
    <DrawerBody>
      <VStack space="md">
        <Button variant="link" onPress={() => navigate('Home')}>
          <ButtonText>Home</ButtonText>
        </Button>
        <Button variant="link" onPress={() => navigate('Profile')}>
          <ButtonText>Profile</ButtonText>
        </Button>
        <Button variant="link" onPress={() => navigate('Settings')}>
          <ButtonText>Settings</ButtonText>
        </Button>
        <Divider />
        <Button variant="link" onPress={handleLogout}>
          <ButtonText color="$red600">Logout</ButtonText>
        </Button>
      </VStack>
    </DrawerBody>
  </DrawerContent>
</Drawer>
```

## Popover

Floating content container anchored to a trigger element.

### Basic Usage

```typescript
import {
  Popover,
  PopoverBackdrop,
  PopoverContent,
  PopoverArrow,
  PopoverHeader,
  PopoverCloseButton,
  PopoverBody,
  PopoverFooter,
} from '@/components/ui/popover';

<Popover>
  <PopoverBackdrop />
  <Button>
    <ButtonText>Open Popover</ButtonText>
  </Button>
  <PopoverContent>
    <PopoverArrow />
    <PopoverHeader>
      <Heading size="sm">Popover Title</Heading>
      <PopoverCloseButton>
        <Icon as={CloseIcon} />
      </PopoverCloseButton>
    </PopoverHeader>
    <PopoverBody>
      <Text>Popover content goes here</Text>
    </PopoverBody>
  </PopoverContent>
</Popover>
```

### Placement Options

```typescript
// Top
<Popover placement="top">
  <Button><ButtonText>Top</ButtonText></Button>
  <PopoverContent>
    <PopoverArrow />
    <PopoverBody><Text>Content</Text></PopoverBody>
  </PopoverContent>
</Popover>

// Bottom (default)
<Popover placement="bottom">
  {/* content */}
</Popover>

// Left
<Popover placement="left">
  {/* content */}
</Popover>

// Right
<Popover placement="right">
  {/* content */}
</Popover>
```

### Controlled Popover

```typescript
const [isOpen, setIsOpen] = useState(false);

<Popover isOpen={isOpen} onClose={() => setIsOpen(false)}>
  <PopoverBackdrop />
  <Button onPress={() => setIsOpen(true)}>
    <ButtonText>Open</ButtonText>
  </Button>
  <PopoverContent>
    <PopoverBody>
      <Text>Controlled popover content</Text>
      <Button onPress={() => setIsOpen(false)}>
        <ButtonText>Close</ButtonText>
      </Button>
    </PopoverBody>
  </PopoverContent>
</Popover>
```

### Form in Popover

```typescript
<Popover>
  <PopoverBackdrop />
  <Button><ButtonText>Edit Profile</ButtonText></Button>
  <PopoverContent>
    <PopoverHeader><Heading size="sm">Edit Name</Heading></PopoverHeader>
    <PopoverBody>
      <Input>
        <InputField placeholder="Enter name" />
      </Input>
    </PopoverBody>
    <PopoverFooter>
      <Button size="sm"><ButtonText>Save</ButtonText></Button>
    </PopoverFooter>
  </PopoverContent>
</Popover>
```

## Tooltip

Contextual help text shown on hover or focus.

### Basic Usage

```typescript
import { Tooltip, TooltipContent, TooltipText } from '@/components/ui/tooltip';

<Tooltip>
  <Button>
    <ButtonText>Hover Me</ButtonText>
  </Button>
  <TooltipContent>
    <TooltipText>This is a helpful tooltip</TooltipText>
  </TooltipContent>
</Tooltip>
```

### Placement Options

```typescript
<Tooltip placement="top">
  <Button><ButtonText>Top</ButtonText></Button>
  <TooltipContent>
    <TooltipText>Tooltip on top</TooltipText>
  </TooltipContent>
</Tooltip>

<Tooltip placement="bottom">
  <Button><ButtonText>Bottom</ButtonText></Button>
  <TooltipContent>
    <TooltipText>Tooltip on bottom</TooltipText>
  </TooltipContent>
</Tooltip>

<Tooltip placement="left">
  <Button><ButtonText>Left</ButtonText></Button>
  <TooltipContent>
    <TooltipText>Tooltip on left</TooltipText>
  </TooltipContent>
</Tooltip>

<Tooltip placement="right">
  <Button><ButtonText>Right</ButtonText></Button>
  <TooltipContent>
    <TooltipText>Tooltip on right</TooltipText>
  </TooltipContent>
</Tooltip>
```

### Custom Delay

```typescript
<Tooltip openDelay={500} closeDelay={200}>
  <Button><ButtonText>Custom Delay</ButtonText></Button>
  <TooltipContent>
    <TooltipText>Opens after 500ms, closes after 200ms</TooltipText>
  </TooltipContent>
</Tooltip>
```

### Rich Content Tooltip

```typescript
<Tooltip>
  <Button><ButtonText>Rich Tooltip</ButtonText></Button>
  <TooltipContent>
    <VStack space="xs">
      <Heading size="xs">Keyboard Shortcut</Heading>
      <Text size="sm">Press Cmd+S to save</Text>
    </VStack>
  </TooltipContent>
</Tooltip>
```

## AlertDialog

Modal dialog for critical confirmations and warnings.

### Basic Usage

```typescript
import {
  AlertDialog,
  AlertDialogBackdrop,
  AlertDialogContent,
  AlertDialogHeader,
  AlertDialogCloseButton,
  AlertDialogBody,
  AlertDialogFooter,
} from '@/components/ui/alert-dialog';

const [showAlert, setShowAlert] = useState(false);

<>
  <Button onPress={() => setShowAlert(true)}>
    <ButtonText>Delete Item</ButtonText>
  </Button>

  <AlertDialog isOpen={showAlert} onClose={() => setShowAlert(false)}>
    <AlertDialogBackdrop />
    <AlertDialogContent>
      <AlertDialogHeader>
        <Heading>Confirm Delete</Heading>
        <AlertDialogCloseButton>
          <Icon as={CloseIcon} />
        </AlertDialogCloseButton>
      </AlertDialogHeader>
      <AlertDialogBody>
        <Text>Are you sure you want to delete this item? This action cannot be undone.</Text>
      </AlertDialogBody>
      <AlertDialogFooter>
        <Button variant="outline" onPress={() => setShowAlert(false)}>
          <ButtonText>Cancel</ButtonText>
        </Button>
        <Button bg="$red600" onPress={handleDelete}>
          <ButtonText>Delete</ButtonText>
        </Button>
      </AlertDialogFooter>
    </AlertDialogContent>
  </AlertDialog>
</>
```

### Async Confirmation

```typescript
const [isDeleting, setIsDeleting] = useState(false);

const handleDelete = async () => {
  setIsDeleting(true);
  try {
    await deleteItem();
    setShowAlert(false);
  } catch (error) {
    console.error(error);
  } finally {
    setIsDeleting(false);
  }
};

<AlertDialogFooter>
  <Button variant="outline" onPress={() => setShowAlert(false)} disabled={isDeleting}>
    <ButtonText>Cancel</ButtonText>
  </Button>
  <Button bg="$red600" onPress={handleDelete} disabled={isDeleting}>
    {isDeleting && <ButtonSpinner />}
    <ButtonText>{isDeleting ? 'Deleting...' : 'Delete'}</ButtonText>
  </Button>
</AlertDialogFooter>
```

### Warning Dialog

```typescript
<AlertDialog isOpen={showAlert} onClose={() => setShowAlert(false)}>
  <AlertDialogBackdrop />
  <AlertDialogContent>
    <AlertDialogHeader>
      <HStack space="sm" alignItems="center">
        <Icon as={AlertTriangleIcon} color="$yellow600" />
        <Heading>Warning</Heading>
      </HStack>
    </AlertDialogHeader>
    <AlertDialogBody>
      <Text>This action may have unintended consequences. Continue?</Text>
    </AlertDialogBody>
    <AlertDialogFooter>
      <Button variant="outline" onPress={() => setShowAlert(false)}>
        <ButtonText>Cancel</ButtonText>
      </Button>
      <Button bg="$yellow600" onPress={handleProceed}>
        <ButtonText>Proceed</ButtonText>
      </Button>
    </AlertDialogFooter>
  </AlertDialogContent>
</AlertDialog>
```

## Menu

Dropdown menu component for actions and options.

### Basic Usage

```typescript
import {
  Menu,
  MenuItem,
  MenuItemLabel,
} from '@/components/ui/menu';

<Menu>
  <Button>
    <ButtonText>Open Menu</ButtonText>
  </Button>
  <MenuContent>
    <MenuItem onPress={() => console.log('Edit')}>
      <MenuItemLabel>Edit</MenuItemLabel>
    </MenuItem>
    <MenuItem onPress={() => console.log('Duplicate')}>
      <MenuItemLabel>Duplicate</MenuItemLabel>
    </MenuItem>
    <MenuItem onPress={() => console.log('Delete')}>
      <MenuItemLabel>Delete</MenuItemLabel>
    </MenuItem>
  </MenuContent>
</Menu>
```

### Menu with Icons

```typescript
import { EditIcon, CopyIcon, TrashIcon } from '@gluestack-ui/themed';

<Menu>
  <Button><ButtonText>Actions</ButtonText></Button>
  <MenuContent>
    <MenuItem>
      <Icon as={EditIcon} mr="$2" />
      <MenuItemLabel>Edit</MenuItemLabel>
    </MenuItem>
    <MenuItem>
      <Icon as={CopyIcon} mr="$2" />
      <MenuItemLabel>Duplicate</MenuItemLabel>
    </MenuItem>
    <Divider />
    <MenuItem>
      <Icon as={TrashIcon} color="$red600" mr="$2" />
      <MenuItemLabel color="$red600">Delete</MenuItemLabel>
    </MenuItem>
  </MenuContent>
</Menu>
```

### Nested Menu

```typescript
<Menu>
  <Button><ButtonText>File</ButtonText></Button>
  <MenuContent>
    <MenuItem><MenuItemLabel>New File</MenuItemLabel></MenuItem>
    <Menu>
      <MenuItem><MenuItemLabel>Open Recent →</MenuItemLabel></MenuItem>
      <MenuContent>
        <MenuItem><MenuItemLabel>File 1.txt</MenuItemLabel></MenuItem>
        <MenuItem><MenuItemLabel>File 2.txt</MenuItemLabel></MenuItem>
      </MenuContent>
    </Menu>
    <MenuItem><MenuItemLabel>Save</MenuItemLabel></MenuItem>
  </MenuContent>
</Menu>
```

### Placement Options

```typescript
<Menu placement="bottom-left">
  <Button><ButtonText>Bottom Left</ButtonText></Button>
  <MenuContent>
    {/* items */}
  </MenuContent>
</Menu>

<Menu placement="top-right">
  <Button><ButtonText>Top Right</ButtonText></Button>
  <MenuContent>
    {/* items */}
  </MenuContent>
</Menu>
```

## Best Practices

**Overlay Components:**
- Use Modal for focused tasks requiring user attention
- Use Drawer for navigation or secondary content
- Use Popover for contextual information and forms
- Use Tooltip for brief help text only
- Use AlertDialog for destructive actions requiring confirmation
- Use Menu for lists of actions or options

**Accessibility:**
- Always provide close buttons
- Support keyboard navigation (Escape to close)
- Trap focus within modals and drawers
- Use appropriate ARIA labels
- Ensure sufficient color contrast
- Test with screen readers

**Performance:**
- Lazy load overlay content when possible
- Avoid nesting too many overlays
- Clean up event listeners on unmount
- Use controlled state only when necessary
- Memoize overlay content for complex UIs

**UX Guidelines:**
- Provide clear action buttons
- Show loading states for async operations
- Prevent accidental closes for important actions
- Use appropriate overlay types for context
- Keep overlay content focused and concise
- Position overlays logically relative to triggers
