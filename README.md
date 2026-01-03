# Expo Skills for AI Agents

A curated collection of specialized skills for Expo and React Native development, compatible with all AI agents that follow the [agentskills.io](https://agentskills.io/) open standard.

## Overview

This repository provides production-ready skills that help AI agents assist with common Expo/React Native development workflows, including:

- Building and debugging with EAS
- Performance optimization and profiling
- Native module integration (Swift/Kotlin)
- iOS widgets, notifications, and extensions
- Release management and changelog generation
- Animation with Skia and Reanimated
- Styling with Unistyles or Uniwind (with/without Tailwind)
- Structured logging systems
- TypeScript quality improvements
- Sentry integration and monitoring
- Creating new skills following agentskills.io standard

**Universal Compatibility**: These skills follow the [agentskills.io](https://agentskills.io/specification) open standard and work with:
- ✅ Claude Code (Anthropic)
- ✅ OpenAI Codex
- ✅ Cursor
- ✅ GitHub Copilot
- ✅ VS Code + Continue
- ✅ Any agent supporting agentskills.io format

## Technologies Covered

These skills support modern Expo/React Native development including:

- **Runtime**: Expo SDK 50+ (Expo Router, API Routes, custom dev clients)
- **Styling**: Uniwind (Tailwind CSS), Unistyles (no Tailwind), StyleSheet
- **Animations**: Reanimated 3/4, Skia for graphics and charts
- **Performance**: Bundle optimization, Flashlight profiling, 60fps patterns
- **Native Modules**: Expo Modules API (Swift/Kotlin), Nitro Modules (high-performance)
- **iOS Native**: WidgetKit, SwiftUI, Xcode debugging, expo-apple-targets
- **Android Native**: Kotlin coroutines, Android Studio debugging
- **Authentication**: Better Auth (OAuth, anonymous, 2FA, magic links)
- **Monetization**: RevenueCat (in-app purchases, subscriptions)
- **Monitoring**: Sentry error tracking and performance monitoring
- **Data**: SQLite (expo-sqlite, nitro-sqlite), Drizzle ORM
- **Networking**: nitro-fetch (HTTP/2, HTTP/3, prefetching)
- **Images**: react-native-fast-image (efficient loading and caching)
- **Build & Deploy**: EAS Build, EAS Update, simulator debugging
- **TypeScript**: Strict mode migration, type safety, Zod validation

## Installation

### For AI Agents (Claude Code, Codex, etc.)

**Option 1: Use existing local repository (Recommended)**
```bash
# Navigate to where you cloned this repo
cd ~/path/to/expo-skills

# Create symlink to Claude Code's skills directory
ln -s $(pwd) ~/.claude/skills/expo-skills

# Verify installation
ls -la ~/.claude/skills/
```

**Option 2: Clone from GitHub**
```bash
# Clone repository
git clone https://github.com/KevinLaRosa/expo-skills.git

# Create symlink
cd expo-skills
ln -s $(pwd) ~/.claude/skills/expo-skills
```

**Option 3: Use directly in your Expo project**
```bash
# Copy specific skills to your project (from where you cloned the repo)
cp -r ~/path/to/expo-skills/expo-logger-setup ./skills/
cp -r ~/path/to/expo-skills/uniwind-styling ./skills/

# Reference in your project documentation
```

### Browse Skills Web Interface

```bash
# Open web interface to explore all skills (from repo directory)
cd ~/path/to/expo-skills
open docs/index.html

# Or if you know the path
open ~/path/to/expo-skills/docs/index.html
```

### Using Individual Skills

Each skill contains complete documentation:

```bash
# Read skill documentation
cat ~/path/to/expo-skills/expo-logger-setup/SKILL.md

# Copy templates to your project
cp ~/path/to/expo-skills/expo-logger-setup/templates/* ./src/utils/logger/

# Run automation scripts
~/path/to/expo-skills/expo-build-debugger/scripts/build.sh --profile preview
```

## Available Skills (23 Total)

### Core Development
- **expo-logger-setup** - Structured logging system with categories and emojis
- **unistyles-styling** - StyleSheet superset with themes, variants, breakpoints (no Tailwind)
- **uniwind-styling** - Tailwind CSS styling with compile-time optimizations
- **expo-build-debugger** - EAS Build, simulator debugging, and profiling
- **expo-sqlite** - Local SQLite database with expo-sqlite or ultra-fast nitro-sqlite

### Performance & Quality
- **expo-performance-audit** - Bundle analysis, Flashlight profiling, optimization patterns
- **expo-fast-image** - Fast image loading and caching (solves flickering, poor caching)
- **nitro-fetch** - Ultra-fast HTTP requests with HTTP/2, HTTP/3, prefetching (220ms faster TTI)
- **reanimated-performance** - 60fps animations with worklets and SharedValues
- **skia-animations** - High-performance Skia-based animations and charts

### Services & Integration
- **better-auth-expo** - Authentication with OAuth, anonymous auth, 2FA, and magic links
- **revenuecat-expo** - In-app purchases and subscriptions with remote paywall configuration

### Production & Monitoring
- **expo-sentry-integration** - Error tracking and performance monitoring
- **expo-changelog-generator** - Automated release notes from git history
- **expo-typescript-fixer** - TypeScript quality and strict mode migration

### Advanced
- **expo-apple-targets** - iOS widgets, notification extensions, WatchKit apps (using expo-apple-targets)
- **expo-native-modules** - Swift/Kotlin API bridges, native SDK integration (using Expo Modules API)
- **nitro-modules** - Ultra-fast native modules with Nitro (15-60x faster than Expo Modules)

### Native Platform Development
- **swift-widgets** - Build performant iOS widgets with SwiftUI and WidgetKit
- **swift-debugging** - Debug Swift code with Xcode, LLDB, and Instruments
- **kotlin-modules** - Build Android modules with Kotlin and coroutines
- **apple-docs-search** - Search Apple Developer docs in AI-readable format (sosumi.ai)

### Meta
- **skill-creator** - Create new skills following agentskills.io standard

## Quick Start

Each skill contains:
- **SKILL.md** - Complete workflow and guidelines
- **scripts/** - Automation scripts (bash/python)
- **references/** - Detailed documentation and best practices
- **templates/** - Reusable code templates (when applicable)

Example usage:
```bash
# Check skill documentation
cat expo-logger-setup/SKILL.md

# Run skill scripts
./expo-build-debugger/scripts/build.sh --profile preview

# Copy templates to your project
cp expo-logger-setup/templates/* ./src/utils/logger/
```

## Attribution

This project structure is inspired by [Dimillian/Skills](https://github.com/Dimillian/Skills), an excellent collection of iOS development skills by [@Dimillian](https://github.com/Dimillian).

We've adapted the architecture, git hooks, and documentation system for the Expo/React Native ecosystem.

## Acknowledgments

### Core Infrastructure
- **Repository structure**: Adapted from [Dimillian/Skills](https://github.com/Dimillian/Skills) by [@Dimillian](https://github.com/Dimillian)
- **Skills format**: [agentskills.io](https://agentskills.io/) open standard
- **Official specification**: [Anthropic Skills](https://github.com/anthropics/skills)
- **Best practices**: [Axiom](https://github.com/CharlesWiltgen/Axiom) by [@CharlesWiltgen](https://github.com/CharlesWiltgen)

### Skill Sources & Documentation

**Styling**:
- **Uniwind**: [Official Uniwind docs](https://docs.uniwind.dev/llms-full.txt)
- **Unistyles**: [Official Unistyles docs](https://www.unistyl.es/llms-full.txt)

**Performance**:
- **React Native Performance Workshop**: Performance patterns and optimization techniques
- **Flashlight**: Performance profiling tool

**Native Development**:
- **Expo Apple Targets**: [@EvanBacon](https://github.com/EvanBacon)'s [expo-apple-targets](https://github.com/EvanBacon/expo-apple-targets)
- **Expo Modules API**: [Official Expo documentation](https://docs.expo.dev/modules/)

**Margelo Libraries** (High-performance implementations):
- **Nitro Modules**: [react-native-nitro-modules](https://nitro.margelo.com/) by [@margelo](https://github.com/margelo)
- **Nitro SQLite**: [react-native-nitro-sqlite](https://github.com/margelo/react-native-nitro-sqlite)
- **Nitro Fetch**: [react-native-nitro-fetch](https://github.com/margelo/react-native-nitro-fetch)
- **Fast Image**: [react-native-fast-image](https://github.com/margelo/react-native-fast-image)

**Data & State**:
- **Expo SQLite**: [Official Expo SQLite](https://docs.expo.dev/versions/latest/sdk/sqlite/)
- **Drizzle ORM**: [Drizzle ORM](https://orm.drizzle.team/)

**Monitoring**:
- **Sentry**: [@mitsuhiko](https://github.com/mitsuhiko)'s [agent-stuff](https://github.com/mitsuhiko/agent-stuff)

**Logging**:
- **FreqWatch Logger**: Custom logger architecture from FreqWatch project

### Community & Tools
- **Claude Code**: [Anthropic Claude Code](https://claude.com/claude-code)
- **OpenAI Codex**: Skills compatibility
- **Expo Team**: Comprehensive SDK and tooling
- **React Native Community**: Open source libraries and patterns

## Contributing

Contributions are welcome! Each skill should follow the template format and include:
- Clear workflow steps
- Practical examples
- Do's and don'ts
- Reference documentation

See `template/SKILL.md` for the standard format.

## License

MIT License - See [LICENSE](LICENSE) file

Portions adapted from Dimillian/Skills (https://github.com/Dimillian/Skills)
Copyright (c) 2024 Thomas Ricouard

## Resources

- [Expo Documentation](https://docs.expo.dev/)
- [React Native Performance](https://reactnative.dev/docs/performance)
- [Uniwind Documentation](https://docs.uniwind.dev/)
- [EAS Build](https://docs.expo.dev/build/introduction/)
- [Reanimated](https://docs.swmansion.com/react-native-reanimated/)
- [Skia](https://shopify.github.io/react-native-skia/)
