---
name: victory-native-charts
description: High-performance charts with Victory Native XL - powered by Skia and Reanimated for smooth 60fps visualizations
license: MIT
compatibility: "Requires: React Native 0.70+, victory-native, @shopify/react-native-skia, react-native-reanimated 3+, react-native-gesture-handler 2+"
---

# Victory Native Charts

## Overview

Victory Native XL is a high-performance charting library for React Native that delivers 60+ FPS visualizations. Built on React Native Skia, Reanimated, and D3, it's a complete rewrite of Victory Native designed specifically for mobile UX with gesture support, smooth animations, and customizable components.

## When to Use This Skill

- Building data visualizations (line, bar, area, pie charts)
- Need 60+ FPS chart rendering without drops
- Creating interactive charts with pan/zoom/gestures
- Implementing real-time data visualizations
- Building dashboards with multiple chart types
- Need customizable chart styling and animations
- Replacing React Native SVG charts with better performance
- Creating mobile-first data experiences

## Workflow

### Step 1: Install Dependencies

```bash
# Install peer dependencies first
npx expo install react-native-reanimated react-native-gesture-handler @shopify/react-native-skia

# Install Victory Native XL
npx expo install victory-native

# Configure Reanimated in babel.config.js
module.exports = {
  presets: ['babel-preset-expo'],
  plugins: [
    'react-native-reanimated/plugin', // MUST be last
  ],
};
```

### Step 2: Create Basic Line Chart

```typescript
import { CartesianChart, Line } from 'victory-native';
import { useFont } from '@shopify/react-native-skia';

type DataPoint = {
  date: string;
  value: number;
};

function LineChart() {
  const font = useFont(require('./assets/fonts/Roboto-Regular.ttf'), 12);

  const data: DataPoint[] = [
    { date: '2024-01', value: 100 },
    { date: '2024-02', value: 150 },
    { date: '2024-03', value: 120 },
    { date: '2024-04', value: 180 },
  ];

  return (
    <CartesianChart
      data={data}
      xKey="date"
      yKeys={['value']}
      axisOptions={{
        font,
        tickCount: 5,
        lineColor: '#71717a',
        labelColor: '#71717a',
      }}
    >
      {({ points }) => (
        <Line
          points={points.value}
          color="#3b82f6"
          strokeWidth={3}
          animate={{ type: 'timing', duration: 300 }}
        />
      )}
    </CartesianChart>
  );
}
```

### Step 3: Create Bar Chart with Styling

```typescript
import { CartesianChart, Bar } from 'victory-native';
import { useFont } from '@shopify/react-native-skia';

type SalesData = {
  month: string;
  sales: number;
};

function BarChart() {
  const font = useFont(require('./assets/fonts/Roboto-Regular.ttf'), 12);

  const data: SalesData[] = [
    { month: 'Jan', sales: 4000 },
    { month: 'Feb', sales: 3000 },
    { month: 'Mar', sales: 5000 },
    { month: 'Apr', sales: 4500 },
  ];

  return (
    <CartesianChart
      data={data}
      xKey="month"
      yKeys={['sales']}
      padding={{ left: 10, right: 10, top: 10, bottom: 10 }}
      axisOptions={{ font }}
    >
      {({ points, chartBounds }) => (
        <Bar
          points={points.sales}
          chartBounds={chartBounds}
          color="#10b981"
          roundedCorners={{
            topLeft: 8,
            topRight: 8,
          }}
          innerPadding={0.3}
          animate={{ type: 'spring' }}
        />
      )}
    </CartesianChart>
  );
}
```

### Step 4: Create Pie/Donut Chart

```typescript
import { PolarChart, Pie } from 'victory-native';
import { useFont } from '@shopify/react-native-skia';

type CategoryData = {
  label: string;
  value: number;
  color: string;
};

function PieChart() {
  const font = useFont(require('./assets/fonts/Roboto-Regular.ttf'), 12);

  const data: CategoryData[] = [
    { label: 'Category A', value: 30, color: '#3b82f6' },
    { label: 'Category B', value: 25, color: '#10b981' },
    { label: 'Category C', value: 20, color: '#f59e0b' },
    { label: 'Category D', value: 25, color: '#ef4444' },
  ];

  return (
    <PolarChart
      data={data}
      labelKey="label"
      valueKey="value"
      colorKey="color"
    >
      <Pie.Chart innerRadius="50%">
        {({ slice }) => (
          <>
            <Pie.Slice />
            <Pie.Label
              font={font}
              color="white"
              radiusOffset={20}
            />
          </>
        )}
      </Pie.Chart>
    </PolarChart>
  );
}
```

### Step 5: Add Gestures and Interactions

```typescript
import { CartesianChart, Line, useChartPressState } from 'victory-native';
import { Circle } from '@shopify/react-native-skia';
import { SharedValue, useDerivedValue } from 'react-native-reanimated';

function InteractiveChart() {
  const { state, isActive } = useChartPressState({ x: 0, y: { value: 0 } });

  const data = [
    { x: 1, value: 100 },
    { x: 2, value: 150 },
    { x: 3, value: 120 },
  ];

  const activeValue = useDerivedValue(() => {
    return isActive ? state.y.value.value : null;
  });

  return (
    <>
      <CartesianChart
        data={data}
        xKey="x"
        yKeys={['value']}
        chartPressState={state}
      >
        {({ points }) => (
          <>
            <Line points={points.value} color="#3b82f6" strokeWidth={3} />
            {isActive && (
              <Circle
                cx={state.x.position}
                cy={state.y.value.position}
                r={8}
                color="#3b82f6"
                opacity={0.8}
              />
            )}
          </>
        )}
      </CartesianChart>
      {activeValue && (
        <Text>Selected: {activeValue.value}</Text>
      )}
    </>
  );
}
```

### Step 6: Implement Pan/Zoom

```typescript
import { CartesianChart, Line, useChartTransformState } from 'victory-native';
import { GestureDetector, Gesture } from 'react-native-gesture-handler';

function ZoomableChart() {
  const { state, panGesture, pinchGesture } = useChartTransformState();

  const data = Array.from({ length: 100 }, (_, i) => ({
    x: i,
    value: Math.sin(i / 10) * 100 + 100,
  }));

  const gesture = Gesture.Simultaneous(panGesture, pinchGesture);

  return (
    <GestureDetector gesture={gesture}>
      <CartesianChart
        data={data}
        xKey="x"
        yKeys={['value']}
        transformState={state}
      >
        {({ points }) => (
          <Line points={points.value} color="#3b82f6" strokeWidth={2} />
        )}
      </CartesianChart>
    </GestureDetector>
  );
}
```

### Step 7: Create Multi-Line Chart with Area Fill

```typescript
import { CartesianChart, Line, Area } from 'victory-native';
import { LinearGradient, vec } from '@shopify/react-native-skia';

type MultiSeriesData = {
  time: number;
  revenue: number;
  expenses: number;
};

function MultiLineChart() {
  const data: MultiSeriesData[] = [
    { time: 1, revenue: 100, expenses: 60 },
    { time: 2, revenue: 150, expenses: 80 },
    { time: 3, revenue: 120, expenses: 70 },
    { time: 4, revenue: 180, expenses: 90 },
  ];

  return (
    <CartesianChart
      data={data}
      xKey="time"
      yKeys={['revenue', 'expenses']}
    >
      {({ points, chartBounds }) => (
        <>
          {/* Revenue area with gradient */}
          <Area points={points.revenue} y0={chartBounds.bottom}>
            <LinearGradient
              start={vec(0, 0)}
              end={vec(0, chartBounds.bottom)}
              colors={['rgba(59, 130, 246, 0.5)', 'rgba(59, 130, 246, 0.0)']}
            />
          </Area>

          {/* Revenue line */}
          <Line
            points={points.revenue}
            color="#3b82f6"
            strokeWidth={3}
            animate={{ type: 'timing', duration: 300 }}
          />

          {/* Expenses line */}
          <Line
            points={points.expenses}
            color="#ef4444"
            strokeWidth={3}
            animate={{ type: 'timing', duration: 300 }}
          />
        </>
      )}
    </CartesianChart>
  );
}
```

### Step 8: Optimize Performance

```typescript
import { memo, useMemo } from 'react';
import { CartesianChart, Line } from 'victory-native';

// Memoize chart component
const Chart = memo(({ data }: { data: DataPoint[] }) => {
  // Memoize processed data
  const processedData = useMemo(() => {
    return data.map((item) => ({
      ...item,
      smoothedValue: calculateMovingAverage(item.value),
    }));
  }, [data]);

  return (
    <CartesianChart
      data={processedData}
      xKey="date"
      yKeys={['smoothedValue']}
    >
      {({ points }) => (
        <Line
          points={points.smoothedValue}
          color="#3b82f6"
          strokeWidth={3}
          // Disable animations for large datasets
          animate={processedData.length < 100 ? { type: 'timing' } : undefined}
        />
      )}
    </CartesianChart>
  );
});

function calculateMovingAverage(value: number): number {
  // Your smoothing logic here
  return value;
}
```

## Guidelines

**Do:**
- Use `useFont` from Skia for custom axis fonts
- Memoize chart components for large datasets
- Use `chartPressState` for interactive tooltips
- Leverage `transformState` for pan/zoom features
- Use `innerPadding` to control bar spacing
- Use `roundedCorners` for modern bar styles
- Combine with Skia gradients for visual effects
- Use `animate` prop for smooth transitions
- Type your data with TypeScript interfaces
- Use `domain` prop to control axis ranges
- Use `viewport` for preset zoom windows

**Don't:**
- Don't use with old Victory Native (SVG-based)
- Don't forget Reanimated babel plugin configuration
- Don't animate charts with 1000+ points (performance)
- Don't access React state directly in render functions
- Don't use console.log in chart render functions
- Don't mix Victory Native XL with React Native SVG charts
- Don't forget to load fonts before rendering
- Don't mutate data props directly
- Don't use heavy computations in render functions
- Don't skip `chartBounds` prop for Bar components

## Examples

### Real-Time Data Chart

```typescript
import { useEffect, useState } from 'react';
import { CartesianChart, Line } from 'victory-native';

function RealtimeChart() {
  const [data, setData] = useState<{ time: number; value: number }[]>([]);

  useEffect(() => {
    const interval = setInterval(() => {
      setData((prev) => {
        const newPoint = {
          time: Date.now(),
          value: Math.random() * 100,
        };
        // Keep last 50 points
        return [...prev.slice(-49), newPoint];
      });
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  return (
    <CartesianChart data={data} xKey="time" yKeys={['value']}>
      {({ points }) => (
        <Line
          points={points.value}
          color="#3b82f6"
          strokeWidth={2}
          connectMissingData
        />
      )}
    </CartesianChart>
  );
}
```

### Custom Tooltip with Active Indicator

```typescript
import { CartesianChart, Line, useChartPressState } from 'victory-native';
import { Circle, Line as SkiaLine } from '@shopify/react-native-skia';
import { Text, View, StyleSheet } from 'react-native';
import Animated, { useAnimatedStyle } from 'react-native-reanimated';

function TooltipChart() {
  const { state, isActive } = useChartPressState({ x: 0, y: { value: 0 } });

  const tooltipStyle = useAnimatedStyle(() => ({
    opacity: isActive ? 1 : 0,
    transform: [
      { translateX: state.x.position.value - 40 },
      { translateY: state.y.value.position.value - 50 },
    ],
  }));

  return (
    <>
      <CartesianChart
        data={data}
        xKey="x"
        yKeys={['value']}
        chartPressState={state}
      >
        {({ points, chartBounds }) => (
          <>
            <Line points={points.value} color="#3b82f6" strokeWidth={3} />
            {isActive && (
              <>
                {/* Vertical indicator line */}
                <SkiaLine
                  p1={{ x: state.x.position.value, y: chartBounds.top }}
                  p2={{ x: state.x.position.value, y: chartBounds.bottom }}
                  color="rgba(0,0,0,0.2)"
                  strokeWidth={1}
                />
                {/* Active point circle */}
                <Circle
                  cx={state.x.position.value}
                  cy={state.y.value.position.value}
                  r={8}
                  color="#3b82f6"
                />
                <Circle
                  cx={state.x.position.value}
                  cy={state.y.value.position.value}
                  r={4}
                  color="white"
                />
              </>
            )}
          </>
        )}
      </CartesianChart>

      {/* Animated tooltip */}
      <Animated.View style={[styles.tooltip, tooltipStyle]}>
        <Text style={styles.tooltipText}>
          Value: {state.y.value.value.value.toFixed(0)}
        </Text>
      </Animated.View>
    </>
  );
}

const styles = StyleSheet.create({
  tooltip: {
    position: 'absolute',
    backgroundColor: 'rgba(0,0,0,0.8)',
    padding: 8,
    borderRadius: 4,
  },
  tooltipText: {
    color: 'white',
    fontSize: 12,
  },
});
```

### Stacked Bar Chart

```typescript
import { CartesianChart, Bar } from 'victory-native';

type StackedData = {
  category: string;
  value1: number;
  value2: number;
  value3: number;
};

function StackedBarChart() {
  const data: StackedData[] = [
    { category: 'A', value1: 30, value2: 20, value3: 10 },
    { category: 'B', value1: 25, value2: 30, value3: 15 },
    { category: 'C', value1: 35, value2: 15, value3: 20 },
  ];

  return (
    <CartesianChart
      data={data}
      xKey="category"
      yKeys={['value1', 'value2', 'value3']}
    >
      {({ points, chartBounds }) => (
        <>
          <Bar
            points={points.value1}
            chartBounds={chartBounds}
            color="#3b82f6"
            innerPadding={0.2}
          />
          <Bar
            points={points.value2}
            chartBounds={chartBounds}
            color="#10b981"
            innerPadding={0.2}
          />
          <Bar
            points={points.value3}
            chartBounds={chartBounds}
            color="#f59e0b"
            innerPadding={0.2}
          />
        </>
      )}
    </CartesianChart>
  );
}
```

## Resources

- [Official Documentation](https://nearform.com/open-source/victory-native/docs/)
- [GitHub Repository](https://github.com/FormidableLabs/victory-native-xl)
- [CartesianChart API](https://nearform.com/open-source/victory-native/docs/cartesian/cartesian-chart/)
- [Line Component](https://nearform.com/open-source/victory-native/docs/cartesian/line/)
- [Bar Component](https://nearform.com/open-source/victory-native/docs/cartesian/bar/)
- [Pie Chart Guide](https://nearform.com/open-source/victory-native/docs/polar/pie/pie-charts/)
- [React Native Skia Docs](https://shopify.github.io/react-native-skia/)
- [Reanimated Docs](https://docs.swmansion.com/react-native-reanimated/)

## Tools & Commands

```bash
# Install all dependencies
npx expo install victory-native @shopify/react-native-skia react-native-reanimated react-native-gesture-handler

# Check for peer dependency issues
npm ls react-native-reanimated @shopify/react-native-skia

# Clear metro cache if charts don't render
npx expo start -c

# Test chart performance in production build
npx expo run:ios --configuration Release
npx expo run:android --variant release
```

## Troubleshooting

**Charts not rendering:**
- Ensure Reanimated plugin is LAST in babel.config.js
- Clear metro cache: `npx expo start -c`
- Verify fonts are loaded with `useFont`
- Check that data array is not empty

**Performance issues:**
- Reduce data points (< 500 recommended for smooth animations)
- Disable animations for large datasets
- Memoize chart components
- Use `connectMissingData={false}` to skip missing values
- Avoid heavy computations in render functions

**Gestures not working:**
- Wrap in `GestureDetector` for pan/zoom
- Ensure `react-native-gesture-handler` is installed
- Use `chartPressState` for press interactions
- Don't nest multiple `GestureDetector` components

**Type errors:**
- Define data types with TypeScript interfaces
- Ensure `xKey` and `yKeys` match data properties
- Import types from 'victory-native' for render props

**Fonts not displaying:**
- Load fonts with `useFont` hook before rendering
- Check font file path is correct
- Use `require()` for font imports in Expo
- Ensure font file is included in app bundle

## Notes

- Victory Native XL renders at 60+ FPS using Skia's native thread
- Complete rewrite from Victory Native (SVG-based)
- Built for mobile-first UX with gesture support
- Uses D3 for data transformations
- Requires Reanimated 3+ and Gesture Handler 2+
- Works with Expo Go and EAS Build
- TypeScript-first with 93.9% TypeScript codebase
- 1000+ GitHub stars, actively maintained by NearForm
