---
name: tanstack-query
description: Server state management with TanStack Query - data fetching, caching, mutations, and real-time updates for React Native/Expo
license: MIT
compatibility: "Requires: React Native/Expo, @tanstack/react-query 5.0+"
---

# TanStack Query

## Overview

TanStack Query (formerly React Query) is the missing data-fetching library for React and React Native applications. It manages fetching, caching, synchronizing, and updating server state with zero configuration, removing the need for global state management, reducers, or normalization systems. Works "amazingly well out-of-the-box" while remaining customizable as your application grows.

**Key capabilities**: Auto caching, background refetching, window/app focus refetching, polling, parallel queries, mutations, garbage collection, pagination, infinite scroll, prefetching, offline support, optimistic updates, and request deduplication.

## When to Use This Skill

- Fetching data from REST APIs or GraphQL endpoints
- Managing server state (distinct from client/UI state)
- Implementing real-time data synchronization
- Building offline-first applications
- Handling complex data fetching patterns (pagination, infinite scroll)
- Optimistic UI updates during mutations
- Automatic background data refreshing
- Request caching and deduplication
- Managing loading, error, and success states declaratively
- React Native apps with network status awareness

**Don't use TanStack Query for**:
- Pure client-side state (use Zustand, Jotai, or React Context)
- Simple one-time fetches (use plain fetch/axios)
- Static data that never changes

## Workflow

### Step 1: Install TanStack Query

```bash
# npm
npm install @tanstack/react-query

# Expo
npx expo install @tanstack/react-query

# Optional: ESLint plugin for best practices
npm install -D @tanstack/eslint-plugin-query
```

**React Native integration** (optional but recommended):
```bash
# For network status detection
npx expo install @react-native-community/netinfo

# Or if using Expo
npx expo install expo-network
```

### Step 2: Setup QueryClient and Provider

Wrap your app with `QueryClientProvider`:

```typescript
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';

// Create a client
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 1000 * 60 * 5, // 5 minutes
      gcTime: 1000 * 60 * 10,   // 10 minutes (formerly cacheTime)
      retry: 2,
      refetchOnWindowFocus: false, // Disable for React Native
    },
  },
});

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <YourApp />
    </QueryClientProvider>
  );
}
```

### Step 3: Use useQuery for Data Fetching

The `useQuery` hook manages fetching, caching, and synchronizing data:

```typescript
import { useQuery } from '@tanstack/react-query';

type User = {
  id: number;
  name: string;
  email: string;
};

function UserProfile({ userId }: { userId: number }) {
  const { data, isLoading, isError, error, isFetching, refetch } = useQuery({
    queryKey: ['user', userId], // Unique key for this query
    queryFn: async () => {
      const response = await fetch(`https://api.example.com/users/${userId}`);
      if (!response.ok) throw new Error('Failed to fetch user');
      return response.json() as Promise<User>;
    },
    staleTime: 1000 * 60, // Consider data fresh for 1 minute
    enabled: !!userId,    // Only run query if userId exists
  });

  if (isLoading) return <Text>Loading...</Text>;
  if (isError) return <Text>Error: {error.message}</Text>;

  return (
    <View>
      <Text>{data.name}</Text>
      <Text>{data.email}</Text>
      <Button title="Refresh" onPress={() => refetch()} />
      {isFetching && <ActivityIndicator />}
    </View>
  );
}
```

**Query states explained**:
- `isPending` - No data yet (initial load)
- `isLoading` - Shorthand for `isPending && isFetching`
- `isError` - Query failed
- `isSuccess` - Data available
- `isFetching` - Currently fetching (even during background updates)

### Step 4: Use useMutation for Updates

The `useMutation` hook manages create, update, and delete operations:

```typescript
import { useMutation, useQueryClient } from '@tanstack/react-query';

function CreateUserForm() {
  const queryClient = useQueryClient();

  const mutation = useMutation({
    mutationFn: async (newUser: { name: string; email: string }) => {
      const response = await fetch('https://api.example.com/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newUser),
      });
      if (!response.ok) throw new Error('Failed to create user');
      return response.json();
    },
    onSuccess: (data) => {
      // Invalidate and refetch users list
      queryClient.invalidateQueries({ queryKey: ['users'] });
      Alert.alert('Success', 'User created!');
    },
    onError: (error: Error) => {
      Alert.alert('Error', error.message);
    },
  });

  const handleSubmit = () => {
    mutation.mutate({ name: 'John', email: 'john@example.com' });
  };

  return (
    <View>
      <Button
        title="Create User"
        onPress={handleSubmit}
        disabled={mutation.isPending}
      />
      {mutation.isPending && <ActivityIndicator />}
    </View>
  );
}
```

### Step 5: Query Invalidation and Refetching

Invalidate queries to mark them as stale and trigger background refetches:

```typescript
import { useQueryClient } from '@tanstack/react-query';

function useUpdateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: updateUserApi,
    onSuccess: (data, variables) => {
      // Invalidate all queries starting with 'users'
      queryClient.invalidateQueries({ queryKey: ['users'] });

      // Invalidate specific user query
      queryClient.invalidateQueries({ queryKey: ['user', variables.userId] });

      // Invalidate exact match only
      queryClient.invalidateQueries({
        queryKey: ['users', 'list'],
        exact: true
      });

      // Custom predicate for granular control
      queryClient.invalidateQueries({
        predicate: (query) =>
          query.queryKey[0] === 'users' && query.queryKey[1]?.version >= 10
      });
    },
  });
}
```

### Step 6: Optimistic Updates

Update UI before server confirmation for instant feedback:

```typescript
function useLikePost() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (postId: number) => {
      await fetch(`/api/posts/${postId}/like`, { method: 'POST' });
    },
    // Optimistically update UI before mutation
    onMutate: async (postId) => {
      // Cancel outgoing refetches (so they don't overwrite optimistic update)
      await queryClient.cancelQueries({ queryKey: ['posts', postId] });

      // Snapshot previous value
      const previousPost = queryClient.getQueryData(['posts', postId]);

      // Optimistically update
      queryClient.setQueryData(['posts', postId], (old: any) => ({
        ...old,
        likes: old.likes + 1,
        isLiked: true,
      }));

      // Return context with snapshot
      return { previousPost };
    },
    // Rollback on error
    onError: (err, postId, context) => {
      queryClient.setQueryData(['posts', postId], context?.previousPost);
    },
    // Always refetch after error or success
    onSettled: (data, error, postId) => {
      queryClient.invalidateQueries({ queryKey: ['posts', postId] });
    },
  });
}
```

### Step 7: React Native Integration

**App focus refetching**:
```typescript
import { useEffect } from 'react';
import { AppState, AppStateStatus, Platform } from 'react-native';
import { focusManager } from '@tanstack/react-query';

function onAppStateChange(status: AppStateStatus) {
  if (Platform.OS !== 'web') {
    focusManager.setFocused(status === 'active');
  }
}

// In your App.tsx
useEffect(() => {
  const subscription = AppState.addEventListener('change', onAppStateChange);
  return () => subscription.remove();
}, []);
```

**Network status awareness**:
```typescript
import NetInfo from '@react-native-community/netinfo';
import { onlineManager } from '@tanstack/react-query';

// Setup online manager
onlineManager.setEventListener((setOnline) => {
  return NetInfo.addEventListener((state) => {
    setOnline(!!state.isConnected);
  });
});
```

**Screen-level refetch with React Navigation**:
```typescript
import { useFocusEffect } from '@react-navigation/native';
import { useCallback } from 'react';

function UserScreen() {
  const { data, refetch } = useQuery({
    queryKey: ['user'],
    queryFn: fetchUser,
  });

  // Refetch when screen comes into focus
  useFocusEffect(
    useCallback(() => {
      refetch();
    }, [refetch])
  );

  return <View>...</View>;
}
```

## Guidelines

**Do:**
- Use unique, descriptive query keys (arrays work best: `['users', userId]`)
- Leverage query key hierarchy for batch invalidation
- Set appropriate `staleTime` to reduce unnecessary refetches
- Use TypeScript for type-safe queries and mutations
- Handle loading, error, and success states explicitly
- Use optimistic updates for better UX
- Implement error boundaries for error handling
- Configure global defaults in QueryClient
- Use `queryOptions()` helper for reusable query configs
- Disable `refetchOnWindowFocus` for React Native
- Integrate with AppState and NetInfo for React Native

**Don't:**
- Don't use TanStack Query for client-side state (theme, form state, etc.)
- Don't forget to invalidate queries after mutations
- Don't ignore error states in UI
- Don't use dynamic/random query keys (breaks caching)
- Don't fetch data on every render (use proper query keys)
- Don't mix server state and client state in queries
- Don't forget to handle offline scenarios
- Don't skip the `enabled` option for conditional queries
- Don't use `refetchInterval` without `refetchIntervalInBackground`
- Don't manually manage loading states (use query states)

## Examples

### TypeScript Type Safety

```typescript
// Define error type globally
declare module '@tanstack/react-query' {
  interface Register {
    defaultError: { message: string; code: string };
  }
}

// Use queryOptions for reusable configs
import { queryOptions, useQuery } from '@tanstack/react-query';

type Todo = { id: number; title: string; completed: boolean };

const todoQueryOptions = (id: number) =>
  queryOptions({
    queryKey: ['todo', id],
    queryFn: async (): Promise<Todo> => {
      const response = await fetch(`/api/todos/${id}`);
      if (!response.ok) throw new Error('Failed to fetch todo');
      return response.json();
    },
  });

// Use in components
function TodoDetail({ id }: { id: number }) {
  const { data } = useQuery(todoQueryOptions(id));
  // data is typed as Todo | undefined

  return <Text>{data?.title}</Text>;
}

// Use for prefetching
const queryClient = useQueryClient();
queryClient.prefetchQuery(todoQueryOptions(5));
```

### Pagination

```typescript
import { useQuery } from '@tanstack/react-query';
import { useState } from 'react';

function PaginatedUsers() {
  const [page, setPage] = useState(1);

  const { data, isPending, isError, isPlaceholderData } = useQuery({
    queryKey: ['users', page],
    queryFn: async () => {
      const response = await fetch(`/api/users?page=${page}`);
      return response.json();
    },
    placeholderData: (previousData) => previousData, // Keep previous data while loading
  });

  return (
    <View>
      <FlatList data={data?.users} ... />
      <View style={{ flexDirection: 'row' }}>
        <Button
          title="Previous"
          onPress={() => setPage((old) => Math.max(old - 1, 1))}
          disabled={page === 1}
        />
        <Button
          title="Next"
          onPress={() => setPage((old) => old + 1)}
          disabled={isPlaceholderData || !data?.hasMore}
        />
      </View>
    </View>
  );
}
```

### Infinite Scroll

```typescript
import { useInfiniteQuery } from '@tanstack/react-query';

type PostsPage = { posts: Post[]; nextCursor?: number };

function InfinitePostsFeed() {
  const {
    data,
    fetchNextPage,
    hasNextPage,
    isFetchingNextPage,
  } = useInfiniteQuery({
    queryKey: ['posts'],
    queryFn: async ({ pageParam }) => {
      const response = await fetch(`/api/posts?cursor=${pageParam}`);
      return response.json() as Promise<PostsPage>;
    },
    initialPageParam: 0,
    getNextPageParam: (lastPage) => lastPage.nextCursor,
  });

  const allPosts = data?.pages.flatMap((page) => page.posts) ?? [];

  return (
    <FlatList
      data={allPosts}
      renderItem={({ item }) => <PostCard post={item} />}
      onEndReached={() => hasNextPage && fetchNextPage()}
      onEndReachedThreshold={0.5}
      ListFooterComponent={
        isFetchingNextPage ? <ActivityIndicator /> : null
      }
    />
  );
}
```

### Dependent Queries

```typescript
function UserPosts({ userId }: { userId: number }) {
  // First, fetch user
  const { data: user } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  });

  // Then fetch posts (only when user is available)
  const { data: posts } = useQuery({
    queryKey: ['posts', user?.id],
    queryFn: () => fetchUserPosts(user!.id),
    enabled: !!user, // Query won't run until user exists
  });

  return <FlatList data={posts} ... />;
}
```

### Parallel Queries

```typescript
function Dashboard() {
  // All queries run in parallel
  const users = useQuery({ queryKey: ['users'], queryFn: fetchUsers });
  const posts = useQuery({ queryKey: ['posts'], queryFn: fetchPosts });
  const stats = useQuery({ queryKey: ['stats'], queryFn: fetchStats });

  if (users.isPending || posts.isPending || stats.isPending) {
    return <LoadingSpinner />;
  }

  return (
    <View>
      <UserList data={users.data} />
      <PostList data={posts.data} />
      <StatsCard data={stats.data} />
    </View>
  );
}

// Or use useQueries for dynamic parallel queries
import { useQueries } from '@tanstack/react-query';

function MultipleUsers({ userIds }: { userIds: number[] }) {
  const userQueries = useQueries({
    queries: userIds.map((id) => ({
      queryKey: ['user', id],
      queryFn: () => fetchUser(id),
    })),
  });

  const isLoading = userQueries.some((q) => q.isPending);
  const users = userQueries.map((q) => q.data).filter(Boolean);

  return <UserList users={users} />;
}
```

### Prefetching

```typescript
import { useQueryClient } from '@tanstack/react-query';

function PostsList() {
  const queryClient = useQueryClient();
  const { data: posts } = useQuery({
    queryKey: ['posts'],
    queryFn: fetchPosts,
  });

  const handleHover = (postId: number) => {
    // Prefetch post details on hover/press
    queryClient.prefetchQuery({
      queryKey: ['post', postId],
      queryFn: () => fetchPost(postId),
      staleTime: 1000 * 60, // Cache for 1 minute
    });
  };

  return (
    <FlatList
      data={posts}
      renderItem={({ item }) => (
        <TouchableOpacity onPressIn={() => handleHover(item.id)}>
          <PostPreview post={item} />
        </TouchableOpacity>
      )}
    />
  );
}
```

### Mutation with Multiple Invalidations

```typescript
function useDeletePost() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (postId: number) => {
      await fetch(`/api/posts/${postId}`, { method: 'DELETE' });
    },
    onSuccess: (data, postId) => {
      // Remove from cache immediately
      queryClient.removeQueries({ queryKey: ['post', postId] });

      // Invalidate related queries
      queryClient.invalidateQueries({ queryKey: ['posts'] });
      queryClient.invalidateQueries({ queryKey: ['user-posts'] });
      queryClient.invalidateQueries({ queryKey: ['feed'] });
    },
  });
}
```

### Error Handling

```typescript
import { useQuery, QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ErrorBoundary } from 'react-error-boundary';

// Global error handling
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      throwOnError: true, // Errors propagate to Error Boundaries
      retry: (failureCount, error) => {
        // Don't retry on 404s
        if (error instanceof Response && error.status === 404) {
          return false;
        }
        return failureCount < 3;
      },
    },
  },
});

// Per-query error handling
function UserProfile() {
  const { data, error, isError } = useQuery({
    queryKey: ['user'],
    queryFn: fetchUser,
    throwOnError: false, // Handle errors locally
  });

  if (isError) {
    return <ErrorView message={error.message} />;
  }

  return <ProfileCard user={data} />;
}

// With Error Boundary
export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <ErrorBoundary FallbackComponent={ErrorFallback}>
        <YourApp />
      </ErrorBoundary>
    </QueryClientProvider>
  );
}
```

### Persisting Cache (Offline Support)

```bash
npm install @tanstack/react-query-persist-client
npm install @tanstack/query-async-storage-persister
npm install @react-native-async-storage/async-storage
```

```typescript
import AsyncStorage from '@react-native-async-storage/async-storage';
import { QueryClient } from '@tanstack/react-query';
import { PersistQueryClientProvider } from '@tanstack/react-query-persist-client';
import { createAsyncStoragePersister } from '@tanstack/query-async-storage-persister';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      gcTime: 1000 * 60 * 60 * 24, // 24 hours
    },
  },
});

const persister = createAsyncStoragePersister({
  storage: AsyncStorage,
  key: 'REACT_QUERY_CACHE',
});

export default function App() {
  return (
    <PersistQueryClientProvider
      client={queryClient}
      persistOptions={{ persister }}
    >
      <YourApp />
    </PersistQueryClientProvider>
  );
}
```

## Resources

- [TanStack Query Docs](https://tanstack.com/query/latest)
- [React Query Course](https://ui.dev/c/react-query) - Official course
- [React Native Docs](https://tanstack.com/query/latest/docs/framework/react/react-native)
- [TypeScript Guide](https://tanstack.com/query/latest/docs/framework/react/typescript)
- [ESLint Plugin](https://tanstack.com/query/latest/docs/eslint/eslint-plugin-query)
- [DevTools](https://tanstack.com/query/latest/docs/framework/react/devtools)
- [Examples](https://tanstack.com/query/latest/docs/framework/react/examples)

## Tools & Commands

- `npm install @tanstack/react-query` - Install TanStack Query
- `npm install -D @tanstack/eslint-plugin-query` - ESLint plugin
- `npm install @tanstack/react-query-devtools` - DevTools for debugging
- `npm install @tanstack/react-query-persist-client` - Cache persistence
- `queryClient.invalidateQueries()` - Invalidate and refetch queries
- `queryClient.prefetchQuery()` - Prefetch data
- `queryClient.setQueryData()` - Manually update cache
- `queryClient.getQueryData()` - Read from cache
- `queryClient.removeQueries()` - Remove queries from cache

## Troubleshooting

### Queries not refetching

**Problem**: Data doesn't update even after invalidation

**Solution**:
1. Check if query is mounted/active (only active queries refetch)
2. Verify `staleTime` isn't too high
3. Ensure `enabled` option isn't false
4. Check network status (React Native)

```typescript
// Debug query state
const { dataUpdatedAt, isStale, isActive } = useQuery({...});
console.log({ dataUpdatedAt, isStale, isActive });
```

### TypeScript errors with generics

**Problem**: Type inference not working correctly

**Solution**:
```typescript
// Use queryOptions helper
const userOptions = queryOptions({
  queryKey: ['user', id],
  queryFn: async (): Promise<User> => fetchUser(id),
});

const { data } = useQuery(userOptions);
// data is typed as User | undefined
```

### Mutations not invalidating queries

**Problem**: UI doesn't update after mutation

**Solution**:
```typescript
// Ensure query keys match
useMutation({
  mutationFn: updateUser,
  onSuccess: () => {
    // This invalidates ['users', 1] and ['users', 2, 'posts']
    queryClient.invalidateQueries({ queryKey: ['users'] });

    // For exact match only
    queryClient.invalidateQueries({ queryKey: ['users'], exact: true });
  },
});
```

### App focus not working in React Native

**Problem**: Queries don't refetch when app comes to foreground

**Solution**:
```typescript
// Setup focus manager
import { AppState } from 'react-native';
import { focusManager } from '@tanstack/react-query';

useEffect(() => {
  const subscription = AppState.addEventListener('change', (status) => {
    focusManager.setFocused(status === 'active');
  });

  return () => subscription.remove();
}, []);
```

### Network status not detected

**Problem**: Queries don't refetch when network returns

**Solution**:
```bash
npx expo install @react-native-community/netinfo
```

```typescript
import NetInfo from '@react-native-community/netinfo';
import { onlineManager } from '@tanstack/react-query';

onlineManager.setEventListener((setOnline) => {
  return NetInfo.addEventListener((state) => {
    setOnline(!!state.isConnected);
  });
});
```

### Stale data showing

**Problem**: Old data visible during refetch

**Solution**:
```typescript
const { data, isRefetching } = useQuery({
  queryKey: ['users'],
  queryFn: fetchUsers,
  staleTime: 1000 * 30, // Data fresh for 30 seconds
});

// Show loading indicator during background refetch
{isRefetching && <RefreshIndicator />}
```

### Memory leaks

**Problem**: Queries continue running after unmount

**Solution**:
```typescript
// Queries automatically cleanup on unmount
// But you can adjust garbage collection time
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      gcTime: 1000 * 60 * 5, // Remove from cache after 5 minutes of inactivity
    },
  },
});
```

---

## Notes

- TanStack Query v5 renamed `cacheTime` to `gcTime` (garbage collection time)
- Works with React 18+ and React Native out of the box
- Zero dependencies despite extensive features
- Query keys should be serializable (arrays work best)
- Queries run in parallel by default
- Mutations run sequentially unless using `mutationScope`
- DevTools available for web (Flipper/Reactotron for React Native)
- Supports SSR, RSC, and streaming in Next.js
- ESLint plugin catches common mistakes
- Optimistic updates require manual rollback on error
- Network status and app focus must be configured for React Native
- Query functions must return a Promise or throw an error
- Type inference works automatically with proper query function types
- Lock package version to specific patch for TypeScript stability
