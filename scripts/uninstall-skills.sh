#!/bin/bash

# Uninstall Expo Skills from AI Agents (Claude Code, Cursor, Codex, etc.)
# Removes symlinks from ~/.claude/skills/ and ~/.cursor/skills/ for all skills in this repository

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

# Target directories for AI agents
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
CURSOR_SKILLS_DIR="$HOME/.cursor/skills"

# Parse command line arguments
AGENT="all"
if [ $# -gt 0 ]; then
    AGENT="$1"
fi

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}Expo Skills Uninstaller for AI Agents${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Function to uninstall skills for a specific agent
uninstall_for_agent() {
    local skills_dir="$1"
    local agent_name="$2"

    echo -e "${BLUE}Uninstalling for $agent_name${NC}"
    echo -e "${BLUE}Target directory:${NC} $skills_dir"
    echo ""

    # Check if directory exists
    if [ ! -d "$skills_dir" ]; then
        echo -e "${YELLOW}No skills directory found at $skills_dir${NC}"
        echo ""
        return
    fi

    # Counter for statistics
    local removed=0
    local not_found=0

    # Find all directories with SKILL.md (excluding template)
    while IFS= read -r skill_dir; do
        skill_name=$(basename "$skill_dir")

        # Skip template directory
        if [ "$skill_name" == "template" ]; then
            continue
        fi

        symlink_path="$skills_dir/$skill_name"

        # Check if symlink exists
        if [ -L "$symlink_path" ]; then
            # Check if it points to our repo
            current_target=$(readlink "$symlink_path")
            if [[ "$current_target" == "$REPO_DIR"* ]]; then
                rm "$symlink_path"
                echo -e "${GREEN}✓${NC} $skill_name (removed)"
                ((removed++))
            else
                echo -e "${YELLOW}⊘${NC} $skill_name (symlink points elsewhere - skipping)"
                ((not_found++))
            fi
        else
            echo -e "${BLUE}⊘${NC} $skill_name (not installed)"
            ((not_found++))
        fi
    done < <(find "$REPO_DIR" -maxdepth 2 -name "SKILL.md" -exec dirname {} \;)

    echo ""
    echo "Statistics for $agent_name:"
    echo -e "  ${GREEN}Removed:${NC}    $removed"
    echo -e "  ${BLUE}Not found:${NC}  $not_found"
    echo ""
}

# Uninstall based on user selection
case "$AGENT" in
    claude)
        uninstall_for_agent "$CLAUDE_SKILLS_DIR" "Claude Code"
        ;;
    cursor)
        uninstall_for_agent "$CURSOR_SKILLS_DIR" "Cursor"
        ;;
    all|*)
        uninstall_for_agent "$CLAUDE_SKILLS_DIR" "Claude Code"
        echo -e "${BLUE}------------------------------------------------${NC}"
        echo ""
        uninstall_for_agent "$CURSOR_SKILLS_DIR" "Cursor"
        ;;
esac

echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}Uninstallation Complete!${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${GREEN}✓ Expo Skills have been uninstalled${NC}"
echo ""
echo "Usage:"
echo "  ./scripts/uninstall-skills.sh         # Uninstall from all agents"
echo "  ./scripts/uninstall-skills.sh claude  # Uninstall from Claude Code only"
echo "  ./scripts/uninstall-skills.sh cursor  # Uninstall from Cursor only"
echo ""
