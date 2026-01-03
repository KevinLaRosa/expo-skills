# Worklets Guide

## What are Worklets?

Worklets are JavaScript functions that can run on the UI thread in React Native. They are the fundamental building block of React Native Reanimated, enabling animations and interactions to run at 60+ FPS without being blocked by the JavaScript thread.

### Why Worklets Matter

**Traditional React Native Animation Problem:**
- Animations run on the JavaScript thread
- JS thread handles UI updates, API calls, state changes, etc.
- When JS thread is busy, animations stutter or drop frames
- Bridge communication adds latency between JS and native UI

**Worklets Solution:**
- Execute directly on the UI thread (native side)
- No bridge communication needed for animations
- Guaranteed 60 FPS performance
- Independent from JS thread workload

### Key Benefits

1. **Performance**: Run at native speeds without JS thread bottlenecks
2. **Responsiveness**: Gesture-driven animations feel immediate
3. **Smooth**: No frame drops during heavy JS operations
4. **Battery Efficient**: Less CPU usage and bridge traffic

## When to Use Worklets

### Ideal Use Cases

**1. Animations**
```javascript
const opacity = useSharedValue(0);

const fadeIn = () => {
  opacity.value = withTiming(1, { duration: 300 });
};
```

**2. Gesture Handlers**
```javascript
const gestureHandler = useAnimatedGestureHandler({
  onActive: (event) => {
    translateX.value = event.translationX;
  }
});
```

**3. Complex Calculations**
```javascript
const animatedStyle = useAnimatedStyle(() => {
  // Complex calculations on UI thread
  const scale = interpolate(
    scrollY.value,
    [0, 100, 200],
    [1, 1.5, 1],
    Extrapolate.CLAMP
  );
  return { transform: [{ scale }] };
});
```

**4. Scroll-Driven Interactions**
```javascript
const scrollHandler = useAnimatedScrollHandler({
  onScroll: (event) => {
    scrollY.value = event.contentOffset.y;
  }
});
```

**5. High-Frequency Updates**
- Real-time drag interactions
- Parallax effects
- Physics-based animations
- Continuous gesture tracking

### When NOT to Use Worklets

- Simple state changes (use regular setState)
- API calls or async operations
- Complex business logic
- Operations requiring npm packages not compatible with UI thread

## How to Create Worklets

### Method 1: Inline 'worklet' Directive

```javascript
function myWorklet(value) {
  'worklet';
  return value * 2;
}
```

### Method 2: useAnimatedStyle (Auto-Worklet)

```javascript
const animatedStyle = useAnimatedStyle(() => {
  // Automatically a worklet - no 'worklet' directive needed
  return {
    opacity: opacity.value,
    transform: [{ translateY: translateY.value }]
  };
});
```

### Method 3: Reanimated Hooks (Auto-Worklet)

All callbacks in these hooks are automatically worklets:
- `useAnimatedGestureHandler`
- `useAnimatedScrollHandler`
- `useDerivedValue`
- `useAnimatedReaction`
- `useAnimatedProps`

```javascript
const derivedValue = useDerivedValue(() => {
  // Automatically a worklet
  return Math.sqrt(x.value ** 2 + y.value ** 2);
});
```

### Method 4: runOnUI

Execute a worklet explicitly on UI thread:

```javascript
const heavyCalculation = (data) => {
  'worklet';
  // Complex computation
  return result;
};

runOnUI(() => {
  const result = heavyCalculation(someData);
  console.log(result);
})();
```

## SharedValues and useSharedValue

### What are SharedValues?

SharedValues are special containers for values that can be accessed and modified from both the JS and UI threads.

```javascript
const offset = useSharedValue(0);
```

### Key Characteristics

1. **Thread-Safe**: Can be read/written from any thread
2. **No Re-Renders**: Changing a SharedValue doesn't trigger React re-renders
3. **Reactive**: Automatically trigger worklet re-executions when changed
4. **Mutable**: Use `.value` property to get/set

### Creating SharedValues

```javascript
import { useSharedValue } from 'react-native-reanimated';

function MyComponent() {
  // Initialize with a value
  const offset = useSharedValue(0);
  const isActive = useSharedValue(false);
  const position = useSharedValue({ x: 0, y: 0 });

  return <View>...</View>;
}
```

### Reading SharedValues

**In Worklets (UI Thread):**
```javascript
const animatedStyle = useAnimatedStyle(() => {
  // Direct access to .value in worklets
  return {
    transform: [{ translateX: offset.value }]
  };
});
```

**In Regular JS (JS Thread):**
```javascript
// Can read, but avoid in performance-critical code
const handlePress = () => {
  console.log('Current offset:', offset.value);
};
```

### Modifying SharedValues

**Direct Assignment:**
```javascript
offset.value = 100; // Instant change
```

**With Animations:**
```javascript
offset.value = withTiming(100, { duration: 300 });
offset.value = withSpring(100, { damping: 10 });
offset.value = withDecay({ velocity: 1000 });
```

**In Gesture Handlers:**
```javascript
const gestureHandler = useAnimatedGestureHandler({
  onStart: (_, ctx) => {
    ctx.startX = offset.value;
  },
  onActive: (event, ctx) => {
    offset.value = ctx.startX + event.translationX;
  }
});
```

## Common Worklet Patterns

### Pattern 1: Animated Style Based on SharedValue

```javascript
function AnimatedBox() {
  const progress = useSharedValue(0);

  const animatedStyle = useAnimatedStyle(() => {
    return {
      opacity: progress.value,
      transform: [
        { scale: interpolate(progress.value, [0, 1], [0.5, 1]) },
        { rotate: `${progress.value * 360}deg` }
      ]
    };
  });

  const startAnimation = () => {
    progress.value = withTiming(1, { duration: 500 });
  };

  return (
    <Animated.View style={[styles.box, animatedStyle]}>
      <Button title="Animate" onPress={startAnimation} />
    </Animated.View>
  );
}
```

### Pattern 2: Derived Values

```javascript
function DerivedExample() {
  const x = useSharedValue(0);
  const y = useSharedValue(0);

  // Automatically recalculates when x or y changes
  const distance = useDerivedValue(() => {
    return Math.sqrt(x.value ** 2 + y.value ** 2);
  });

  const animatedStyle = useAnimatedStyle(() => {
    return {
      transform: [
        { translateX: x.value },
        { translateY: y.value }
      ]
    };
  });

  return <Animated.View style={animatedStyle} />;
}
```

### Pattern 3: Animated Reactions

```javascript
function ReactionExample() {
  const progress = useSharedValue(0);

  // Run side effects when SharedValues change
  useAnimatedReaction(
    () => progress.value,
    (currentValue, previousValue) => {
      if (currentValue > 0.5 && previousValue <= 0.5) {
        runOnJS(hapticFeedback)();
      }
    }
  );

  return <View>...</View>;
}
```

### Pattern 4: Interpolation

```javascript
const animatedStyle = useAnimatedStyle(() => {
  const opacity = interpolate(
    scrollY.value,
    [0, 100, 200],
    [1, 0.5, 0],
    Extrapolate.CLAMP
  );

  const translateY = interpolate(
    scrollY.value,
    [0, 200],
    [0, -50],
    Extrapolate.EXTEND
  );

  return { opacity, transform: [{ translateY }] };
});
```

### Pattern 5: Communicating with JS Thread

```javascript
import { runOnJS } from 'react-native-reanimated';

function JSBridgeExample() {
  const offset = useSharedValue(0);

  const handleComplete = () => {
    console.log('Animation complete!');
  };

  const gestureHandler = useAnimatedGestureHandler({
    onEnd: () => {
      offset.value = withTiming(0, { duration: 300 }, (finished) => {
        if (finished) {
          // Call JS function from worklet
          runOnJS(handleComplete)();
        }
      });
    }
  });

  return <View>...</View>;
}
```

### Pattern 6: Context in Gesture Handlers

```javascript
const gestureHandler = useAnimatedGestureHandler({
  onStart: (_, ctx) => {
    // Store initial values in context
    ctx.startX = translateX.value;
    ctx.startY = translateY.value;
  },
  onActive: (event, ctx) => {
    // Use context values
    translateX.value = ctx.startX + event.translationX;
    translateY.value = ctx.startY + event.translationY;
  },
  onEnd: (event, ctx) => {
    // Animate back using context
    translateX.value = withSpring(ctx.startX);
  }
});
```

## Debugging Worklets

### Console Logging

**In Worklets (UI Thread):**
```javascript
const animatedStyle = useAnimatedStyle(() => {
  console.log('Value:', offset.value); // Works, but limited
  return { transform: [{ translateX: offset.value }] };
});
```

### Using runOnJS for Better Debugging

```javascript
import { runOnJS } from 'react-native-reanimated';

function MyComponent() {
  const debugLog = (message, value) => {
    console.log(message, value);
  };

  const animatedStyle = useAnimatedStyle(() => {
    runOnJS(debugLog)('Current offset:', offset.value);
    return { transform: [{ translateX: offset.value }] };
  });

  return <Animated.View style={animatedStyle} />;
}
```

### Checking Worklet Execution Thread

```javascript
import { getViewProp } from 'react-native-reanimated';

const myWorklet = () => {
  'worklet';
  console.log('Running on UI thread');
  // Worklet code here
};

// Verify it's actually running on UI thread
runOnUI(() => {
  myWorklet();
})();
```

### Common Debugging Issues

**Issue 1: "X is not a worklet" Error**
```javascript
// BAD: External function not marked as worklet
function multiply(a, b) {
  return a * b;
}

const animatedStyle = useAnimatedStyle(() => {
  return { width: multiply(10, 20) }; // ERROR!
});

// GOOD: Mark function as worklet
function multiply(a, b) {
  'worklet';
  return a * b;
}
```

**Issue 2: Accessing Non-Worklet Variables**
```javascript
// BAD: Accessing JS-only values
const data = fetchData(); // Not available on UI thread

const animatedStyle = useAnimatedStyle(() => {
  return { width: data.width }; // ERROR!
});

// GOOD: Use SharedValues or constants
const width = useSharedValue(100);
```

**Issue 3: Using Incompatible Libraries**
```javascript
// BAD: Most npm packages don't work in worklets
import moment from 'moment';

const animatedStyle = useAnimatedStyle(() => {
  const formatted = moment().format(); // ERROR!
  return {};
});

// GOOD: Use Reanimated-compatible functions
const animatedStyle = useAnimatedStyle(() => {
  const timestamp = Date.now(); // Native JS works
  return {};
});
```

## Performance Tips

### 1. Minimize Worklet Complexity

```javascript
// BAD: Complex calculations in every frame
const animatedStyle = useAnimatedStyle(() => {
  const expensiveResult = complexCalculation(
    data1.value,
    data2.value,
    data3.value
  );
  return { width: expensiveResult };
});

// GOOD: Use useDerivedValue to cache
const cachedResult = useDerivedValue(() => {
  return complexCalculation(data1.value, data2.value, data3.value);
});

const animatedStyle = useAnimatedStyle(() => {
  return { width: cachedResult.value };
});
```

### 2. Avoid Unnecessary Re-Executions

```javascript
// BAD: Creates new object every time
const animatedStyle = useAnimatedStyle(() => {
  return {
    transform: [{ translateX: offset.value }],
    shadowOffset: { width: 0, height: 2 }, // Recreated unnecessarily
  };
});

// GOOD: Only return what changes
const animatedStyle = useAnimatedStyle(() => {
  return {
    transform: [{ translateX: offset.value }]
  };
});

// Static styles in StyleSheet
const styles = StyleSheet.create({
  box: {
    shadowOffset: { width: 0, height: 2 }
  }
});
```

### 3. Use Appropriate Animation Types

```javascript
// For smooth, natural motion
offset.value = withSpring(100);

// For precise timing
offset.value = withTiming(100, { duration: 300 });

// For physics-based deceleration
offset.value = withDecay({ velocity: event.velocityX });

// For continuous updates (gestures)
offset.value = event.translationX; // Direct assignment
```

### 4. Batch Updates When Possible

```javascript
// BAD: Multiple separate animations
const animate = () => {
  x.value = withTiming(100);
  y.value = withTiming(200);
  scale.value = withTiming(1.5);
};

// GOOD: Still separate but they'll batch naturally
// Reanimated optimizes this automatically
const animate = () => {
  x.value = withTiming(100, { duration: 300 });
  y.value = withTiming(200, { duration: 300 });
  scale.value = withTiming(1.5, { duration: 300 });
};
```

### 5. Clean Up Animations

```javascript
function MyComponent() {
  const offset = useSharedValue(0);
  const isActive = useRef(true);

  useEffect(() => {
    return () => {
      isActive.current = false;
      // Cancel ongoing animations on unmount
      cancelAnimation(offset);
    };
  }, []);

  return <View>...</View>;
}
```

### 6. Optimize Interpolations

```javascript
// BAD: Recalculating arrays every frame
const animatedStyle = useAnimatedStyle(() => {
  return {
    opacity: interpolate(scroll.value, [0, 100, 200], [1, 0.5, 0])
  };
});

// GOOD: Define ranges outside if they're constant
const inputRange = [0, 100, 200];
const outputRange = [1, 0.5, 0];

const animatedStyle = useAnimatedStyle(() => {
  return {
    opacity: interpolate(scroll.value, inputRange, outputRange)
  };
});
```

### 7. Use Direct Manipulation for Simple Cases

```javascript
// For very simple animations without complex logic
const opacity = useSharedValue(1);

const fadeOut = () => {
  opacity.value = withTiming(0, { duration: 200 });
};

const animatedStyle = useAnimatedStyle(() => ({
  opacity: opacity.value
}));
```

### 8. Avoid Excessive Console Logging

```javascript
// BAD: Logging every frame (60+ times per second)
const animatedStyle = useAnimatedStyle(() => {
  console.log(offset.value); // Performance killer!
  return { transform: [{ translateX: offset.value }] };
});

// GOOD: Log only when needed via reactions
useAnimatedReaction(
  () => offset.value,
  (value) => {
    if (value > 100) {
      runOnJS(console.log)('Threshold reached');
    }
  }
);
```

## Summary

Worklets are the foundation of React Native Reanimated's performance:

- **What**: JS functions running on UI thread
- **Why**: 60+ FPS animations without JS thread interference
- **When**: Animations, gestures, high-frequency updates
- **How**: Use 'worklet' directive or Reanimated hooks
- **SharedValues**: Thread-safe value containers
- **Patterns**: Animated styles, derived values, interpolations
- **Debug**: Use console.log and runOnJS carefully
- **Performance**: Minimize complexity, batch updates, cache calculations

Master these concepts to build buttery-smooth React Native animations!
