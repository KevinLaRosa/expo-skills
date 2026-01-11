#!/bin/bash

# Install Expo Skills for AI Agents (Claude Code, Cursor, OpenCode, Codex, etc.)
# Creates symlinks in ~/.claude/skills/, ~/.cursor/skills/, and ~/.config/opencode/skill/
# for all skills in this repository

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
OPENCODE_SKILLS_DIR="$HOME/.config/opencode/skill"

# Parse command line arguments
AGENT="all"
if [ $# -gt 0 ]; then
    AGENT="$1"
fi

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}Expo Skills Installer for AI Agents${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# If no argument provided, show interactive menu
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}Select installation target:${NC}"
    echo ""
    echo "  1) All agents (Claude Code, Cursor, OpenCode)"
    echo "  2) Claude Code only"
    echo "  3) Cursor only"
    echo "  4) OpenCode only"
    echo "  5) Custom selection"
    echo ""
    read -p "Enter your choice (1-5): " choice
    echo ""

    case "$choice" in
        1)
            AGENT="all"
            ;;
        2)
            AGENT="claude"
            ;;
        3)
            AGENT="cursor"
            ;;
        4)
            AGENT="opencode"
            ;;
        5)
            echo -e "${YELLOW}Select agents to install (space-separated):${NC}"
            echo "  Options: claude cursor opencode"
            echo ""
            read -p "Enter agents: " -a selected_agents
            AGENT="custom"
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting.${NC}"
            exit 1
            ;;
    esac
fi


# Function to install skills for a specific agent
install_for_agent() {
    local skills_dir="$1"
    local agent_name="$2"

    echo -e "${BLUE}Installing for $agent_name${NC}"
    echo -e "${BLUE}Target directory:${NC} $skills_dir"
    echo ""

    # Create directory if it doesn't exist
    if [ ! -d "$skills_dir" ]; then
        echo -e "${YELLOW}Creating $skills_dir directory...${NC}"
        mkdir -p "$skills_dir"
        echo -e "${GREEN}✓ Directory created${NC}"
        echo ""
    fi

    # Counter for statistics
    local created=0
    local skipped=0
    local updated=0

    # Find all directories with SKILL.md (excluding template)
    while IFS= read -r skill_dir; do
        skill_name=$(basename "$skill_dir")

        # Skip template directory
        if [ "$skill_name" == "template" ]; then
            continue
        fi

        symlink_path="$skills_dir/$skill_name"

        # Check if symlink already exists
        if [ -L "$symlink_path" ]; then
            # Check if it points to the correct location
            current_target=$(readlink "$symlink_path")
            if [ "$current_target" == "$skill_dir" ]; then
                echo -e "${GREEN}✓${NC} $skill_name (already installed)"
                ((skipped++))
            else
                # Update symlink to point to correct location
                rm "$symlink_path"
                ln -s "$skill_dir" "$symlink_path"
                echo -e "${YELLOW}↻${NC} $skill_name (updated symlink)"
                ((updated++))
            fi
        elif [ -e "$symlink_path" ]; then
            # Path exists but is not a symlink
            echo -e "${RED}✗${NC} $skill_name (path exists but is not a symlink - skipping)"
            ((skipped++))
        else
            # Create new symlink
            ln -s "$skill_dir" "$symlink_path"
            echo -e "${GREEN}+${NC} $skill_name (installed)"
            ((created++))
        fi
    done < <(find "$REPO_DIR" -maxdepth 2 -name "SKILL.md" -exec dirname {} \;)

    echo ""
    echo "Statistics for $agent_name:"
    echo -e "  ${GREEN}Created:${NC}  $created"
    echo -e "  ${YELLOW}Updated:${NC}  $updated"
    echo -e "  ${BLUE}Skipped:${NC}  $skipped"
    echo -e "  ${GREEN}Total:${NC}    $((created + updated + skipped))"
    echo ""
}

# Install based on user selection
case "$AGENT" in
    claude)
        install_for_agent "$CLAUDE_SKILLS_DIR" "Claude Code"
        ;;
    cursor)
        install_for_agent "$CURSOR_SKILLS_DIR" "Cursor"
        ;;
    opencode)
        install_for_agent "$OPENCODE_SKILLS_DIR" "OpenCode"
        ;;
    custom)
        first=true
        for agent in "${selected_agents[@]}"; do
            if [ "$first" = false ]; then
                echo -e "${BLUE}------------------------------------------------${NC}"
                echo ""
            fi
            first=false

            case "$agent" in
                claude)
                    install_for_agent "$CLAUDE_SKILLS_DIR" "Claude Code"
                    ;;
                cursor)
                    install_for_agent "$CURSOR_SKILLS_DIR" "Cursor"
                    ;;
                opencode)
                    install_for_agent "$OPENCODE_SKILLS_DIR" "OpenCode"
                    ;;
                *)
                    echo -e "${RED}Unknown agent: $agent (skipping)${NC}"
                    ;;
            esac
        done
        ;;
    all|*)
        install_for_agent "$CLAUDE_SKILLS_DIR" "Claude Code"
        echo -e "${BLUE}------------------------------------------------${NC}"
        echo ""
        install_for_agent "$CURSOR_SKILLS_DIR" "Cursor"
        echo -e "${BLUE}------------------------------------------------${NC}"
        echo ""
        install_for_agent "$OPENCODE_SKILLS_DIR" "OpenCode"
        ;;
esac

echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""
echo -e "${GREEN}✓ All skills are now available to your AI agents!${NC}"
echo ""
echo "To verify installation:"
if [ "$AGENT" == "claude" ]; then
    echo "  ls -la $CLAUDE_SKILLS_DIR"
elif [ "$AGENT" == "cursor" ]; then
    echo "  ls -la $CURSOR_SKILLS_DIR"
elif [ "$AGENT" == "opencode" ]; then
    echo "  ls -la $OPENCODE_SKILLS_DIR"
else
    echo "  ls -la $CLAUDE_SKILLS_DIR"
    echo "  ls -la $CURSOR_SKILLS_DIR"
    echo "  ls -la $OPENCODE_SKILLS_DIR"
fi
echo ""
echo "Usage:"
echo "  ./scripts/install-skills.sh          # Install for all agents"
echo "  ./scripts/install-skills.sh claude   # Install for Claude Code only"
echo "  ./scripts/install-skills.sh cursor   # Install for Cursor only"
echo "  ./scripts/install-skills.sh opencode # Install for OpenCode only"
echo ""
