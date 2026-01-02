# Expo Skills for Claude Code

A curated collection of specialized skills for Expo and React Native development, designed for use with [Claude Code](https://claude.com/claude-code).

## Overview

This repository provides production-ready skills that help Claude assist with common Expo/React Native development workflows, including:

- Building and debugging with EAS
- Performance optimization and profiling
- Native module integration (Swift/Kotlin)
- Release management and changelog generation
- Animation with Skia and Reanimated
- Styling with Uniwind/NativeWind
- Structured logging systems
- TypeScript quality improvements
- Sentry integration and monitoring

## Target Stack

These skills are optimized for modern Expo projects using:

- **Runtime**: Expo SDK 54+ with Expo Router
- **State**: Zustand + TanStack Query
- **Styling**: Uniwind (NativeWind v4) + Tailwind CSS
- **Animations**: Reanimated 4 + Skia + Liquid Glass
- **Native**: Swift modules, widgets, custom notifications
- **Monitoring**: Sentry
- **Storage**: MMKV + Secure Store
- **UI**: Victory Native (charts), Zeego (menus)

## Installation

### Using Claude Code

```bash
# Clone this repository
git clone https://github.com/[your-username]/expo-skills.git

# Install in Claude Code's skills directory
ln -s $(pwd)/expo-skills ~/.claude/skills/expo-skills

# Or copy specific skills to your project
```

### Browse Skills

Open `docs/index.html` in your browser to explore all available skills with their documentation and references.

## Available Skills

### Core Development
- **expo-logger-setup** - Structured logging system with categories and emojis
- **uniwind-styling** - Tailwind CSS styling with compile-time optimizations
- **expo-build-debugger** - EAS Build, simulator debugging, and profiling

### Performance & Quality
- **expo-performance-audit** - Bundle analysis, Flashlight profiling, optimization patterns
- **reanimated-performance** - 60fps animations with worklets and SharedValues
- **skia-animations** - High-performance Skia-based animations and charts

### Production & Monitoring
- **expo-sentry-integration** - Error tracking and performance monitoring
- **expo-changelog-generator** - Automated release notes from git history
- **expo-typescript-fixer** - TypeScript quality and strict mode migration

### Advanced
- **expo-native-modules** - Swift/Kotlin modules, widgets, custom notifications

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

- **Structure and tooling**: Adapted from [Dimillian/Skills](https://github.com/Dimillian/Skills)
- **Official format**: Based on [Anthropic Skills Specification](https://github.com/anthropics/skills)
- **Logger system**: Inspired by FreqWatch logging architecture
- **Performance patterns**: Based on React Native Performance and Debugging workshops
- **Uniwind docs**: Official Uniwind documentation for LLMs

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
