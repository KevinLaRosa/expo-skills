# Victory Native XL Integration Reference

This guide covers how to use Victory Native XL for creating high-performance charts in React Native with Skia.

## Table of Contents

1. [Overview](#overview)
2. [Installation](#installation)
3. [CartesianChart Basics](#cartesianchart-basics)
4. [Line Charts](#line-charts)
5. [Bar Charts](#bar-charts)
6. [Area Charts](#area-charts)
7. [Multiple Series](#multiple-series)
8. [Custom Styling](#custom-styling)
9. [Animations](#animations)
10. [Gestures and Interactions](#gestures-and-interactions)
11. [Tooltips](#tooltips)
12. [Performance Optimization](#performance-optimization)
13. [Advanced Features](#advanced-features)

---

## Overview

Victory Native XL is a ground-up rewrite of Victory Native that leverages modern React Native tooling:

- **React Native Reanimated**: Smooth, high-performance animations
- **React Native Gesture Handler**: Rich gesture-based interactions
- **React Native Skia**: GPU-accelerated rendering

### Key Features

- High-performance rendering with 1000+ data points
- Gesture-driven interactions (pan, zoom, press)
- Customizable Skia graphics
- Reanimated-powered animations
- Minimal boilerplate code (~300 lines for complex charts)

### Architecture

Victory Native XL handles the mathematical complexities of charting and path drawing, allowing you to focus on creating custom visualizations without worrying about coordinate transformations and scales.

---

## Installation

```bash
# Install Victory Native XL
npm install victory-native

# Install peer dependencies
npm install react-native-reanimated react-native-gesture-handler @shopify/react-native-skia
```

Or with yarn:

```bash
yarn add victory-native
yarn add react-native-reanimated react-native-gesture-handler @shopify/react-native-skia
```

### Setup

Make sure to configure Reanimated in your `babel.config.js`:

```javascript
module.exports = {
  presets: ['module:metro-react-native-babel-preset'],
  plugins: ['react-native-reanimated/plugin'],
};
```

---

## CartesianChart Basics

The `CartesianChart` component is the core component of Victory Native XL.

### Basic Structure

```tsx
import { CartesianChart, Line } from 'victory-native';
import { View } from 'react-native';

const DATA = [
  { x: 1, y: 10 },
  { x: 2, y: 20 },
  { x: 3, y: 15 },
  { x: 4, y: 30 },
  { x: 5, y: 25 },
];

export function BasicChart() {
  return (
    <View style={{ height: 300 }}>
      <CartesianChart data={DATA} xKey="x" yKeys={["y"]}>
        {({ points }) => (
          <Line points={points.y} color="red" strokeWidth={3} />
        )}
      </CartesianChart>
    </View>
  );
}
```

### Render Function Pattern

CartesianChart uses a render function for its children prop. The render function receives chart data transformed into Skia-ready coordinates:

```tsx
<CartesianChart data={DATA} xKey="x" yKeys={["y"]}>
  {({ points, chartBounds }) => (
    // Return Skia elements here
    <Line points={points.y} color="blue" strokeWidth={2} />
  )}
</CartesianChart>
```

---

## Line Charts

Line charts display data as a continuous line connecting points.

### Basic Line Chart

```tsx
import { CartesianChart, Line } from 'victory-native';

const DATA = Array.from({ length: 20 }, (_, i) => ({
  day: i,
  sales: Math.random() * 100,
}));

export function LineChartExample() {
  return (
    <View style={{ height: 300 }}>
      <CartesianChart data={DATA} xKey="day" yKeys={["sales"]}>
        {({ points }) => (
          <Line points={points.sales} color="#3b82f6" strokeWidth={2} />
        )}
      </CartesianChart>
    </View>
  );
}
```

### Curved Line Chart

```tsx
<CartesianChart data={DATA} xKey="day" yKeys={["sales"]}>
  {({ points }) => (
    <Line
      points={points.sales}
      color="#3b82f6"
      strokeWidth={2}
      curveType="natural" // Options: linear, natural, step
    />
  )}
</CartesianChart>
```

### Multiple Lines

```tsx
const DATA = [
  { month: 'Jan', revenue: 1000, expenses: 800 },
  { month: 'Feb', revenue: 1200, expenses: 900 },
  { month: 'Mar', revenue: 1500, expenses: 1000 },
];

<CartesianChart data={DATA} xKey="month" yKeys={["revenue", "expenses"]}>
  {({ points }) => (
    <>
      <Line points={points.revenue} color="#10b981" strokeWidth={2} />
      <Line points={points.expenses} color="#ef4444" strokeWidth={2} />
    </>
  )}
</CartesianChart>
```

---

## Bar Charts

Bar charts display data as rectangular bars.

### Basic Bar Chart

```tsx
import { CartesianChart, Bar } from 'victory-native';

const DATA = [
  { month: 'Jan', listens: 1000 },
  { month: 'Feb', listens: 1500 },
  { month: 'Mar', listens: 1200 },
  { month: 'Apr', listens: 1800 },
];

export function BarChartExample() {
  return (
    <View style={{ height: 300 }}>
      <CartesianChart data={DATA} xKey="month" yKeys={["listens"]}>
        {({ points, chartBounds }) => (
          <Bar
            points={points.listens}
            chartBounds={chartBounds}
            color="#8b5cf6"
          />
        )}
      </CartesianChart>
    </View>
  );
}
```

### Rounded Corner Bars

```tsx
<CartesianChart data={DATA} xKey="month" yKeys={["listens"]}>
  {({ points, chartBounds }) => (
    <Bar
      points={points.listens}
      chartBounds={chartBounds}
      color="#8b5cf6"
      roundedCorners={{
        topLeft: 8,
        topRight: 8,
      }}
    />
  )}
</CartesianChart>
```

### Gradient-Filled Bars

```tsx
import { LinearGradient, vec } from '@shopify/react-native-skia';

<CartesianChart data={DATA} xKey="month" yKeys={["listens"]}>
  {({ points, chartBounds }) => (
    <Bar
      points={points.listens}
      chartBounds={chartBounds}
    >
      <LinearGradient
        start={vec(0, 0)}
        end={vec(0, chartBounds.bottom)}
        colors={['#a78bfa', '#8b5cf6']}
      />
    </Bar>
  )}
</CartesianChart>
```

### Grouped Bar Chart

```tsx
const DATA = [
  { month: 'Jan', product1: 1000, product2: 800 },
  { month: 'Feb', product1: 1200, product2: 900 },
];

<CartesianChart data={DATA} xKey="month" yKeys={["product1", "product2"]}>
  {({ points, chartBounds }) => (
    <>
      <Bar
        points={points.product1}
        chartBounds={chartBounds}
        color="#3b82f6"
      />
      <Bar
        points={points.product2}
        chartBounds={chartBounds}
        color="#10b981"
      />
    </>
  )}
</CartesianChart>
```

---

## Area Charts

Area charts display data as filled regions under a line.

### Basic Area Chart

```tsx
import { CartesianChart, Area } from 'victory-native';

const DATA = [
  { day: 1, value: 10 },
  { day: 2, value: 25 },
  { day: 3, value: 15 },
  { day: 4, value: 30 },
];

export function AreaChartExample() {
  return (
    <View style={{ height: 300 }}>
      <CartesianChart data={DATA} xKey="day" yKeys={["value"]}>
        {({ points }) => (
          <Area
            points={points.value}
            y0={0}
            color="#3b82f6"
            opacity={0.5}
          />
        )}
      </CartesianChart>
    </View>
  );
}
```

### Area Chart with Gradient

```tsx
import { LinearGradient, vec } from '@shopify/react-native-skia';

<CartesianChart data={DATA} xKey="day" yKeys={["value"]}>
  {({ points, chartBounds }) => (
    <Area points={points.value} y0={0}>
      <LinearGradient
        start={vec(0, 0)}
        end={vec(0, chartBounds.bottom)}
        colors={['rgba(59, 130, 246, 0.5)', 'rgba(59, 130, 246, 0.1)']}
      />
    </Area>
  )}
</CartesianChart>
```

### Range Area Chart (High/Low)

```tsx
const DATA = [
  { day: 1, high: 30, low: 10 },
  { day: 2, high: 35, low: 15 },
  { day: 3, high: 32, low: 12 },
];

<CartesianChart data={DATA} xKey="day" yKeys={["high", "low"]}>
  {({ points }) => (
    <Area
      points={points.high}
      y0={points.low}
      color="#10b981"
      opacity={0.3}
    />
  )}
</CartesianChart>
```

### Stacked Area Chart

```tsx
<CartesianChart data={DATA} xKey="day" yKeys={["series1", "series2"]}>
  {({ points }) => (
    <>
      <Area
        points={points.series1}
        y0={0}
        color="rgba(59, 130, 246, 0.5)"
      />
      <Area
        points={points.series2}
        y0={points.series1}
        color="rgba(16, 185, 129, 0.5)"
      />
    </>
  )}
</CartesianChart>
```

---

## Multiple Series

Victory Native XL makes it easy to display multiple data series in the same chart.

### Multi-Series Line Chart

```tsx
const DATA = [
  { time: 1, x: 10, y: 15, z: 12 },
  { time: 2, x: 20, y: 25, z: 18 },
  { time: 3, x: 15, y: 20, z: 22 },
];

<CartesianChart data={DATA} xKey="time" yKeys={["x", "y", "z"]}>
  {({ points }) => (
    <>
      <Line points={points.x} color="#ef4444" strokeWidth={2} />
      <Line points={points.y} color="#3b82f6" strokeWidth={2} />
      <Line points={points.z} color="#10b981" strokeWidth={2} />
    </>
  )}
</CartesianChart>
```

### Combining Chart Types

```tsx
<CartesianChart data={DATA} xKey="month" yKeys={["sales", "target"]}>
  {({ points, chartBounds }) => (
    <>
      <Bar
        points={points.sales}
        chartBounds={chartBounds}
        color="#3b82f6"
      />
      <Line
        points={points.target}
        color="#ef4444"
        strokeWidth={3}
        strokeDasharray={[5, 5]}
      />
    </>
  )}
</CartesianChart>
```

---

## Custom Styling

Victory Native XL provides flexible styling options through Skia components.

### Custom Colors

```tsx
<CartesianChart data={DATA} xKey="x" yKeys={["y"]}>
  {({ points }) => (
    <Line
      points={points.y}
      color="#f59e0b"
      strokeWidth={3}
    />
  )}
</CartesianChart>
```

### Stroke Patterns

```tsx
<Line
  points={points.y}
  color="#3b82f6"
  strokeWidth={2}
  strokeDasharray={[10, 5]} // Dashed line
/>
```

### Custom Point Markers

```tsx
import { Circle } from '@shopify/react-native-skia';

<CartesianChart data={DATA} xKey="x" yKeys={["y"]}>
  {({ points }) => (
    <>
      <Line points={points.y} color="#3b82f6" strokeWidth={2} />
      {points.y.map((point, index) => (
        <Circle
          key={index}
          cx={point.x}
          cy={point.y}
          r={4}
          color="#3b82f6"
        />
      ))}
    </>
  )}
</CartesianChart>
```

### Axes Styling

```tsx
<CartesianChart
  data={DATA}
  xKey="x"
  yKeys={["y"]}
  axisOptions={{
    font: customFont,
    lineColor: '#d1d5db',
    labelColor: '#6b7280',
  }}
>
  {/* ... */}
</CartesianChart>
```

---

## Animations

Victory Native XL leverages Reanimated for smooth animations.

### Animate on Data Change

```tsx
import { useSharedValue, withTiming } from 'react-native-reanimated';

const [data, setData] = useState(initialData);

// Data automatically animates when it changes
<CartesianChart
  data={data}
  xKey="x"
  yKeys={["y"]}
  animationDuration={500}
>
  {({ points }) => (
    <Line points={points.y} color="#3b82f6" strokeWidth={2} />
  )}
</CartesianChart>
```

### Custom Animation Timing

```tsx
<CartesianChart
  data={data}
  xKey="x"
  yKeys={["y"]}
  animationDuration={1000}
  animateOnMount
>
  {({ points }) => (
    <Area points={points.y} y0={0} color="#3b82f6" />
  )}
</CartesianChart>
```

### Progressive Reveal Animation

```tsx
const progress = useSharedValue(0);

useEffect(() => {
  progress.value = withTiming(1, { duration: 1500 });
}, []);

<CartesianChart data={DATA} xKey="x" yKeys={["y"]}>
  {({ points }) => {
    const animatedPoints = useDerivedValue(() => {
      const count = Math.floor(points.y.length * progress.value);
      return points.y.slice(0, count);
    });

    return <Line points={animatedPoints} color="#3b82f6" strokeWidth={2} />;
  }}
</CartesianChart>
```

---

## Gestures and Interactions

Victory Native XL provides opt-in support for press gestures and interactions.

### Basic Press Gesture

```tsx
import { useChartPressState } from 'victory-native';

const { state, isActive } = useChartPressState({ x: 0, y: { y: 0 } });

<CartesianChart
  data={DATA}
  xKey="day"
  yKeys={["y"]}
  chartPressState={state}
>
  {({ points, chartBounds }) => (
    <>
      <Line points={points.y} color="#3b82f6" strokeWidth={2} />
      {isActive && (
        <Circle
          cx={state.x.position}
          cy={state.y.y.position}
          r={8}
          color="#ef4444"
        />
      )}
    </>
  )}
</CartesianChart>
```

### Multi-Touch Support

```tsx
const { state, isActive } = useChartPressState({
  x: 0,
  y: { series1: 0, series2: 0 }
});

<CartesianChart
  data={DATA}
  xKey="x"
  yKeys={["series1", "series2"]}
  chartPressState={state}
>
  {({ points }) => (
    <>
      <Line points={points.series1} color="#3b82f6" strokeWidth={2} />
      <Line points={points.series2} color="#10b981" strokeWidth={2} />
    </>
  )}
</CartesianChart>
```

### Tracking Closest Point

The `useChartPressState` hook exposes the closest data point as Reanimated shared values:

```tsx
const { state, isActive } = useChartPressState({ x: 0, y: { y: 0 } });

// Access values in JavaScript
const xValue = useDerivedValue(() => state.x.value.value);
const yValue = useDerivedValue(() => state.y.y.value.value);
```

---

## Tooltips

Tooltips display information about data points on user interaction.

### Basic Tooltip

```tsx
import { useChartPressState } from 'victory-native';
import { Text } from 'react-native';
import Animated, { useAnimatedProps } from 'react-native-reanimated';

const AnimatedText = Animated.createAnimatedComponent(Text);

export function ChartWithTooltip() {
  const { state, isActive } = useChartPressState({ x: 0, y: { y: 0 } });

  const animatedText = useAnimatedProps(() => ({
    text: `${state.y.y.value.value.toFixed(2)}`,
  }));

  return (
    <>
      <CartesianChart
        data={DATA}
        xKey="x"
        yKeys={["y"]}
        chartPressState={state}
      >
        {({ points }) => (
          <Line points={points.y} color="#3b82f6" strokeWidth={2} />
        )}
      </CartesianChart>
      {isActive && (
        <AnimatedText
          style={{ fontSize: 16, fontWeight: 'bold' }}
          animatedProps={animatedText}
        />
      )}
    </>
  );
}
```

### Positioned Tooltip

```tsx
import { Circle, RoundedRect, Text as SkiaText } from '@shopify/react-native-skia';

<CartesianChart
  data={DATA}
  xKey="x"
  yKeys={["y"]}
  chartPressState={state}
>
  {({ points, chartBounds }) => (
    <>
      <Line points={points.y} color="#3b82f6" strokeWidth={2} />
      {isActive && (
        <>
          <Circle
            cx={state.x.position}
            cy={state.y.y.position}
            r={8}
            color="#ef4444"
          />
          <RoundedRect
            x={state.x.position.value - 40}
            y={state.y.y.position.value - 40}
            width={80}
            height={30}
            r={8}
            color="rgba(0,0,0,0.8)"
          />
          <SkiaText
            x={state.x.position.value}
            y={state.y.y.position.value - 25}
            text={state.y.y.value.value.toFixed(1)}
            color="white"
          />
        </>
      )}
    </>
  )}
</CartesianChart>
```

---

## Performance Optimization

Victory Native XL is designed for high performance, but following best practices ensures optimal results.

### Best Practices

1. **Handle Large Datasets Efficiently**
   ```tsx
   // Victory Native XL can handle 1000+ points smoothly
   const largeDataset = Array.from({ length: 1000 }, (_, i) => ({
     x: i,
     y: Math.sin(i * 0.1) * 100,
   }));
   ```

2. **Memoize Expensive Calculations**
   ```tsx
   const processedData = useMemo(() => {
     return rawData.map(item => ({
       x: item.timestamp,
       y: calculateComplexValue(item),
     }));
   }, [rawData]);
   ```

3. **Use Reanimated for Smooth Interactions**
   - All gesture tracking runs on the UI thread
   - No bridge crossing for 60+ FPS performance

4. **Optimize Re-renders**
   ```tsx
   const ChartComponent = memo(({ data }) => (
     <CartesianChart data={data} xKey="x" yKeys={["y"]}>
       {({ points }) => <Line points={points.y} color="#3b82f6" />}
     </CartesianChart>
   ));
   ```

### Streaming Data Example

For real-time data updates:

```tsx
const [streamData, setStreamData] = useState(initialData);

useEffect(() => {
  const interval = setInterval(() => {
    setStreamData(prev => {
      const newPoint = {
        x: prev.length,
        y: Math.random() * 100
      };
      return [...prev.slice(-100), newPoint]; // Keep last 100 points
    });
  }, 100);

  return () => clearInterval(interval);
}, []);

<CartesianChart data={streamData} xKey="x" yKeys={["y"]}>
  {({ points }) => <Line points={points.y} color="#3b82f6" strokeWidth={2} />}
</CartesianChart>
```

---

## Advanced Features

### Custom Skia Graphics

Victory Native XL allows you to render custom Skia components inside charts:

```tsx
import { Path, Skia } from '@shopify/react-native-skia';

<CartesianChart data={DATA} xKey="x" yKeys={["y"]}>
  {({ points, chartBounds }) => {
    const customPath = Skia.Path.Make();
    // Custom path drawing logic
    points.y.forEach((point, i) => {
      if (i === 0) customPath.moveTo(point.x, point.y);
      else customPath.lineTo(point.x, point.y);
    });

    return <Path path={customPath} color="#3b82f6" style="stroke" strokeWidth={2} />;
  }}
</CartesianChart>
```

### Accessing Chart Bounds

The `chartBounds` object provides the chart's drawable area:

```tsx
{({ points, chartBounds }) => {
  // chartBounds = { left, top, right, bottom }
  const width = chartBounds.right - chartBounds.left;
  const height = chartBounds.bottom - chartBounds.top;

  return (
    <RoundedRect
      x={chartBounds.left}
      y={chartBounds.top}
      width={width}
      height={height}
      r={8}
      color="rgba(0,0,0,0.05)"
    />
  );
}}
```

### Financial Charts (Candlestick Pattern)

```tsx
const CandlestickChart = ({ data }: { data: CandlestickData[] }) => (
  <CartesianChart data={data} xKey="time" yKeys={["open", "high", "low", "close"]}>
    {({ points, chartBounds }) => (
      <>
        {data.map((candle, i) => {
          const x = points.open[i].x;
          const open = points.open[i].y;
          const close = points.close[i].y;
          const high = points.high[i].y;
          const low = points.low[i].y;

          const isPositive = close > open;
          const color = isPositive ? '#10b981' : '#ef4444';

          return (
            <React.Fragment key={i}>
              {/* Wick */}
              <Line
                p1={{ x, y: high }}
                p2={{ x, y: low }}
                color={color}
                strokeWidth={1}
              />
              {/* Body */}
              <RoundedRect
                x={x - 4}
                y={Math.min(open, close)}
                width={8}
                height={Math.abs(close - open)}
                r={2}
                color={color}
              />
            </React.Fragment>
          );
        })}
      </>
    )}
  </CartesianChart>
);
```

### Real-World Example: Apple Stocks Clone

Victory Native XL can create complex, interactive financial charts with 1000+ data points in ~300 lines of code:

```tsx
const StockChart = () => {
  const { state, isActive } = useChartPressState({ x: 0, y: { price: 0 } });

  return (
    <View style={{ flex: 1 }}>
      <CartesianChart
        data={stockData}
        xKey="timestamp"
        yKeys={["price"]}
        chartPressState={state}
      >
        {({ points, chartBounds }) => (
          <>
            <Area points={points.price} y0={chartBounds.bottom}>
              <LinearGradient
                start={vec(0, 0)}
                end={vec(0, chartBounds.bottom)}
                colors={['rgba(59, 130, 246, 0.5)', 'rgba(59, 130, 246, 0.0)']}
              />
            </Area>
            <Line points={points.price} color="#3b82f6" strokeWidth={2} />
            {isActive && (
              <>
                <Circle
                  cx={state.x.position}
                  cy={state.y.price.position}
                  r={8}
                  color="white"
                  style="stroke"
                  strokeWidth={2}
                />
                <Line
                  p1={{ x: state.x.position.value, y: chartBounds.top }}
                  p2={{ x: state.x.position.value, y: chartBounds.bottom }}
                  color="rgba(0,0,0,0.1)"
                  strokeWidth={1}
                  strokeDasharray={[5, 5]}
                />
              </>
            )}
          </>
        )}
      </CartesianChart>
    </View>
  );
};
```

---

## Additional Resources

- **Official Documentation**: [Victory Native Docs](https://nearform.com/open-source/victory-native/docs/getting-started/)
- **GitHub Repository**: [FormidableLabs/victory-native-xl](https://github.com/FormidableLabs/victory-native-xl)
- **CartesianChart Guide**: [Cartesian Chart Documentation](https://nearform.com/open-source/victory-native/docs/cartesian/cartesian-chart/)
- **Bar Chart Guide**: [Basic Bar Chart](https://nearform.com/open-source/victory-native/docs/cartesian/guides/basic-bar-chart/)
- **Area Chart Guide**: [Area Chart Documentation](https://nearform.com/open-source/victory-native/docs/cartesian/area/)
- **Chart Gestures**: [Chart Gestures Documentation](https://nearform.com/open-source/victory-native/docs/cartesian/chart-gestures/)
- **Victory Native Blog**: [Victory Native Turns 40](https://nearform.com/digital-community/victory-native-turns-40/)

---

## Important Notes

### Limitations

- **No Pie Charts**: Victory Native XL focuses on Cartesian charts (Line, Bar, Area). For pie charts, consider using the older Victory library or implementing custom Skia graphics.
- **Cartesian Only**: The current API is optimized for x/y coordinate systems.

### Version Requirements

Victory Native XL requires:
- React Native Reanimated (3.x+)
- React Native Gesture Handler (2.x+)
- @shopify/react-native-skia (latest)

### Migration from Victory Native

Victory Native XL is a complete rewrite. If migrating from Victory Native (the older version), expect significant API changes focused on performance and Skia integration.

---

**Last Updated**: January 2026
