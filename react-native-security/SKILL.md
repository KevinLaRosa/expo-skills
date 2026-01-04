---
name: react-native-security
description: Secure React Native apps with encryption, certificate pinning, jailbreak detection, and security auditing using RNSEC scanner
license: MIT
compatibility: "Requires: React Native 0.74+, Expo SDK 50+, RNSEC security scanner"
---

# React Native Security

## Overview

Implement production-grade security in React Native apps using encrypted storage, certificate pinning, jailbreak/root detection, and automated security scanning with RNSEC (React Native Security Scanner).

## When to Use This Skill

- Storing sensitive data (tokens, credentials, user data)
- Handling payment information or financial data
- Need certificate pinning for API calls
- Detecting jailbroken/rooted devices
- Securing API keys and secrets
- Preventing reverse engineering
- Auditing app for security vulnerabilities
- Implementing secure authentication
- Protecting against MITM attacks

## Workflow

### Step 1: Security Audit with RNSEC

**RNSEC** - Automated React Native security scanner (68+ rules)

```bash
# Install RNSEC
npm install -g rnsec

# Run security scan (zero configuration)
rnsec scan

# Scan specific directory
rnsec scan ./src

# Generate JSON report
rnsec scan --format json --output security-report.json
```

**What RNSEC detects:**
- ✅ Hardcoded API keys, JWT tokens, AWS credentials
- ✅ Insecure AsyncStorage usage (plaintext storage)
- ✅ Cleartext HTTP traffic (Android `usesCleartextTraffic`)
- ✅ iOS App Transport Security violations
- ✅ WebView misconfigurations (JavaScript injection)
- ✅ Weak authentication patterns
- ✅ Insecure random number generators
- ✅ Exposed secrets in source code

**Example output:**

```
❌ CRITICAL: Hardcoded API key found
   File: src/api/config.ts:12
   const API_KEY = "sk_live_abc123";

❌ HIGH: AsyncStorage used for sensitive data
   File: src/auth/storage.ts:8
   await AsyncStorage.setItem('authToken', token);

⚠️  MEDIUM: Cleartext traffic enabled
   File: android/app/src/main/AndroidManifest.xml:15
   android:usesCleartextTraffic="true"
```

### Step 2: Secure Storage with Expo Secure Store

**Problem**: AsyncStorage is plaintext - accessible with root/jailbreak

```bash
npx expo install expo-secure-store
```

**✅ Secure approach:**

```typescript
import * as SecureStore from 'expo-secure-store';

// Store sensitive data (encrypted)
await SecureStore.setItemAsync('authToken', token);
await SecureStore.setItemAsync('refreshToken', refreshToken);
await SecureStore.setItemAsync('userId', userId);

// Retrieve
const authToken = await SecureStore.getItemAsync('authToken');

// Delete
await SecureStore.deleteItemAsync('authToken');
```

**Platform implementation:**
- iOS: Keychain (hardware-backed encryption)
- Android: EncryptedSharedPreferences (AES-256-GCM)

**❌ NEVER do this:**

```typescript
// Insecure - plaintext storage!
await AsyncStorage.setItem('authToken', token);
await AsyncStorage.setItem('password', password);
await AsyncStorage.setItem('creditCard', cardNumber);
```

### Step 3: Protect API Keys with Environment Variables

**❌ NEVER hardcode secrets:**

```typescript
// INSECURE - visible in bundle!
const API_KEY = 'sk_live_abc123';
const STRIPE_KEY = 'pk_test_xyz789';
```

**✅ Use environment variables:**

```bash
# Install expo-constants
npx expo install expo-constants

# Create .env file (add to .gitignore!)
echo ".env" >> .gitignore
```

**.env:**

```bash
API_KEY=sk_live_abc123
STRIPE_KEY=pk_test_xyz789
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

**app.config.js:**

```javascript
export default {
  expo: {
    extra: {
      apiKey: process.env.API_KEY,
      stripeKey: process.env.STRIPE_KEY,
      supabaseUrl: process.env.SUPABASE_URL,
      supabaseAnonKey: process.env.SUPABASE_ANON_KEY,
    },
  },
};
```

**Usage:**

```typescript
import Constants from 'expo-constants';

const API_KEY = Constants.expoConfig?.extra?.apiKey;
const STRIPE_KEY = Constants.expoConfig?.extra?.stripeKey;

// Use in API calls
fetch(`https://api.example.com/data`, {
  headers: {
    'Authorization': `Bearer ${API_KEY}`,
  },
});
```

**IMPORTANT**: .env files are still bundled in production! For maximum security, use a backend proxy.

### Step 4: Certificate Pinning (SSL Pinning)

**Problem**: MITM attacks can intercept HTTPS requests

**Solution**: Pin SSL certificates to prevent unauthorized certificates

```bash
npm install react-native-ssl-pinning
```

```typescript
import { fetch as sslFetch } from 'react-native-ssl-pinning';

// Pin specific certificate
const response = await sslFetch('https://api.example.com/data', {
  method: 'GET',
  headers: {
    'Authorization': `Bearer ${token}`,
  },
  sslPinning: {
    // SHA-256 hash of server certificate
    certs: ['sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA='],
  },
});
```

**Get certificate hash:**

```bash
# macOS/Linux
openssl s_client -connect api.example.com:443 < /dev/null | \
  openssl x509 -pubkey -noout | \
  openssl pkey -pubin -outform der | \
  openssl dgst -sha256 -binary | \
  openssl enc -base64

# Output: sha256/ABC123...
```

**Why certificate pinning:**
- Prevents MITM attacks even with trusted CA certificates
- Protects against compromised Certificate Authorities
- Ensures communication only with your actual server

### Step 5: Jailbreak/Root Detection

**Problem**: Jailbroken/rooted devices can bypass security

```bash
npm install jail-monkey
```

```typescript
import JailMonkey from 'jail-monkey';

function useDeviceSecurity() {
  const isJailbroken = JailMonkey.isJailBroken();
  const canMockLocation = JailMonkey.canMockLocation();  // Android
  const isOnExternalStorage = JailMonkey.isOnExternalStorage();  // Android
  const trustFall = JailMonkey.trustFall();  // Overall security check

  return {
    isJailbroken,
    canMockLocation,
    isOnExternalStorage,
    isSecure: !trustFall,  // true if device is compromised
  };
}

// Usage
function App() {
  const { isJailbroken, isSecure } = useDeviceSecurity();

  if (isJailbroken || !isSecure) {
    return (
      <View>
        <Text>⚠️ Security Warning</Text>
        <Text>
          This app cannot run on jailbroken/rooted devices for your security.
        </Text>
      </View>
    );
  }

  return <MainApp />;
}
```

**What jail-monkey detects:**
- ✅ Jailbroken iOS devices (Cydia, suspicious paths)
- ✅ Rooted Android devices (su binary, Magisk)
- ✅ Mock location (GPS spoofing)
- ✅ External storage installation (Android)

### Step 6: Code Obfuscation

**Problem**: JavaScript bundles can be reverse-engineered

**Solution**: Obfuscate code to make reverse engineering harder

**Hermes + Proguard (Android):**

```gradle
// android/app/build.gradle
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

**JavaScript Obfuscation:**

```bash
npm install --save-dev javascript-obfuscator
```

**metro.config.js:**

```javascript
const { getDefaultConfig } = require('expo/metro-config');
const JavaScriptObfuscator = require('javascript-obfuscator');

const config = getDefaultConfig(__dirname);

if (process.env.NODE_ENV === 'production') {
  config.transformer.minifierPath = require.resolve('./obfuscator');
}

module.exports = config;
```

**obfuscator.js:**

```javascript
const JavaScriptObfuscator = require('javascript-obfuscator');

module.exports = async ({ code, map }) => {
  const obfuscated = JavaScriptObfuscator.obfuscate(code, {
    compact: true,
    controlFlowFlattening: true,
    deadCodeInjection: true,
    stringArray: true,
    stringArrayRotate: true,
    stringArrayShuffle: true,
  });

  return {
    code: obfuscated.getObfuscatedCode(),
    map,
  };
};
```

**IMPORTANT**: Obfuscation is not encryption - determined attackers can still reverse engineer. Use it as one layer of defense.

### Step 7: Secure Network Communication

**Disable cleartext traffic (Android):**

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
  android:usesCleartextTraffic="false"  <!-- Disable HTTP -->
  android:networkSecurityConfig="@xml/network_security_config">
```

**network_security_config.xml:**

```xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
  <!-- Only allow HTTPS -->
  <base-config cleartextTrafficPermitted="false">
    <trust-anchors>
      <certificates src="system" />
    </trust-anchors>
  </base-config>

  <!-- Optional: Certificate pinning -->
  <domain-config cleartextTrafficPermitted="false">
    <domain includeSubdomains="true">api.example.com</domain>
    <pin-set>
      <pin digest="SHA-256">base64_encoded_cert_hash</pin>
    </pin-set>
  </domain-config>
</network-security-config>
```

**iOS App Transport Security (ATS):**

```xml
<!-- ios/YourApp/Info.plist -->
<key>NSAppTransportSecurity</key>
<dict>
  <!-- Require HTTPS everywhere -->
  <key>NSAllowsArbitraryLoads</key>
  <false/>

  <!-- Optional: Exceptions for specific domains -->
  <key>NSExceptionDomains</key>
  <dict>
    <key>localhost</key>
    <dict>
      <key>NSExceptionAllowsInsecureHTTPLoads</key>
      <true/>
    </dict>
  </dict>
</dict>
```

### Step 8: Secure Authentication

**Best practices:**

```typescript
import * as SecureStore from 'expo-secure-store';
import * as Crypto from 'expo-crypto';

class AuthManager {
  // ✅ Generate secure tokens
  static async generateSecureToken() {
    const randomBytes = await Crypto.getRandomBytesAsync(32);
    return Array.from(randomBytes)
      .map(b => b.toString(16).padStart(2, '0'))
      .join('');
  }

  // ✅ Store tokens securely
  static async storeTokens(accessToken: string, refreshToken: string) {
    await SecureStore.setItemAsync('accessToken', accessToken);
    await SecureStore.setItemAsync('refreshToken', refreshToken);
  }

  // ✅ Retrieve tokens
  static async getAccessToken() {
    return await SecureStore.getItemAsync('accessToken');
  }

  // ✅ Clear on logout
  static async logout() {
    await SecureStore.deleteItemAsync('accessToken');
    await SecureStore.deleteItemAsync('refreshToken');
    await SecureStore.deleteItemAsync('userId');
  }

  // ✅ Token refresh logic
  static async refreshAccessToken() {
    const refreshToken = await SecureStore.getItemAsync('refreshToken');
    if (!refreshToken) throw new Error('No refresh token');

    const response = await fetch('https://api.example.com/auth/refresh', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken }),
    });

    const { accessToken, refreshToken: newRefreshToken } = await response.json();

    await this.storeTokens(accessToken, newRefreshToken);
    return accessToken;
  }
}
```

**❌ NEVER:**
- Store passwords in any form
- Use weak random generators (Math.random())
- Store tokens in AsyncStorage
- Log sensitive data to console
- Store biometric data (let OS handle it)

### Step 9: WebView Security

**Problem**: WebViews can be exploited for JavaScript injection

```typescript
import { WebView } from 'react-native-webview';

// ✅ Secure WebView configuration
<WebView
  source={{ uri: 'https://trusted-domain.com' }}

  // Disable JavaScript execution (if not needed)
  javaScriptEnabled={false}

  // Disable automatic detection of URLs
  dataDetectorTypes="none"

  // Only allow specific domains
  originWhitelist={['https://trusted-domain.com']}

  // Disable auto-link detection
  allowsLinkPreview={false}

  // Handle navigation
  onNavigationStateChange={(navState) => {
    // Prevent navigation to untrusted domains
    if (!navState.url.startsWith('https://trusted-domain.com')) {
      return false;
    }
  }}
/>
```

**❌ NEVER load user-provided HTML:**

```typescript
// INSECURE - XSS vulnerability!
<WebView source={{ html: userProvidedHTML }} />
```

### Step 10: Secure Data Validation

**Always validate and sanitize user input:**

```bash
npm install zod
```

```typescript
import { z } from 'zod';

// Define schema
const LoginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8).max(100),
});

const CreditCardSchema = z.object({
  number: z.string().regex(/^\d{16}$/),
  cvv: z.string().regex(/^\d{3,4}$/),
  expiry: z.string().regex(/^(0[1-9]|1[0-2])\/\d{2}$/),
});

// Validate input
function handleLogin(data: unknown) {
  try {
    const validated = LoginSchema.parse(data);
    // Safe to use validated.email and validated.password
  } catch (error) {
    // Invalid input - reject
    console.error('Invalid login data:', error);
  }
}
```

## Guidelines

**Do:**
- Use Expo Secure Store for sensitive data (tokens, credentials)
- Run RNSEC security scanner before every release
- Use environment variables for API keys (with backend proxy for production)
- Implement certificate pinning for API calls
- Detect jailbroken/rooted devices with jail-monkey
- Disable cleartext HTTP traffic (HTTPS only)
- Obfuscate production JavaScript bundles
- Validate and sanitize all user input with Zod
- Use secure random generators (expo-crypto, not Math.random())
- Implement proper authentication token refresh
- Clear sensitive data on logout
- Use WebView security configurations

**Don't:**
- Don't store sensitive data in AsyncStorage (plaintext!)
- Don't hardcode API keys in source code
- Don't store passwords (use tokens only)
- Don't log sensitive data to console (strip in production)
- Don't trust jailbroken/rooted devices
- Don't allow HTTP connections (HTTPS only)
- Don't load user-provided HTML in WebView
- Don't use Math.random() for security (use expo-crypto)
- Don't skip security audits (use RNSEC)
- Don't forget to add .env to .gitignore
- Don't use weak authentication (implement MFA/2FA)

## Examples

### Complete Secure Auth Flow

```typescript
import * as SecureStore from 'expo-secure-store';
import * as Crypto from 'expo-crypto';
import JailMonkey from 'jail-monkey';

export class SecureAuthService {
  // Check device security first
  static isDeviceSecure(): boolean {
    return !JailMonkey.trustFall();
  }

  // Login with security checks
  static async login(email: string, password: string) {
    // 1. Check device security
    if (!this.isDeviceSecure()) {
      throw new Error('Device compromised - cannot login');
    }

    // 2. Hash password before sending
    const passwordHash = await Crypto.digestStringAsync(
      Crypto.CryptoDigestAlgorithm.SHA256,
      password
    );

    // 3. Call API with certificate pinning
    const response = await fetch('https://api.example.com/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, passwordHash }),
    });

    const { accessToken, refreshToken, user } = await response.json();

    // 4. Store tokens securely
    await SecureStore.setItemAsync('accessToken', accessToken);
    await SecureStore.setItemAsync('refreshToken', refreshToken);
    await SecureStore.setItemAsync('userId', user.id);

    return user;
  }

  // Secure API call with auto-refresh
  static async secureAPICall(endpoint: string, options: RequestInit = {}) {
    let accessToken = await SecureStore.getItemAsync('accessToken');

    const makeRequest = async (token: string) => {
      return fetch(`https://api.example.com${endpoint}`, {
        ...options,
        headers: {
          ...options.headers,
          'Authorization': `Bearer ${token}`,
        },
      });
    };

    let response = await makeRequest(accessToken!);

    // Token expired - refresh and retry
    if (response.status === 401) {
      const refreshToken = await SecureStore.getItemAsync('refreshToken');
      const refreshResponse = await fetch('https://api.example.com/auth/refresh', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken }),
      });

      const { accessToken: newAccessToken, refreshToken: newRefreshToken } =
        await refreshResponse.json();

      // Update tokens
      await SecureStore.setItemAsync('accessToken', newAccessToken);
      await SecureStore.setItemAsync('refreshToken', newRefreshToken);

      // Retry original request
      response = await makeRequest(newAccessToken);
    }

    return response;
  }

  // Secure logout
  static async logout() {
    await SecureStore.deleteItemAsync('accessToken');
    await SecureStore.deleteItemAsync('refreshToken');
    await SecureStore.deleteItemAsync('userId');
  }
}
```

### RNSEC Integration in CI/CD

```yaml
# .github/workflows/security-check.yml
name: Security Check

on: [push, pull_request]

jobs:
  security-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install RNSEC
        run: npm install -g rnsec

      - name: Run security scan
        run: rnsec scan --format json --output security-report.json

      - name: Upload security report
        uses: actions/upload-artifact@v3
        with:
          name: security-report
          path: security-report.json

      - name: Fail on critical vulnerabilities
        run: |
          if grep -q '"severity":"CRITICAL"' security-report.json; then
            echo "❌ Critical vulnerabilities found!"
            exit 1
          fi
```

## Resources

- [RNSEC Security Scanner](https://www.rnsec.dev/)
- [Expo Secure Store](https://docs.expo.dev/versions/latest/sdk/securestore/)
- [OWASP Mobile Security](https://owasp.org/www-project-mobile-security/)
- [React Native Security](https://reactnative.dev/docs/security)
- [jail-monkey](https://github.com/GantMan/jail-monkey)
- [react-native-ssl-pinning](https://github.com/MaxToyberman/react-native-ssl-pinning)

## Tools & Commands

- `rnsec scan` - Run security audit (68+ rules)
- `rnsec scan --format json` - Generate JSON report
- Expo Secure Store - Hardware-backed encrypted storage
- jail-monkey - Jailbreak/root detection
- Zod - Runtime schema validation
- expo-crypto - Cryptographically secure random generation

## Troubleshooting

### RNSEC reports false positives

**Problem**: Scanner flags non-sensitive data

**Solution**:
```javascript
// Add // rnsec-disable-next-line to ignore specific lines
// rnsec-disable-next-line
const API_URL = "https://public-api.example.com";  // Public URL, not sensitive
```

### Expo Secure Store fails on Android

**Problem**: "Could not encrypt/decrypt data"

**Solution**:
```bash
# Ensure device has lock screen enabled
# Secure Store requires device authentication

# Check in code:
const canUseSecureStore = await SecureStore.isAvailableAsync();
if (!canUseSecureStore) {
  // Fallback or require lock screen
}
```

### Certificate pinning breaks in development

**Problem**: Cannot connect to localhost or staging

**Solution**:
```typescript
// Disable pinning in development
const usePinning = __DEV__ ? false : true;

const response = await sslFetch(url, {
  sslPinning: usePinning ? {
    certs: ['sha256/ABC123...'],
  } : undefined,
});
```

---

## Notes

- **RNSEC** scanner has 68+ security rules (zero configuration)
- **AsyncStorage is plaintext** - never use for sensitive data
- Use **Expo Secure Store** (iOS Keychain, Android EncryptedSharedPreferences)
- **Environment variables are still bundled** - use backend proxy for max security
- **Certificate pinning** prevents MITM attacks
- **jail-monkey** detects jailbroken/rooted devices
- **Cleartext HTTP** should be disabled in production
- **Code obfuscation** makes reverse engineering harder (not impossible)
- **Always validate input** with runtime schemas (Zod)
- **Never log sensitive data** to console in production
- Run **RNSEC scan before every release**
