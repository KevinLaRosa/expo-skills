---
name: expo-typescript-fixer
description: Fix TypeScript errors, enable strict mode, detect dead code with knip, and implement runtime validation with Zod
license: MIT
compatibility: "Requires: TypeScript 5+, Node.js 18+, knip, zod packages"
---

# Expo TypeScript Fixer

## Overview

Improve code quality by fixing TypeScript errors, enabling strict mode, detecting unused code, and adding runtime validation.

## When to Use This Skill

- TypeScript errors piling up
- Want to enable strict mode
- Need to detect dead code
- Implementing runtime validation
- Improving type safety
- Preparing for production

## Workflow

### Step 1: Check TypeScript Errors

```bash
# Run TypeScript compiler
npx tsc --noEmit

# Count errors
npx tsc --noEmit | grep "error TS" | wc -l
```

### Step 2: Enable Strict Mode Gradually

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": false,
    // Enable one by one:
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true
  }
}
```

### Step 3: Detect Dead Code with Knip

```bash
npm install -D knip

# Run knip
npx knip

# Fix: Remove unused exports and dependencies
```

### Step 4: Runtime Validation with Zod

```typescript
import { z } from 'zod';

// Define schema
const UserSchema = z.object({
  id: z.string(),
  email: z.string().email(),
  age: z.number().min(18),
});

// Validate API response
async function fetchUser(id: string) {
  const response = await fetch(`/users/${id}`);
  const data = await response.json();

  // Runtime validation
  const user = UserSchema.parse(data);
  return user;  // Typed as { id: string; email: string; age: number; }
}
```

### Step 5: Type Expo Router Routes

```typescript
// expo-router.d.ts
declare module 'expo-router' {
  export function useRouter(): {
    push: (href: '/home' | '/profile' | `/user/${string}`) => void;
    replace: (href: '/home' | '/profile') => void;
  };
}
```

## Guidelines

**Do:**
- Fix errors incrementally
- Use Zod for API boundaries
- Enable strict mode gradually
- Run knip regularly

**Don't:**
- Don't use `any` type
- Don't ignore TypeScript errors
- Don't skip runtime validation for external data

## Resources

- [TypeScript Patterns](references/typescript-patterns.md)
- [Zod Validation](references/zod-validation.md)

---

## Notes

- Strict mode catches bugs early
- Zod provides runtime + compile-time safety
- Knip finds truly dead code
