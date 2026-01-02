---
name: skia-animations
description: Build high-performance charts, gradients, and custom graphics with React Native Skia for 60fps visualizations
license: MIT
compatibility: "Requires: @shopify/react-native-skia 1+, Expo SDK 50+, react-native-reanimated (for animations)"
---

# Skia Animations

## Overview

Create high-performance 2D graphics, charts, and animations using React Native Skia, a declarative API for the Skia graphics engine.

## When to Use This Skill

- Building custom charts (line, bar, pie)
- Creating complex gradients and visual effects
- Need 60fps graphics rendering
- Implementing custom shapes and paths
- Building data visualizations with Victory Native
- Creating animated graphics and illustrations

## Workflow

### Step 1: Install Skia

```bash
npx expo install @shopify/react-native-skia
```

### Step 2: Basic Skia Canvas

```typescript
import { Canvas, Circle, Group } from '@shopify/react-native-skia';

function SkiaExample() {
  return (
    <Canvas style={{ width: 256, height: 256 }}>
      <Group blendMode="multiply">
        <Circle cx={128} cy={128} r={64} color="cyan" />
        <Circle cx={128} cy={64} r={64} color="magenta" />
      </Group>
    </Canvas>
  );
}
```

### Step 3: Animated Charts with Victory Native

```bash
npx expo install victory-native
```

```typescript
import { CartesianChart, Line } from 'victory-native';

function Chart({ data }) {
  return (
    <CartesianChart
      data={data}
      xKey="date"
      yKeys={["value"]}
    >
      {({ points }) => <Line points={points.value} color="red" strokeWidth={3} />}
    </CartesianChart>
  );
}
```

## Guidelines

**Do:**
- Use Skia for complex graphics
- Leverage Victory Native for charts
- Combine with Reanimated for animations
- Use worklets for performance

**Don't:**
- Don't use for simple UI (use View/Text instead)
- Don't forget to memoize Skia components

## Resources

- [Skia Patterns](references/skia-patterns.md)
- [Victory Native Guide](references/victory-native-integration.md)

---

## Notes

- Skia renders on native thread (60fps)
- Perfect for data visualization
