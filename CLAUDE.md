# Claude Instructions for Expo Skills Repository

## Repository Purpose

This is a **skills library for Expo/React Native development**. Each skill is a self-contained workflow guide that Claude can use to help developers with common tasks.

## How to Work with This Repository

### When Adding New Skills

1. **Copy the template**:
   ```bash
   cp -r template/ new-skill-name/
   ```

2. **Edit SKILL.md** with proper frontmatter:
   ```yaml
   ---
   name: skill-name
   description: Clear, concise description of what this skill does
   ---
   ```

3. **Regenerate index**:
   ```bash
   python3 scripts/build_docs_index.py
   ```

### When Updating Existing Skills

- Edit the SKILL.md file directly
- Add references in `references/` folder if needed
- Add scripts in `scripts/` folder if automation is helpful
- Regenerate index: `python3 scripts/build_docs_index.py`

### Structure Guidelines

Each skill MUST have:
- `SKILL.md` with YAML frontmatter
- Clear workflow with numbered steps
- Do's and Don'ts section
- Practical examples
- Resources section

Each skill MAY have:
- `scripts/` - Automation scripts (bash, python)
- `references/` - Detailed documentation
- `templates/` - Code templates to copy

## Important Notes

- **Never** include "by Claude" or similar attribution in commit messages
- **Always** regenerate `docs/skills.json` after adding/editing skills
- **Keep** skills focused and single-purpose
- **Test** all code examples and scripts before committing
- **Maintain** the phase structure (Phase 1-4) for organization

## Skill Categories

### Phase 1 - Core Development (Foundation)
Essential skills needed from day 1:
- Logging, styling, build & debug

### Phase 2 - Performance & Quality
Optimization after basic functionality works:
- Performance audits, animations, graphics

### Phase 3 - Production & Monitoring
Pre-deployment requirements:
- Monitoring, releases, type safety

### Phase 4 - Advanced
Complex native integrations:
- Native modules, widgets, custom notifications

## Attribution

This repository structure is inspired by:
- Dimillian/Skills (iOS development)
- Anthropic Skills Specification
- FreqWatch (logger implementation)

## Commit Message Format

Use conventional commits:
```
feat: add new skill for X
fix: correct typo in skill Y
docs: update README
chore: regenerate skills index
```

**Do NOT include**:
- "Generated with Claude"
- "Co-Authored-By: Claude"
- Any AI attribution

## Automation

- Git hook (`scripts/git-hooks/pre-commit`) auto-updates `docs/skills.json`
- Web interface at `docs/index.html` for browsing skills
- Build script (`scripts/build_docs_index.py`) for manual index generation
