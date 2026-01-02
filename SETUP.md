# Quick Setup Guide

Fast track to get Expo Skills up and running.

## Installation

### Option 1: Clone and Install Git Hook

```bash
cd /Users/Roger/Developer/skills

# Install git hook (auto-generates skills.json on commit)
ln -sf ../../scripts/git-hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit

# Generate initial skills index
python3 scripts/build_docs_index.py
```

### Option 2: Use Individual Skills

Copy specific skills to your Expo project:

```bash
# Example: Copy logger setup
cp -r expo-logger-setup/templates/* your-expo-app/src/utils/logger/
```

## Browse Skills

Open the web interface to explore all skills:

```bash
# Serve locally
python3 -m http.server 8000 --directory .

# Open in browser
open http://localhost:8000/docs/index.html
```

Or directly open `docs/index.html` in your browser.

## Using a Skill

Each skill folder contains:
- **SKILL.md** - Complete workflow and instructions
- **scripts/** - Automation scripts (if applicable)
- **references/** - Detailed documentation
- **templates/** - Code templates to copy (if applicable)

Example workflow:

```bash
# 1. Read the skill
cat expo-logger-setup/SKILL.md

# 2. Copy templates to your project
cp expo-logger-setup/templates/* ~/your-app/src/utils/logger/

# 3. Follow the workflow steps in SKILL.md
```

## Available Skills

Currently implemented:
- **expo-logger-setup** - Structured logging with categories and emojis

Coming soon:
- **uniwind-styling** - Tailwind CSS with Uniwind
- **expo-build-debugger** - EAS Build and debugging
- **expo-performance-audit** - Performance profiling
- **reanimated-performance** - 60fps animations
- **skia-animations** - Skia-based animations
- **expo-sentry-integration** - Error monitoring
- **expo-changelog-generator** - Release notes automation
- **expo-typescript-fixer** - TypeScript quality
- **expo-native-modules** - Native modules and widgets

## Creating New Skills

Use the template to create your own:

```bash
# 1. Copy template
cp -r template new-skill-name

# 2. Edit SKILL.md with frontmatter
cat > new-skill-name/SKILL.md << 'EOF'
---
name: new-skill-name
description: What this skill does
---

# New Skill Name

## Overview
...
EOF

# 3. Regenerate index
python3 scripts/build_docs_index.py
```

## Development Workflow

```bash
# 1. Create or edit a skill
vim expo-logger-setup/SKILL.md

# 2. Add references (optional)
vim expo-logger-setup/references/new-reference.md

# 3. Regenerate index
python3 scripts/build_docs_index.py

# 4. Preview in browser
open docs/index.html

# 5. Commit (auto-updates skills.json via git hook)
git add .
git commit -m "Add new skill"
```

## Troubleshooting

### Git hook not working

```bash
# Check if hook is executable
ls -la .git/hooks/pre-commit

# Make it executable
chmod +x .git/hooks/pre-commit

# Verify symlink
ls -la .git/hooks/pre-commit
# Should show: .git/hooks/pre-commit -> ../../scripts/git-hooks/pre-commit
```

### skills.json not updating

```bash
# Manually run the build script
python3 scripts/build_docs_index.py

# Check if docs directory exists
ls -la docs/
```

### Web interface not loading skills

```bash
# Verify skills.json exists and is valid
cat docs/skills.json | python3 -m json.tool

# Check browser console for errors
# Open docs/index.html and press F12
```

## Next Steps

1. **Browse skills**: Open `docs/index.html` to explore available skills
2. **Try expo-logger-setup**: Copy the logger to a test project
3. **Create custom skills**: Use the template to build your own
4. **Contribute**: Share useful skills back to the community

## Resources

- [Main README](README.md) - Full documentation
- [Template](template/SKILL.md) - Skill template
- [Plan](../../../.claude/plans/concurrent-percolating-crown.md) - Original implementation plan
