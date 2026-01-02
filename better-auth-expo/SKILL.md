---
name: better-auth-expo
description: Implement comprehensive authentication in Expo apps with Better Auth - email/password, OAuth providers, anonymous auth, 2FA, and secure session management
license: MIT
compatibility: "Requires: Expo SDK 50+, expo-secure-store, expo-web-browser, better-auth 1.0+, TypeScript"
---

# Better Auth for Expo

## Overview

Implement production-grade authentication in Expo apps using Better Auth, the most comprehensive TypeScript authentication framework with support for 40+ OAuth providers, anonymous auth, 2FA, magic links, and secure session management.

## When to Use This Skill

- Need user authentication in Expo app
- Want OAuth social login (Google, GitHub, Apple, etc.)
- Need anonymous auth for guest users
- Require two-factor authentication (2FA)
- Want magic link or email OTP login
- Need secure session persistence
- Building multi-tenant apps with organizations

**When you see:**
- "Add login to my Expo app"
- "Need Google/Apple sign-in"
- "Guest mode with account linking"
- "Secure session storage"
- "User authentication with TypeScript"

**Prerequisites**: Expo SDK 50+, TypeScript, backend server (or Expo API Routes).

## Workflow

### Step 1: Install Better Auth

**Install dependencies:**

```bash
# Server dependencies
npm install better-auth @better-auth/expo

# Client dependencies (Expo app)
npm install better-auth @better-auth/expo expo-secure-store

# For social OAuth (if needed)
npx expo install expo-linking expo-web-browser expo-constants
```

**IMPORTANT - Metro Configuration:**

Add to `metro.config.js`:

```javascript
const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

config.resolver.unstable_enablePackageExports = true;

module.exports = config;
```

### Step 2: Setup Backend (Server)

**Create auth instance:**

```typescript
// lib/auth.ts (server-side)
import { betterAuth } from "better-auth";
import Database from "better-auth/adapters/drizzle";  // or prisma, mongodb, etc.

export const auth = betterAuth({
  database: Database(db),  // Your database instance
  emailAndPassword: {
    enabled: true,
  },
  socialProviders: {
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID!,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET!,
    },
    github: {
      clientId: process.env.GITHUB_CLIENT_ID!,
      clientSecret: process.env.GITHUB_CLIENT_SECRET!,
    },
  },
  trustedOrigins: [
    "exp://192.168.*.*:*",  // Development (Expo Go)
    "myapp://",              // Production deep link
  ],
  plugins: [
    // Add plugins here (see Step 4)
  ],
});
```

**Create API route:**

```typescript
// app/api/auth/[...all]+api.ts (Expo API Routes)
import { auth } from "@/lib/auth";

export async function GET(request: Request) {
  return auth.handler(request);
}

export async function POST(request: Request) {
  return auth.handler(request);
}
```

### Step 3: Setup Client (Expo App)

**Initialize auth client:**

```typescript
// lib/auth-client.ts
import { createAuthClient } from "better-auth/client";
import { expoClient } from "@better-auth/expo/client";

export const authClient = createAuthClient({
  baseURL: "http://localhost:3000",  // Your server URL
  plugins: [
    expoClient({
      scheme: "myapp",  // Your app scheme (from app.json)
      // storage: AsyncStorage,  // Optional: custom storage
      // disableCache: false,    // Optional: disable session caching
    }),
  ],
});

export const { signIn, signUp, signOut, useSession } = authClient;
```

**Use in React components:**

```typescript
// app/(auth)/login.tsx
import { signIn, useSession } from "@/lib/auth-client";

export default function LoginScreen() {
  const { data: session, isPending } = useSession();
  const [email, setEmail] = React.useState("");
  const [password, setPassword] = React.useState("");

  const handleLogin = async () => {
    await signIn.email({
      email,
      password,
    });
  };

  if (session) {
    return <Redirect href="/(app)/home" />;
  }

  return (
    <View>
      <TextInput value={email} onChangeText={setEmail} />
      <TextInput value={password} onChangeText={setPassword} secureTextEntry />
      <Button title="Sign In" onPress={handleLogin} />
    </View>
  );
}
```

### Step 4: Add Plugins (IMPORTANT!)

**Each plugin requires 3 steps:**
1. Install plugin on server
2. Run migrations
3. Install plugin on client

#### Anonymous Auth Plugin

```typescript
// lib/auth.ts (server)
import { anonymous } from "better-auth/plugins";

export const auth = betterAuth({
  // ... other config
  plugins: [
    anonymous({
      onLinkAccount: async ({ anonymousUser, newUser }) => {
        // Migrate data when guest converts to real account
        await migrateUserData(anonymousUser.id, newUser.id);
      },
    }),
  ],
});
```

**Run migrations:**

```bash
npx @better-auth/cli migrate
```

**Client plugin:**

```typescript
// lib/auth-client.ts
import { anonymousClient } from "better-auth/client/plugins";

export const authClient = createAuthClient({
  // ... other config
  plugins: [
    expoClient({ scheme: "myapp" }),
    anonymousClient(),  // ✅ Add client plugin
  ],
});
```

**Usage:**

```typescript
// Guest sign-in
const user = await authClient.signIn.anonymous();

// Later, link to real account
await signUp.email({
  email: "user@example.com",
  password: "secure-password",
});
// onLinkAccount callback fires automatically
```

#### Two-Factor Authentication (2FA)

```typescript
// lib/auth.ts (server)
import { twoFactor } from "better-auth/plugins";

export const auth = betterAuth({
  plugins: [
    twoFactor({
      totpOptions: {
        period: 30,
      },
    }),
  ],
});
```

```bash
npx @better-auth/cli migrate
```

```typescript
// lib/auth-client.ts
import { twoFactorClient } from "better-auth/client/plugins";

plugins: [
  expoClient({ scheme: "myapp" }),
  twoFactorClient(),  // ✅ Add client plugin
];
```

#### Magic Link

```typescript
// lib/auth.ts (server)
import { magicLink } from "better-auth/plugins";

export const auth = betterAuth({
  plugins: [
    magicLink({
      sendMagicLink: async ({ email, url }) => {
        // Send email with magic link
        await sendEmail(email, url);
      },
    }),
  ],
});
```

```bash
npx @better-auth/cli migrate
```

```typescript
// lib/auth-client.ts
import { magicLinkClient } from "better-auth/client/plugins";

plugins: [
  expoClient({ scheme: "myapp" }),
  magicLinkClient(),  // ✅ Add client plugin
];
```

### Step 5: OAuth Social Login

**Google Sign-In:**

```typescript
// Google OAuth requires expo-web-browser
import * as WebBrowser from "expo-web-browser";

const handleGoogleLogin = async () => {
  await signIn.social({
    provider: "google",
    callbackURL: "/auth/callback",
  });
};
```

**Better Auth automatically:**
- Opens browser for OAuth flow
- Handles redirect callback
- Stores session in SecureStore

**Available providers (40+):**
- Google, GitHub, Apple, Microsoft
- Discord, Twitter, Facebook, LinkedIn
- And many more...

### Step 6: Session Management

**Access session:**

```typescript
import { useSession } from "@/lib/auth-client";

function ProfileScreen() {
  const { data: session, isPending, error } = useSession();

  if (isPending) return <ActivityIndicator />;
  if (!session) return <Redirect href="/login" />;

  return (
    <View>
      <Text>Welcome, {session.user.name}!</Text>
      <Text>Email: {session.user.email}</Text>
    </View>
  );
}
```

**Sign out:**

```typescript
await signOut();
```

**Protected routes (with Expo Router):**

```typescript
// app/(app)/_layout.tsx
import { useSession } from "@/lib/auth-client";
import { Redirect } from "expo-router";

export default function AppLayout() {
  const { data: session, isPending } = useSession();

  if (isPending) return <ActivityIndicator />;
  if (!session) return <Redirect href="/(auth)/login" />;

  return <Stack />;
}
```

### Step 7: Database Migrations

**Better Auth requires database tables:**

```bash
# Generate migration
npx @better-auth/cli generate

# Run migration
npx @better-auth/cli migrate
```

**Supported databases:**
- PostgreSQL (with Drizzle, Prisma)
- MySQL (with Drizzle, Prisma)
- SQLite (with Drizzle, Prisma)
- MongoDB (with Prisma)
- And more...

## Guidelines

**Do:**
- Always run migrations after adding plugins
- Use SecureStore for session storage (default)
- Add expo-web-browser for OAuth
- Configure trustedOrigins for production
- Enable `unstable_enablePackageExports` in Metro
- Install BOTH server and client plugins
- Use TypeScript for type safety

**Don't:**
- Don't skip Metro configuration (causes module errors)
- Don't forget to run migrations after plugins
- Don't hardcode API URL (use environment variables)
- Don't skip client plugin when adding server plugin
- Don't use insecure storage for sessions
- Don't forget deep link scheme for OAuth

## Examples

### Complete Anonymous → Real Account Flow

```typescript
// 1. Guest sign-in on app launch
const guestUser = await authClient.signIn.anonymous();

// 2. User adds items to cart, explores app
// (data associated with guestUser.id)

// 3. User decides to create account
await signUp.email({
  email: "user@example.com",
  password: "secure-password",
});

// 4. onLinkAccount callback migrates data
// Server (lib/auth.ts):
anonymous({
  onLinkAccount: async ({ anonymousUser, newUser }) => {
    await db.cartItem.updateMany({
      where: { userId: anonymousUser.id },
      data: { userId: newUser.id },
    });
  },
});
```

### Multi-Provider Login

```typescript
// Email/Password
await signIn.email({ email, password });

// Google
await signIn.social({ provider: "google" });

// GitHub
await signIn.social({ provider: "github" });

// Apple
await signIn.social({ provider: "apple" });

// Anonymous
await signIn.anonymous();
```

### API Requests with Session

```typescript
import { authClient } from "@/lib/auth-client";

async function fetchProtectedData() {
  const session = await authClient.session.get();

  const response = await fetch("https://api.example.com/data", {
    headers: {
      Authorization: `Bearer ${session.token}`,
      Cookie: `better-auth.session=${session.id}`,
    },
    credentials: "omit",  // Don't auto-send cookies
  });

  return response.json();
}
```

## Resources

- [Better Auth Documentation](https://www.better-auth.com/)
- [Expo Integration Guide](references/better-auth-expo.md)
- [Anonymous Plugin](references/anonymous-plugin.md)
- [Better Auth Plugins](https://www.better-auth.com/docs/plugins)
- [OAuth Providers](https://www.better-auth.com/docs/authentication/oauth)

## Tools & Commands

- `npx @better-auth/cli migrate` - Run database migrations
- `npx @better-auth/cli generate` - Generate migration files
- `npx expo install expo-secure-store` - Install secure storage
- `npx expo install expo-web-browser expo-linking` - OAuth dependencies

## Troubleshooting

### Module resolution errors

**Problem**: "Cannot find module 'better-auth/client'"

**Solution**:
```javascript
// metro.config.js
config.resolver.unstable_enablePackageExports = true;
```

### Plugin not working

**Problem**: Added plugin but methods not available

**Solution**:
```bash
# 1. Check server plugin installed
# 2. Run migrations
npx @better-auth/cli migrate

# 3. Add client plugin
import { anonymousClient } from "better-auth/client/plugins";
```

### OAuth redirect not working

**Problem**: OAuth flow doesn't redirect back to app

**Solution**:
```typescript
// Check scheme in app.json matches auth-client.ts
// app.json
{
  "expo": {
    "scheme": "myapp"
  }
}

// auth-client.ts
expoClient({ scheme: "myapp" })

// Add to trustedOrigins (server)
trustedOrigins: ["myapp://"]
```

---

## Notes

- Better Auth is TypeScript-first (full type safety)
- Supports 40+ OAuth providers out of the box
- Plugin system for extensibility
- Secure by default (SecureStore, HTTPS)
- Works with Expo API Routes or external server
- Compatible with all major databases
- **Critical**: Always install BOTH server AND client plugins
- Session caching eliminates loading states on app reload
- Deep linking required for OAuth on mobile
