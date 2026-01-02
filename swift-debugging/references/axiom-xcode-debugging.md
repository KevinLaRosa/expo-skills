# Xcode Debugging - Environment-First Diagnostics

> Source: [Axiom - Xcode Debugging](https://charleswiltgen.github.io/Axiom/skills/debugging/xcode-debugging)

## Overview
The Xcode Debugging skill focuses on environment-first diagnostics for resolving mysterious Xcode issues. The core principle states: **"80% of 'mysterious' Xcode issues are environment problems (stale Derived Data, stuck simulators, zombie processes), not code bugs."**

## When to Use This Skill

Apply this skill when encountering:
- BUILD FAILED with no clear error details
- Tests passing yesterday but failing today with no code changes
- Builds succeeding but executing old code
- Simulator unable to boot or stuck at splash screen
- "No such module" errors after SPM updates
- Intermittent build failures

## Red Flags Requiring Environment Investigation

- "It works on my machine but not CI"
- Tests passing previously, now failing
- Build succeeds yet old code executes
- Inconsistent success/failure patterns
- Unresponsive or stuck simulator
- Multiple zombie xcodebuild processes

## Environment-First Checklist

**Step 1: Detect zombie processes**
```bash
ps aux | grep -E "xcodebuild|Simulator" | grep -v grep
```

**Step 2: Terminate problematic processes**
```bash
killall xcodebuild 2>/dev/null
killall Simulator 2>/dev/null
```

**Step 3: Clean Derived Data**
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
```

**Step 4: Reset simulators (if needed)**
```bash
xcrun simctl shutdown all
xcrun simctl erase all
```

**Step 5: Clear SPM cache (for module errors)**
```bash
rm -rf ~/Library/Caches/org.swift.swiftpm
```

## Troubleshooting Guide by Symptom

| Symptom | Solution | Time Required |
|---------|----------|--------------|
| Stale builds, old code executing | Delete Derived Data | 2 minutes |
| "No such module" errors | Delete Derived Data + SPM cache | 3 minutes |
| Simulator unresponsive | simctl shutdown + reboot | 2 minutes |
| Zombie processes | killall command | 1 minute |
| Multiple issues | Full reset + reboot | 10 minutes |

## Time Cost Transparency

- **2-5 minutes:** Derived Data cleanup
- **5-10 minutes:** Full environment reset
- **30+ minutes:** Debugging code when actual issue is environmental

## Example Prompts for Claude

Users can ask Claude questions such as:
- "Build fails with BUILD FAILED but no error details. I haven't changed anything."
- "Tests passed yesterday, failing today with no code changes. What's happening?"
- "App builds but runs old code from before my changes."
- "Simulator says 'Unable to boot simulator'. How do I recover?"

## Related Resources

- `/axiom:fix-build` command for automated diagnosis
- `build-fixer` agent for autonomous build issue resolution
- `build-debugging` skill for dependency resolution
- `performance-profiling` skill for performance-specific issues
