---
name: reanimated-performance
description: Create 60fps animations with React Native Reanimated using worklets, SharedValues, and gesture-driven interactions
---

# Reanimated Performance

## Overview

Build high-performance 60fps animations using React Native Reanimated worklets that run on the UI thread, bypassing the JavaScript thread bottleneck.

## When to Use This Skill

- Need 60fps animations without drops
- Building gesture-driven UI (swipe, drag, pinch)
- Animating during scroll events
- Creating smooth transitions between screens
- Optimizing existing Animated API animations
- Building interactive components (sliders, carousels)

## Workflow

### Step 1: Install Reanimated

```bash
npx expo install react-native-reanimated react-native-gesture-handler

# Add babel plugin to babel.config.js
module.exports = {
  plugins: ['react-native-reanimated/plugin'], // Must be last
};
```

### Step 2: Use SharedValues

```typescript
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';

function AnimatedBox() {
  const offset = useSharedValue(0);

  const animatedStyles = useAnimatedStyle(() => ({
    transform: [{ translateX: withSpring(offset.value * 200) }],
  }));

  return (
    <Animated.View style={[styles.box, animatedStyles]}>
      <Pressable onPress={() => (offset.value = offset.value === 0 ? 1 : 0)}>
        <Text>Move</Text>
      </Pressable>
    </Animated.View>
  );
}
```

### Step 3: Gesture Handler Integration

```typescript
import { Gesture, GestureDetector } from 'react-native-gesture-handler';
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withDecay,
} from 'react-native-reanimated';

function DraggableCard() {
  const translateX = useSharedValue(0);
  const translateY = useSharedValue(0);

  const pan = Gesture.Pan()
    .onChange((event) => {
      translateX.value += event.changeX;
      translateY.value += event.changeY;
    })
    .onEnd((event) => {
      translateX.value = withDecay({
        velocity: event.velocityX,
        deceleration: 0.998,
      });
      translateY.value = withDecay({
        velocity: event.velocityY,
        deceleration: 0.998,
      });
    });

  const animatedStyle = useAnimatedStyle(() => ({
    transform: [
      { translateX: translateX.value },
      { translateY: translateY.value },
    ],
  }));

  return (
    <GestureDetector gesture={pan}>
      <Animated.View style={[styles.card, animatedStyle]} />
    </GestureDetector>
  );
}
```

## Guidelines

**Do:**
- Use worklets for all animation logic
- Use SharedValues for animated values
- Use useAnimatedStyle for style updates
- Use withSpring/withTiming for smooth animations
- Mark functions as 'worklet' when needed
- Use runOnJS() to call JS functions from worklets

**Don't:**
- Don't use Animated API and Reanimated together
- Don't access React state directly in worklets
- Don't call async functions in worklets
- Don't forget 'worklet' directive for helper functions
- Don't use console.log in worklets (use runOnJS)

## Resources

- [Worklets Guide](references/worklets-guide.md)
- [Gesture Handler Integration](references/gesture-handler-integration.md)
- [Official Docs](https://docs.swmansion.com/react-native-reanimated/)

## Tools & Commands

- Enable "Slow Animations" in dev menu for debugging

---

## Notes

- Worklets run on UI thread = 60fps guaranteed
- Compatible with Expo Go and EAS Build
