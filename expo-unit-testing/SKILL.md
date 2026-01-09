---
name: expo-unit-testing
description: Unit test React Native/Expo apps with Jest and React Native Testing Library using jest-expo preset for component testing, hooks, and mocking
license: MIT
compatibility: "Requires: Expo SDK 48+, Jest, @testing-library/react-native, Node.js 18+"
---

# Expo Unit Testing

## Overview

Write unit tests for Expo/React Native apps using Jest and React Native Testing Library with the jest-expo preset that automatically mocks Expo SDK modules.

## When to Use This Skill

- Setting up unit testing in a new Expo project
- Testing React Native components in isolation
- Testing custom hooks and business logic
- Testing utility functions and helpers
- Mocking Expo modules (Camera, Location, AsyncStorage, etc.)
- Testing navigation flows with React Navigation
- Measuring code coverage for CI/CD
- Fast feedback loop during development (runs in milliseconds)
- When you see error: "Cannot find module 'expo-modules-core'"
- Testing edge cases and error handling

## Workflow

### Step 1: Install Dependencies

```bash
npx expo install jest-expo jest @types/jest --dev
npx expo install @testing-library/react-native --dev
```

**What gets installed:**
- `jest` - Test runner
- `jest-expo` - Expo-specific Jest preset with native module mocks
- `@testing-library/react-native` - Component testing utilities
- `@types/jest` - TypeScript definitions

### Step 2: Configure Jest

**Add to package.json:**
```json
{
  "scripts": {
    "test": "jest --watchAll",
    "test:ci": "jest --ci --coverage --maxWorkers=2"
  },
  "jest": {
    "preset": "jest-expo",
    "transformIgnorePatterns": [
      "node_modules/(?!((jest-)?react-native|@react-native(-community)?)|expo(nent)?|@expo(nent)?/.*|@expo-google-fonts/.*|react-navigation|@react-navigation/.*|@unimodules/.*|unimodules|sentry-expo|native-base|react-native-svg)"
    ],
    "collectCoverageFrom": [
      "**/*.{ts,tsx,js,jsx}",
      "!**/coverage/**",
      "!**/node_modules/**",
      "!**/babel.config.js",
      "!**/expo-env.d.ts",
      "!**/.expo/**"
    ]
  }
}
```

**For pnpm users:**
```json
{
  "jest": {
    "preset": "jest-expo",
    "transformIgnorePatterns": [
      "node_modules/(?!(?:.pnpm/)?((jest-)?react-native|@react-native(-community)?|expo(nent)?|@expo(nent)?/.*|@expo-google-fonts/.*|react-navigation|@react-navigation/.*|@unimodules/.*|unimodules|sentry-expo|native-base|react-native-svg))"
    ]
  }
}
```

### Step 3: Create Test File Structure

```bash
# Option 1: __tests__ directory (recommended)
mkdir -p src/components/__tests__
touch src/components/__tests__/Button.test.tsx

# Option 2: Co-located with source
touch src/components/Button.test.tsx
```

**Naming conventions:**
- `*.test.ts` or `*.test.tsx` - Unit tests
- `*.spec.ts` or `*.spec.tsx` - Alternative convention
- Place in `__tests__/` folder or co-locate with source

### Step 4: Write Component Tests

**Basic component test:**
```tsx
import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react-native';
import { Button } from '../Button';

describe('Button', () => {
  it('renders correctly', () => {
    render(<Button title="Press me" onPress={() => {}} />);

    expect(screen.getByText('Press me')).toBeTruthy();
  });

  it('calls onPress when pressed', () => {
    const onPressMock = jest.fn();
    render(<Button title="Press me" onPress={onPressMock} />);

    fireEvent.press(screen.getByText('Press me'));

    expect(onPressMock).toHaveBeenCalledTimes(1);
  });

  it('is disabled when loading', () => {
    render(<Button title="Submit" onPress={() => {}} loading />);

    const button = screen.getByText('Submit');
    expect(button).toBeDisabled();
  });
});
```

### Step 5: Query Elements

**Query methods (prefer accessibility queries):**

```tsx
import { render, screen } from '@testing-library/react-native';

// ✅ By role (best for accessibility)
screen.getByRole('button', { name: 'Submit' });

// ✅ By label (accessibility)
screen.getByLabelText('Email address');

// ✅ By text content
screen.getByText('Welcome');
screen.getByText(/welcome/i); // Regex, case-insensitive

// ✅ By testID (fallback when no better option)
screen.getByTestId('submit-button');

// ⚠️ Async queries (wait for element)
await screen.findByText('Loaded');

// ⚠️ Query variants
screen.getByText('Text');      // Throws if not found
screen.queryByText('Text');    // Returns null if not found
screen.findByText('Text');     // Async, waits for element
```

### Step 6: Simulate User Events

**Fire events:**
```tsx
import { render, screen, fireEvent } from '@testing-library/react-native';

// Press button
fireEvent.press(screen.getByText('Submit'));

// Type in TextInput
const input = screen.getByPlaceholderText('Enter email');
fireEvent.changeText(input, 'test@example.com');

// Scroll
fireEvent.scroll(screen.getByTestId('scroll-view'), {
  nativeEvent: { contentOffset: { y: 200 } }
});

// Focus/Blur
fireEvent(input, 'focus');
fireEvent(input, 'blur');
```

**User Event (more realistic):**
```tsx
import { render, screen, userEvent } from '@testing-library/react-native';

const user = userEvent.setup();

// Press with realistic timing
await user.press(screen.getByText('Submit'));

// Type with realistic delays
await user.type(screen.getByPlaceholderText('Email'), 'test@example.com');
```

### Step 7: Test Custom Hooks

```tsx
import { renderHook, waitFor } from '@testing-library/react-native';
import { useCounter } from '../hooks/useCounter';

describe('useCounter', () => {
  it('increments counter', () => {
    const { result } = renderHook(() => useCounter());

    expect(result.current.count).toBe(0);

    result.current.increment();

    expect(result.current.count).toBe(1);
  });

  it('handles async increment', async () => {
    const { result } = renderHook(() => useCounter());

    result.current.incrementAsync();

    await waitFor(() => {
      expect(result.current.count).toBe(1);
    });
  });
});
```

### Step 8: Mock Expo Modules

**jest-expo automatically mocks most modules, but you can customize:**

```tsx
// Mock expo-router
jest.mock('expo-router', () => ({
  useRouter: () => ({
    push: jest.fn(),
    replace: jest.fn(),
    back: jest.fn(),
  }),
  useLocalSearchParams: () => ({ id: '123' }),
}));

// Mock expo-camera
jest.mock('expo-camera', () => ({
  Camera: 'Camera',
  CameraType: { back: 0, front: 1 },
  useCameraPermissions: () => [{ granted: true }, jest.fn()],
}));

// Mock expo-location
jest.mock('expo-location', () => ({
  requestForegroundPermissionsAsync: jest.fn().mockResolvedValue({
    status: 'granted',
  }),
  getCurrentPositionAsync: jest.fn().mockResolvedValue({
    coords: { latitude: 37.78, longitude: -122.4 },
  }),
}));

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage', () =>
  require('@react-native-async-storage/async-storage/jest/async-storage-mock')
);
```

### Step 9: Test Async Operations

```tsx
import { render, screen, waitFor } from '@testing-library/react-native';

describe('UserProfile', () => {
  it('loads user data', async () => {
    render(<UserProfile userId="123" />);

    // Wait for loading to finish
    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeTruthy();
    });
  });

  it('shows error on failure', async () => {
    // Mock API failure
    global.fetch = jest.fn().mockRejectedValue(new Error('Network error'));

    render(<UserProfile userId="123" />);

    await waitFor(() => {
      expect(screen.getByText(/error/i)).toBeTruthy();
    });
  });
});
```

### Step 10: Snapshot Testing

```tsx
import { render } from '@testing-library/react-native';

describe('Button', () => {
  it('matches snapshot', () => {
    const { toJSON } = render(<Button title="Submit" onPress={() => {}} />);

    expect(toJSON()).toMatchSnapshot();
  });
});
```

**Update snapshots:**
```bash
# Update all snapshots
npm test -- -u

# Update specific snapshot
npm test Button.test.tsx -- -u
```

### Step 11: Run Tests

```bash
# Watch mode (development)
npm test

# Run all tests once
npm test -- --watchAll=false

# Run specific test file
npm test Button.test.tsx

# Run with coverage
npm test -- --coverage

# CI mode
npm run test:ci
```

## Guidelines

**Do:**
- ✅ Use `jest-expo` preset (handles Expo module mocking automatically)
- ✅ Query by role/label first (accessibility), testID as fallback
- ✅ Test user behavior, not implementation details
- ✅ Use `screen` queries instead of destructuring `render()`
- ✅ Test error states and edge cases
- ✅ Mock navigation, API calls, and external dependencies
- ✅ Use `waitFor` for async operations
- ✅ Keep tests isolated (no shared state between tests)
- ✅ Use descriptive test names (it('shows error when API fails'))
- ✅ Aim for 70-80% code coverage on critical paths

**Don't:**
- ❌ Don't test implementation details (state variables, internal functions)
- ❌ Don't query by className or style (implementation detail)
- ❌ Don't use snapshot testing as primary validation (brittle)
- ❌ Don't forget to clean up after tests (jest-expo handles cleanup)
- ❌ Don't mock everything (test real logic when possible)
- ❌ Don't write tests that depend on execution order
- ❌ Don't use `getBy*` for elements that may not exist (use `queryBy*`)
- ❌ Don't forget to await async queries (`findBy*`, `waitFor`)

## Examples

### Example 1: Form Validation

```tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react-native';
import { LoginForm } from '../LoginForm';

describe('LoginForm', () => {
  it('validates email format', async () => {
    const onSubmit = jest.fn();
    render(<LoginForm onSubmit={onSubmit} />);

    const emailInput = screen.getByPlaceholderText('Email');
    const submitButton = screen.getByText('Login');

    fireEvent.changeText(emailInput, 'invalid-email');
    fireEvent.press(submitButton);

    await waitFor(() => {
      expect(screen.getByText('Invalid email format')).toBeTruthy();
      expect(onSubmit).not.toHaveBeenCalled();
    });
  });

  it('submits with valid credentials', async () => {
    const onSubmit = jest.fn();
    render(<LoginForm onSubmit={onSubmit} />);

    fireEvent.changeText(screen.getByPlaceholderText('Email'), 'user@example.com');
    fireEvent.changeText(screen.getByPlaceholderText('Password'), 'password123');
    fireEvent.press(screen.getByText('Login'));

    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({
        email: 'user@example.com',
        password: 'password123',
      });
    });
  });
});
```

### Example 2: Testing with React Navigation

```tsx
import { render, screen, fireEvent } from '@testing-library/react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { HomeScreen } from '../screens/HomeScreen';

const Stack = createNativeStackNavigator();

const TestNavigator = () => (
  <NavigationContainer>
    <Stack.Navigator>
      <Stack.Screen name="Home" component={HomeScreen} />
    </Stack.Navigator>
  </NavigationContainer>
);

describe('HomeScreen', () => {
  it('navigates to profile on button press', () => {
    const mockNavigate = jest.fn();

    jest.mock('@react-navigation/native', () => ({
      ...jest.requireActual('@react-navigation/native'),
      useNavigation: () => ({ navigate: mockNavigate }),
    }));

    render(<TestNavigator />);

    fireEvent.press(screen.getByText('Go to Profile'));

    expect(mockNavigate).toHaveBeenCalledWith('Profile');
  });
});
```

### Example 3: Testing TanStack Query

```tsx
import { render, screen, waitFor } from '@testing-library/react-native';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { UserList } from '../UserList';

const createTestQueryClient = () =>
  new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });

describe('UserList', () => {
  it('displays users after loading', async () => {
    global.fetch = jest.fn().mockResolvedValue({
      json: async () => [
        { id: 1, name: 'Alice' },
        { id: 2, name: 'Bob' },
      ],
    });

    const queryClient = createTestQueryClient();

    render(
      <QueryClientProvider client={queryClient}>
        <UserList />
      </QueryClientProvider>
    );

    expect(screen.getByText('Loading...')).toBeTruthy();

    await waitFor(() => {
      expect(screen.getByText('Alice')).toBeTruthy();
      expect(screen.getByText('Bob')).toBeTruthy();
    });
  });
});
```

### Example 4: Testing Custom Hook with Dependencies

```tsx
import { renderHook, waitFor } from '@testing-library/react-native';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useUser } from '../hooks/useUser';

describe('useUser', () => {
  it('fetches user data', async () => {
    global.fetch = jest.fn().mockResolvedValue({
      json: async () => ({ id: 1, name: 'John' }),
    });

    const queryClient = new QueryClient();

    const { result } = renderHook(() => useUser('1'), {
      wrapper: ({ children }) => (
        <QueryClientProvider client={queryClient}>
          {children}
        </QueryClientProvider>
      ),
    });

    await waitFor(() => {
      expect(result.current.data).toEqual({ id: 1, name: 'John' });
    });
  });
});
```

### Example 5: Mocking Native Modules

```tsx
import { render, screen, fireEvent } from '@testing-library/react-native';
import { Camera } from 'expo-camera';
import { CameraScreen } from '../CameraScreen';

jest.mock('expo-camera', () => ({
  Camera: ({ children, ...props }: any) => (
    <div data-testid="camera" {...props}>{children}</div>
  ),
  CameraType: { back: 0, front: 1 },
  useCameraPermissions: () => [
    { granted: true, status: 'granted' },
    jest.fn(),
  ],
}));

describe('CameraScreen', () => {
  it('requests camera permission on mount', () => {
    const { getByTestId } = render(<CameraScreen />);

    expect(getByTestId('camera')).toBeTruthy();
  });

  it('shows permission denied message', () => {
    // Override mock for this test
    jest.mocked(Camera.useCameraPermissions).mockReturnValue([
      { granted: false, status: 'denied' },
      jest.fn(),
    ]);

    render(<CameraScreen />);

    expect(screen.getByText(/camera permission denied/i)).toBeTruthy();
  });
});
```

## Resources

- [Expo Unit Testing Guide](https://docs.expo.dev/develop/unit-testing/)
- [React Native Testing Library](https://oss.callstack.com/react-native-testing-library/)
- [jest-expo GitHub](https://github.com/expo/expo/tree/main/packages/jest-expo)
- [Testing Library Queries](https://testing-library.com/docs/queries/about)
- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Common Testing Mistakes](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)

## Tools & Commands

- `npm test` - Run tests in watch mode
- `npm test -- --coverage` - Generate coverage report
- `npm test -- -u` - Update snapshots
- `npm test Button.test.tsx` - Run specific test file
- `npm test -- --verbose` - Show individual test results
- `npm test -- --silent` - Suppress console output

## Troubleshooting

### "Cannot find module 'expo-modules-core'"

**Problem**: Jest can't resolve Expo modules

**Solution**:
```json
{
  "jest": {
    "preset": "jest-expo",
    "transformIgnorePatterns": [
      "node_modules/(?!((jest-)?react-native|@react-native(-community)?)|expo(nent)?|@expo(nent)?/.*|react-navigation|@react-navigation/.*)"
    ]
  }
}
```

### Tests timeout with async operations

**Problem**: Tests hang and timeout after 5 seconds

**Solution**:
```tsx
// Increase timeout for specific test
it('loads data', async () => {
  // ...test code
}, 10000); // 10 second timeout

// Or use waitFor with timeout
await waitFor(
  () => expect(screen.getByText('Loaded')).toBeTruthy(),
  { timeout: 5000 }
);
```

### Mock not working for Expo module

**Problem**: Expo module mock isn't applied

**Solution**:
```tsx
// Create manual mock in __mocks__ directory
// __mocks__/expo-camera.js
module.exports = {
  Camera: 'Camera',
  useCameraPermissions: () => [{ granted: true }, jest.fn()],
};

// Or mock before importing component
jest.mock('expo-camera');
import { MyComponent } from './MyComponent';
```

### "Unable to find node on an unmounted component"

**Problem**: Querying component after it unmounts

**Solution**:
```tsx
// Use cleanup (automatic in jest-expo)
import { render, cleanup } from '@testing-library/react-native';

afterEach(cleanup);

// Or use queryBy* instead of getBy*
expect(screen.queryByText('Gone')).toBeNull();
```

### Coverage not collecting from all files

**Problem**: Coverage only shows tested files

**Solution**:
```json
{
  "jest": {
    "collectCoverageFrom": [
      "src/**/*.{ts,tsx}",
      "!src/**/*.test.{ts,tsx}",
      "!src/**/__tests__/**"
    ]
  }
}
```

### Snapshot tests failing after React Native update

**Problem**: Snapshots changed after upgrade

**Solution**:
```bash
# Review changes first
npm test -- --watchAll=false

# Update if changes are expected
npm test -- -u

# Or for specific file
npm test Button.test.tsx -- -u
```
