# Anonymous Authentication Plugin

> Source: [Better Auth - Anonymous Plugin](https://www.better-auth.com/docs/plugins/anonymous)

## Overview
The Anonymous plugin for Better Auth enables authenticated user experiences without requiring PII. Users can authenticate immediately and "link an authentication method to their account when ready."

## Installation Steps

**1. Configure the Plugin**
Add the anonymous plugin to your auth configuration:
```ts
import { betterAuth } from "better-auth"
import { anonymous } from "better-auth/plugins"

export const auth = betterAuth({
    plugins: [anonymous()]
})
```

**2. Update Database Schema**
Execute migrations or generate schema updates using the CLI (npm, pnpm, yarn, or bun):
```bash
npx @better-auth/cli migrate
# or
npx @better-auth/cli generate
```

**3. Add Client Plugin**
Integrate the client-side plugin into your authentication client:
```ts
import { createAuthClient } from "better-auth/client"
import { anonymousClient } from "better-auth/client/plugins"

export const authClient = createAuthClient({
    plugins: [anonymousClient()]
})
```

## Core Usage

**Anonymous Sign-In**
```ts
const user = await authClient.signIn.anonymous()
```

**Account Linking**
When users sign in via another method, trigger the `onLinkAccount` callback to migrate their data:
```ts
anonymous({
    onLinkAccount: async ({ anonymousUser, newUser }) => {
        // Migrate user data (cart items, preferences, etc.)
    }
})
```

## Configuration Options

- **emailDomainName**: Custom domain for generated emails (default: `temp-{id}@example.com`)
- **generateRandomEmail**: Custom email generation function
- **onLinkAccount**: Callback for data migration during account linking
- **disableDeleteAnonymousUser**: Preserve anonymous user records post-linking
- **generateName**: Custom name generation for anonymous accounts
