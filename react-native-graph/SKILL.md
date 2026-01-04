---
name: react-native-graph
description: High-performance line charts with react-native-graph - powered by Skia for smooth 120fps visualizations with pan gestures
license: MIT
compatibility: "Requires: React Native 0.74+, @shopify/react-native-skia, react-native-reanimated 4, react-native-gesture-handler 2+"
---

# React Native Graph

## Overview

Build high-performance line charts for React Native using react-native-graph, powered by Skia's 2D graphics engine. Delivers up to 120fps animations with smooth pan/scrub gestures, optimized for crypto and financial applications.

## When to Use This Skill

- Building line charts for crypto/financial data
- Need 120fps chart rendering for smooth animations
- Creating interactive charts with pan/scrub gestures
- Displaying price history or time-series data
- Building dashboards with real-time data updates
- Need better performance than SVG-based charts
- Creating mobile-first data visualizations
- Showing data with cubic bezier curve interpolation

**Key advantages over Victory Native:**
- Simpler API focused on line charts
- Up to 120fps (vs 60fps)
- Non-blocking animations
- Built by Margelo (performance-focused)

## Workflow

### Step 1: Install Dependencies

```bash
# Install peer dependencies first
npx expo install react-native-reanimated react-native-gesture-handler @shopify/react-native-skia

# Install react-native-graph
npm install react-native-graph

# Configure Reanimated in babel.config.js
module.exports = {
  presets: ['babel-preset-expo'],
  plugins: [
    'react-native-reanimated/plugin', // MUST be last
  ],
};
```

**IMPORTANT**: Rebuild after installation (hot reload won't work):

```bash
# iOS
npx expo run:ios

# Android
npx expo run:android
```

### Step 2: Create Basic Line Chart

```typescript
import { LineGraph } from 'react-native-graph';

interface DataPoint {
  value: number;
  date: Date;
}

export function PriceChart() {
  const data: DataPoint[] = [
    { value: 100, date: new Date('2024-01-01') },
    { value: 120, date: new Date('2024-01-02') },
    { value: 110, date: new Date('2024-01-03') },
    { value: 150, date: new Date('2024-01-04') },
    { value: 140, date: new Date('2024-01-05') },
  ];

  return (
    <LineGraph
      points={data}
      color="#4484B2"
      animated={true}
    />
  );
}
```

### Step 3: Add Pan Gesture Interaction

```typescript
import { LineGraph } from 'react-native-graph';
import { useState } from 'react';

export function InteractiveChart() {
  const [selectedValue, setSelectedValue] = useState<number | null>(null);

  const data: DataPoint[] = [
    { value: 100, date: new Date('2024-01-01') },
    { value: 120, date: new Date('2024-01-02') },
    { value: 150, date: new Date('2024-01-03') },
  ];

  return (
    <View>
      {selectedValue && (
        <Text className="text-2xl font-bold">
          ${selectedValue.toFixed(2)}
        </Text>
      )}

      <LineGraph
        points={data}
        color="#4484B2"
        animated={true}
        enablePanGesture={true}
        panGestureDelay={300}
        onGestureStart={() => console.log('User started scrubbing')}
        onPointSelected={(point) => setSelectedValue(point.value)}
        onGestureEnd={() => setSelectedValue(null)}
      />
    </View>
  );
}
```

### Step 4: Add Custom Selection Dot

```typescript
import { LineGraph, SelectionDotProps } from 'react-native-graph';

function CustomDot({ isActive }: SelectionDotProps) {
  return (
    <View
      style={{
        width: 12,
        height: 12,
        borderRadius: 6,
        backgroundColor: isActive ? '#4484B2' : 'transparent',
        borderWidth: 2,
        borderColor: '#4484B2',
      }}
    />
  );
}

export function StyledChart() {
  return (
    <LineGraph
      points={data}
      color="#4484B2"
      animated={true}
      enablePanGesture={true}
      SelectionDot={CustomDot}
    />
  );
}
```

### Step 5: Add Axis Labels

```typescript
import { LineGraph } from 'react-native-graph';

export function ChartWithLabels() {
  const data: DataPoint[] = [
    { value: 100, date: new Date('2024-01-01') },
    { value: 150, date: new Date('2024-01-05') },
  ];

  const maxValue = Math.max(...data.map(p => p.value));
  const minValue = Math.min(...data.map(p => p.value));

  return (
    <LineGraph
      points={data}
      color="#4484B2"
      animated={true}
      TopAxisLabel={() => (
        <Text className="text-sm text-gray-500">
          ${maxValue.toFixed(2)}
        </Text>
      )}
      BottomAxisLabel={() => (
        <Text className="text-sm text-gray-500">
          ${minValue.toFixed(2)}
        </Text>
      )}
    />
  );
}
```

### Step 6: Fixed Range for Consistent Scale

```typescript
import { LineGraph } from 'react-native-graph';

export function FixedRangeChart() {
  const data: DataPoint[] = [
    { value: 100, date: new Date('2024-01-01') },
    { value: 120, date: new Date('2024-01-02') },
  ];

  return (
    <LineGraph
      points={data}
      color="#4484B2"
      animated={true}
      Range={{
        x: {
          min: new Date('2024-01-01').getTime(),
          max: new Date('2024-01-07').getTime(),
        },
        y: {
          min: 0,
          max: 200,
        },
      }}
    />
  );
}
```

### Step 7: Lightweight Mode for Lists

```typescript
import { LineGraph } from 'react-native-graph';
import { FlashList } from '@shopify/flash-list';

interface CryptoToken {
  id: string;
  name: string;
  priceHistory: DataPoint[];
}

export function TokenList({ tokens }: { tokens: CryptoToken[] }) {
  return (
    <FlashList
      data={tokens}
      renderItem={({ item }) => (
        <View className="p-4 border-b border-gray-200">
          <Text className="font-bold">{item.name}</Text>

          {/* Lightweight renderer - no animations */}
          <LineGraph
            points={item.priceHistory}
            color="#4484B2"
            animated={false}  // ← Lightweight mode
            style={{ height: 50, width: 100 }}
          />
        </View>
      )}
      estimatedItemSize={100}
    />
  );
}
```

## Guidelines

**Do:**
- Use `animated={true}` for single charts with gestures
- Use `animated={false}` for multiple charts in lists (better performance)
- Set `panGestureDelay` to prevent accidental scrubbing
- Use `Range` for consistent scale across data updates
- Rebuild app after installing (no hot reload support)
- Use TypeScript for type-safe DataPoint interface

**Don't:**
- Don't use for bar charts, pie charts, or other chart types (line only)
- Don't enable pan gesture without animated={true}
- Don't forget to configure Reanimated plugin in babel.config.js
- Don't use heavy calculations in SelectionDot component
- Don't use TopAxisLabel/BottomAxisLabel without animated={true}
- Don't mix animated and non-animated charts in same screen (performance)

## Examples

### Crypto Price Chart

```typescript
import { LineGraph } from 'react-native-graph';
import { useQuery } from '@tanstack/react-query';

export function EthereumChart() {
  const { data: priceHistory } = useQuery({
    queryKey: ['ethereum-price'],
    queryFn: () => fetchEthereumPrices(),
  });

  const [selectedPoint, setSelectedPoint] = useState<DataPoint | null>(null);

  if (!priceHistory) return <ActivityIndicator />;

  const currentPrice = selectedPoint?.value ?? priceHistory[priceHistory.length - 1].value;

  return (
    <View className="p-4">
      <Text className="text-3xl font-bold text-gray-900">
        ${currentPrice.toFixed(2)}
      </Text>

      <LineGraph
        points={priceHistory}
        color="#627EEA"
        animated={true}
        enablePanGesture={true}
        panGestureDelay={200}
        onPointSelected={setSelectedPoint}
        onGestureEnd={() => setSelectedPoint(null)}
        SelectionDot={({ isActive }) => (
          <View
            style={{
              width: 10,
              height: 10,
              borderRadius: 5,
              backgroundColor: isActive ? '#627EEA' : 'transparent',
              borderWidth: 2,
              borderColor: '#627EEA',
            }}
          />
        )}
        style={{ height: 200, width: '100%' }}
      />
    </View>
  );
}
```

### Real-Time Data Updates

```typescript
import { LineGraph } from 'react-native-graph';
import { useEffect, useState } from 'react';

export function LiveChart() {
  const [data, setData] = useState<DataPoint[]>([]);

  useEffect(() => {
    const interval = setInterval(() => {
      setData(prev => [
        ...prev,
        {
          value: Math.random() * 100 + 50,
          date: new Date(),
        },
      ].slice(-50)); // Keep last 50 points
    }, 1000);

    return () => clearInterval(interval);
  }, []);

  return (
    <LineGraph
      points={data}
      color="#10B981"
      animated={true}
      style={{ height: 150 }}
    />
  );
}
```

### Multiple Token Comparison

```typescript
export function TokenComparison() {
  const tokens = [
    { id: 'btc', name: 'Bitcoin', color: '#F7931A', data: btcData },
    { id: 'eth', name: 'Ethereum', color: '#627EEA', data: ethData },
    { id: 'sol', name: 'Solana', color: '#14F195', data: solData },
  ];

  return (
    <ScrollView className="p-4">
      {tokens.map(token => (
        <View key={token.id} className="mb-6">
          <Text className="font-bold text-lg mb-2">{token.name}</Text>

          {/* Lightweight mode for multiple charts */}
          <LineGraph
            points={token.data}
            color={token.color}
            animated={false}
            style={{ height: 80 }}
          />
        </View>
      ))}
    </ScrollView>
  );
}
```

## Resources

- [GitHub Repository](https://github.com/margelo/react-native-graph)
- [Margelo Blog](https://margelo.io/)
- [React Native Skia](https://shopify.github.io/react-native-skia/)
- [Reanimated Docs](https://docs.swmansion.com/react-native-reanimated/)

## Tools & Commands

- `npm install react-native-graph` - Install library
- `npx expo install react-native-reanimated react-native-gesture-handler @shopify/react-native-skia` - Install dependencies
- `npx expo run:ios` - Rebuild for iOS
- `npx expo run:android` - Rebuild for Android

## Troubleshooting

### Graph not rendering

**Problem**: Chart shows blank screen

**Solution**:
```bash
# Ensure all peer dependencies installed
npx expo install react-native-reanimated react-native-gesture-handler @shopify/react-native-skia

# Verify babel.config.js includes Reanimated plugin
cat babel.config.js

# Rebuild (hot reload doesn't work)
npx expo run:ios --device
```

### Pan gesture not working

**Problem**: Cannot scrub through data

**Solution**:
```typescript
// Both animated AND enablePanGesture required
<LineGraph
  points={data}
  color="#4484B2"
  animated={true}          // ← Required
  enablePanGesture={true}  // ← Required
  onPointSelected={handleSelect}
/>
```

### Performance issues with multiple charts

**Problem**: App lags with many charts on screen

**Solution**:
```typescript
// Use animated={false} for list items
<FlashList
  data={tokens}
  renderItem={({ item }) => (
    <LineGraph
      points={item.data}
      color={item.color}
      animated={false}  // ← Lightweight renderer
    />
  )}
/>
```

### TopAxisLabel not showing

**Problem**: Custom axis labels not rendering

**Solution**:
```typescript
// TopAxisLabel/BottomAxisLabel require animated={true}
<LineGraph
  points={data}
  color="#4484B2"
  animated={true}  // ← Required for axis labels
  TopAxisLabel={() => <Text>Max</Text>}
/>
```

---

## Notes

- Built by **Margelo** (creators of react-native-mmkv, react-native-fast-image)
- Powers **Pink Panda Wallet** with thousands of token graphs
- Supports up to **120fps** animations (double Victory Native)
- **Non-blocking animations** - won't freeze navigation or scrolling
- **Line charts only** - not for bar, pie, or other chart types
- Uses **Skia** for native 2D rendering (same as Flutter)
- **Cubic bezier interpolation** for smooth curves between data points
- Best for **crypto, finance, and time-series data**
- Use `animated={false}` for displaying multiple charts in lists
- Combine with **TanStack Query** for real-time data fetching
