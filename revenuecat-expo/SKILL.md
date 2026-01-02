---
name: revenuecat-expo
description: Implement in-app purchases and subscriptions in Expo apps with RevenueCat - handles StoreKit, Google Play Billing, paywalls, entitlements, and subscription management
license: MIT
compatibility: "Requires: Expo SDK 50+, expo-dev-client, RevenueCat account, App Store Connect / Google Play Console setup"
---

# RevenueCat for Expo

## Overview

Implement production-grade in-app purchases and subscriptions in Expo apps using RevenueCat, which wraps StoreKit (iOS), Google Play Billing (Android), and provides remote paywall configuration, subscription analytics, and entitlement management.

## When to Use This Skill

- Need in-app purchases in Expo app
- Want subscription management (monthly/yearly plans)
- Need remote paywall configuration (no app update)
- Want subscription analytics and metrics
- Need cross-platform IAP (iOS + Android)
- Want A/B testing for pricing
- Need customer entitlement management

**When you see:**
- "Add subscriptions to my app"
- "Monetize with in-app purchases"
- "Premium features behind paywall"
- "Monthly/yearly subscription plans"
- "Unlock features with purchase"

**Prerequisites**: Expo SDK 50+, expo-dev-client, RevenueCat account, App Store Connect / Google Play Console configured.

## Workflow

### Step 1: RevenueCat Dashboard Setup

**1. Create RevenueCat Account**
- Go to https://app.revenuecat.com/
- Create new project

**2. Connect App Stores**
- iOS: Add App Store Connect API key
- Android: Add Google Play service account JSON

**3. Create Products**
- Add your IAP products from App Store Connect
- Add your IAP products from Google Play Console
- RevenueCat syncs product IDs automatically

**4. Create Entitlements**
- Entitlement = Feature access (e.g., "premium", "pro")
- Not tied to specific products
- Example: "premium" entitlement for all subscription tiers

**5. Create Offerings**
- Offering = Group of products shown to user
- Example: "default" offering with monthly + yearly plans
- Remote configuration (change without app update)

**6. Design Paywalls** (Optional)
- Visual paywall builder
- No-code paywall customization
- A/B testing variants

### Step 2: Install RevenueCat SDK

**Install dependencies:**

```bash
# Install RevenueCat SDK
npx expo install react-native-purchases react-native-purchases-ui

# Install dev client (required for native modules)
npx expo install expo-dev-client
```

**IMPORTANT - Must rebuild after installation:**

```bash
# Build for iOS simulator
eas build --platform ios --profile ios-simulator

# OR build for Android
eas build --platform android --profile development

# Then start dev server
npx expo start --dev-client
```

**⚠️ Hot reload won't work** - native modules require full rebuild!

### Step 3: Configure RevenueCat SDK

**Initialize at app entry point:**

```typescript
// app/_layout.tsx or App.tsx
import Purchases, { LOG_LEVEL } from 'react-native-purchases';
import { useEffect } from 'react';
import { Platform } from 'react-native';

const REVENUECAT_APPLE_API_KEY = "appl_xxx";  // From RevenueCat dashboard
const REVENUECAT_GOOGLE_API_KEY = "goog_xxx";

export default function RootLayout() {
  useEffect(() => {
    // Enable debug logging (remove in production)
    Purchases.setLogLevel(LOG_LEVEL.VERBOSE);

    // Configure SDK with platform-specific API key
    if (Platform.OS === 'ios') {
      Purchases.configure({ apiKey: REVENUECAT_APPLE_API_KEY });
    } else if (Platform.OS === 'android') {
      Purchases.configure({ apiKey: REVENUECAT_GOOGLE_API_KEY });
    }
  }, []);

  return <Stack />;
}
```

**Identify users (optional but recommended):**

```typescript
// After user signs in
await Purchases.logIn(userId);

// Anonymous users work too (RevenueCat generates ID)
// No need to call logIn if you want anonymous purchases
```

### Step 4: Check Entitlements

**Check if user has access:**

```typescript
import Purchases from 'react-native-purchases';

async function checkPremiumAccess(): Promise<boolean> {
  try {
    const customerInfo = await Purchases.getCustomerInfo();

    // Check if user has "premium" entitlement
    const hasPremium = typeof customerInfo.entitlements.active["premium"] !== "undefined";

    return hasPremium;
  } catch (error) {
    console.error("Error fetching customer info:", error);
    return false;
  }
}

// Usage in component
function PremiumFeature() {
  const [isPremium, setIsPremium] = useState(false);

  useEffect(() => {
    checkPremiumAccess().then(setIsPremium);
  }, []);

  if (!isPremium) {
    return <PaywallScreen />;
  }

  return <PremiumContent />;
}
```

**Listen for changes:**

```typescript
useEffect(() => {
  // Listen for purchase updates
  const customerInfoListener = Purchases.addCustomerInfoUpdateListener((info) => {
    const hasPremium = typeof info.entitlements.active["premium"] !== "undefined";
    setIsPremium(hasPremium);
  });

  return () => {
    customerInfoListener.remove();
  };
}, []);
```

### Step 5: Display Paywall

**Option 1: RevenueCat's Pre-built Paywall (Recommended)**

```typescript
import { RevenueCatUI } from 'react-native-purchases-ui';

async function showPaywall() {
  try {
    const paywallResult = await RevenueCatUI.presentPaywall();

    if (paywallResult === RevenueCatUI.PAYWALL_RESULT.PURCHASED) {
      // User purchased, refresh entitlements
      const customerInfo = await Purchases.getCustomerInfo();
      console.log("User is now premium!");
    } else if (paywallResult === RevenueCatUI.PAYWALL_RESULT.CANCELLED) {
      console.log("User dismissed paywall");
    }
  } catch (error) {
    console.error("Error showing paywall:", error);
  }
}

// In component
function LockedFeature() {
  return (
    <View>
      <Text>This feature requires Premium</Text>
      <Button title="Upgrade to Premium" onPress={showPaywall} />
    </View>
  );
}
```

**Option 2: Custom Paywall**

```typescript
import Purchases, { PurchasesOffering } from 'react-native-purchases';

function CustomPaywall() {
  const [offering, setOffering] = useState<PurchasesOffering | null>(null);

  useEffect(() => {
    async function fetchOffering() {
      try {
        const offerings = await Purchases.getOfferings();
        if (offerings.current) {
          setOffering(offerings.current);
        }
      } catch (error) {
        console.error("Error fetching offerings:", error);
      }
    }
    fetchOffering();
  }, []);

  const handlePurchase = async (packageId: string) => {
    try {
      const { customerInfo } = await Purchases.purchasePackage(
        offering!.availablePackages.find(pkg => pkg.identifier === packageId)!
      );

      const hasPremium = typeof customerInfo.entitlements.active["premium"] !== "undefined";
      if (hasPremium) {
        console.log("Purchase successful!");
      }
    } catch (error: any) {
      if (!error.userCancelled) {
        console.error("Purchase error:", error);
      }
    }
  };

  if (!offering) return <ActivityIndicator />;

  return (
    <View>
      <Text>Choose Your Plan</Text>

      {offering.availablePackages.map((pkg) => (
        <View key={pkg.identifier}>
          <Text>{pkg.product.title}</Text>
          <Text>{pkg.product.description}</Text>
          <Text>{pkg.product.priceString}</Text>
          <Button
            title="Subscribe"
            onPress={() => handlePurchase(pkg.identifier)}
          />
        </View>
      ))}

      <Button title="Restore Purchases" onPress={restorePurchases} />
    </View>
  );
}

async function restorePurchases() {
  try {
    const customerInfo = await Purchases.restorePurchases();
    console.log("Purchases restored:", customerInfo);
  } catch (error) {
    console.error("Error restoring purchases:", error);
  }
}
```

### Step 6: Handle Subscription States

**Check subscription status:**

```typescript
async function getSubscriptionStatus() {
  const customerInfo = await Purchases.getCustomerInfo();

  // Active entitlements
  const activeEntitlements = Object.keys(customerInfo.entitlements.active);
  console.log("Active entitlements:", activeEntitlements);

  // Expiration date
  const premiumEntitlement = customerInfo.entitlements.active["premium"];
  if (premiumEntitlement) {
    console.log("Expires:", premiumEntitlement.expirationDate);
    console.log("Will renew:", premiumEntitlement.willRenew);
    console.log("Is active:", premiumEntitlement.isActive);
  }

  // Check if in trial
  const isInTrial = premiumEntitlement?.periodType === "trial";

  return {
    hasPremium: !!premiumEntitlement,
    expiresAt: premiumEntitlement?.expirationDate,
    willRenew: premiumEntitlement?.willRenew ?? false,
    isInTrial,
  };
}
```

### Step 7: Testing

**iOS Sandbox Testing:**

```bash
# 1. Create sandbox tester in App Store Connect
# Users and Access → Sandbox Testers → + icon

# 2. Sign out of real App Store account on device
# Settings → App Store → Sign Out

# 3. Build and run app
eas build --platform ios --profile ios-simulator
npx expo start --dev-client

# 4. Make purchase (sign in with sandbox tester when prompted)
```

**Android Testing:**

```bash
# 1. Add internal testers in Google Play Console
# Testing → Internal testing → Testers

# 2. Upload app to internal testing track
eas build --platform android --profile development

# 3. Install app from Play Store internal test link
# 4. Make purchase (no credit card charged in test mode)
```

**Expo Go Preview Mode:**

RevenueCat detects Expo Go and enters "Preview API Mode":
- No real purchases possible
- Can test UI/UX only
- For actual purchase testing, use dev client build

## Guidelines

**Do:**
- Always rebuild after installing RevenueCat
- Use entitlements (not product IDs) to gate features
- Handle purchase errors gracefully
- Provide "Restore Purchases" button
- Test with sandbox/test accounts
- Log RevenueCat events for debugging
- Identify users with `logIn()` for cross-device sync

**Don't:**
- Don't rely on hot reload after SDK installation
- Don't hardcode product IDs (use offerings)
- Don't forget to test restore purchases
- Don't skip error handling on purchases
- Don't test with real Apple/Google accounts
- Don't forget to remove LOG_LEVEL.VERBOSE in production
- Don't gate critical app functionality behind paywall

## Examples

### Complete Subscription Flow

```typescript
// 1. Check on app launch
const customerInfo = await Purchases.getCustomerInfo();
const isPremium = typeof customerInfo.entitlements.active["premium"] !== "undefined";

if (!isPremium) {
  // 2. Show paywall
  const result = await RevenueCatUI.presentPaywall();

  if (result === RevenueCatUI.PAYWALL_RESULT.PURCHASED) {
    // 3. Grant access
    const updatedInfo = await Purchases.getCustomerInfo();
    const nowPremium = typeof updatedInfo.entitlements.active["premium"] !== "undefined";
    console.log("User is premium:", nowPremium);
  }
}
```

### Subscription Tiers

```typescript
// RevenueCat Dashboard:
// - Entitlement: "basic" → Monthly plan
// - Entitlement: "pro" → Yearly plan
// - Offering: "default" → Both packages

const customerInfo = await Purchases.getCustomerInfo();

const hasBasic = typeof customerInfo.entitlements.active["basic"] !== "undefined";
const hasPro = typeof customerInfo.entitlements.active["pro"] !== "undefined";

if (hasPro) {
  return <ProFeatures />;
} else if (hasBasic) {
  return <BasicFeatures />;
} else {
  return <FreeFeatures />;
}
```

### One-Time Purchase (Non-Subscription)

```typescript
// Works same as subscriptions, just different product type

async function buyPremiumFeature() {
  try {
    const offerings = await Purchases.getOfferings();
    const premiumPackage = offerings.current?.availablePackages.find(
      pkg => pkg.identifier === "premium_feature"
    );

    if (premiumPackage) {
      const { customerInfo } = await Purchases.purchasePackage(premiumPackage);

      const hasFeature = typeof customerInfo.entitlements.active["premium_feature"] !== "undefined";
      return hasFeature;
    }
  } catch (error: any) {
    if (!error.userCancelled) {
      console.error("Purchase failed:", error);
    }
  }
  return false;
}
```

## Resources

- [RevenueCat Documentation](https://www.revenuecat.com/docs)
- [Expo Installation Guide](references/revenuecat-expo.md)
- [Quickstart Guide](https://www.revenuecat.com/docs/getting-started/quickstart)
- [Paywalls Documentation](https://www.revenuecat.com/docs/tools/paywalls)
- [Testing Guide](https://www.revenuecat.com/docs/test-and-launch/sandbox)

## Tools & Commands

- `npx expo install react-native-purchases` - Install SDK
- `eas build --platform ios --profile ios-simulator` - Build for iOS
- `eas build --platform android --profile development` - Build for Android
- `Purchases.setLogLevel(LOG_LEVEL.VERBOSE)` - Enable debug logs

## Troubleshooting

### "Invalid API key" error

**Problem**: SDK can't connect to RevenueCat

**Solution**:
```typescript
// Check you're using correct platform key
// iOS: appl_xxx
// Android: goog_xxx

if (Platform.OS === 'ios') {
  Purchases.configure({ apiKey: APPLE_KEY });  // Not Google key!
}
```

### Purchases not working in Expo Go

**Problem**: Can't make purchases in Expo Go

**Solution**:
```bash
# Expo Go uses Preview API Mode (no real purchases)
# Build dev client instead:
eas build --platform ios --profile ios-simulator
npx expo start --dev-client
```

### Product not found

**Problem**: `getOfferings()` returns empty

**Solution**:
```bash
# 1. Check products exist in App Store Connect / Play Console
# 2. Check products added to RevenueCat dashboard
# 3. Check offering configured in RevenueCat
# 4. Wait a few hours (App Store can take time to propagate)
```

### "No active entitlement" after purchase

**Problem**: Purchase succeeded but entitlement not active

**Solution**:
```typescript
// Check entitlement ID matches exactly
// Dashboard: "premium"
// Code: customerInfo.entitlements.active["premium"]  // Must match!

// Also check product is attached to entitlement in dashboard
```

---

## Notes

- RevenueCat handles all IAP complexity (StoreKit, Play Billing)
- Remote paywall configuration (no app update needed)
- Cross-platform subscription status syncing
- Built-in analytics and charts
- A/B testing for pricing optimization
- Supports iOS, Android, web, macOS, etc.
- **Critical**: Must rebuild app after installing SDK (no hot reload)
- Free tier available (up to $2.5k monthly revenue)
- Paid tiers unlock advanced features (experiments, integrations)
