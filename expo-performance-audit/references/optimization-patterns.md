# React Native Optimization Patterns

This guide covers proven optimization patterns for React Native and Expo applications, based on real-world performance workshop best practices.

## React Performance Patterns

### React.memo - Preventing Unnecessary Re-renders

`React.memo` creates a memoized component that only re-renders when its props change.

#### When to Use
- Component receives same props frequently
- Component is expensive to render
- Parent re-renders often but child props rarely change

#### Basic Usage

```javascript
// Without memo - re-renders on every parent render
function UserCard({ user, onPress }) {
  console.log('Rendering UserCard');
  return (
    <Pressable onPress={onPress}>
      <Text>{user.name}</Text>
      <Text>{user.email}</Text>
    </Pressable>
  );
}

// With memo - only re-renders when props change
const UserCard = React.memo(({ user, onPress }) => {
  console.log('Rendering UserCard');
  return (
    <Pressable onPress={onPress}>
      <Text>{user.name}</Text>
      <Text>{user.email}</Text>
    </Pressable>
  );
});
```

#### Custom Comparison Function

```javascript
const UserCard = React.memo(
  ({ user, onPress }) => (
    <Pressable onPress={onPress}>
      <Text>{user.name}</Text>
    </Pressable>
  ),
  (prevProps, nextProps) => {
    // Return true if props are equal (skip render)
    // Return false if props are different (re-render)
    return prevProps.user.id === nextProps.user.id &&
           prevProps.user.name === nextProps.user.name;
  }
);
```

#### Common Pitfalls

```javascript
// BAD: Inline objects/arrays break memoization
<UserCard
  user={user}
  style={{ margin: 10 }} // New object every render!
  tags={['admin', 'verified']} // New array every render!
/>

// GOOD: Stable references
const cardStyle = { margin: 10 };
const userTags = ['admin', 'verified'];

<UserCard
  user={user}
  style={cardStyle}
  tags={userTags}
/>

// BEST: Use StyleSheet
const styles = StyleSheet.create({
  card: { margin: 10 }
});

<UserCard user={user} style={styles.card} />
```

### useMemo - Memoizing Expensive Calculations

`useMemo` caches the result of expensive computations between renders.

#### When to Use
- Expensive calculations (sorting, filtering, transforming data)
- Creating objects/arrays used as props
- Computing derived state

#### Basic Usage

```javascript
function UserList({ users, searchQuery }) {
  // Without useMemo - filters on every render
  const filteredUsers = users.filter(user =>
    user.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  // With useMemo - only filters when users or searchQuery changes
  const filteredUsers = useMemo(() => {
    return users.filter(user =>
      user.name.toLowerCase().includes(searchQuery.toLowerCase())
    );
  }, [users, searchQuery]);

  return <FlashList data={filteredUsers} />;
}
```

#### Complex Transformations

```javascript
function Dashboard({ transactions }) {
  const stats = useMemo(() => {
    // Expensive calculation
    const total = transactions.reduce((sum, t) => sum + t.amount, 0);
    const average = total / transactions.length;
    const byCategory = transactions.reduce((acc, t) => {
      acc[t.category] = (acc[t.category] || 0) + t.amount;
      return acc;
    }, {});

    return { total, average, byCategory };
  }, [transactions]);

  return (
    <View>
      <Text>Total: ${stats.total}</Text>
      <Text>Average: ${stats.average}</Text>
    </View>
  );
}
```

#### Creating Stable References

```javascript
function Parent() {
  const [count, setCount] = useState(0);

  // BAD: New object every render
  const config = { theme: 'dark', size: 'large' };

  // GOOD: Stable reference
  const config = useMemo(() =>
    ({ theme: 'dark', size: 'large' }),
    []
  );

  return <Child config={config} />;
}
```

### useCallback - Memoizing Function References

`useCallback` returns a memoized callback function with a stable reference.

#### When to Use
- Passing callbacks to memoized child components
- Callbacks used as dependencies in useEffect
- Event handlers passed to optimized lists

#### Basic Usage

```javascript
function Parent() {
  const [items, setItems] = useState([]);

  // Without useCallback - new function every render
  const handlePress = (id) => {
    console.log('Pressed:', id);
  };

  // With useCallback - stable function reference
  const handlePress = useCallback((id) => {
    console.log('Pressed:', id);
  }, []); // Dependencies

  return (
    <FlashList
      data={items}
      renderItem={({ item }) => (
        <ItemCard item={item} onPress={handlePress} />
      )}
    />
  );
}
```

#### With Dependencies

```javascript
function TodoList({ onUpdate }) {
  const [filter, setFilter] = useState('all');

  const handleToggle = useCallback((id) => {
    // Uses filter and onUpdate
    const todo = todos.find(t => t.id === id);
    if (shouldShowTodo(todo, filter)) {
      onUpdate(id);
    }
  }, [filter, onUpdate]); // Re-create when these change

  return <List onToggle={handleToggle} />;
}
```

#### Complete Example

```javascript
const MemoizedListItem = React.memo(({ item, onPress, onDelete }) => {
  return (
    <View>
      <Pressable onPress={() => onPress(item.id)}>
        <Text>{item.title}</Text>
      </Pressable>
      <Button onPress={() => onDelete(item.id)} title="Delete" />
    </View>
  );
});

function TodoApp() {
  const [todos, setTodos] = useState([]);

  const handlePress = useCallback((id) => {
    console.log('Pressed:', id);
  }, []);

  const handleDelete = useCallback((id) => {
    setTodos(prev => prev.filter(t => t.id !== id));
  }, []);

  return (
    <FlashList
      data={todos}
      renderItem={({ item }) => (
        <MemoizedListItem
          item={item}
          onPress={handlePress}
          onDelete={handleDelete}
        />
      )}
    />
  );
}
```

## List Optimization

### FlashList vs FlatList

FlashList is Shopify's high-performance list component that significantly outperforms FlatList.

#### Performance Comparison

| Feature | FlatList | FlashList |
|---------|----------|-----------|
| Blank cells during scroll | Common | Rare |
| JS thread blocking | High | Low |
| Memory usage | Higher | Lower |
| Initial render | Slower | Faster |

#### Migration from FlatList

```javascript
// Before: FlatList
import { FlatList } from 'react-native';

<FlatList
  data={items}
  renderItem={renderItem}
  keyExtractor={item => item.id}
/>

// After: FlashList
import { FlashList } from "@shopify/flash-list";

<FlashList
  data={items}
  renderItem={renderItem}
  estimatedItemSize={100} // Required!
/>
```

#### Key Props

```javascript
<FlashList
  data={items}
  renderItem={renderItem}

  // Required: Helps FlashList optimize rendering
  estimatedItemSize={100}

  // Optional optimizations
  drawDistance={500} // How far ahead to render
  estimatedListSize={{ height: 600, width: 400 }}

  // Use getItemType for heterogeneous lists
  getItemType={(item) => item.type}
/>
```

#### Heterogeneous Lists

```javascript
const data = [
  { type: 'header', title: 'Section 1' },
  { type: 'item', name: 'Item 1' },
  { type: 'item', name: 'Item 2' },
  { type: 'header', title: 'Section 2' },
];

<FlashList
  data={data}
  getItemType={(item) => item.type}
  renderItem={({ item }) => {
    if (item.type === 'header') {
      return <HeaderComponent title={item.title} />;
    }
    return <ItemComponent name={item.name} />;
  }}
  estimatedItemSize={60}
/>
```

#### Best Practices

```javascript
// 1. Memoize renderItem
const renderItem = useCallback(({ item }) => (
  <MemoizedItem item={item} />
), []);

// 2. Use estimatedItemSize
// Measure typical item height in your UI
<FlashList estimatedItemSize={85} />

// 3. Optimize item components
const MemoizedItem = React.memo(({ item }) => (
  <View style={styles.item}>
    <Text>{item.title}</Text>
  </View>
));

// 4. Provide stable keys
<FlashList
  data={items}
  keyExtractor={(item) => item.id.toString()}
/>
```

## Image Optimization

### Modern Image Formats

#### Using expo-image

```javascript
import { Image } from 'expo-image';

// Basic usage with caching
<Image
  source={{ uri: 'https://example.com/photo.jpg' }}
  style={{ width: 300, height: 200 }}
  contentFit="cover"
  cachePolicy="memory-disk" // Cache in memory and disk
/>
```

#### WebP Format

WebP provides 25-35% better compression than JPEG/PNG.

```javascript
// Use WebP sources
<Image
  source={{ uri: 'https://example.com/photo.webp' }}
  style={{ width: 300, height: 200 }}
/>

// Fallback for older platforms
<Image
  source={{
    uri: Platform.select({
      ios: 'photo.webp',
      android: 'photo.webp',
      default: 'photo.jpg', // Fallback
    })
  }}
/>
```

### Blurhash & Thumbhash Placeholders

Blurhash creates tiny placeholder images that provide smooth loading UX.

#### Using Blurhash

```javascript
import { Image } from 'expo-image';

// Generate blurhash on backend when uploading image
// Store alongside image URL in database

<Image
  source={{ uri: imageUrl }}
  placeholder={blurhash} // e.g., "LGF5]+Yk^6#M@-5c,1J5@[or[Q6."
  contentFit="cover"
  transition={1000} // Smooth transition
  style={styles.image}
/>
```

#### Generating Blurhash

```javascript
// On backend (Node.js)
const { encode } = require('blurhash');
const sharp = require('sharp');

async function generateBlurhash(imagePath) {
  const image = await sharp(imagePath)
    .raw()
    .ensureAlpha()
    .resize(32, 32, { fit: 'inside' })
    .toBuffer({ resolveWithObject: true });

  const blurhash = encode(
    new Uint8ClampedArray(image.data),
    image.info.width,
    image.info.height,
    4,
    4
  );

  return blurhash;
}
```

### Image Caching Strategies

```javascript
import { Image } from 'expo-image';

// Memory-only cache (fast, limited capacity)
<Image cachePolicy="memory" source={uri} />

// Disk cache (persistent, larger capacity)
<Image cachePolicy="disk" source={uri} />

// Memory + Disk (best performance)
<Image cachePolicy="memory-disk" source={uri} />

// No cache (always fetch fresh)
<Image cachePolicy="none" source={uri} />
```

#### Prefetching Images

```javascript
import { Image } from 'expo-image';

// Prefetch images before they're needed
useEffect(() => {
  const imagesToPrefetch = [
    'https://example.com/image1.jpg',
    'https://example.com/image2.jpg',
  ];

  Image.prefetch(imagesToPrefetch);
}, []);
```

### Responsive Images

```javascript
// Load appropriate size based on screen dimensions
import { useWindowDimensions } from 'react-native';

function ResponsiveImage({ imageId }) {
  const { width } = useWindowDimensions();

  const imageUrl = useMemo(() => {
    if (width < 400) return `${CDN}/${imageId}/small.webp`;
    if (width < 800) return `${CDN}/${imageId}/medium.webp`;
    return `${CDN}/${imageId}/large.webp`;
  }, [width, imageId]);

  return <Image source={{ uri: imageUrl }} />;
}
```

## Animation Performance

### Reanimated Worklets

Reanimated 2+ runs animations on the UI thread for 60 FPS performance.

#### Basic Animations

```javascript
import Animated, {
  useSharedValue,
  useAnimatedStyle,
  withSpring,
} from 'react-native-reanimated';

function AnimatedBox() {
  const offset = useSharedValue(0);

  const animatedStyles = useAnimatedStyle(() => ({
    transform: [{ translateX: offset.value }],
  }));

  const handlePress = () => {
    offset.value = withSpring(100);
  };

  return (
    <>
      <Animated.View style={[styles.box, animatedStyles]} />
      <Button onPress={handlePress} title="Animate" />
    </>
  );
}
```

#### Gesture Handling

```javascript
import { GestureDetector, Gesture } from 'react-native-gesture-handler';
import Animated, {
  useSharedValue,
  useAnimatedStyle,
} from 'react-native-reanimated';

function DraggableBox() {
  const translateX = useSharedValue(0);
  const translateY = useSharedValue(0);

  const pan = Gesture.Pan()
    .onChange((event) => {
      translateX.value += event.changeX;
      translateY.value += event.changeY;
    });

  const animatedStyles = useAnimatedStyle(() => ({
    transform: [
      { translateX: translateX.value },
      { translateY: translateY.value },
    ],
  }));

  return (
    <GestureDetector gesture={pan}>
      <Animated.View style={[styles.box, animatedStyles]} />
    </GestureDetector>
  );
}
```

#### Complex Worklets

```javascript
import { runOnUI } from 'react-native-reanimated';

// Worklet - runs on UI thread
function processData(data) {
  'worklet';
  return data.map(item => item * 2);
}

function MyComponent() {
  const handlePress = () => {
    // Run complex calculation on UI thread
    runOnUI(() => {
      'worklet';
      const result = processData([1, 2, 3, 4, 5]);
      console.log(result);
    })();
  };

  return <Button onPress={handlePress} />;
}
```

#### Performance Comparison

```javascript
// BAD: Animated API (runs on JS thread)
const fadeAnim = useRef(new Animated.Value(0)).current;

Animated.timing(fadeAnim, {
  toValue: 1,
  duration: 500,
  useNativeDriver: true, // Helps, but still limited
}).start();

// GOOD: Reanimated (runs on UI thread)
const opacity = useSharedValue(0);

opacity.value = withTiming(1, { duration: 500 });
```

## Code Splitting & Lazy Loading

### Screen-Level Code Splitting

```javascript
import React, { Suspense, lazy } from 'react';
import { ActivityIndicator } from 'react-native';

// Lazy load heavy screens
const ProfileScreen = lazy(() => import('./screens/ProfileScreen'));
const SettingsScreen = lazy(() => import('./screens/SettingsScreen'));
const AnalyticsScreen = lazy(() => import('./screens/AnalyticsScreen'));

function LoadingFallback() {
  return <ActivityIndicator size="large" />;
}

function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Profile">
          {() => (
            <Suspense fallback={<LoadingFallback />}>
              <ProfileScreen />
            </Suspense>
          )}
        </Stack.Screen>
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

### Component-Level Lazy Loading

```javascript
// Heavy components loaded on demand
const ChartComponent = lazy(() => import('./components/Chart'));
const MapComponent = lazy(() => import('./components/Map'));

function Dashboard() {
  const [showChart, setShowChart] = useState(false);

  return (
    <View>
      <Button onPress={() => setShowChart(true)} title="Show Chart" />

      {showChart && (
        <Suspense fallback={<LoadingSpinner />}>
          <ChartComponent data={data} />
        </Suspense>
      )}
    </View>
  );
}
```

### Library-Level Code Splitting

```javascript
// Defer loading heavy libraries
const loadMapLibrary = async () => {
  const { MapView } = await import('react-native-maps');
  return MapView;
};

function LocationScreen() {
  const [MapView, setMapView] = useState(null);

  useEffect(() => {
    loadMapLibrary().then(setMapView);
  }, []);

  if (!MapView) return <LoadingSpinner />;

  return <MapView />;
}
```

## Production Optimizations

### Metro Bundler Configuration

```javascript
// metro.config.js
module.exports = {
  transformer: {
    getTransformOptions: async () => ({
      transform: {
        experimentalImportSupport: false,
        inlineRequires: true, // Optimize imports
      },
    }),
    minifierConfig: {
      compress: {
        drop_console: true, // Remove console.log
      },
    },
  },
};
```

### Babel Configuration

```javascript
// babel.config.js
module.exports = function(api) {
  api.cache(true);

  return {
    presets: ['babel-preset-expo'],
    plugins: [
      // Remove console logs in production
      process.env.NODE_ENV === 'production' && [
        'transform-remove-console',
        { exclude: ['error', 'warn'] }
      ],

      // Optimize lodash imports
      'lodash',

      // Reanimated plugin (must be last)
      'react-native-reanimated/plugin',
    ].filter(Boolean),
  };
};
```

### App Configuration

```json
// app.json
{
  "expo": {
    "jsEngine": "hermes",
    "experiments": {
      "reactCompiler": true
    },
    "plugins": [
      [
        "expo-build-properties",
        {
          "android": {
            "enableProguardInReleaseBuilds": true,
            "enableShrinkResourcesInReleaseBuilds": true
          },
          "ios": {
            "deploymentTarget": "15.0"
          }
        }
      ]
    ]
  }
}
```

### Environment-Based Optimizations

```javascript
// utils/logger.js
export const logger = {
  log: __DEV__ ? console.log : () => {},
  warn: __DEV__ ? console.warn : () => {},
  error: console.error, // Always log errors
};

// Usage
import { logger } from './utils/logger';

logger.log('Debug info'); // Only in development
logger.error('Critical error'); // Always logged
```

## Summary

Key takeaways for React Native performance:

1. **Use React.memo** for components with stable props
2. **Use useMemo** for expensive calculations
3. **Use useCallback** for stable function references
4. **Prefer FlashList** over FlatList for all lists
5. **Use expo-image** with blurhash for better image handling
6. **Use Reanimated** for all animations
7. **Implement lazy loading** for heavy screens/components
8. **Configure production optimizations** in Metro and Babel
9. **Profile regularly** with Flashlight
10. **Test on real devices**, especially low-end ones
