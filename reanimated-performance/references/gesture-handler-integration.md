# Gesture Handler Integration Guide

## React Native Gesture Handler with Reanimated

React Native Gesture Handler combined with Reanimated provides the most performant way to handle touch interactions in React Native. Gestures run entirely on the UI thread, ensuring smooth 60 FPS interactions.

### Why This Integration Matters

**Traditional TouchableOpacity/PanResponder Problems:**
- Runs on JavaScript thread
- Bridge communication latency
- Stutters during heavy JS operations
- Limited gesture types

**Gesture Handler + Reanimated Solution:**
- Gestures processed on UI thread
- No bridge delays
- Smooth even during JS thread busy periods
- Rich gesture vocabulary
- Composable gesture system

### Installation

```bash
npm install react-native-gesture-handler react-native-reanimated
```

```bash
cd ios && pod install
```

**babel.config.js:**
```javascript
module.exports = {
  presets: ['module:metro-react-native-babel-preset'],
  plugins: ['react-native-reanimated/plugin'], // Must be last
};
```

**App.js/App.tsx:**
```javascript
import { GestureHandlerRootView } from 'react-native-gesture-handler';

export default function App() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      {/* Your app content */}
    </GestureHandlerRootView>
  );
}
```

## Core Gesture Types

### Pan Gesture

Track continuous touch movements (drag, swipe).

**Basic Pan Gesture:**
```javascript
import { GestureDetector, Gesture } from 'react-native-gesture-handler';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring
} from 'react-native-reanimated';

function DraggableBox() {
  const translateX = useSharedValue(0);
  const translateY = useSharedValue(0);

  const pan = Gesture.Pan()
    .onChange((event) => {
      translateX.value += event.changeX;
      translateY.value += event.changeY;
    })
    .onFinalize(() => {
      translateX.value = withSpring(0);
      translateY.value = withSpring(0);
    });

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: translateX.value },
      { translateY: translateY.value }
    ]
  }));

  return (
    <GestureDetector gesture={pan}>
      <Animated.View style={[styles.box, animatedStyle]} />
    </GestureDetector>
  );
}
```

**Advanced Pan with Context:**
```javascript
function DraggableWithContext() {
  const translateX = useSharedValue(0);
  const translateY = useSharedValue(0);
  const context = useSharedValue({ x: 0, y: 0 });

  const pan = Gesture.Pan()
    .onStart(() => {
      context.value = {
        x: translateX.value,
        y: translateY.value
      };
    })
    .onChange((event) => {
      translateX.value = context.value.x + event.translationX;
      translateY.value = context.value.y + event.translationY;
    })
    .onEnd((event) => {
      // Decay animation based on velocity
      if (Math.abs(event.velocityX) > 500) {
        translateX.value = withDecay({ velocity: event.velocityX });
      }
      if (Math.abs(event.velocityY) > 500) {
        translateY.value = withDecay({ velocity: event.velocityY });
      }
    });

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: translateX.value },
      { translateY: translateY.value }
    ]
  }));

  return (
    <GestureDetector gesture={pan}>
      <Animated.View style={[styles.box, animatedStyle]} />
    </GestureDetector>
  );
}
```

### Tap Gesture

Detect single, double, or multiple taps.

**Single Tap:**
```javascript
function TappableBox() {
  const scale = useSharedValue(1);

  const tap = Gesture.Tap()
    .onStart(() => {
      scale.value = withSpring(0.9);
    })
    .onEnd(() => {
      scale.value = withSpring(1);
    });

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }]
  }));

  return (
    <GestureDetector gesture={tap}>
      <Animated.View style={[styles.box, animatedStyle]} />
    </GestureDetector>
  );
}
```

**Double Tap:**
```javascript
function DoubleTappable() {
  const scale = useSharedValue(1);

  const doubleTap = Gesture.Tap()
    .numberOfTaps(2)
    .onEnd(() => {
      scale.value = withSpring(scale.value === 1 ? 2 : 1);
    });

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }]
  }));

  return (
    <GestureDetector gesture={doubleTap}>
      <Animated.View style={[styles.box, animatedStyle]} />
    </GestureDetector>
  );
}
```

**Long Press:**
```javascript
function LongPressable() {
  const opacity = useSharedValue(1);

  const longPress = Gesture.LongPress()
    .minDuration(500)
    .onStart(() => {
      opacity.value = withTiming(0.5);
    })
    .onEnd(() => {
      opacity.value = withTiming(1);
    });

  const animatedStyle = useAnimatedStyle(() => ({
    opacity: opacity.value
  }));

  return (
    <GestureDetector gesture={longPress}>
      <Animated.View style={[styles.box, animatedStyle]} />
    </GestureDetector>
  );
}
```

### Pinch Gesture

Scale/zoom with two fingers.

```javascript
function PinchableImage() {
  const scale = useSharedValue(1);
  const savedScale = useSharedValue(1);

  const pinch = Gesture.Pinch()
    .onUpdate((event) => {
      scale.value = savedScale.value * event.scale;
    })
    .onEnd(() => {
      savedScale.value = scale.value;
    });

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }]
  }));

  return (
    <GestureDetector gesture={pinch}>
      <Animated.Image
        source={require('./image.png')}
        style={[styles.image, animatedStyle]}
      />
    </GestureDetector>
  );
}
```

**Pinch with Limits:**
```javascript
function PinchWithLimits() {
  const scale = useSharedValue(1);
  const savedScale = useSharedValue(1);

  const pinch = Gesture.Pinch()
    .onUpdate((event) => {
      // Clamp between 0.5x and 3x
      const newScale = savedScale.value * event.scale;
      scale.value = Math.min(Math.max(newScale, 0.5), 3);
    })
    .onEnd(() => {
      savedScale.value = scale.value;

      // Snap back if outside comfortable range
      if (scale.value < 1) {
        scale.value = withSpring(1);
        savedScale.value = 1;
      }
    });

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ scale: scale.value }]
  }));

  return (
    <GestureDetector gesture={pinch}>
      <Animated.View style={[styles.box, animatedStyle]} />
    </GestureDetector>
  );
}
```

### Rotation Gesture

Rotate with two fingers.

```javascript
function RotatableBox() {
  const rotation = useSharedValue(0);
  const savedRotation = useSharedValue(0);

  const rotate = Gesture.Rotation()
    .onUpdate((event) => {
      rotation.value = savedRotation.value + event.rotation;
    })
    .onEnd(() => {
      savedRotation.value = rotation.value;
    });

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ rotateZ: `${rotation.value}rad` }]
  }));

  return (
    <GestureDetector gesture={rotate}>
      <Animated.View style={[styles.box, animatedStyle]} />
    </GestureDetector>
  );
}
```

## useAnimatedGestureHandler (Legacy API)

**Note:** `useAnimatedGestureHandler` is the older API. New code should use `Gesture.Pan()` with callbacks as shown above. However, you may encounter this in existing codebases.

```javascript
import { PanGestureHandler } from 'react-native-gesture-handler';
import Animated, { useAnimatedGestureHandler } from 'react-native-reanimated';

function LegacyPanExample() {
  const translateX = useSharedValue(0);

  const gestureHandler = useAnimatedGestureHandler({
    onStart: (_, ctx) => {
      ctx.startX = translateX.value;
    },
    onActive: (event, ctx) => {
      translateX.value = ctx.startX + event.translationX;
    },
    onEnd: () => {
      translateX.value = withSpring(0);
    }
  });

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: translateX.value }]
  }));

  return (
    <PanGestureHandler onGestureEvent={gestureHandler}>
      <Animated.View style={[styles.box, animatedStyle]} />
    </PanGestureHandler>
  );
}
```

## Gesture-Driven Animations

### Scroll-Based Parallax

```javascript
import { useAnimatedScrollHandler } from 'react-native-reanimated';

function ParallaxHeader() {
  const scrollY = useSharedValue(0);

  const scrollHandler = useAnimatedScrollHandler({
    onScroll: (event) => {
      scrollY.value = event.contentOffset.y;
    }
  });

  const headerStyle = useAnimatedStyle(() => ({
    transform: [
      { translateY: -scrollY.value * 0.5 }, // Parallax effect
      { scale: interpolate(scrollY.value, [0, 100], [1, 0.8]) }
    ],
    opacity: interpolate(scrollY.value, [0, 100], [1, 0])
  }));

  return (
    <View>
      <Animated.View style={[styles.header, headerStyle]}>
        <Text>Header</Text>
      </Animated.View>
      <Animated.ScrollView onScroll={scrollHandler} scrollEventThrottle={16}>
        {/* Content */}
      </Animated.ScrollView>
    </View>
  );
}
```

### Pull-to-Refresh

```javascript
function PullToRefresh() {
  const translateY = useSharedValue(0);
  const isRefreshing = useSharedValue(false);

  const pan = Gesture.Pan()
    .onUpdate((event) => {
      if (event.translationY > 0 && !isRefreshing.value) {
        translateY.value = event.translationY * 0.5; // Resistance
      }
    })
    .onEnd((event) => {
      if (translateY.value > 100) {
        isRefreshing.value = true;
        runOnJS(performRefresh)();
      } else {
        translateY.value = withSpring(0);
      }
    });

  const performRefresh = async () => {
    await fetchData();
    translateY.value = withSpring(0);
    isRefreshing.value = false;
  };

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ translateY: translateY.value }]
  }));

  const spinnerStyle = useAnimatedStyle(() => ({
    opacity: interpolate(translateY.value, [0, 100], [0, 1]),
    transform: [
      { scale: interpolate(translateY.value, [0, 100], [0, 1]) }
    ]
  }));

  return (
    <View>
      <Animated.View style={[styles.spinner, spinnerStyle]}>
        <ActivityIndicator />
      </Animated.View>
      <GestureDetector gesture={pan}>
        <Animated.ScrollView style={animatedStyle}>
          {/* Content */}
        </Animated.ScrollView>
      </GestureDetector>
    </View>
  );
}
```

### Swipe to Dismiss

```javascript
function SwipeableDismiss({ onDismiss }) {
  const translateX = useSharedValue(0);
  const DISMISS_THRESHOLD = 150;

  const pan = Gesture.Pan()
    .onChange((event) => {
      translateX.value += event.changeX;
    })
    .onEnd((event) => {
      if (Math.abs(translateX.value) > DISMISS_THRESHOLD) {
        translateX.value = withTiming(
          translateX.value > 0 ? 500 : -500,
          { duration: 200 },
          () => {
            runOnJS(onDismiss)();
          }
        );
      } else {
        translateX.value = withSpring(0);
      }
    });

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ translateX: translateX.value }],
    opacity: interpolate(
      Math.abs(translateX.value),
      [0, DISMISS_THRESHOLD],
      [1, 0.3]
    )
  }));

  return (
    <GestureDetector gesture={pan}>
      <Animated.View style={[styles.card, animatedStyle]}>
        <Text>Swipe to dismiss</Text>
      </Animated.View>
    </GestureDetector>
  );
}
```

## Simultaneous Gestures

### Gesture Composition

**Simultaneous Gestures (Both Active):**
```javascript
function PanAndPinch() {
  const translateX = useSharedValue(0);
  const translateY = useSharedValue(0);
  const scale = useSharedValue(1);

  const pan = Gesture.Pan()
    .onChange((event) => {
      translateX.value += event.changeX;
      translateY.value += event.changeY;
    });

  const pinch = Gesture.Pinch()
    .onChange((event) => {
      scale.value = event.scale;
    });

  // Both gestures can be active simultaneously
  const composed = Gesture.Simultaneous(pan, pinch);

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: translateX.value },
      { translateY: translateY.value },
      { scale: scale.value }
    ]
  }));

  return (
    <GestureDetector gesture={composed}>
      <Animated.Image
        source={require('./image.png')}
        style={[styles.image, animatedStyle]}
      />
    </GestureDetector>
  );
}
```

**Exclusive Gestures (One at a Time):**
```javascript
function TapOrLongPress() {
  const opacity = useSharedValue(1);

  const tap = Gesture.Tap()
    .onEnd(() => {
      opacity.value = withSequence(
        withTiming(0.5, { duration: 100 }),
        withTiming(1, { duration: 100 })
      );
    });

  const longPress = Gesture.LongPress()
    .minDuration(500)
    .onStart(() => {
      opacity.value = withTiming(0.3);
    })
    .onEnd(() => {
      opacity.value = withTiming(1);
    });

  // Only one gesture will be active
  const composed = Gesture.Exclusive(longPress, tap);

  const animatedStyle = useAnimatedStyle(() => ({
    opacity: opacity.value
  }));

  return (
    <GestureDetector gesture={composed}>
      <Animated.View style={[styles.box, animatedStyle]} />
    </GestureDetector>
  );
}
```

**Race Gestures (First One Wins):**
```javascript
function SwipeDirections() {
  const translateX = useSharedValue(0);
  const translateY = useSharedValue(0);

  const swipeLeft = Gesture.Pan()
    .activeOffsetX(-10)
    .onUpdate((event) => {
      translateX.value = event.translationX;
    });

  const swipeUp = Gesture.Pan()
    .activeOffsetY(-10)
    .onUpdate((event) => {
      translateY.value = event.translationY;
    });

  // First gesture to activate wins
  const race = Gesture.Race(swipeLeft, swipeUp);

  return (
    <GestureDetector gesture={race}>
      <Animated.View style={styles.box} />
    </GestureDetector>
  );
}
```

## Practical Examples

### Example 1: Swipeable Card Stack (Tinder-like)

```javascript
function SwipeableCard({ card, onSwipe }) {
  const translateX = useSharedValue(0);
  const translateY = useSharedValue(0);
  const rotateZ = useSharedValue(0);

  const SWIPE_THRESHOLD = 150;

  const pan = Gesture.Pan()
    .onChange((event) => {
      translateX.value += event.changeX;
      translateY.value += event.changeY;
      rotateZ.value = translateX.value / 10; // Rotate as you swipe
    })
    .onEnd((event) => {
      if (Math.abs(translateX.value) > SWIPE_THRESHOLD) {
        // Swipe off screen
        const direction = translateX.value > 0 ? 1 : -1;
        translateX.value = withTiming(direction * 500, { duration: 200 });
        translateY.value = withTiming(-100, { duration: 200 }, () => {
          runOnJS(onSwipe)(direction > 0 ? 'right' : 'left');
        });
      } else {
        // Snap back
        translateX.value = withSpring(0);
        translateY.value = withSpring(0);
        rotateZ.value = withSpring(0);
      }
    });

  const animatedStyle = useAnimatedStyle(() => {
    const opacity = interpolate(
      Math.abs(translateX.value),
      [0, SWIPE_THRESHOLD],
      [1, 0.5]
    );

    return {
      opacity,
      transform: [
        { translateX: translateX.value },
        { translateY: translateY.value },
        { rotateZ: `${rotateZ.value}deg` }
      ]
    };
  });

  return (
    <GestureDetector gesture={pan}>
      <Animated.View style={[styles.card, animatedStyle]}>
        <Image source={card.image} style={styles.cardImage} />
        <Text>{card.title}</Text>
      </Animated.View>
    </GestureDetector>
  );
}
```

### Example 2: Draggable Sortable List Item

```javascript
function DraggableListItem({ item, onReorder }) {
  const translateY = useSharedValue(0);
  const isDragging = useSharedValue(false);

  const pan = Gesture.Pan()
    .onStart(() => {
      isDragging.value = true;
    })
    .onChange((event) => {
      translateY.value += event.changeY;
    })
    .onEnd(() => {
      isDragging.value = false;
      const newIndex = Math.round(translateY.value / ITEM_HEIGHT);
      runOnJS(onReorder)(item.id, newIndex);
      translateY.value = withSpring(0);
    });

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ translateY: translateY.value }],
    zIndex: isDragging.value ? 100 : 1,
    elevation: isDragging.value ? 10 : 0,
    scale: isDragging.value ? 1.05 : 1
  }));

  return (
    <GestureDetector gesture={pan}>
      <Animated.View style={[styles.listItem, animatedStyle]}>
        <Text>{item.title}</Text>
      </Animated.View>
    </GestureDetector>
  );
}
```

### Example 3: Zoomable Image with Pan

```javascript
function ZoomableImage({ source }) {
  const scale = useSharedValue(1);
  const savedScale = useSharedValue(1);
  const translateX = useSharedValue(0);
  const translateY = useSharedValue(0);
  const savedTranslateX = useSharedValue(0);
  const savedTranslateY = useSharedValue(0);

  const pinch = Gesture.Pinch()
    .onUpdate((event) => {
      scale.value = Math.max(1, savedScale.value * event.scale);
    })
    .onEnd(() => {
      savedScale.value = scale.value;
      if (scale.value < 1.1) {
        scale.value = withSpring(1);
        savedScale.value = 1;
        translateX.value = withSpring(0);
        translateY.value = withSpring(0);
        savedTranslateX.value = 0;
        savedTranslateY.value = 0;
      }
    });

  const pan = Gesture.Pan()
    .enabled(scale.value > 1)
    .onStart(() => {
      savedTranslateX.value = translateX.value;
      savedTranslateY.value = translateY.value;
    })
    .onChange((event) => {
      translateX.value = savedTranslateX.value + event.translationX;
      translateY.value = savedTranslateY.value + event.translationY;
    });

  const doubleTap = Gesture.Tap()
    .numberOfTaps(2)
    .onEnd(() => {
      if (scale.value > 1) {
        scale.value = withSpring(1);
        savedScale.value = 1;
        translateX.value = withSpring(0);
        translateY.value = withSpring(0);
      } else {
        scale.value = withSpring(2);
        savedScale.value = 2;
      }
    });

  const composed = Gesture.Simultaneous(
    Gesture.Race(doubleTap, pinch),
    pan
  );

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: translateX.value },
      { translateY: translateY.value },
      { scale: scale.value }
    ]
  }));

  return (
    <GestureDetector gesture={composed}>
      <Animated.Image source={source} style={[styles.image, animatedStyle]} />
    </GestureDetector>
  );
}
```

### Example 4: Bottom Sheet with Snap Points

```javascript
function BottomSheet({ children, snapPoints = [100, 300, 600] }) {
  const translateY = useSharedValue(snapPoints[0]);

  const pan = Gesture.Pan()
    .onChange((event) => {
      translateY.value = Math.max(
        snapPoints[snapPoints.length - 1],
        translateY.value + event.changeY
      );
    })
    .onEnd((event) => {
      // Find nearest snap point
      const destination = snapPoints.reduce((prev, curr) => {
        return Math.abs(curr - translateY.value) <
               Math.abs(prev - translateY.value)
          ? curr
          : prev;
      });

      // Include velocity in decision
      if (event.velocityY > 500 && destination < snapPoints[snapPoints.length - 1]) {
        const currentIndex = snapPoints.indexOf(destination);
        translateY.value = withSpring(snapPoints[currentIndex - 1] || destination);
      } else if (event.velocityY < -500 && destination > snapPoints[0]) {
        const currentIndex = snapPoints.indexOf(destination);
        translateY.value = withSpring(snapPoints[currentIndex + 1] || destination);
      } else {
        translateY.value = withSpring(destination);
      }
    });

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [{ translateY: translateY.value }]
  }));

  return (
    <GestureDetector gesture={pan}>
      <Animated.View style={[styles.bottomSheet, animatedStyle]}>
        <View style={styles.handle} />
        {children}
      </Animated.View>
    </GestureDetector>
  );
}
```

## Best Practices

### 1. Always Use GestureHandlerRootView

```javascript
// App.js
import { GestureHandlerRootView } from 'react-native-gesture-handler';

export default function App() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <NavigationContainer>
        {/* Your app */}
      </NavigationContainer>
    </GestureHandlerRootView>
  );
}
```

### 2. Use Context for Start Values

```javascript
const pan = Gesture.Pan()
  .onStart(() => {
    // Save starting position
    context.value = { x: translateX.value, y: translateY.value };
  })
  .onChange((event) => {
    // Use context
    translateX.value = context.value.x + event.translationX;
  });
```

### 3. Optimize Gesture Handlers

```javascript
// BAD: Creates new object every frame
const pan = Gesture.Pan().onChange((event) => {
  position.value = { x: event.x, y: event.y }; // Object creation!
});

// GOOD: Update values directly
const pan = Gesture.Pan().onChange((event) => {
  x.value = event.x;
  y.value = event.y;
});
```

### 4. Clean Up on Component Unmount

```javascript
useEffect(() => {
  return () => {
    cancelAnimation(translateX);
    cancelAnimation(translateY);
  };
}, []);
```

### 5. Use Appropriate Gesture Configuration

```javascript
const pan = Gesture.Pan()
  .minDistance(10) // Minimum distance before activation
  .activeOffsetX([-10, 10]) // Only horizontal movement
  .failOffsetY([-5, 5]) // Fail if vertical movement too large
  .onChange((event) => {
    translateX.value += event.changeX;
  });
```

### 6. Combine runOnJS for Side Effects

```javascript
const pan = Gesture.Pan()
  .onEnd(() => {
    if (translateX.value > threshold) {
      runOnJS(handleSuccess)(); // Call React state updates
    }
  });
```

## Summary

React Native Gesture Handler + Reanimated provides:

- **Performance**: UI-thread gesture processing
- **Variety**: Pan, Tap, Pinch, Rotation, LongPress
- **Composition**: Simultaneous, Exclusive, Race gestures
- **Integration**: Seamless with SharedValues and animations
- **Flexibility**: Swipeable cards, zoomable images, bottom sheets, etc.

Master these patterns to build fluid, responsive touch interactions in React Native!
