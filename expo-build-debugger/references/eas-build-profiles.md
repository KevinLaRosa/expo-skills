# EAS Build Profiles Reference

## Overview

EAS Build uses `eas.json` to configure named groups of settings called **build profiles**. Each profile describes parameters needed for specific build types, allowing you to maintain different configurations for development, testing, and production releases.

## Default Build Profiles

### Development Profile

The development profile is optimized for active development and includes developer tools.

**Key Characteristics:**
- Includes `"developmentClient": true` to support expo-dev-client
- Defaults to `"distribution": "internal"` for direct device installation
- Includes developer tools and debug capabilities
- Never submitted to app stores
- Can be configured for iOS Simulator with `"simulator": true`
- Larger build size due to included debugging tools

**Example Configuration:**
```json
{
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "ios": {
        "simulator": true
      }
    }
  }
}
```

**When to Use:**
- Active feature development
- Testing on physical devices or simulators
- Debugging with React Native DevTools
- Hot reloading and fast refresh workflows

### Preview Profile

The preview profile excludes developer tools and is intended for team testing in production-like environments.

**Key Characteristics:**
- No developer tools included
- Uses `"distribution": "internal"` for internal testing
- Packaged for testing rather than store submission
- Android: Recommended to use APK format for easier installation
- Mimics production environment without app store distribution

**Example Configuration:**
```json
{
  "build": {
    "preview": {
      "distribution": "internal",
      "android": {
        "buildType": "apk"
      }
    }
  }
}
```

**When to Use:**
- QA testing before production release
- Stakeholder demos and reviews
- Beta testing with internal teams
- Testing production-like behavior without app store submission

### Production Profile

The production profile is optimized for app store submission with minimal build size and maximum performance.

**Key Characteristics:**
- Optimized for app store submission
- Must be installed through respective app stores (App Store, Google Play)
- Android defaults to AAB (Android App Bundle) format (required by Google Play Store)
- Cannot be directly installed on emulators/simulators
- Code minification and optimization enabled
- Smallest build size

**Example Configuration:**
```json
{
  "build": {
    "production": {
      "android": {
        "buildType": "aab"
      },
      "ios": {
        "resourceClass": "large"
      }
    }
  }
}
```

**When to Use:**
- Final release builds for app stores
- Production updates and patches
- App Store Connect / Google Play Console submissions

## Configuration Options

### Profile Extension

Profiles can inherit settings from other profiles using the `"extends"` property. This allows sharing common configurations while maintaining separation of concerns.

**Example:**
```json
{
  "build": {
    "base": {
      "node": "20.11.0",
      "env": {
        "API_URL": "https://api.example.com"
      }
    },
    "development": {
      "extends": "base",
      "developmentClient": true,
      "env": {
        "API_URL": "https://dev-api.example.com"
      }
    },
    "production": {
      "extends": "base"
    }
  }
}
```

**Extension Rules:**
- Chains can go up to 5 levels deep
- Cannot have circular dependencies
- Child profiles override parent settings
- Platform-specific settings override global ones

### Platform-Specific Settings

Configure Android and iOS separately within each profile using `android` and `ios` objects. Platform-specific options override globally-defined ones.

**Example:**
```json
{
  "build": {
    "preview": {
      "distribution": "internal",
      "android": {
        "buildType": "apk",
        "gradleCommand": ":app:assembleRelease"
      },
      "ios": {
        "simulator": true,
        "buildConfiguration": "Release"
      }
    }
  }
}
```

### Build Tool Versions

Set versions for Node.js, npm, Yarn, Ruby, and other tools per profile. Common practice is to define versions once in a base profile and extend from it.

**Example:**
```json
{
  "build": {
    "production": {
      "node": "20.11.0",
      "yarn": "1.22.19",
      "npm": "10.2.4",
      "cocoapods": "1.15.0"
    }
  }
}
```

**Available Version Options:**
- `node`: Node.js version
- `npm`: npm version
- `yarn`: Yarn version (classic or berry)
- `pnpm`: pnpm version
- `bun`: Bun version
- `cocoapods`: CocoaPods version (iOS only)

### Resource Classes

Choose between `medium` (default) and `large` virtual machine configurations. Larger classes require paid EAS plans but enable faster builds.

**Example:**
```json
{
  "build": {
    "production": {
      "ios": {
        "resourceClass": "large"
      },
      "android": {
        "resourceClass": "large"
      }
    }
  }
}
```

**Resource Class Comparison:**

| Resource Class | vCPUs | Memory | Build Speed | Cost |
|---------------|-------|--------|-------------|------|
| medium | 4 | 8 GB | Standard | Free tier available |
| large | 8 | 32 GB | ~2x faster | Paid plans only |

### Environment Variables

Define environment variables in the `env` field, which apply during local evaluation and on the build server. Different profiles can override values for staging versus production scenarios.

**Example:**
```json
{
  "build": {
    "development": {
      "env": {
        "APP_VARIANT": "development",
        "API_URL": "https://dev-api.example.com",
        "ENABLE_ANALYTICS": "false"
      }
    },
    "preview": {
      "env": {
        "APP_VARIANT": "preview",
        "API_URL": "https://staging-api.example.com",
        "ENABLE_ANALYTICS": "true"
      }
    },
    "production": {
      "env": {
        "APP_VARIANT": "production",
        "API_URL": "https://api.example.com",
        "ENABLE_ANALYTICS": "true"
      }
    }
  }
}
```

## iOS-Specific Configuration

### iOS Build Settings

**Common iOS Options:**
```json
{
  "build": {
    "production": {
      "ios": {
        "simulator": false,
        "buildConfiguration": "Release",
        "scheme": "YourAppScheme",
        "resourceClass": "large",
        "autoIncrement": "buildNumber",
        "bundler": "metro"
      }
    }
  }
}
```

**Key iOS Settings:**
- `simulator`: Build for iOS Simulator (true/false)
- `buildConfiguration`: Xcode build configuration (Debug/Release)
- `scheme`: Xcode scheme to build
- `autoIncrement`: Auto-increment version or build number
- `bundler`: JavaScript bundler to use (metro/webpack)

### iOS Simulator Builds

For local testing on iOS Simulator:

```json
{
  "build": {
    "simulator": {
      "ios": {
        "simulator": true,
        "buildConfiguration": "Release"
      }
    }
  }
}
```

Build and install:
```bash
eas build -p ios --profile simulator
eas build:run -p ios --latest
```

### Fastlane & Gymfile

EAS Build utilizes Fastlane Gym for iOS compilation. If no custom Gymfile exists in the `ios` directory, a default configuration is generated automatically with settings for:
- Build scheme and output directory
- Export options with app-store provisioning
- Keychain integration for code signing

### Credential Management

Credentials come from either:
- Local `credentials.json` files
- Remote EAS servers

Determined by the `credentialsSource` setting in eas.json:

```json
{
  "build": {
    "production": {
      "ios": {
        "credentialsSource": "remote"
      }
    }
  }
}
```

Options: `"remote"` (default), `"local"`

## Android-Specific Configuration

### Android Build Settings

**Common Android Options:**
```json
{
  "build": {
    "production": {
      "android": {
        "buildType": "aab",
        "gradleCommand": ":app:bundleRelease",
        "resourceClass": "large",
        "autoIncrement": "versionCode",
        "image": "latest"
      }
    }
  }
}
```

**Key Android Settings:**
- `buildType`: Output format (aab/apk)
- `gradleCommand`: Custom Gradle command to execute
- `autoIncrement`: Auto-increment version or version code
- `image`: Build image version (affects Android SDK, NDK versions)

### Build Type: APK vs AAB

**APK (Android Package)**
- Directly installable on devices
- Larger file size (contains all device configurations)
- Good for internal testing and distribution
- Not required by Google Play Store

```json
{
  "build": {
    "preview": {
      "android": {
        "buildType": "apk",
        "gradleCommand": ":app:assembleRelease"
      }
    }
  }
}
```

**AAB (Android App Bundle)**
- Required format for Google Play Store submissions
- Smaller download size for end users
- Google Play generates optimized APKs per device
- Cannot be directly installed on devices

```json
{
  "build": {
    "production": {
      "android": {
        "buildType": "aab",
        "gradleCommand": ":app:bundleRelease"
      }
    }
  }
}
```

### Keystore Management

Android requires certificate-based app signing. EAS Build manages this by:
- Storing keystores securely (never committing them to repositories)
- Creating an `eas-build.gradle` file that reads credentials from `credentials.json`
- Automatically configuring signing configs for release and debug builds

The auto-generated `eas-build.gradle` reads keystore paths, passwords, and key aliases from your credentials file during the build process.

## Best Practices

### 1. Use Profile Extension for Common Settings

Create a base profile with shared configuration:

```json
{
  "build": {
    "base": {
      "node": "20.11.0",
      "yarn": "1.22.19"
    },
    "development": {
      "extends": "base",
      "developmentClient": true
    },
    "preview": {
      "extends": "base",
      "distribution": "internal"
    },
    "production": {
      "extends": "base"
    }
  }
}
```

### 2. Separate Environment Variables by Profile

```json
{
  "build": {
    "development": {
      "env": {
        "ENVIRONMENT": "development",
        "API_URL": "http://localhost:3000"
      }
    },
    "production": {
      "env": {
        "ENVIRONMENT": "production",
        "API_URL": "https://api.production.com"
      }
    }
  }
}
```

### 3. Use Appropriate Resource Classes

- Use `medium` for development and preview builds
- Use `large` for production builds to speed up release cycles

### 4. Platform-Specific Optimization

```json
{
  "build": {
    "production": {
      "android": {
        "buildType": "aab",
        "resourceClass": "large"
      },
      "ios": {
        "resourceClass": "large",
        "autoIncrement": "buildNumber"
      }
    }
  }
}
```

### 5. Version Management

Use auto-increment for version management:

```json
{
  "build": {
    "production": {
      "autoIncrement": true,
      "android": {
        "autoIncrement": "versionCode"
      },
      "ios": {
        "autoIncrement": "buildNumber"
      }
    }
  }
}
```

### 6. Testing Before Production

Always test with preview builds before production:

```bash
# Build preview
eas build --platform all --profile preview

# Test thoroughly

# Build production
eas build --platform all --profile production
```

## Common Profile Configurations

### Complete Development Setup

```json
{
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "ios": {
        "simulator": true,
        "resourceClass": "medium"
      },
      "android": {
        "buildType": "apk",
        "gradleCommand": ":app:assembleDebug"
      },
      "env": {
        "ENVIRONMENT": "development"
      }
    }
  }
}
```

### Complete Preview Setup

```json
{
  "build": {
    "preview": {
      "distribution": "internal",
      "ios": {
        "resourceClass": "medium"
      },
      "android": {
        "buildType": "apk",
        "resourceClass": "medium"
      },
      "env": {
        "ENVIRONMENT": "staging"
      }
    }
  }
}
```

### Complete Production Setup

```json
{
  "build": {
    "production": {
      "ios": {
        "resourceClass": "large",
        "autoIncrement": "buildNumber"
      },
      "android": {
        "buildType": "aab",
        "resourceClass": "large",
        "autoIncrement": "versionCode"
      },
      "env": {
        "ENVIRONMENT": "production"
      }
    }
  }
}
```

## Troubleshooting

### Build Fails with Version Conflicts

**Solution:** Specify exact tool versions in your profile:

```json
{
  "build": {
    "production": {
      "node": "20.11.0",
      "yarn": "1.22.19"
    }
  }
}
```

### iOS Build Fails to Sign

**Solution:** Check credential source and ensure certificates are valid:

```json
{
  "build": {
    "production": {
      "ios": {
        "credentialsSource": "remote"
      }
    }
  }
}
```

Regenerate credentials if needed:
```bash
eas credentials
```

### Android Build Size Too Large

**Solution:** Use AAB format for production:

```json
{
  "build": {
    "production": {
      "android": {
        "buildType": "aab"
      }
    }
  }
}
```

### Slow Build Times

**Solution:** Upgrade to large resource class:

```json
{
  "build": {
    "production": {
      "resourceClass": "large"
    }
  }
}
```

## Additional Resources

- [Official EAS Build Documentation](https://docs.expo.dev/build/introduction/)
- [eas.json Schema Reference](https://docs.expo.dev/build/eas-json/)
- [iOS Build Configuration](https://docs.expo.dev/build-reference/ios-builds/)
- [Android Build Configuration](https://docs.expo.dev/build-reference/android-builds/)
