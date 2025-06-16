#!/bin/bash

# push.sh - Copy configuration files from this dotfiles repository to the system
# This script will copy all configuration files from the repository to their
# system locations, with safety checks to prevent accidental overwrites.

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
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$REPO_ROOT/configuration"

# Check if ACCEPT_ALL flag is set
ACCEPT_ALL="${ACCEPT_ALL:-0}"

echo -e "${BLUE}=== Dotfiles Push Script ===${NC}"
echo "Copying configuration files from repository to system..."
echo "Repository root: $REPO_ROOT"
echo "Configuration directory: $CONFIG_DIR"
if [ "$ACCEPT_ALL" = "1" ]; then
    echo -e "${YELLOW}ACCEPT_ALL mode enabled - will overwrite without prompting${NC}"
fi
echo ""

# Function to prompt user for confirmation
prompt_user() {
    local message="$1"
    if [ "$ACCEPT_ALL" = "1" ]; then
        echo -e "${CYAN}Auto-accepting (ACCEPT_ALL=1):${NC} $message"
        return 0
    fi
    
    echo -e "${YELLOW}$message${NC}"
    echo -n "Continue? [y/N]: "
    read -r response
    case "$response" in
        [yY]|[yY][eE][sS])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Function to check if files are different
files_differ() {
    local source="$1"
    local dest="$2"
    
    if [ ! -f "$dest" ]; then
        return 0  # Destination doesn't exist, so they "differ"
    fi
    
    if [ ! -f "$source" ]; then
        return 1  # Source doesn't exist, can't differ
    fi
    
    # Use diff to check if files are different (suppress output)
    if diff -q "$source" "$dest" > /dev/null 2>&1; then
        return 1  # Files are the same
    else
        return 0  # Files are different
    fi
}

# Function to check if directories are different
directories_differ() {
    local source="$1"
    local dest="$2"
    
    if [ ! -d "$dest" ]; then
        return 0  # Destination doesn't exist, so they "differ"
    fi
    
    if [ ! -d "$source" ]; then
        return 1  # Source doesn't exist, can't differ
    fi
    
    # Use diff to check if directories are different (suppress output)
    if diff -rq "$source" "$dest" > /dev/null 2>&1; then
        return 1  # Directories are the same
    else
        return 0  # Directories are different
    fi
}

# Function to copy file with safety checks and logging
copy_file_safe() {
    local source="$1"
    local dest="$2"
    local dest_dir="$(dirname "$dest")"
    
    if [ ! -f "$source" ]; then
        echo -e "${RED}✗ Source file not found:${NC} $source"
        return 1
    fi
    
    # Check if files differ
    if files_differ "$source" "$dest"; then
        if [ -f "$dest" ]; then
            echo -e "${YELLOW}File exists and differs:${NC} $dest"
            echo -e "${CYAN}Showing differences:${NC}"
            diff -u "$dest" "$source" || true  # Show diff, don't fail if files differ
            echo ""
            if ! prompt_user "Overwrite $dest?"; then
                echo -e "${YELLOW}Skipping:${NC} $dest"
                return 0
            fi
        else
            echo -e "${YELLOW}Creating new file:${NC} $dest"
            if ! prompt_user "Create $dest?"; then
                echo -e "${YELLOW}Skipping:${NC} $dest"
                return 0
            fi
        fi
    else
        echo -e "${GREEN}Files are identical, skipping:${NC} $dest"
        return 0
    fi
    
    echo -e "${YELLOW}Copying:${NC} $source -> $dest"
    mkdir -p "$dest_dir"
    cp "$source" "$dest"
    echo -e "${GREEN}✓ Success${NC}"
}

# Function to copy directory with safety checks and logging
copy_directory_safe() {
    local source="$1"
    local dest="$2"
    local dest_parent="$(dirname "$dest")"
    
    if [ ! -d "$source" ]; then
        echo -e "${RED}✗ Source directory not found:${NC} $source"
        return 1
    fi
    
    # Check if directories differ
    if directories_differ "$source" "$dest"; then
        if [ -d "$dest" ]; then
            echo -e "${YELLOW}Directory exists and differs:${NC} $dest"
            echo -e "${CYAN}Showing directory differences:${NC}"
            diff -rq "$source" "$dest" || true  # Show diff, don't fail if directories differ
            echo ""
            if ! prompt_user "Overwrite directory $dest?"; then
                echo -e "${YELLOW}Skipping:${NC} $dest"
                return 0
            fi
        else
            echo -e "${YELLOW}Creating new directory:${NC} $dest"
            if ! prompt_user "Create directory $dest?"; then
                echo -e "${YELLOW}Skipping:${NC} $dest"
                return 0
            fi
        fi
    else
        echo -e "${GREEN}Directories are identical, skipping:${NC} $dest"
        return 0
    fi
    
    echo -e "${YELLOW}Copying directory:${NC} $source -> $dest"
    mkdir -p "$dest_parent"
    rm -rf "$dest"  # Remove existing to ensure clean copy
    cp -r "$source" "$dest"
    echo -e "${GREEN}✓ Success${NC}"
}

echo -e "${BLUE}=== Nix Configuration ===${NC}"
copy_file_safe "$CONFIG_DIR/nix/flake.nix" "$HOME/.config/nix/flake.nix"
copy_file_safe "$CONFIG_DIR/nix/flake.lock" "$HOME/.config/nix/flake.lock"
echo ""

echo -e "${BLUE}=== Tmux Configuration ===${NC}"
copy_file_safe "$CONFIG_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
echo ""

echo -e "${BLUE}=== Zsh Configuration ===${NC}"
copy_file_safe "$CONFIG_DIR/zsh/.zshrc" "$HOME/.zshrc"
copy_file_safe "$CONFIG_DIR/zsh/.p10k.zsh" "$HOME/.p10k.zsh"
echo ""

echo -e "${BLUE}=== Kitty Configuration ===${NC}"
copy_directory_safe "$CONFIG_DIR/kitty" "$HOME/.config/kitty"
echo ""

echo -e "${BLUE}=== Karabiner Configuration ===${NC}"
copy_directory_safe "$CONFIG_DIR/karabiner" "$HOME/.config/karabiner"
echo ""

echo -e "${GREEN}=== Push Complete ===${NC}"
echo "Configuration files have been pushed to the system."
echo ""
echo -e "${CYAN}Usage tips:${NC}"
echo "• To skip all prompts and accept all changes: ACCEPT_ALL=1 ./utilities/push.sh"
echo "• To see what changed before running: ./utilities/pull.sh && git diff"
echo "• Files that are identical are automatically skipped" 