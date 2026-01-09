# Animations Integration Reference

Guide for integrating animations with Gluestack UI components using Reanimated, Moti, and native animations.

## Reanimated + Gluestack UI

### Animated Modal Entrance

```typescript
import { Modal, ModalBackdrop, ModalContent } from '@/components/ui/modal';
import Animated, {
  useAnimatedStyle,
  withSpring,
  withTiming,
  useSharedValue,
  Easing,
} from 'react-native-reanimated';

function AnimatedModal() {
  const [showModal, setShowModal] = useState(false);
  const scale = useSharedValue(0);
  const opacity = useSharedValue(0);

  useEffect(() => {
    if (showModal) {
      scale.value = withSpring(1, { damping: 15 });
      opacity.value = withTiming(1, { duration: 200 });
    } else {
      scale.value = withTiming(0, { duration: 150 });
      opacity.value = withTiming(0, { duration: 150 });
    }
  }, [showModal]);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
    opacity: opacity.value,
  }));

  return (
    <Modal isOpen={showModal} onClose={() => setShowModal(false)}>
      <ModalBackdrop />
      <Animated.View style={animatedStyle}>
        <ModalContent>
          <ModalHeader>
            <Heading>Animated Modal</Heading>
          </ModalHeader>
          <ModalBody>
            <Text>Content with spring animation</Text>
          </ModalBody>
        </ModalContent>
      </Animated.View>
    </Modal>
  );
}
```

### Animated Button Press

```typescript
import { Button, ButtonText } from '@/components/ui/button';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withSpring,
} from 'react-native-reanimated';
import { Pressable } from 'react-native';

const AnimatedPressable = Animated.createAnimatedComponent(Pressable);

function AnimatedButton() {
  const scale = useSharedValue(1);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  const handlePressIn = () => {
    scale.value = withSpring(0.95);
  };

  const handlePressOut = () => {
    scale.value = withSpring(1);
  };

  return (
    <AnimatedPressable
      style={animatedStyle}
      onPressIn={handlePressIn}
      onPressOut={handlePressOut}
    >
      <Button>
        <ButtonText>Press Me</ButtonText>
      </Button>
    </AnimatedPressable>
  );
}
```

### Animated Card List

```typescript
import { Card, CardBody } from '@/components/ui/card';
import Animated, {
  FadeInDown,
  FadeOutUp,
  Layout,
} from 'react-native-reanimated';

const AnimatedCard = Animated.createAnimatedComponent(Card);

function AnimatedCardList({ items }: { items: Item[] }) {
  return (
    <FlatList
      data={items}
      keyExtractor={(item) => item.id}
      renderItem={({ item, index }) => (
        <AnimatedCard
          entering={FadeInDown.delay(index * 100)}
          exiting={FadeOutUp}
          layout={Layout.springify()}
        >
          <CardBody>
            <Heading size="md">{item.title}</Heading>
            <Text>{item.description}</Text>
          </CardBody>
        </AnimatedCard>
      )}
    />
  );
}
```

### Animated Toast

```typescript
import { useToast, Toast, ToastTitle } from '@/components/ui/toast';
import Animated, {
  SlideInDown,
  SlideOutUp,
} from 'react-native-reanimated';

const AnimatedToast = Animated.createAnimatedComponent(Toast);

function useAnimatedToast() {
  const toast = useToast();

  const showAnimatedToast = (message: string) => {
    toast.show({
      placement: 'top',
      duration: 3000,
      render: ({ id }) => (
        <AnimatedToast
          nativeID={`toast-${id}`}
          action="success"
          entering={SlideInDown}
          exiting={SlideOutUp}
        >
          <ToastTitle>{message}</ToastTitle>
        </AnimatedToast>
      ),
    });
  };

  return { showAnimatedToast };
}
```

### Animated Progress

```typescript
import { Progress, ProgressFilledTrack } from '@/components/ui/progress';
import Animated, {
  useAnimatedStyle,
  withTiming,
  Easing,
} from 'react-native-reanimated';

function AnimatedProgress({ value }: { value: number }) {
  const width = useSharedValue(0);

  useEffect(() => {
    width.value = withTiming(value, {
      duration: 500,
      easing: Easing.bezier(0.25, 0.1, 0.25, 1),
    });
  }, [value]);

  const animatedStyle = useAnimatedStyle(() => ({
    width: `${width.value}%`,
  }));

  return (
    <Progress value={value} width="$full">
      <Animated.View style={animatedStyle}>
        <ProgressFilledTrack />
      </Animated.View>
    </Progress>
  );
}
```

### Animated Accordion

```typescript
import {
  Accordion,
  AccordionItem,
  AccordionTrigger,
  AccordionContent,
  AccordionTriggerText,
  AccordionContentText,
} from '@/components/ui/accordion';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withTiming,
  Easing,
} from 'react-native-reanimated';

function AnimatedAccordionItem({ title, content }: { title: string; content: string }) {
  const [isExpanded, setIsExpanded] = useState(false);
  const height = useSharedValue(0);
  const rotate = useSharedValue(0);

  useEffect(() => {
    height.value = withTiming(isExpanded ? 'auto' : 0, {
      duration: 300,
      easing: Easing.bezier(0.4, 0.0, 0.2, 1),
    });
    rotate.value = withTiming(isExpanded ? 180 : 0, { duration: 300 });
  }, [isExpanded]);

  const contentStyle = useAnimatedStyle(() => ({
    height: height.value,
    overflow: 'hidden',
  }));

  const iconStyle = useAnimatedStyle(() => ({
    transform: [{ rotate: `${rotate.value}deg` }],
  }));

  return (
    <AccordionItem>
      <AccordionTrigger onPress={() => setIsExpanded(!isExpanded)}>
        <AccordionTriggerText>{title}</AccordionTriggerText>
        <Animated.View style={iconStyle}>
          <Icon as={ChevronDownIcon} />
        </Animated.View>
      </AccordionTrigger>
      <Animated.View style={contentStyle}>
        <AccordionContent>
          <AccordionContentText>{content}</AccordionContentText>
        </AccordionContent>
      </Animated.View>
    </AccordionItem>
  );
}
```

### Animated Badge Counter

```typescript
import { Badge, BadgeText } from '@/components/ui/badge';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withSpring,
  withSequence,
} from 'react-native-reanimated';

function AnimatedBadge({ count }: { count: number }) {
  const scale = useSharedValue(1);
  const prevCount = useRef(count);

  useEffect(() => {
    if (count !== prevCount.current) {
      scale.value = withSequence(
        withSpring(1.3),
        withSpring(1)
      );
      prevCount.current = count;
    }
  }, [count]);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }],
  }));

  return (
    <Animated.View style={animatedStyle}>
      <Badge action="error" variant="solid" borderRadius="$full">
        <BadgeText>{count}</BadgeText>
      </Badge>
    </Animated.View>
  );
}
```

### Page Transition with Animated Box

```typescript
import { Box } from '@/components/ui/box';
import Animated, {
  FadeIn,
  FadeOut,
  SlideInRight,
  SlideOutLeft,
} from 'react-native-reanimated';

const AnimatedBox = Animated.createAnimatedComponent(Box);

function PageTransition({ children, entering = 'fade' }: Props) {
  const enteringAnimation = {
    fade: FadeIn,
    slide: SlideInRight,
  }[entering];

  return (
    <AnimatedBox
      flex={1}
      entering={enteringAnimation}
      exiting={FadeOut}
    >
      {children}
    </AnimatedBox>
  );
}

// Usage in navigation
function HomeScreen() {
  return (
    <PageTransition entering="slide">
      <VStack space="lg" p="$4">
        <Heading>Home Screen</Heading>
        {/* content */}
      </VStack>
    </PageTransition>
  );
}
```

### Animated Input Focus

```typescript
import { Input, InputField } from '@/components/ui/input';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withTiming,
} from 'react-native-reanimated';

function AnimatedInput() {
  const borderWidth = useSharedValue(1);
  const borderColor = useSharedValue('#E5E5E5');

  const animatedStyle = useAnimatedStyle(() => ({
    borderWidth: borderWidth.value,
    borderColor: borderColor.value,
  }));

  const handleFocus = () => {
    borderWidth.value = withTiming(2, { duration: 200 });
    borderColor.value = '#3B82F6'; // blue
  };

  const handleBlur = () => {
    borderWidth.value = withTiming(1, { duration: 200 });
    borderColor.value = '#E5E5E5'; // gray
  };

  return (
    <Animated.View style={animatedStyle}>
      <Input>
        <InputField
          placeholder="Animated input"
          onFocus={handleFocus}
          onBlur={handleBlur}
        />
      </Input>
    </Animated.View>
  );
}
```

## Moti Integration

Moti provides a simpler API for common animations.

### Moti Button

```typescript
import { MotiView } from 'moti';
import { Button, ButtonText } from '@/components/ui/button';

function MotiButton() {
  return (
    <MotiView
      from={{ scale: 0.9, opacity: 0 }}
      animate={{ scale: 1, opacity: 1 }}
      transition={{ type: 'timing', duration: 300 }}
    >
      <Button>
        <ButtonText>Animated with Moti</ButtonText>
      </Button>
    </MotiView>
  );
}
```

### Skeleton Loading with Moti

```typescript
import { MotiView } from 'moti';
import { Skeleton } from '@/components/ui/skeleton';

function MotiSkeleton() {
  return (
    <MotiView
      from={{ opacity: 0.3 }}
      animate={{ opacity: 1 }}
      transition={{
        type: 'timing',
        duration: 1000,
        loop: true,
      }}
    >
      <Skeleton height={200} width="100%" />
    </MotiView>
  );
}
```

## Performance Tips

**Best Practices:**
- Use `useAnimatedStyle` for style animations
- Prefer `withSpring` and `withTiming` over JS-based animations
- Use `layout` prop for layout animations
- Memoize animated components
- Use `entering`/`exiting` props for mount/unmount animations
- Avoid animating `width`/`height` (use `scale` instead)
- Use `runOnUI` for expensive calculations
- Profile with Reanimated DevTools

**Common Pitfalls:**
- Don't wrap every Gluestack component in Animated.View unnecessarily
- Use createAnimatedComponent only when needed
- Avoid animating too many properties simultaneously
- Test on lower-end devices

## Resources

- **Reanimated docs**: https://docs.swmansion.com/react-native-reanimated/
- **Moti docs**: https://moti.fyi/
- **reanimated-performance skill**: See companion skill for advanced patterns
