# RevenueCat Expo Installation

> Source: [RevenueCat - Expo Installation](https://www.revenuecat.com/docs/getting-started/installation/expo)

## Overview

RevenueCat simplifies in-app purchases and subscriptions by wrapping StoreKit, Google Play Billing, and RevenueCat Web Billing. The platform handles IAP infrastructure so developers can focus on building their app business.

## Initial Setup

### Project Creation
Start with an existing Expo project or create a new one:
```
npx create-expo-app@latest
```

Install the dev client dependency:
```
npx expo install expo-dev-client
```

### SDK Installation
Install RevenueCat's core and UI packages:
```
npx expo install react-native-purchases react-native-purchases-ui
```

**Critical Note:** After SDK installation, you must run the full build process. Hot reloading alone will cause native module errors.

## Dashboard Configuration

Set up these components in RevenueCat's dashboard:

1. **Create a Project** — Container for your apps, products, and paywalls
2. **Connect Stores** — Link Apple App Store, Google Play, or other platforms
3. **Add Products** — Configure offerings for each connected store
4. **Create Entitlements** — Define access levels customers earn through purchases
5. **Build Offerings** — Organize products into collections for your paywall
6. **Design Paywalls** — Configure UI remotely without code changes

## SDK Configuration

Initialize RevenueCat at your app's entry point:

```javascript
import Purchases, { LOG_LEVEL } from 'react-native-purchases';

useEffect(() => {
  Purchases.setLogLevel(LOG_LEVEL.VERBOSE);
  if (Platform.OS === 'ios') {
    Purchases.configure({apiKey: <apple_api_key>});
  } else {
    Purchases.configure({apiKey: <google_api_key>});
  }
}, []);
```

## Customer Management

### Identify Users
Use RevenueCat's customer identification system to maintain consistent subscription status across platforms.

### Check Subscription Status
Fetch customer info and verify entitlements:

```javascript
const customerInfo = await Purchases.getCustomerInfo();
if(typeof customerInfo.entitlements.active[<entitlement_id>] !== "undefined") {
  // Grant premium access
}
```

### Present Paywalls
Display purchase UI when customers lack entitlements. Refer to React Native Paywalls documentation for multiple implementation approaches.

## Testing Your App

### iOS Simulator Testing

1. Install EAS CLI: `npm install -g eas-cli`
2. Authenticate: `eas login`
3. Initialize: `eas init`
4. Configure builds: `eas build:configure`

Update `eas.json` with simulator profile, then build:
```
eas build --platform ios --profile ios-simulator
```

Start the development server:
```
npx expo start
```

### Android Testing

Build for physical device or emulator:
```
eas build --platform android --profile development
```

Install Expo Orbit for device management or use QR codes for emulator installation.

## Expo Go Alternative

Expo Go provides a sandbox environment with mock APIs for subscription logic testing. However, real purchases require a development build. The framework automatically detects Expo Go and disables native purchase functionality, allowing UI testing without a custom build.

**Key Limitation:** "Preview API Mode" in Expo Go prevents actual transactions—development builds are necessary for production testing.
