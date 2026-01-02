# Better Auth Expo Integration

> Source: [Better Auth - Expo Integration](https://www.better-auth.com/docs/integrations/expo)

## Overview

Better Auth supports both Expo native and web applications, enabling developers to build cross-platform apps with React Native. The framework accommodates separate servers or Expo's API Routes feature for hosting the authentication backend.

## Installation Steps

### 1. Backend Configuration
Set up a Better Auth server instance separately or use Expo's API Routes. The authentication handler should be mounted in an API route file that exports both GET and POST methods.

### 2. Dependencies
Install core packages on both server and client:
- Server: `better-auth` and `@better-auth/expo`
- Client: Same packages plus `expo-secure-store` for secure session storage
- Social auth requires: `expo-linking`, `expo-web-browser`, `expo-constants`

### 3. Server Setup
Add the Expo plugin to your Better Auth configuration alongside preferred authentication methods like email/password authentication.

### 4. Client Initialization
Initialize the auth client by specifying the backend URL and configuring the Expo client plugin with secure storage and deep-link scheme settings.

## Key Configuration Requirements

**Trusted Origins**: Register your app's scheme in `trustedOrigins` configuration. Development mode supports wildcard patterns for Expo's `exp://` scheme, while production uses specific app schemes.

**Metro Bundler**: Enable `unstable_enablePackageExports` in metro configuration to properly resolve Better Auth exports. Alternatively, use babel-plugin-module-resolver for manual path resolution.

## Usage Patterns

### Authentication
Users can sign in via email/password or social providers. Social authentication handles authorization URLs and callbacks automatically through the Expo web browser.

### Session Management
Access session data using the `useSession` hook. Session information caches locally in SecureStore, eliminating loading spinners on app reloads.

### Authenticated Requests
Manually retrieve session cookies and add them to request headers, setting `credentials: "omit"` to prevent interference with manual cookie management.

## Plugin Options

**Client options include:**
- `storage`: Custom storage mechanism (defaults to SecureStore)
- `scheme`: Deep-link scheme (auto-detected from app.json)
- `disableCache`: Toggle session caching behavior
- `cookiePrefix`: Identify Better Auth cookies among third-party ones

These configurations ensure secure, seamless authentication across mobile and web platforms.
