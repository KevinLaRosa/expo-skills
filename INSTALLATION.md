# Installation Guide

Complete guide to installing and using Expo Skills with any AI agent.

## Quick Start

**Clone the repository:**

```bash
git clone https://github.com/KevinLaRosa/expo-skills.git
cd expo-skills
```

## Installation Methods

### Method 1: For Claude Code (Recommended)

Install skills so Claude can automatically discover and use them:

```bash
# From the repo directory
cd ~/path/to/expo-skills  # Or wherever you cloned it

# Create symlink to Claude Code's skills directory
ln -s $(pwd) ~/.claude/skills/expo-skills

# Verify installation
ls -la ~/.claude/skills/
# Should show: expo-skills -> /your/path/to/expo-skills
```

**Test it:**
```bash
# Start Claude Code
claude

# Skills are now available automatically!
# Claude will reference them when you ask about Expo/React Native tasks
```

### Method 2: For OpenAI Codex / Cursor / Other AI Agents

Most AI agents that support agentskills.io will auto-discover skills in standard locations:

```bash
# Navigate to repo
cd ~/path/to/expo-skills

# Option A: Create symlink in standard location
ln -s $(pwd) ~/.agent-skills/expo-skills

# Option B: Set environment variable (if agent supports it)
export AGENT_SKILLS_PATH="$(pwd)"
```

**For Cursor:**
```bash
# Cursor may look in .cursor directory
mkdir -p ~/.cursor/skills
ln -s $(pwd) ~/.cursor/skills/expo-skills
```

### Method 3: Direct Usage (No Symlink)

Use skills directly without installing to agent directories:

```bash
# Clone repository
git clone https://github.com/KevinLaRosa/expo-skills.git
cd expo-skills

# Open web interface to browse
open docs/index.html

# Read a skill
cat expo-logger-setup/SKILL.md

# Copy templates to your project
cp expo-logger-setup/templates/* /path/to/your/project/src/utils/logger/
```

## Verify Installation

### Check Skill Count

```bash
# Navigate to repo
cd ~/path/to/expo-skills

# Count skills
ls */SKILL.md | wc -l
# Should show: 23
```

### List All Skills

```bash
cd ~/path/to/expo-skills
ls -d */ | grep -E "^expo-|^nitro-|^skill-|^unistyles|^uniwind|^reanimated|^skia|^swift-|^kotlin-|^apple-|^better-|^revenuecat"
```

Expected output (23 skills):
```
apple-docs-search/
better-auth-expo/
expo-apple-targets/
expo-build-debugger/
expo-changelog-generator/
expo-fast-image/
expo-logger-setup/
expo-native-modules/
expo-performance-audit/
expo-sentry-integration/
expo-sqlite/
expo-typescript-fixer/
kotlin-modules/
nitro-fetch/
nitro-modules/
reanimated-performance/
revenuecat-expo/
skia-animations/
skill-creator/
swift-debugging/
swift-widgets/
unistyles-styling/
uniwind-styling/
```

## Browse Skills

### Web Interface

```bash
cd ~/path/to/expo-skills
open docs/index.html
```

This opens an interactive web interface to explore all skills.

### Command Line

```bash
# View a skill
cd ~/path/to/expo-skills
cat better-auth-expo/SKILL.md

# Search for specific skills
ls */SKILL.md | grep auth
```

## Using Skills in Projects

### Copy Templates

```bash
# Example: Add logger to your Expo project
cd /path/to/your/expo/project
cp ~/path/to/expo-skills/expo-logger-setup/templates/* ./src/utils/logger/
```

### Run Scripts

```bash
# Example: Run EAS build script
~/path/to/expo-skills/expo-build-debugger/scripts/build.sh --profile preview
```

### Reference Documentation

```bash
# Read references
cat ~/path/to/expo-skills/swift-widgets/references/axiom-swiftui-performance.md
```

## Platform-Specific Notes

### macOS

```bash
# Use 'open' to view files
open ~/path/to/expo-skills/docs/index.html
```

### Linux

```bash
# Use 'xdg-open' instead of 'open'
xdg-open ~/path/to/expo-skills/docs/index.html
```

### Windows (WSL)

```bash
# Navigate to repo in WSL
cd ~/path/to/expo-skills

# Use explorer.exe to open
explorer.exe docs/index.html
```

## Update Skills

Skills are updated via git:

```bash
cd ~/path/to/expo-skills
git pull origin main
```

Symlinks will automatically point to updated skills.

## Uninstall

### Remove Symlinks

```bash
# Remove Claude Code symlink
rm ~/.claude/skills/expo-skills

# Remove agent-skills symlink (if created)
rm ~/.agent-skills/expo-skills

# Remove Cursor symlink (if created)
rm ~/.cursor/skills/expo-skills
```

### Remove Repository

```bash
# Delete the cloned repository
rm -rf ~/path/to/expo-skills
```

## Troubleshooting

### "Skills not found" in Claude Code

**Check symlink exists:**
```bash
ls -la ~/.claude/skills/
```

**Should show:**
```
expo-skills -> /your/path/to/expo-skills
```

**If not, recreate:**
```bash
cd ~/path/to/expo-skills
ln -s $(pwd) ~/.claude/skills/expo-skills
```

### Broken symlink after moving repository

If you moved the repository, update the symlink:

```bash
# Remove old symlink
rm ~/.claude/skills/expo-skills

# Create new one from new location
cd ~/new/path/to/expo-skills
ln -s $(pwd) ~/.claude/skills/expo-skills
```

### Skills not loading

1. Verify symlink points to correct location
2. Ensure repository contains SKILL.md files
3. Restart AI agent (Claude Code, etc.)

## Next Steps

After installation:

1. **Browse skills**: `open ~/path/to/expo-skills/docs/index.html`
2. **Start using**: Ask Claude Code about Expo tasks
3. **Copy templates**: Add templates to your projects
4. **Read docs**: Explore skill references for deep dives

## Support

- **Issues**: https://github.com/KevinLaRosa/expo-skills/issues
- **Docs**: https://agentskills.io/
- **Skills Format**: https://github.com/anthropics/skills
