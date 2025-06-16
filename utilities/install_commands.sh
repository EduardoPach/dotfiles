#!/bin/bash

# install_commands.sh - Install dotfiles commands globally
# This script creates symlinks for pull.sh and push.sh in /usr/local/bin
# so they can be run from anywhere as 'dotfiles-pull' and 'dotfiles-push'

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}=== Dotfiles Commands Installation ===${NC}"
echo "This script will install dotfiles commands globally."
echo "Commands will be available as:"
echo "  • dotfiles-pull  (pulls configs from system to repo)"
echo "  • dotfiles-push  (pushes configs from repo to system)"
echo "  • dotfiles-setup (complete machine setup)"
echo ""

# Check if scripts exist
if [ ! -f "$SCRIPT_DIR/pull.sh" ]; then
    echo -e "${RED}✗ pull.sh not found in utilities directory${NC}"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/push.sh" ]; then
    echo -e "${RED}✗ push.sh not found in utilities directory${NC}"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/setup.sh" ]; then
    echo -e "${RED}✗ setup.sh not found in utilities directory${NC}"
    exit 1
fi

# Check if /usr/local/bin exists and is in PATH
if [ ! -d "/usr/local/bin" ]; then
    echo -e "${RED}✗ /usr/local/bin directory does not exist${NC}"
    echo "Creating /usr/local/bin directory..."
    sudo mkdir -p /usr/local/bin
fi

if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
    echo -e "${YELLOW}⚠ Warning: /usr/local/bin is not in your PATH${NC}"
    echo "You may need to add it to your shell configuration."
    echo "Add this line to your ~/.zshrc or ~/.bashrc:"
    echo "  export PATH=\"/usr/local/bin:\$PATH\""
    echo ""
fi

# Function to create symlink
create_symlink() {
    local source="$1"
    local target="$2"
    local command_name="$3"
    
    if [ -L "$target" ] || [ -f "$target" ]; then
        echo -e "${YELLOW}Removing existing $command_name command...${NC}"
        sudo rm -f "$target"
    fi
    
    echo -e "${CYAN}Creating symlink:${NC} $target -> $source"
    sudo ln -s "$source" "$target"
    
    if [ -x "$target" ]; then
        echo -e "${GREEN}✓ $command_name command installed successfully${NC}"
    else
        echo -e "${RED}✗ Failed to install $command_name command${NC}"
        return 1
    fi
}

echo "Installing commands to /usr/local/bin..."
echo "This requires sudo privileges."
echo ""

# Create symlinks
create_symlink "$SCRIPT_DIR/pull.sh" "/usr/local/bin/dotfiles-pull" "dotfiles-pull"
create_symlink "$SCRIPT_DIR/push.sh" "/usr/local/bin/dotfiles-push" "dotfiles-push" 
create_symlink "$SCRIPT_DIR/setup.sh" "/usr/local/bin/dotfiles-setup" "dotfiles-setup"

echo ""
echo -e "${GREEN}=== Installation Complete! ===${NC}"
echo ""
echo -e "${CYAN}You can now run these commands from anywhere:${NC}"
echo "  • ${YELLOW}dotfiles-pull${NC}   - Pull configurations from system to repository"
echo "  • ${YELLOW}dotfiles-push${NC}   - Push configurations from repository to system"
echo "  • ${YELLOW}dotfiles-setup${NC}  - Complete machine setup (new machines only)"
echo ""
echo -e "${CYAN}Examples:${NC}"
echo "  dotfiles-pull                    # Interactive pull"
echo "  dotfiles-push                    # Interactive push with safety prompts"
echo "  ACCEPT_ALL=1 dotfiles-push       # Automated push without prompts"
echo ""

# Test the commands
echo -e "${BLUE}Testing commands...${NC}"
if command -v dotfiles-pull >/dev/null 2>&1; then
    echo -e "${GREEN}✓ dotfiles-pull is available${NC}"
else
    echo -e "${RED}✗ dotfiles-pull not found in PATH${NC}"
fi

if command -v dotfiles-push >/dev/null 2>&1; then
    echo -e "${GREEN}✓ dotfiles-push is available${NC}"
else
    echo -e "${RED}✗ dotfiles-push not found in PATH${NC}"
fi

if command -v dotfiles-setup >/dev/null 2>&1; then
    echo -e "${GREEN}✓ dotfiles-setup is available${NC}"
else
    echo -e "${RED}✗ dotfiles-setup not found in PATH${NC}"
fi 