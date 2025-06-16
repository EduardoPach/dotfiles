#!/bin/bash

# uninstall_commands.sh - Remove globally installed dotfiles commands
# This script removes the symlinks created by install_commands.sh

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Dotfiles Commands Uninstallation ===${NC}"
echo "Removing globally installed dotfiles commands..."
echo ""

# Function to remove symlink
remove_symlink() {
    local target="$1"
    local command_name="$2"
    
    if [ -L "$target" ] || [ -f "$target" ]; then
        echo -e "Removing $command_name command..."
        sudo rm -f "$target"
        echo -e "${GREEN}✓ $command_name removed${NC}"
    else
        echo -e "✓ $command_name was not installed"
    fi
}

# Remove symlinks
remove_symlink "/usr/local/bin/dotfiles-pull" "dotfiles-pull"
remove_symlink "/usr/local/bin/dotfiles-push" "dotfiles-push"
remove_symlink "/usr/local/bin/dotfiles-setup" "dotfiles-setup"

echo ""
echo -e "${GREEN}=== Uninstallation Complete! ===${NC}"
echo "Global dotfiles commands have been removed."
echo "You can still run the scripts directly from the utilities directory." 