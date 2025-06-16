#!/bin/bash

# pull.sh - Copy configuration files from the system to this dotfiles repository
# This script will copy (not move) all configuration files from their system locations
# to the configuration directory in this repository, organized by tool/group name.

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$REPO_ROOT/configuration"

echo -e "${BLUE}=== Dotfiles Pull Script ===${NC}"
echo "Copying configuration files from system to repository..."
echo "Repository root: $REPO_ROOT"
echo "Configuration directory: $CONFIG_DIR"
echo ""

# Function to copy file with logging
copy_file() {
    local source="$1"
    local dest="$2"
    local dest_dir="$(dirname "$dest")"
    
    if [ -f "$source" ]; then
        echo -e "${YELLOW}Copying:${NC} $source -> $dest"
        mkdir -p "$dest_dir"
        cp "$source" "$dest"
        echo -e "${GREEN}✓ Success${NC}"
    else
        echo -e "${RED}✗ Source file not found:${NC} $source"
    fi
}

# Function to copy directory with logging
copy_directory() {
    local source="$1"
    local dest="$2"
    local dest_parent="$(dirname "$dest")"
    
    if [ -d "$source" ]; then
        echo -e "${YELLOW}Copying directory:${NC} $source -> $dest"
        mkdir -p "$dest_parent"
        cp -r "$source" "$dest"
        echo -e "${GREEN}✓ Success${NC}"
    else
        echo -e "${RED}✗ Source directory not found:${NC} $source"
    fi
}

echo -e "${BLUE}=== Nix Configuration ===${NC}"
copy_file "$HOME/.config/nix/flake.nix" "$CONFIG_DIR/nix/flake.nix"
copy_file "$HOME/.config/nix/flake.lock" "$CONFIG_DIR/nix/flake.lock"
echo ""

echo -e "${BLUE}=== Tmux Configuration ===${NC}"
copy_file "$HOME/.tmux.conf" "$CONFIG_DIR/tmux/.tmux.conf"
echo ""

echo -e "${BLUE}=== Zsh Configuration ===${NC}"
copy_file "$HOME/.zshrc" "$CONFIG_DIR/zsh/.zshrc"
copy_file "$HOME/.p10k.zsh" "$CONFIG_DIR/zsh/.p10k.zsh"
echo ""

echo -e "${BLUE}=== Kitty Configuration ===${NC}"
if [ -d "$HOME/.config/kitty" ]; then
    echo -e "${YELLOW}Copying directory:${NC} $HOME/.config/kitty -> $CONFIG_DIR/kitty"
    mkdir -p "$CONFIG_DIR"
    # Remove existing kitty directory if it exists to ensure clean copy
    rm -rf "$CONFIG_DIR/kitty"
    cp -r "$HOME/.config/kitty" "$CONFIG_DIR/kitty"
    echo -e "${GREEN}✓ Success${NC}"
else
    echo -e "${RED}✗ Source directory not found:${NC} $HOME/.config/kitty"
fi
echo ""

echo -e "${BLUE}=== Karabiner Configuration ===${NC}"
if [ -d "$HOME/.config/karabiner" ]; then
    echo -e "${YELLOW}Copying directory:${NC} $HOME/.config/karabiner -> $CONFIG_DIR/karabiner"
    mkdir -p "$CONFIG_DIR"
    # Remove existing karabiner directory if it exists to ensure clean copy
    rm -rf "$CONFIG_DIR/karabiner"
    cp -r "$HOME/.config/karabiner" "$CONFIG_DIR/karabiner"
    echo -e "${GREEN}✓ Success${NC}"
else
    echo -e "${RED}✗ Source directory not found:${NC} $HOME/.config/karabiner"
fi
echo ""

echo -e "${GREEN}=== Pull Complete ===${NC}"
echo "All configuration files have been copied to the repository."
echo "You can now review the changes and commit them if desired."
echo ""
echo "To see what was copied, run:"
echo "  git status"
echo "  git diff" 