# Installation Guide

Complete guide to installing and using Expo Skills with any AI agent.

## Quick Start

**Skills are already on your machine!**

```bash
📂 Location: /Users/Roger/Developer/skills
🌐 GitHub: https://github.com/KevinLaRosa/expo-skills
📊 Total: 17 skills
```

## Installation Methods

### Method 1: For Claude Code (Recommended)

Install skills so Claude can automatically discover and use them:

```bash
# Create symlink to Claude Code's skills directory
ln -s /Users/Roger/Developer/skills ~/.claude/skills/expo-skills

# Verify installation
ls -la ~/.claude/skills/
# Should show: expo-skills -> /Users/Roger/Developer/skills
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
# Option A: Create symlink in standard location
ln -s /Users/Roger/Developer/skills ~/.agent-skills/expo-skills

# Option B: Set environment variable (if agent supports it)
export AGENT_SKILLS_PATH="/Users/Roger/Developer/skills"
```

**For Cursor:**
```bash
# Cursor looks in project .cursor/skills/
cd ~/FreqWatch
mkdir -p .cursor/skills
ln -s /Users/Roger/Developer/skills .cursor/skills/expo-skills
```

### Method 3: Direct Project Usage

Copy specific skills directly into your project:

```bash
# Navigate to your Expo project
cd ~/FreqWatch

# Create skills directory
mkdir -p skills

# Copy skills you need
cp -r ~/Developer/skills/expo-logger-setup skills/
cp -r ~/Developer/skills/uniwind-styling skills/
cp -r ~/Developer/skills/expo-sqlite skills/

# Now skills are documented in your project
cat skills/expo-logger-setup/SKILL.md
```

### Method 4: Clone from GitHub

If you're on a different machine:

```bash
# Clone repository
git clone https://github.com/KevinLaRosa/expo-skills.git

# Navigate to repo
cd expo-skills

# Create symlink for Claude Code
ln -s $(pwd) ~/.claude/skills/expo-skills

# Or for other agents
ln -s $(pwd) ~/.agent-skills/expo-skills
```

## Browsing Skills

### Web Interface

Open the web interface to explore all skills:

```bash
# Open in browser
open /Users/Roger/Developer/skills/docs/index.html
```

Features:
- Search skills by name
- Filter by category
- View descriptions
- Dark/light theme

### Command Line

```bash
# List all skills
ls /Users/Roger/Developer/skills/*/SKILL.md

# Read a specific skill
cat ~/Developer/skills/expo-logger-setup/SKILL.md

# Search skills by keyword
grep -r "SQLite" ~/Developer/skills/*/SKILL.md

# Count total skills
ls -d ~/Developer/skills/*/ | grep -v -E "(docs|scripts|template)" | wc -l
```

## Using Skills

### With AI Agents

Once installed, AI agents automatically use skills when relevant:

**Example conversation with Claude:**
```
You: "Help me setup logging in my Expo app"
Claude: [Uses expo-logger-setup skill automatically]
        "I'll help you setup structured logging using the logger
         from FreqWatch. Let me create the logger files..."
```

**Manual invocation (if supported):**
```
You: "Use the nitro-modules skill to create a fast image processor"
```

### Manually Following Skills

Even without AI agents, skills are excellent documentation:

```bash
# 1. Read the skill
cat ~/Developer/skills/expo-sqlite/SKILL.md

# 2. Follow the workflow step-by-step
# (Skills have numbered workflows)

# 3. Copy templates if available
cp ~/Developer/skills/expo-logger-setup/templates/* ./src/utils/logger/

# 4. Run automation scripts
~/Developer/skills/expo-build-debugger/scripts/build.sh --profile preview
```

## Verifying Installation

### Check Claude Code Integration

```bash
# Check if symlink exists
ls -la ~/.claude/skills/ | grep expo-skills

# Should output:
# expo-skills -> /Users/Roger/Developer/skills
```

### Check Skills are Accessible

```bash
# Verify all 17 skills are present
ls /Users/Roger/Developer/skills/ | grep -E "^expo-|^nitro-|^skill-|^unistyles|^uniwind|^reanimated|^skia"

# Should list:
# expo-apple-targets
# expo-build-debugger
# expo-changelog-generator
# expo-fast-image
# expo-logger-setup
# expo-native-modules
# expo-performance-audit
# expo-sentry-integration
# expo-sqlite
# expo-typescript-fixer
# nitro-fetch
# nitro-modules
# reanimated-performance
# skia-animations
# skill-creator
# unistyles-styling
# uniwind-styling
```

### Test Web Interface

```bash
# Open web interface
open ~/Developer/skills/docs/index.html

# Should open browser showing all 17 skills
# Click on a skill to view details
```

## Updating Skills

Skills are version-controlled with Git:

```bash
# Navigate to skills directory
cd /Users/Roger/Developer/skills

# Check for updates
git status
git log

# Pull latest changes (if someone else updated)
git pull origin main

# View changes
git diff
```

## Creating New Skills

Use the `skill-creator` skill to create new skills:

```bash
# Read the skill-creator documentation
cat ~/Developer/skills/skill-creator/SKILL.md

# Copy template
cp -r ~/Developer/skills/template ~/Developer/skills/my-new-skill

# Edit SKILL.md
vim ~/Developer/skills/my-new-skill/SKILL.md

# Follow agentskills.io format (see skill-creator for details)
```

## Troubleshooting

### Skills not detected by Claude Code

**Problem**: Claude doesn't reference skills

**Solution**:
```bash
# 1. Check symlink exists
ls -la ~/.claude/skills/ | grep expo-skills

# 2. Recreate symlink if needed
rm ~/.claude/skills/expo-skills
ln -s /Users/Roger/Developer/skills ~/.claude/skills/expo-skills

# 3. Restart Claude Code
```

### Web interface not opening

**Problem**: `open docs/index.html` doesn't work

**Solution**:
```bash
# Use full path
open /Users/Roger/Developer/skills/docs/index.html

# Or navigate in browser manually
# file:///Users/Roger/Developer/skills/docs/index.html
```

### Skills out of sync with GitHub

**Problem**: Local changes not on GitHub

**Solution**:
```bash
cd /Users/Roger/Developer/skills
git status                    # Check what changed
git add .                     # Stage changes
git commit -m "Update skills" # Commit
git push origin main          # Push to GitHub
```

## Platform-Specific Notes

### macOS (Current System)
- ✅ All features supported
- ✅ Symlinks work natively
- ✅ `open` command opens files in default apps

### Linux
- ✅ Symlinks work natively
- ⚠️ Use `xdg-open` instead of `open`
- ⚠️ Paths may differ: `~/.local/share/claude/skills/`

### Windows
- ⚠️ Symlinks require admin privileges or Developer Mode
- ⚠️ Use Git Bash or WSL for best experience
- ⚠️ Paths: `%USERPROFILE%\.claude\skills\`

## Additional Resources

- **GitHub Repository**: https://github.com/KevinLaRosa/expo-skills
- **agentskills.io Standard**: https://agentskills.io/
- **Claude Code Documentation**: https://claude.com/claude-code
- **OpenAI Codex Documentation**: https://developers.openai.com/codex/skills/

## Support

For issues or questions:
- Check existing skills: `cat ~/Developer/skills/skill-creator/SKILL.md`
- Review documentation: `open ~/Developer/skills/docs/index.html`
- Check GitHub issues: https://github.com/KevinLaRosa/expo-skills/issues
