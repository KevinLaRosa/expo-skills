---
name: zustand-state
description: Lightweight state management with Zustand - simple stores, React hooks, middleware, and TypeScript support
license: MIT
compatibility: "Requires: React Native/Expo, zustand 4.0+"
---

# Zustand State Management

## Overview

Implement lightweight, scalable state management in React Native with Zustand - a small, fast, hook-based state management solution with minimal boilerplate that handles React concurrency and zombie child issues automatically.

## When to Use This Skill

- Need simpler alternative to Redux or Context API
- Managing global app state
- Sharing state across components without prop drilling
- Need persistent state across app restarts
- Want DevTools integration for debugging
- Need async actions and middleware
- Building scalable React Native apps

**When you see:**
- "Manage global state"
- "Alternative to Redux"
- "Share state between screens"
- "Persist state"
- "State management library"

**Prerequisites**: React Native/Expo, zustand 4.0+.

## Workflow

### Step 1: Install Zustand

```bash
npm install zustand

# For Expo
npx expo install zustand

# Optional: Install middleware dependencies
npm install zustand immer
```

No providers, reducers, or boilerplate required.

### Step 2: Create Basic Store

```typescript
import { create } from 'zustand';

interface BearStore {
  bears: number;
  increasePopulation: () => void;
  removeAllBears: () => void;
}

export const useBearStore = create<BearStore>((set) => ({
  bears: 0,
  increasePopulation: () => set((state) => ({ bears: state.bears + 1 })),
  removeAllBears: () => set({ bears: 0 }),
}));
```

**Key points:**
- `create` returns a hook
- `set` updates state immutably
- No need for actions/reducers separation

### Step 3: Use Store in Components

```typescript
import { useBearStore } from './stores/bearStore';

function BearCounter() {
  // Subscribe to specific slice
  const bears = useBearStore((state) => state.bears);

  return <Text>{bears} bears around here...</Text>;
}

function Controls() {
  // Get actions only (won't re-render on state change)
  const increasePopulation = useBearStore((state) => state.increasePopulation);
  const removeAllBears = useBearStore((state) => state.removeAllBears);

  return (
    <View>
      <Button title="Add Bear" onPress={increasePopulation} />
      <Button title="Remove All" onPress={removeAllBears} />
    </View>
  );
}

// Or get entire state (re-renders on any change)
function BearInfo() {
  const { bears, increasePopulation } = useBearStore();

  return (
    <View>
      <Text>Bears: {bears}</Text>
      <Button title="Add" onPress={increasePopulation} />
    </View>
  );
}
```

### Step 4: Implement Async Actions

```typescript
import { create } from 'zustand';

interface UserStore {
  users: User[];
  isLoading: boolean;
  error: string | null;
  fetchUsers: () => Promise<void>;
}

export const useUserStore = create<UserStore>((set, get) => ({
  users: [],
  isLoading: false,
  error: null,

  fetchUsers: async () => {
    set({ isLoading: true, error: null });

    try {
      const response = await fetch('https://api.example.com/users');
      const users = await response.json();

      set({ users, isLoading: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Unknown error',
        isLoading: false
      });
    }
  },
}));

// Usage in component
function UserList() {
  const { users, isLoading, error, fetchUsers } = useUserStore();

  useEffect(() => {
    fetchUsers();
  }, []);

  if (isLoading) return <ActivityIndicator />;
  if (error) return <Text>Error: {error}</Text>;

  return (
    <FlatList
      data={users}
      renderItem={({ item }) => <Text>{item.name}</Text>}
    />
  );
}
```

### Step 5: Add Persist Middleware

```typescript
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface SettingsStore {
  theme: 'light' | 'dark';
  notifications: boolean;
  setTheme: (theme: 'light' | 'dark') => void;
  toggleNotifications: () => void;
}

export const useSettingsStore = create<SettingsStore>()(
  persist(
    (set) => ({
      theme: 'light',
      notifications: true,
      setTheme: (theme) => set({ theme }),
      toggleNotifications: () => set((state) => ({
        notifications: !state.notifications
      })),
    }),
    {
      name: 'settings-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
);
```

**IMPORTANT**: Notice the extra `()` after `create<SettingsStore>()` when using middleware with TypeScript.

### Step 6: Use MMKV for High-Performance Persistence (Recommended)

For production apps, use MMKV instead of AsyncStorage for **30x faster performance** and synchronous operations.

**Install MMKV:**

```bash
npm install react-native-mmkv

# For Expo
npx expo install react-native-mmkv
```

**Create MMKV storage adapter:**

```typescript
// utils/mmkv-storage.ts
import { MMKV } from 'react-native-mmkv';
import { StateStorage } from 'zustand/middleware';

// Initialize MMKV instance
export const storage = new MMKV();

// Create Zustand storage adapter
export const mmkvStorage: StateStorage = {
  setItem: (name, value) => {
    return storage.set(name, value);
  },
  getItem: (name) => {
    const value = storage.getString(name);
    return value ?? null;
  },
  removeItem: (name) => {
    return storage.delete(name);
  },
};
```

**Use MMKV in persist middleware:**

```typescript
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { mmkvStorage } from './utils/mmkv-storage';

interface SettingsStore {
  theme: 'light' | 'dark';
  notifications: boolean;
  language: string;
  setTheme: (theme: 'light' | 'dark') => void;
  toggleNotifications: () => void;
  setLanguage: (language: string) => void;
}

export const useSettingsStore = create<SettingsStore>()(
  persist(
    (set) => ({
      theme: 'light',
      notifications: true,
      language: 'en',
      setTheme: (theme) => set({ theme }),
      toggleNotifications: () => set((state) => ({
        notifications: !state.notifications
      })),
      setLanguage: (language) => set({ language }),
    }),
    {
      name: 'settings-storage',
      storage: createJSONStorage(() => mmkvStorage), // Use MMKV instead of AsyncStorage
    }
  )
);
```

**Why MMKV over AsyncStorage:**
- ⚡ **30x faster** read/write operations
- 🔄 **Synchronous API** - no async/await needed
- 📦 **Smaller memory footprint**
- 🔐 **Built-in encryption support**
- 🚀 **Production-ready** - used by major apps (Discord, Instagram)

**Complete example with encryption:**

```typescript
import { MMKV } from 'react-native-mmkv';
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { StateStorage } from 'zustand/middleware';

// Create encrypted MMKV instance
const secureStorage = new MMKV({
  id: 'secure-app-storage',
  encryptionKey: 'your-encryption-key-here', // Use secure key generation in production
});

// MMKV storage adapter
const secureMMKVStorage: StateStorage = {
  setItem: (name, value) => {
    return secureStorage.set(name, value);
  },
  getItem: (name) => {
    const value = secureStorage.getString(name);
    return value ?? null;
  },
  removeItem: (name) => {
    return secureStorage.delete(name);
  },
};

// Auth store with encrypted persistence
interface AuthStore {
  user: User | null;
  token: string | null;
  refreshToken: string | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

export const useAuthStore = create<AuthStore>()(
  persist(
    (set) => ({
      user: null,
      token: null,
      refreshToken: null,

      login: async (email, password) => {
        const response = await fetch('https://api.example.com/login', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ email, password }),
        });

        const { user, token, refreshToken } = await response.json();
        set({ user, token, refreshToken });
      },

      logout: () => set({ user: null, token: null, refreshToken: null }),
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => secureMMKVStorage), // Encrypted storage
      partialize: (state) => ({
        user: state.user,
        token: state.token,
        refreshToken: state.refreshToken,
      }),
    }
  )
);
```

**Performance comparison:**

| Operation | AsyncStorage | MMKV | Speed Increase |
|-----------|--------------|------|----------------|
| Read      | ~14ms        | ~0.5ms | 28x faster |
| Write     | ~18ms        | ~0.6ms | 30x faster |
| Delete    | ~12ms        | ~0.4ms | 30x faster |

**See also:** `mmkv-storage` skill for complete MMKV documentation.

### Step 7: Integrate DevTools Middleware

```typescript
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';

interface TodoStore {
  todos: Todo[];
  addTodo: (text: string) => void;
  toggleTodo: (id: string) => void;
  removeTodo: (id: string) => void;
}

export const useTodoStore = create<TodoStore>()(
  devtools(
    (set) => ({
      todos: [],

      addTodo: (text) => set(
        (state) => ({
          todos: [...state.todos, { id: Date.now().toString(), text, completed: false }],
        }),
        false,
        'addTodo' // Action name in DevTools
      ),

      toggleTodo: (id) => set(
        (state) => ({
          todos: state.todos.map((todo) =>
            todo.id === id ? { ...todo, completed: !todo.completed } : todo
          ),
        }),
        false,
        'toggleTodo'
      ),

      removeTodo: (id) => set(
        (state) => ({
          todos: state.todos.filter((todo) => todo.id !== id),
        }),
        false,
        'removeTodo'
      ),
    }),
    { name: 'TodoStore' }
  )
);
```

**DevTools setup:**
```bash
# Install Redux DevTools Extension in your browser
# Works automatically in development mode
```

### Step 8: Use Immer Middleware for Nested Updates

```typescript
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

interface CartStore {
  items: { id: string; name: string; quantity: number }[];
  addItem: (item: { id: string; name: string }) => void;
  updateQuantity: (id: string, quantity: number) => void;
  removeItem: (id: string) => void;
}

export const useCartStore = create<CartStore>()(
  immer((set) => ({
    items: [],

    addItem: (item) => set((state) => {
      const existing = state.items.find((i) => i.id === item.id);
      if (existing) {
        existing.quantity += 1;
      } else {
        state.items.push({ ...item, quantity: 1 });
      }
    }),

    updateQuantity: (id, quantity) => set((state) => {
      const item = state.items.find((i) => i.id === id);
      if (item) {
        item.quantity = quantity;
      }
    }),

    removeItem: (id) => set((state) => {
      const index = state.items.findIndex((i) => i.id === id);
      if (index !== -1) {
        state.items.splice(index, 1);
      }
    }),
  }))
);
```

**Immer benefits:**
- Mutate state directly (Immer handles immutability)
- Cleaner code for nested updates
- No spread operators needed

### Step 9: Combine Multiple Middleware

```typescript
import { create } from 'zustand';
import { devtools, persist, createJSONStorage } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface AuthStore {
  user: User | null;
  token: string | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

export const useAuthStore = create<AuthStore>()(
  devtools(
    persist(
      immer((set) => ({
        user: null,
        token: null,

        login: async (email, password) => {
          const response = await fetch('https://api.example.com/login', {
            method: 'POST',
            body: JSON.stringify({ email, password }),
          });
          const { user, token } = await response.json();

          set((state) => {
            state.user = user;
            state.token = token;
          });
        },

        logout: () => set((state) => {
          state.user = null;
          state.token = null;
        }),
      })),
      {
        name: 'auth-storage',
        storage: createJSONStorage(() => AsyncStorage),
      }
    ),
    { name: 'AuthStore' }
  )
);
```

**Middleware order:** `devtools > persist > immer > store`

### Step 10: Access Store Outside React

```typescript
// In API utility or non-React code
import { useAuthStore } from './stores/authStore';

export async function fetchWithAuth(url: string) {
  const token = useAuthStore.getState().token;

  const response = await fetch(url, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response.json();
}

// Subscribe to changes
const unsubscribe = useAuthStore.subscribe(
  (state) => state.token,
  (token) => {
    console.log('Token changed:', token);
  }
);

// Manual state update
useAuthStore.setState({ token: 'new-token' });

// Cleanup
unsubscribe();
```

### Step 11: Create Slices for Large Stores

```typescript
import { create } from 'zustand';

// User slice
interface UserSlice {
  user: User | null;
  setUser: (user: User) => void;
}

const createUserSlice = (set): UserSlice => ({
  user: null,
  setUser: (user) => set({ user }),
});

// Settings slice
interface SettingsSlice {
  theme: 'light' | 'dark';
  language: string;
  setTheme: (theme: 'light' | 'dark') => void;
  setLanguage: (language: string) => void;
}

const createSettingsSlice = (set): SettingsSlice => ({
  theme: 'light',
  language: 'en',
  setTheme: (theme) => set({ theme }),
  setLanguage: (language) => set({ language }),
});

// Combine slices
type StoreState = UserSlice & SettingsSlice;

export const useAppStore = create<StoreState>()((...a) => ({
  ...createUserSlice(...a),
  ...createSettingsSlice(...a),
}));

// Usage
function Profile() {
  const user = useAppStore((state) => state.user);
  const theme = useAppStore((state) => state.theme);

  return (
    <View>
      <Text>User: {user?.name}</Text>
      <Text>Theme: {theme}</Text>
    </View>
  );
}
```

## Guidelines

**Do:**
- Use selective subscriptions to optimize re-renders
- Create separate stores for different domains
- Use TypeScript for type safety
- Combine middleware for advanced features
- Use `get()` parameter to access current state in actions
- Test stores independently (they're just functions)
- Use Immer for complex nested state updates
- Persist only necessary state data

**Don't:**
- Don't use single store for entire app (split by domain)
- Don't mutate state without Immer middleware
- Don't subscribe to entire store if only need subset
- Don't forget extra `()` with TypeScript and middleware
- Don't store sensitive data in persisted state without encryption
- Don't use Context API when Zustand is simpler
- Don't nest stores (keep them independent)
- Don't forget to cleanup subscriptions outside React

## Examples

### Complete Auth Flow

```typescript
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import AsyncStorage from '@react-native-async-storage/async-storage';

interface AuthStore {
  user: User | null;
  token: string | null;
  isLoading: boolean;
  error: string | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  checkAuth: () => Promise<void>;
}

export const useAuthStore = create<AuthStore>()(
  persist(
    (set, get) => ({
      user: null,
      token: null,
      isLoading: false,
      error: null,

      login: async (email, password) => {
        set({ isLoading: true, error: null });

        try {
          const response = await fetch('https://api.example.com/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password }),
          });

          if (!response.ok) throw new Error('Login failed');

          const { user, token } = await response.json();
          set({ user, token, isLoading: false });
        } catch (error) {
          set({
            error: error instanceof Error ? error.message : 'Unknown error',
            isLoading: false
          });
        }
      },

      logout: () => set({ user: null, token: null }),

      checkAuth: async () => {
        const { token } = get();
        if (!token) return;

        try {
          const response = await fetch('https://api.example.com/me', {
            headers: { Authorization: `Bearer ${token}` },
          });

          if (!response.ok) {
            set({ user: null, token: null });
            return;
          }

          const user = await response.json();
          set({ user });
        } catch {
          set({ user: null, token: null });
        }
      },
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
      partialize: (state) => ({
        token: state.token,
        user: state.user
      }), // Only persist these fields
    }
  )
);

// Usage in App.tsx
function App() {
  const { checkAuth } = useAuthStore();

  useEffect(() => {
    checkAuth();
  }, []);

  return <Navigation />;
}
```

### Shopping Cart with Computed Values

```typescript
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

interface CartItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
}

interface CartStore {
  items: CartItem[];
  addItem: (item: Omit<CartItem, 'quantity'>) => void;
  removeItem: (id: string) => void;
  updateQuantity: (id: string, quantity: number) => void;
  clearCart: () => void;
  // Computed values
  getTotal: () => number;
  getItemCount: () => number;
}

export const useCartStore = create<CartStore>()(
  immer((set, get) => ({
    items: [],

    addItem: (item) => set((state) => {
      const existing = state.items.find((i) => i.id === item.id);
      if (existing) {
        existing.quantity += 1;
      } else {
        state.items.push({ ...item, quantity: 1 });
      }
    }),

    removeItem: (id) => set((state) => {
      const index = state.items.findIndex((i) => i.id === id);
      if (index !== -1) state.items.splice(index, 1);
    }),

    updateQuantity: (id, quantity) => set((state) => {
      const item = state.items.find((i) => i.id === id);
      if (item) {
        if (quantity <= 0) {
          const index = state.items.findIndex((i) => i.id === id);
          state.items.splice(index, 1);
        } else {
          item.quantity = quantity;
        }
      }
    }),

    clearCart: () => set({ items: [] }),

    getTotal: () => {
      const { items } = get();
      return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
    },

    getItemCount: () => {
      const { items } = get();
      return items.reduce((count, item) => count + item.quantity, 0);
    },
  }))
);

// Usage
function CartScreen() {
  const items = useCartStore((state) => state.items);
  const total = useCartStore((state) => state.getTotal());
  const itemCount = useCartStore((state) => state.getItemCount());
  const { updateQuantity, removeItem } = useCartStore();

  return (
    <View>
      <Text>Total Items: {itemCount}</Text>
      <Text>Total: ${total.toFixed(2)}</Text>

      {items.map((item) => (
        <View key={item.id}>
          <Text>{item.name} - ${item.price}</Text>
          <Text>Quantity: {item.quantity}</Text>
          <Button
            title="Remove"
            onPress={() => removeItem(item.id)}
          />
        </View>
      ))}
    </View>
  );
}
```

### API State Management Pattern

```typescript
import { create } from 'zustand';

interface ApiState<T> {
  data: T | null;
  isLoading: boolean;
  error: string | null;
}

interface ProductsStore extends ApiState<Product[]> {
  fetchProducts: () => Promise<void>;
  reset: () => void;
}

export const useProductsStore = create<ProductsStore>((set) => ({
  data: null,
  isLoading: false,
  error: null,

  fetchProducts: async () => {
    set({ isLoading: true, error: null });

    try {
      const response = await fetch('https://api.example.com/products');
      const data = await response.json();
      set({ data, isLoading: false });
    } catch (error) {
      set({
        error: error instanceof Error ? error.message : 'Failed to fetch',
        isLoading: false
      });
    }
  },

  reset: () => set({ data: null, isLoading: false, error: null }),
}));

// Generic API hook creator
function createApiStore<T>(url: string) {
  return create<ApiState<T> & { fetch: () => Promise<void> }>((set) => ({
    data: null,
    isLoading: false,
    error: null,

    fetch: async () => {
      set({ isLoading: true, error: null });
      try {
        const response = await fetch(url);
        const data = await response.json();
        set({ data, isLoading: false });
      } catch (error) {
        set({
          error: error instanceof Error ? error.message : 'Failed',
          isLoading: false
        });
      }
    },
  }));
}

// Usage
const useUsersStore = createApiStore<User[]>('https://api.example.com/users');
```

## Resources

- [Zustand GitHub Repository](https://github.com/pmndrs/zustand)
- [Official Documentation](https://zustand-demo.pmnd.rs/)
- [NPM Package](https://www.npmjs.com/package/zustand)
- [Comparison with Redux](https://github.com/pmndrs/zustand#comparison-with-redux)
- [MMKV Persist Middleware Docs](https://github.com/mrousavy/react-native-mmkv/blob/main/docs/WRAPPER_ZUSTAND_PERSIST_MIDDLEWARE.md)
- `mmkv-storage` skill - Complete MMKV integration guide

## Tools & Commands

- `npm install zustand` - Install Zustand
- `npm install immer` - Install Immer middleware
- `npx expo install zustand` - Install for Expo
- Redux DevTools Extension - Debug stores in browser

## Troubleshooting

### TypeScript errors with middleware

**Problem**: Type errors when using middleware with TypeScript

**Solution**:
```typescript
// Add extra () after create<Type>()
export const useStore = create<StoreType>()(
  middleware((set) => ({
    // store
  }))
);

// NOT this:
export const useStore = create<StoreType>(
  middleware((set) => ({
    // store
  }))
);
```

### Re-rendering issues

**Problem**: Component re-renders too often

**Solution**:
```typescript
// Bad: Subscribes to entire store
const { bears, fish } = useStore();

// Good: Selective subscription
const bears = useStore((state) => state.bears);

// Or use shallow comparison
import { shallow } from 'zustand/shallow';

const { bears, fish } = useStore(
  (state) => ({ bears: state.bears, fish: state.fish }),
  shallow
);
```

### Persist not working in React Native

**Problem**: State not persisting across app restarts

**Solution**:
```typescript
import AsyncStorage from '@react-native-async-storage/async-storage';
import { persist, createJSONStorage } from 'zustand/middleware';

// Install AsyncStorage first
// npm install @react-native-async-storage/async-storage

export const useStore = create()(
  persist(
    (set) => ({ /* store */ }),
    {
      name: 'my-storage',
      storage: createJSONStorage(() => AsyncStorage), // Required for RN
    }
  )
);
```

### Actions not updating state

**Problem**: State changes but component doesn't re-render

**Solution**:
```typescript
// Bad: Mutating state directly
addItem: (item) => {
  state.items.push(item); // Won't trigger re-render
}

// Good: Use set() to update
addItem: (item) => set((state) => ({
  items: [...state.items, item]
}))

// Or use Immer middleware
import { immer } from 'zustand/middleware/immer';

export const useStore = create()(
  immer((set) => ({
    items: [],
    addItem: (item) => set((state) => {
      state.items.push(item); // Immer handles immutability
    }),
  }))
);
```

### DevTools not showing actions

**Problem**: Redux DevTools doesn't show action names

**Solution**:
```typescript
// Add action names as third parameter
addTodo: (text) => set(
  (state) => ({ todos: [...state.todos, text] }),
  false, // Don't replace state
  'addTodo' // Action name in DevTools
)
```

---

## Notes

- No providers or context wrappers needed
- ~2KB bundle size (minified + gzipped)
- Works with React, React Native, and vanilla JS
- Handles React 18 concurrent mode automatically
- Solves zombie child problem by design
- Can be used outside React components
- Middleware is composable and chainable
- State updates are batched automatically
- Full TypeScript support with inference
- Used by thousands of production apps
- Created by Poimandres (same team as Three.js, React Three Fiber)
