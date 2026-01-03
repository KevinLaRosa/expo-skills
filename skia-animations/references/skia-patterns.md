# React Native Skia Patterns Reference

This guide covers common patterns, best practices, and techniques for working with `@shopify/react-native-skia`.

## Table of Contents

1. [Gradients](#gradients)
2. [Shadows](#shadows)
3. [Blur Effects](#blur-effects)
4. [Drawing Shapes](#drawing-shapes)
5. [Paths](#paths)
6. [Animations](#animations)
7. [Performance Optimization](#performance-optimization)
8. [Shaders and Effects](#shaders-and-effects)
9. [Image Filters](#image-filters)
10. [Charts and Data Visualization](#charts-and-data-visualization)

---

## Gradients

React Native Skia supports multiple gradient types that can be applied to shapes and drawings.

### Linear Gradient

```tsx
import { Canvas, Rect, LinearGradient, vec } from '@shopify/react-native-skia';

<Canvas style={{ flex: 1 }}>
  <Rect x={0} y={0} width={256} height={256}>
    <LinearGradient
      start={vec(0, 0)}
      end={vec(256, 256)}
      colors={['#00ff87', '#60efff']}
    />
  </Rect>
</Canvas>
```

### Radial Gradient

```tsx
import { Canvas, Circle, RadialGradient, vec } from '@shopify/react-native-skia';

<Canvas style={{ flex: 1 }}>
  <Circle cx={128} cy={128} r={128}>
    <RadialGradient
      c={vec(128, 128)}
      r={128}
      colors={['#00ff87', '#60efff']}
    />
  </Circle>
</Canvas>
```

### Sweep Gradient

```tsx
import { Canvas, Rect, SweepGradient, vec } from '@shopify/react-native-skia';

<Canvas style={{ flex: 1 }}>
  <Rect x={0} y={0} width={256} height={256}>
    <SweepGradient
      c={vec(128, 128)}
      colors={['cyan', 'magenta', 'yellow', 'cyan']}
    />
  </Rect>
</Canvas>
```

### Two Point Conical Gradient

```tsx
import { Canvas, Rect, TwoPointConicalGradient, vec } from '@shopify/react-native-skia';

<Canvas style={{ flex: 1 }}>
  <Rect x={0} y={0} width={256} height={256}>
    <TwoPointConicalGradient
      start={vec(64, 64)}
      startR={64}
      end={vec(192, 192)}
      endR={64}
      colors={['#00ff87', '#60efff']}
    />
  </Rect>
</Canvas>
```

### Animating Gradients

```tsx
import { useSharedValue, withRepeat, withTiming } from 'react-native-reanimated';

const progress = useSharedValue(0);

useEffect(() => {
  progress.value = withRepeat(withTiming(1, { duration: 2000 }), -1, true);
}, []);

// Use interpolateColors for animating gradient colors
import { interpolateColors } from '@shopify/react-native-skia';

const colors = useDerivedValue(() => {
  return interpolateColors(
    progress.value,
    [0, 0.5, 1],
    [['#ff0000', '#00ff00'], ['#00ff00', '#0000ff'], ['#0000ff', '#ff0000']]
  );
});
```

---

## Shadows

Shadows add depth and elevation to your graphics. React Native Skia supports both outer and inner shadows.

### Basic Shadow

```tsx
import { Canvas, Circle, Shadow } from '@shopify/react-native-skia';

<Canvas style={{ flex: 1 }}>
  <Circle cx={128} cy={128} r={64} color="#61DAFB">
    <Shadow dx={4} dy={4} blur={10} color="rgba(0,0,0,0.3)" />
  </Circle>
</Canvas>
```

### Inner Shadow

```tsx
<Circle cx={128} cy={128} r={64} color="#61DAFB">
  <Shadow dx={2} dy={2} blur={8} color="rgba(0,0,0,0.4)" inner />
</Circle>
```

### Neumorphism Effect (Multiple Shadows)

```tsx
<Circle cx={128} cy={128} r={64} color="#e0e5ec">
  <Shadow dx={-8} dy={-8} blur={15} color="rgba(255,255,255,0.7)" />
  <Shadow dx={8} dy={8} blur={15} color="rgba(174,174,192,0.4)" />
</Circle>
```

---

## Blur Effects

Blur effects are implemented using image filters and can be applied to any drawable component.

### Basic Blur

```tsx
import { Canvas, Circle, Blur } from '@shopify/react-native-skia';

<Canvas style={{ flex: 1 }}>
  <Circle cx={128} cy={128} r={64} color="#61DAFB">
    <Blur blur={10} />
  </Circle>
</Canvas>
```

### Directional Blur (X and Y)

```tsx
<Circle cx={128} cy={128} r={64} color="#61DAFB">
  <Blur blur={10} blurY={20} /> {/* More blur on Y axis */}
</Circle>
```

### Backdrop Blur (Glassmorphism)

```tsx
import { Canvas, BackdropBlur, RoundedRect, Fill } from '@shopify/react-native-skia';

<Canvas style={{ flex: 1 }}>
  <Fill color="lightblue" />
  <BackdropBlur blur={10} clip={{ x: 50, y: 50, width: 200, height: 200 }}>
    <RoundedRect x={50} y={50} width={200} height={200} r={16} color="rgba(255,255,255,0.5)" />
  </BackdropBlur>
</Canvas>
```

---

## Drawing Shapes

React Native Skia provides primitives for common shapes.

### Circle

```tsx
import { Canvas, Circle } from '@shopify/react-native-skia';

<Canvas style={{ flex: 1 }}>
  <Circle cx={128} cy={128} r={64} color="#61DAFB" />
</Canvas>
```

### Rectangle

```tsx
import { Canvas, Rect } from '@shopify/react-native-skia';

<Canvas style={{ flex: 1 }}>
  <Rect x={50} y={50} width={200} height={100} color="#61DAFB" />
</Canvas>
```

### Rounded Rectangle

```tsx
import { Canvas, RoundedRect } from '@shopify/react-native-skia';

<Canvas style={{ flex: 1 }}>
  <RoundedRect x={50} y={50} width={200} height={100} r={16} color="#61DAFB" />
</Canvas>
```

### Line

```tsx
import { Canvas, Line, vec } from '@shopify/react-native-skia';

<Canvas style={{ flex: 1 }}>
  <Line p1={vec(0, 0)} p2={vec(256, 256)} color="#61DAFB" strokeWidth={2} />
</Canvas>
```

### Polygon

```tsx
import { Canvas, Polygon, vec } from '@shopify/react-native-skia';

<Canvas style={{ flex: 1 }}>
  <Polygon
    points={[vec(128, 0), vec(256, 256), vec(0, 256)]}
    color="#61DAFB"
  />
</Canvas>
```

---

## Paths

Paths allow you to draw complex shapes using SVG notation or imperative commands.

### SVG Path

```tsx
import { Canvas, Path } from '@shopify/react-native-skia';

<Canvas style={{ flex: 1 }}>
  <Path
    path="M 128 0 L 256 256 L 0 256 Z"
    color="#61DAFB"
    style="fill"
  />
</Canvas>
```

### Creating Paths Imperatively

```tsx
import { Skia } from '@shopify/react-native-skia';

const path = Skia.Path.Make();
path.moveTo(128, 0);
path.lineTo(256, 256);
path.lineTo(0, 256);
path.close();

<Canvas style={{ flex: 1 }}>
  <Path path={path} color="#61DAFB" />
</Canvas>
```

### Path from SVG String

```tsx
const path = Skia.Path.MakeFromSVGString(
  'M 10 10 H 90 V 90 H 10 L 10 10'
);

<Canvas style={{ flex: 1 }}>
  <Path path={path} color="#61DAFB" />
</Canvas>
```

### Path Operations

```tsx
import { Skia, PathOp } from '@shopify/react-native-skia';

const circle1 = Skia.Path.Make();
circle1.addCircle(100, 100, 50);

const circle2 = Skia.Path.Make();
circle2.addCircle(150, 100, 50);

// Union, Difference, Intersection, XOR, ReverseDifference
const result = Skia.Path.MakeFromOp(circle1, circle2, PathOp.Union);
```

### Animating Paths

```tsx
import { useDerivedValue } from 'react-native-reanimated';
import { Skia, interpolatePaths } from '@shopify/react-native-skia';

const progress = useSharedValue(0);

const path1 = Skia.Path.MakeFromSVGString('M 0 0 L 100 0 L 100 100 L 0 100 Z');
const path2 = Skia.Path.MakeFromSVGString('M 50 0 L 100 50 L 50 100 L 0 50 Z');

const animatedPath = useDerivedValue(() => {
  return interpolatePaths(progress.value, [0, 1], [path1, path2]);
});

<Canvas style={{ flex: 1 }}>
  <Path path={animatedPath} color="#61DAFB" />
</Canvas>
```

---

## Animations

React Native Skia integrates seamlessly with Reanimated for high-performance animations.

### Basic Animation with Reanimated

```tsx
import { useSharedValue, withRepeat, withTiming } from 'react-native-reanimated';
import { Canvas, Circle } from '@shopify/react-native-skia';

const cx = useSharedValue(50);

useEffect(() => {
  cx.value = withRepeat(withTiming(200, { duration: 1000 }), -1, true);
}, []);

<Canvas style={{ flex: 1 }}>
  <Circle cx={cx} cy={128} r={40} color="#61DAFB" />
</Canvas>
```

### Using Derived Values

```tsx
import { useDerivedValue } from 'react-native-reanimated';

const progress = useSharedValue(0);

const radius = useDerivedValue(() => {
  return 20 + progress.value * 60;
});

<Canvas style={{ flex: 1 }}>
  <Circle cx={128} cy={128} r={radius} color="#61DAFB" />
</Canvas>
```

### Spring Animations

```tsx
import { withSpring } from 'react-native-reanimated';

const scale = useSharedValue(1);

const handlePress = () => {
  scale.value = withSpring(scale.value === 1 ? 1.5 : 1);
};

const transform = useDerivedValue(() => [{ scale: scale.value }]);
```

### Gesture-Based Animations

```tsx
import { GestureDetector, Gesture } from 'react-native-gesture-handler';
import { useSharedValue, withDecay } from 'react-native-reanimated';

const offsetX = useSharedValue(0);
const offsetY = useSharedValue(0);

const pan = Gesture.Pan()
  .onChange((e) => {
    offsetX.value += e.changeX;
    offsetY.value += e.changeY;
  })
  .onEnd((e) => {
    offsetX.value = withDecay({ velocity: e.velocityX });
    offsetY.value = withDecay({ velocity: e.velocityY });
  });

<GestureDetector gesture={pan}>
  <Canvas style={{ flex: 1 }}>
    <Circle cx={offsetX} cy={offsetY} r={40} color="#61DAFB" />
  </Canvas>
</GestureDetector>
```

---

## Performance Optimization

React Native Skia leverages GPU acceleration for high performance, but proper optimization is key.

### Best Practices

1. **Memoize Path Creation**
   ```tsx
   import { useMemo } from 'react';

   const path = useMemo(() => {
     const p = Skia.Path.Make();
     // Expensive path operations
     return p;
   }, [dependencies]);
   ```

2. **Avoid Skia in Repetitive Lists**
   - Don't use Skia components as FlatList items
   - Consider using Skia for full-screen visualizations instead

3. **Use Reanimated for Smooth Interactions**
   ```tsx
   const animatedPath = useDerivedValue(() => {
     // Path calculations run on UI thread
     return createPath(progress.value);
   }, [progress]);
   ```

4. **Batch Operations**
   - Combine multiple drawing operations when possible
   - Use Group components to organize and optimize rendering

5. **Leverage GPU Acceleration**
   - Skia uses Metal on iOS and OpenGL on Android
   - Animations run at 60+ FPS (or 120 FPS on capable devices)

6. **Performance Improvements**
   - Recent updates delivered up to 50% faster animations on iOS
   - Nearly 200% faster on Android

### Frame-Perfect Timing

```tsx
import { useFrameCallback } from 'react-native-reanimated';

const progress = useSharedValue(0);

useFrameCallback((frameInfo) => {
  progress.value = (frameInfo.timestamp / 1000) % 1;
});
```

---

## Shaders and Effects

Shaders allow you to create custom visual effects using GLSL (SkSL).

### Runtime Shader (Custom GLSL)

```tsx
import { Canvas, Rect, Shader, Skia } from '@shopify/react-native-skia';

const source = Skia.RuntimeEffect.Make(`
  uniform vec2 resolution;
  uniform float time;

  half4 main(vec2 pos) {
    vec2 uv = pos / resolution;
    float r = abs(sin(uv.x * 10.0 + time));
    float g = abs(cos(uv.y * 10.0 + time));
    float b = abs(sin(time));
    return vec4(r, g, b, 1.0);
  }
`)!;

const shader = source.makeShader([
  256, 256, // resolution
  Date.now() / 1000 // time
]);

<Canvas style={{ flex: 1 }}>
  <Rect x={0} y={0} width={256} height={256}>
    <Shader source={shader} />
  </Rect>
</Canvas>
```

### Glassmorphism Effect

```tsx
import { Canvas, BackdropBlur, RoundedRect, Fill } from '@shopify/react-native-skia';

<Canvas style={{ flex: 1 }}>
  <Fill color="#667788" />
  {/* Background content */}
  <BackdropBlur blur={20} clip={{ x: 50, y: 50, width: 200, height: 200 }}>
    <RoundedRect
      x={50}
      y={50}
      width={200}
      height={200}
      r={16}
      color="rgba(255,255,255,0.2)"
    />
  </BackdropBlur>
</Canvas>
```

### Ripple Effect

```tsx
const rippleShader = Skia.RuntimeEffect.Make(`
  uniform vec2 center;
  uniform float radius;
  uniform float time;

  half4 main(vec2 pos) {
    float dist = distance(pos, center);
    float wave = sin(dist * 0.1 - time * 5.0) * 0.5 + 0.5;
    float alpha = smoothstep(radius + 20.0, radius, dist) * wave;
    return vec4(0.3, 0.6, 1.0, alpha);
  }
`)!;
```

---

## Image Filters

Image filters transform the appearance of rendered content.

### Color Matrix

```tsx
import { Canvas, Image, ColorMatrix, useImage } from '@shopify/react-native-skia';

const image = useImage(require('./photo.jpg'));

// Grayscale matrix
const grayscale = [
  0.33, 0.33, 0.33, 0, 0,
  0.33, 0.33, 0.33, 0, 0,
  0.33, 0.33, 0.33, 0, 0,
  0,    0,    0,    1, 0,
];

<Canvas style={{ flex: 1 }}>
  <Image image={image} x={0} y={0} width={256} height={256}>
    <ColorMatrix matrix={grayscale} />
  </Image>
</Canvas>
```

### Sepia Effect

```tsx
const sepia = [
  0.393, 0.769, 0.189, 0, 0,
  0.349, 0.686, 0.168, 0, 0,
  0.272, 0.534, 0.131, 0, 0,
  0,     0,     0,     1, 0,
];
```

### Combining Filters

```tsx
<Image image={image} x={0} y={0} width={256} height={256}>
  <ColorMatrix matrix={sepia} />
  <Blur blur={5} />
</Image>
```

### Displacement Map

```tsx
import { DisplacementMap } from '@shopify/react-native-skia';

<Image image={image} x={0} y={0} width={256} height={256}>
  <DisplacementMap channelX="r" channelY="g" scale={20} />
</Image>
```

---

## Charts and Data Visualization

Skia is excellent for creating custom charts and data visualizations.

### Line Chart Pattern

```tsx
import { Canvas, Path, Skia } from '@shopify/react-native-skia';

const createLinePath = (data: number[], width: number, height: number) => {
  const path = Skia.Path.Make();
  const xStep = width / (data.length - 1);
  const yScale = height / Math.max(...data);

  data.forEach((value, index) => {
    const x = index * xStep;
    const y = height - value * yScale;

    if (index === 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }
  });

  return path;
};

const data = [10, 30, 20, 50, 40, 60, 45];
const path = createLinePath(data, 300, 200);

<Canvas style={{ flex: 1 }}>
  <Path path={path} color="#61DAFB" style="stroke" strokeWidth={2} />
</Canvas>
```

### Bar Chart Pattern

```tsx
const BarChart = ({ data }: { data: number[] }) => {
  const width = 300;
  const height = 200;
  const barWidth = width / data.length;
  const maxValue = Math.max(...data);

  return (
    <Canvas style={{ width, height }}>
      {data.map((value, index) => {
        const barHeight = (value / maxValue) * height;
        const x = index * barWidth;
        const y = height - barHeight;

        return (
          <RoundedRect
            key={index}
            x={x + 5}
            y={y}
            width={barWidth - 10}
            height={barHeight}
            r={4}
            color="#61DAFB"
          />
        );
      })}
    </Canvas>
  );
};
```

### Animated Area Chart

```tsx
const createAreaPath = (data: number[], progress: number, width: number, height: number) => {
  const path = Skia.Path.Make();
  const xStep = width / (data.length - 1);
  const yScale = height / Math.max(...data);
  const visiblePoints = Math.floor(data.length * progress);

  path.moveTo(0, height);

  for (let i = 0; i <= visiblePoints; i++) {
    const x = i * xStep;
    const y = height - data[i] * yScale;
    path.lineTo(x, y);
  }

  path.lineTo(visiblePoints * xStep, height);
  path.close();

  return path;
};

const progress = useSharedValue(0);

useEffect(() => {
  progress.value = withTiming(1, { duration: 1500 });
}, []);

const animatedPath = useDerivedValue(() => {
  return createAreaPath(data, progress.value, 300, 200);
});
```

### Pie Chart Pattern

```tsx
const PieChart = ({ data }: { data: number[] }) => {
  const total = data.reduce((sum, val) => sum + val, 0);
  const centerX = 150;
  const centerY = 150;
  const radius = 100;

  let startAngle = -Math.PI / 2;

  return (
    <Canvas style={{ width: 300, height: 300 }}>
      {data.map((value, index) => {
        const sweepAngle = (value / total) * 2 * Math.PI;
        const path = Skia.Path.Make();

        path.moveTo(centerX, centerY);
        path.addArc(
          { x: centerX - radius, y: centerY - radius, width: radius * 2, height: radius * 2 },
          (startAngle * 180) / Math.PI,
          (sweepAngle * 180) / Math.PI
        );
        path.close();

        startAngle += sweepAngle;

        return <Path key={index} path={path} color={colors[index]} />;
      })}
    </Canvas>
  );
};
```

---

## Additional Resources

- **Official Documentation**: [React Native Skia Docs](https://shopify.github.io/react-native-skia/)
- **GitHub Repository**: [Shopify/react-native-skia](https://github.com/Shopify/react-native-skia)
- **Shopify Engineering Blog**: [Getting Started with React Native Skia](https://shopify.engineering/getting-started-with-react-native-skia)
- **Gradients Guide**: [Gradients Documentation](https://shopify.github.io/react-native-skia/docs/shaders/gradients/)
- **Animations Guide**: [Animations Documentation](https://shopify.github.io/react-native-skia/docs/animations/animations/)
- **Image Filters**: [Image Filters Documentation](https://shopify.github.io/react-native-skia/docs/image-filters/overview/)
- **Color Filters**: [Color Filters Documentation](https://shopify.github.io/react-native-skia/docs/color-filters/)

---

**Note**: React Native Skia requires `react-native@>=0.79` and `react@>=19`, with minimum support for iOS 14 and Android API level 21 or above.
