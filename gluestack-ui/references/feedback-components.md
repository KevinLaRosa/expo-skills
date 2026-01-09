# Feedback Components Reference

Comprehensive guide to feedback components in Gluestack UI v2. These components provide visual feedback for user actions, loading states, and system messages.

## Toast

Temporary notification messages that appear on screen.

### Basic Usage

```typescript
import { useToast, Toast, ToastTitle, ToastDescription } from '@/components/ui/toast';

function MyComponent() {
  const toast = useToast();

  const showToast = () => {
    toast.show({
      placement: 'top',
      render: ({ id }) => (
        <Toast nativeID={`toast-${id}`} action="success">
          <ToastTitle>Success</ToastTitle>
          <ToastDescription>Your changes have been saved</ToastDescription>
        </Toast>
      ),
    });
  };

  return (
    <Button onPress={showToast}>
      <ButtonText>Show Toast</ButtonText>
    </Button>
  );
}
```

### Toast Variants

```typescript
// Success toast
toast.show({
  render: ({ id }) => (
    <Toast nativeID={`toast-${id}`} action="success">
      <ToastTitle>Success</ToastTitle>
      <ToastDescription>Operation completed successfully</ToastDescription>
    </Toast>
  ),
});

// Error toast
toast.show({
  render: ({ id }) => (
    <Toast nativeID={`toast-${id}`} action="error">
      <ToastTitle>Error</ToastTitle>
      <ToastDescription>Something went wrong</ToastDescription>
    </Toast>
  ),
});

// Warning toast
toast.show({
  render: ({ id }) => (
    <Toast nativeID={`toast-${id}`} action="warning">
      <ToastTitle>Warning</ToastTitle>
      <ToastDescription>Please review your input</ToastDescription>
    </Toast>
  ),
});

// Info toast
toast.show({
  render: ({ id }) => (
    <Toast nativeID={`toast-${id}`} action="info">
      <ToastTitle>Info</ToastTitle>
      <ToastDescription>New features available</ToastDescription>
    </Toast>
  ),
});
```

### Toast Placement

```typescript
// Top
toast.show({
  placement: 'top',
  render: ({ id }) => <Toast nativeID={`toast-${id}`}>{/* content */}</Toast>,
});

// Top right
toast.show({
  placement: 'top-right',
  render: ({ id }) => <Toast nativeID={`toast-${id}`}>{/* content */}</Toast>,
});

// Bottom (default)
toast.show({
  placement: 'bottom',
  render: ({ id }) => <Toast nativeID={`toast-${id}`}>{/* content */}</Toast>,
});

// Bottom left
toast.show({
  placement: 'bottom-left',
  render: ({ id }) => <Toast nativeID={`toast-${id}`}>{/* content */}</Toast>,
});
```

### Toast with Action Button

```typescript
toast.show({
  render: ({ id }) => (
    <Toast nativeID={`toast-${id}`} action="info">
      <VStack space="xs">
        <ToastTitle>Update Available</ToastTitle>
        <ToastDescription>A new version is ready to install</ToastDescription>
        <HStack space="sm" mt="$2">
          <Button size="sm" onPress={() => handleUpdate()}>
            <ButtonText>Update Now</ButtonText>
          </Button>
          <Button size="sm" variant="outline" onPress={() => toast.close(id)}>
            <ButtonText>Later</ButtonText>
          </Button>
        </HStack>
      </VStack>
    </Toast>
  ),
});
```

### Toast with Custom Duration

```typescript
toast.show({
  duration: 5000, // 5 seconds
  render: ({ id }) => (
    <Toast nativeID={`toast-${id}`}>
      <ToastTitle>Custom Duration</ToastTitle>
      <ToastDescription>This toast will disappear in 5 seconds</ToastDescription>
    </Toast>
  ),
});
```

### Close Toast Programmatically

```typescript
const toastId = toast.show({
  render: ({ id }) => (
    <Toast nativeID={`toast-${id}`}>
      <ToastTitle>Processing...</ToastTitle>
    </Toast>
  ),
});

// Later, close it
toast.close(toastId);

// Close all toasts
toast.closeAll();
```

### Toast Queue

```typescript
// Multiple toasts will queue automatically
const showMultipleToasts = () => {
  toast.show({
    render: ({ id }) => (
      <Toast nativeID={`toast-${id}`}><ToastTitle>First</ToastTitle></Toast>
    ),
  });
  toast.show({
    render: ({ id }) => (
      <Toast nativeID={`toast-${id}`}><ToastTitle>Second</ToastTitle></Toast>
    ),
  });
  toast.show({
    render: ({ id }) => (
      <Toast nativeID={`toast-${id}`}><ToastTitle>Third</ToastTitle></Toast>
    ),
  });
};
```

## Alert

Inline message component for important information.

### Basic Usage

```typescript
import { Alert, AlertIcon, AlertText } from '@/components/ui/alert';
import { InfoIcon } from '@gluestack-ui/themed';

<Alert action="info">
  <AlertIcon as={InfoIcon} />
  <AlertText>This is an informational alert</AlertText>
</Alert>
```

### Alert Variants

```typescript
// Info (default)
<Alert action="info">
  <AlertIcon as={InfoIcon} />
  <AlertText>For your information</AlertText>
</Alert>

// Success
<Alert action="success">
  <AlertIcon as={CheckCircleIcon} />
  <AlertText>Operation completed successfully</AlertText>
</Alert>

// Warning
<Alert action="warning">
  <AlertIcon as={AlertTriangleIcon} />
  <AlertText>Please review this warning</AlertText>
</Alert>

// Error
<Alert action="error">
  <AlertIcon as={AlertCircleIcon} />
  <AlertText>An error has occurred</AlertText>
</Alert>
```

### Alert with Title

```typescript
import { Alert, AlertIcon, AlertText, VStack, Heading } from '@/components/ui/alert';

<Alert action="warning" p="$4">
  <HStack space="md" alignItems="flex-start">
    <AlertIcon as={AlertTriangleIcon} mt="$0.5" />
    <VStack space="xs" flex={1}>
      <Heading size="sm">Warning</Heading>
      <AlertText>
        Your session will expire in 5 minutes. Please save your work.
      </AlertText>
    </VStack>
  </HStack>
</Alert>
```

### Dismissible Alert

```typescript
const [showAlert, setShowAlert] = useState(true);

{showAlert && (
  <Alert action="info">
    <HStack space="md" alignItems="center" justifyContent="space-between" flex={1}>
      <HStack space="sm" alignItems="center" flex={1}>
        <AlertIcon as={InfoIcon} />
        <AlertText flex={1}>This is a dismissible alert</AlertText>
      </HStack>
      <Button
        size="sm"
        variant="link"
        onPress={() => setShowAlert(false)}
      >
        <Icon as={CloseIcon} />
      </Button>
    </HStack>
  </Alert>
)}
```

### Alert with Action Button

```typescript
<Alert action="error" p="$4">
  <VStack space="md" flex={1}>
    <HStack space="sm" alignItems="center">
      <AlertIcon as={AlertCircleIcon} />
      <VStack flex={1}>
        <Heading size="sm">Connection Failed</Heading>
        <AlertText>Unable to connect to the server</AlertText>
      </VStack>
    </HStack>
    <Button size="sm" onPress={handleRetry}>
      <ButtonText>Retry Connection</ButtonText>
    </Button>
  </VStack>
</Alert>
```

### Alert Variants

```typescript
// Subtle (light background)
<Alert variant="subtle" action="info">
  <AlertIcon as={InfoIcon} />
  <AlertText>Subtle alert style</AlertText>
</Alert>

// Solid (colored background)
<Alert variant="solid" action="success">
  <AlertIcon as={CheckCircleIcon} />
  <AlertText color="$white">Solid alert style</AlertText>
</Alert>

// Outline (border only)
<Alert variant="outline" action="warning">
  <AlertIcon as={AlertTriangleIcon} />
  <AlertText>Outline alert style</AlertText>
</Alert>
```

## Progress

Linear progress indicator for loading and completion states.

### Basic Usage

```typescript
import { Progress, ProgressFilledTrack } from '@/components/ui/progress';

<Progress value={60} width="$full">
  <ProgressFilledTrack />
</Progress>
```

### Progress with Label

```typescript
const [progress, setProgress] = useState(0);

<VStack space="sm">
  <HStack justifyContent="space-between">
    <Text>Uploading...</Text>
    <Text>{progress}%</Text>
  </HStack>
  <Progress value={progress} width="$full">
    <ProgressFilledTrack />
  </Progress>
</VStack>
```

### Animated Progress

```typescript
const [progress, setProgress] = useState(0);

useEffect(() => {
  const interval = setInterval(() => {
    setProgress((prev) => {
      if (prev >= 100) {
        clearInterval(interval);
        return 100;
      }
      return prev + 10;
    });
  }, 500);

  return () => clearInterval(interval);
}, []);

<Progress value={progress} width="$full">
  <ProgressFilledTrack />
</Progress>
```

### Progress Sizes

```typescript
<VStack space="md">
  <Progress value={60} size="xs" width="$full">
    <ProgressFilledTrack />
  </Progress>
  <Progress value={60} size="sm" width="$full">
    <ProgressFilledTrack />
  </Progress>
  <Progress value={60} size="md" width="$full">
    <ProgressFilledTrack />
  </Progress>
  <Progress value={60} size="lg" width="$full">
    <ProgressFilledTrack />
  </Progress>
</VStack>
```

### Colored Progress

```typescript
<Progress value={60} width="$full">
  <ProgressFilledTrack bg="$green500" />
</Progress>

<Progress value={60} width="$full">
  <ProgressFilledTrack bg="$red500" />
</Progress>

<Progress value={60} width="$full">
  <ProgressFilledTrack bg="$yellow500" />
</Progress>
```

### Indeterminate Progress

```typescript
<Progress value={null} width="$full">
  <ProgressFilledTrack />
</Progress>
```

### Multi-Step Progress

```typescript
const steps = ['Step 1', 'Step 2', 'Step 3', 'Step 4'];
const [currentStep, setCurrentStep] = useState(1);
const progress = (currentStep / steps.length) * 100;

<VStack space="md">
  <Progress value={progress} width="$full">
    <ProgressFilledTrack />
  </Progress>
  <HStack justifyContent="space-between">
    {steps.map((step, index) => (
      <Text
        key={step}
        size="sm"
        color={index < currentStep ? '$blue500' : '$gray500'}
      >
        {step}
      </Text>
    ))}
  </HStack>
</VStack>
```

## Spinner

Loading spinner for async operations.

### Basic Usage

```typescript
import { Spinner } from '@/components/ui/spinner';

<Spinner />
```

### Spinner Sizes

```typescript
<HStack space="md" alignItems="center">
  <Spinner size="small" />
  <Spinner size="large" />
</HStack>
```

### Colored Spinner

```typescript
<Spinner color="$blue500" />
<Spinner color="$green500" />
<Spinner color="$red500" />
```

### Loading State

```typescript
const [loading, setLoading] = useState(false);

{loading ? (
  <Center height={200}>
    <VStack space="md" alignItems="center">
      <Spinner size="large" />
      <Text>Loading...</Text>
    </VStack>
  </Center>
) : (
  <Text>Content loaded</Text>
)}
```

### Button with Spinner

```typescript
const [loading, setLoading] = useState(false);

<Button disabled={loading} onPress={handleSubmit}>
  {loading && <ButtonSpinner mr="$1" />}
  <ButtonText>{loading ? 'Submitting...' : 'Submit'}</ButtonText>
</Button>
```

### Full Page Loading

```typescript
{loading && (
  <Box
    position="absolute"
    top={0}
    left={0}
    right={0}
    bottom={0}
    bg="$white"
    opacity={0.9}
    justifyContent="center"
    alignItems="center"
    zIndex={9999}
  >
    <VStack space="md" alignItems="center">
      <Spinner size="large" />
      <Text>Loading...</Text>
    </VStack>
  </Box>
)}
```

## Skeleton

Placeholder loading component that mimics content structure.

### Basic Usage

```typescript
import { Skeleton, SkeletonText } from '@/components/ui/skeleton';

<VStack space="md">
  <Skeleton height={200} borderRadius="$md" />
  <SkeletonText lines={3} />
</VStack>
```

### Card Skeleton

```typescript
<Box
  borderWidth="$1"
  borderColor="$gray200"
  borderRadius="$lg"
  p="$4"
>
  <VStack space="md">
    <HStack space="md" alignItems="center">
      <Skeleton variant="circular" size={50} />
      <VStack space="sm" flex={1}>
        <Skeleton height={20} width="60%" />
        <Skeleton height={16} width="40%" />
      </VStack>
    </HStack>
    <Skeleton height={150} borderRadius="$md" />
    <SkeletonText lines={2} />
  </VStack>
</Box>
```

### List Skeleton

```typescript
<VStack space="md">
  {[1, 2, 3, 4].map((item) => (
    <HStack key={item} space="md" alignItems="center">
      <Skeleton variant="circular" size={40} />
      <VStack space="sm" flex={1}>
        <Skeleton height={16} width="70%" />
        <Skeleton height={14} width="50%" />
      </VStack>
    </HStack>
  ))}
</VStack>
```

### Skeleton Variants

```typescript
// Rectangular (default)
<Skeleton height={100} width={200} />

// Circular
<Skeleton variant="circular" size={60} />

// Rounded
<Skeleton height={100} width={200} borderRadius="$lg" />
```

### Animated Skeleton

```typescript
<Skeleton height={200} isLoaded={!loading}>
  {/* Actual content shows when loading is false */}
  <Image source={{ uri: imageUrl }} />
</Skeleton>
```

### Conditional Rendering with Skeleton

```typescript
const [loading, setLoading] = useState(true);
const [data, setData] = useState(null);

{loading ? (
  <VStack space="md">
    <Skeleton height={200} />
    <SkeletonText lines={3} />
  </VStack>
) : (
  <VStack space="md">
    <Image source={{ uri: data.image }} height={200} />
    <Text>{data.description}</Text>
  </VStack>
)}
```

## Common Feedback Patterns

### Form Submission Feedback

```typescript
const [submitting, setSubmitting] = useState(false);
const [submitted, setSubmitted] = useState(false);
const toast = useToast();

const handleSubmit = async () => {
  setSubmitting(true);
  try {
    await submitForm();
    setSubmitted(true);
    toast.show({
      render: ({ id }) => (
        <Toast nativeID={`toast-${id}`} action="success">
          <ToastTitle>Success</ToastTitle>
          <ToastDescription>Form submitted successfully</ToastDescription>
        </Toast>
      ),
    });
  } catch (error) {
    toast.show({
      render: ({ id }) => (
        <Toast nativeID={`toast-${id}`} action="error">
          <ToastTitle>Error</ToastTitle>
          <ToastDescription>{error.message}</ToastDescription>
        </Toast>
      ),
    });
  } finally {
    setSubmitting(false);
  }
};

<Button disabled={submitting} onPress={handleSubmit}>
  {submitting && <ButtonSpinner mr="$1" />}
  <ButtonText>{submitting ? 'Submitting...' : 'Submit'}</ButtonText>
</Button>
```

### Upload Progress

```typescript
const [uploading, setUploading] = useState(false);
const [progress, setProgress] = useState(0);

<VStack space="md">
  <Progress value={progress} width="$full">
    <ProgressFilledTrack />
  </Progress>
  <Text textAlign="center">
    {uploading ? `Uploading... ${progress}%` : 'Upload complete'}
  </Text>
</VStack>
```

### Offline Alert

```typescript
const [isOnline, setIsOnline] = useState(true);

{!isOnline && (
  <Alert action="warning">
    <AlertIcon as={WifiOffIcon} />
    <AlertText>You are currently offline</AlertText>
  </Alert>
)}
```

## Best Practices

**Feedback Components:**
- Use Toast for temporary notifications (3-5 seconds)
- Use Alert for persistent inline messages
- Use Progress for deterministic loading states
- Use Spinner for indeterminate loading states
- Use Skeleton for content loading placeholders
- Provide clear, concise messages
- Match feedback type to action severity
- Don't stack multiple toasts at once
- Use appropriate colors for message types
- Always provide context in error messages

**Performance:**
- Avoid showing too many toasts simultaneously
- Limit skeleton complexity for better performance
- Use spinners sparingly (prefer progress when possible)
- Clean up toast timers on unmount
- Debounce progress updates for smooth animations

**Accessibility:**
- Ensure toast messages are announced by screen readers
- Provide alternative text for icons
- Use appropriate ARIA roles
- Ensure sufficient color contrast
- Don't rely solely on color to convey meaning
- Make dismissible alerts keyboard accessible
