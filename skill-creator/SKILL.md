---
name: skill-creator
description: Create new agent skills following the agentskills.io standard with proper structure, frontmatter, and best practices for Claude Code and OpenAI Codex
license: MIT
compatibility: "Requires: Text editor, git (optional), basic understanding of agent skills concepts"
---

# Skill Creator

## Overview

Create new agent skills that follow the [agentskills.io](https://agentskills.io/) open standard for maximum compatibility with Claude Code, OpenAI Codex, and other AI agent platforms.

## When to Use This Skill

- Creating a new skill for your skills repository
- Standardizing existing documentation as an agent skill
- Packaging domain expertise or workflows for AI agents
- Ensuring skills are compatible across multiple agent platforms
- Building reusable knowledge modules for your team

## Workflow

### Step 1: Understand the Standard

**Required Files:**
- `SKILL.md` - Main skill file with YAML frontmatter and Markdown instructions

**Optional Directories:**
- `scripts/` - Executable code (Python, Bash, JavaScript)
- `references/` - Additional documentation loaded on demand
- `assets/` - Static resources like templates and data files

**Progressive Disclosure:**
- Metadata (~100 tokens) - Loads at startup
- Full SKILL.md (<5000 tokens recommended) - Loads when activated
- Resource files - Load only when needed

### Step 2: Define Skill Metadata

Create `SKILL.md` with required frontmatter:

```markdown
---
name: my-skill-name
description: Clear description of what this skill does and when to use it (1-2 sentences, max 1024 chars)
license: MIT
compatibility: "Requires: List key dependencies, versions, tools here (max 500 chars)"
---

# My Skill Name

[Content here...]
```

**Frontmatter Rules:**

**name** (required):
- 1-64 characters
- Lowercase alphanumeric and hyphens only
- Cannot start/end with hyphens
- No consecutive hyphens
- Must match parent directory name

**description** (required):
- 1-1024 characters
- Explain what skill does AND when to use it
- Include keywords for agent discovery
- Focus on outcomes, not implementation

**license** (optional):
- Name of license (e.g., "MIT", "Apache-2.0")
- Or reference to bundled LICENSE file

**compatibility** (optional):
- Max 500 characters
- List system packages, tools, versions
- Environment requirements (network access, specific OS)
- Example: "Requires: Node.js 18+, Docker, internet access"

### Step 3: Structure the Skill Content

**Recommended Sections:**

```markdown
# Skill Name

## Overview
1-2 sentences explaining purpose and value

## When to Use This Skill
- Scenario 1 with specific error messages or conditions
- Scenario 2 with concrete use cases
- Scenario 3 with decision criteria

## Workflow

### Step 1: [Action Name]
Clear, actionable instructions
- Command to run: `command --flag`
- Parameters to provide
- Expected outcome

### Step 2: [Action Name]
Continue with steps...

## Guidelines

**Do:**
- Best practice 1
- Pattern 2
- Recommendation 3

**Don't:**
- Anti-pattern 1
- Common mistake 2
- What to avoid 3

## Examples

### Example 1: [Use Case]
\`\`\`typescript
// Practical code example
\`\`\`

## Resources
- [Reference Doc](references/detailed-guide.md)
- [External Link](https://example.com)

## Tools & Commands
- \`tool-name\` - Description
- \`command\` - What it does
```

**Best Practices from agentskills.io:**

1. **Error Message Indexing** - Reference specific errors that trigger this skill
   - Example: "When you see `MODULE_NOT_FOUND`..." → use this skill

2. **Decision Trees** - Include "when to use" decision criteria
   - Example: "Use this when X, but not when Y"

3. **Concrete Examples** - Show real-world scenarios, not just theory

4. **Progressive Detail** - Keep SKILL.md concise, put exhaustive docs in `references/`

5. **Action Commands** - Reference CLI shortcuts if available
   - Example: "Or run `/create-component` for quick setup"

### Step 4: Add Supporting Files (Optional)

**scripts/** - Automation and executables:
```bash
scripts/
├── setup.sh              # Installation/setup script
├── validate.py           # Validation script
└── generate.js           # Code generation
```

Mark scripts executable:
```bash
chmod +x scripts/*.sh
```

**references/** - Detailed documentation:
```bash
references/
├── api-reference.md      # Complete API docs
├── troubleshooting.md    # Common issues
├── best-practices.md     # In-depth patterns
└── examples.md           # Extended examples
```

**assets/** - Static resources:
```bash
assets/
├── templates/
│   ├── component.tsx     # Code templates
│   └── config.json       # Config templates
└── data/
    └── sample-data.json  # Test data
```

### Step 5: Optimize for Token Efficiency

**Keep SKILL.md Under 5000 Tokens:**
- Use concise language
- Move exhaustive details to `references/`
- Link to external docs instead of copying

**Example - Before (verbose):**
```markdown
## Step 1: Install the Package

First, you need to install the package using npm. Open your terminal
and navigate to your project directory. Then run the following command
to install the package and save it to your package.json file...
```

**Example - After (concise):**
```markdown
## Step 1: Install Package

\`\`\`bash
npm install package-name
\`\`\`
```

### Step 6: Test and Validate

**Validation Checklist:**

✅ **Frontmatter**
- [ ] `name` matches directory name
- [ ] `name` uses only lowercase, hyphens
- [ ] `description` is 1-1024 characters
- [ ] `description` explains WHAT and WHEN
- [ ] `compatibility` lists key requirements (if applicable)

✅ **Structure**
- [ ] SKILL.md has clear workflow steps
- [ ] Examples are practical and runnable
- [ ] Guidelines include do's and don'ts
- [ ] File is under 5000 tokens (use `wc -w`)

✅ **Files**
- [ ] Scripts are executable (`chmod +x`)
- [ ] References are linked from SKILL.md
- [ ] Assets are organized logically

### Step 7: Add to Repository

```bash
# Create skill directory
mkdir -p ~/skills/my-skill-name

# Create SKILL.md
vim ~/skills/my-skill-name/SKILL.md

# Add optional directories
mkdir -p ~/skills/my-skill-name/{scripts,references,assets}

# Make scripts executable
chmod +x ~/skills/my-skill-name/scripts/*.sh

# Test skill discovery
# (Depends on your agent platform)
```

## Guidelines

**Do:**
- Keep name short, descriptive, kebab-case
- Include keywords in description for discoverability
- Use progressive disclosure (light SKILL.md, detailed references/)
- Test skills with real use cases
- Version control your skills (git)
- Document compatibility requirements clearly
- Link to authoritative external docs instead of copying
- Use concrete examples over abstract explanations

**Don't:**
- Don't exceed 5000 tokens in SKILL.md
- Don't use uppercase or special chars in skill name
- Don't duplicate content between SKILL.md and references
- Don't forget to make scripts executable
- Don't copy entire external documentation (link instead)
- Don't make assumptions about user environment (document in compatibility)

## Examples

### Example 1: Minimal Skill

```markdown
---
name: hello-world
description: Print hello world message in multiple languages for testing agent skill execution
license: MIT
compatibility: "Requires: Bash shell"
---

# Hello World

## Overview
Test skill execution by printing hello world in different languages.

## Workflow

### Step 1: Choose Language

Run one of these commands:

\`\`\`bash
echo "Hello, World!"           # English
echo "Bonjour, le monde!"      # French
echo "¡Hola, Mundo!"            # Spanish
\`\`\`

## Resources
- [Hello World Collection](https://en.wikipedia.org/wiki/%22Hello,_World!%22_program)
```

### Example 2: Skill with Scripts

```
my-deployment-skill/
├── SKILL.md
├── scripts/
│   ├── deploy.sh             # Main deployment script
│   └── rollback.sh           # Rollback script
└── references/
    └── deployment-guide.md   # Detailed deployment docs
```

`SKILL.md`:
```markdown
---
name: my-deployment-skill
description: Deploy applications to production with automated rollback capability
license: MIT
compatibility: "Requires: Docker, kubectl, access to production cluster"
---

# My Deployment Skill

## Workflow

### Step 1: Deploy
\`\`\`bash
./scripts/deploy.sh --environment production --version 1.2.3
\`\`\`

### Step 2: Verify
Check deployment status...

### Step 3: Rollback (if needed)
\`\`\`bash
./scripts/rollback.sh --to-version 1.2.2
\`\`\`

## Resources
- [Complete Deployment Guide](references/deployment-guide.md)
```

### Example 3: Domain Expertise Skill

```markdown
---
name: legal-contract-review
description: Review legal contracts for common issues following standardized checklist for tech companies
license: MIT
compatibility: "Requires: Access to contract document, basic legal terminology knowledge"
---

# Legal Contract Review

## When to Use This Skill
- Reviewing SaaS vendor contracts
- Before signing customer agreements
- When you see: indemnification clauses, liability caps, data processing terms

## Workflow

### Step 1: Identify Contract Type
- SaaS Agreement
- MSA (Master Service Agreement)
- DPA (Data Processing Agreement)

### Step 2: Key Sections to Review
[Detailed checklist...]

### Step 3: Flag Issues
[Common red flags...]

## Resources
- [Contract Review Checklist](references/checklist.md)
- [Red Flags Guide](references/red-flags.md)
```

## Resources

- [Agent Skills Official Spec](https://agentskills.io/specification)
- [Agent Skills Home](https://agentskills.io/home)
- [Example Skills on GitHub](https://github.com/topics/agent-skills)
- [Anthropic Skills Format](https://github.com/anthropics/skills)

## Tools & Commands

- `wc -w SKILL.md` - Count words (tokens ≈ words × 1.3)
- `chmod +x scripts/*.sh` - Make scripts executable
- `git add skill-name/` - Version control your skill

## Troubleshooting

### Skill not discovered by agent

**Problem**: Agent doesn't see the new skill

**Solution**:
1. Check `name` matches directory name exactly
2. Verify YAML frontmatter is valid (no tabs, proper quotes)
3. Ensure SKILL.md is in root of skill directory
4. Restart agent or refresh skills index

### Name validation error

**Problem**: "Invalid skill name" error

**Solution**:
```bash
# ❌ Bad
My-Skill-Name    # Uppercase
my_skill_name    # Underscores
-my-skill        # Starts with hyphen
my--skill        # Consecutive hyphens

# ✅ Good
my-skill-name
data-analysis
deploy-app
```

### SKILL.md too large

**Problem**: Skill file exceeds recommended token limit

**Solution**:
1. Move detailed docs to `references/`
2. Link to external authoritative docs
3. Remove verbose explanations
4. Use concise examples
5. Check: `wc -w SKILL.md` (keep under ~4000 words)

---

## Notes

- Standard created by Anthropic, now openly maintained
- Compatible with: Claude Code, OpenAI Codex, Cursor, VS Code
- Skills are portable across agent platforms
- Progressive disclosure optimizes context usage
- Version control recommended (git) for team collaboration
