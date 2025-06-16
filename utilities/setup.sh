#!/bin/bash

# setup.sh - Complete machine setup script for dotfiles
# This script will set up a new machine by performing manual steps,
# pushing configurations, and running final setup commands.

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║                        Dotfiles Setup Script                        ║${NC}"
echo -e "${MAGENTA}║                   Complete Machine Setup Automation                 ║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Repository root: $REPO_ROOT"
echo "This script will set up your entire working environment."
echo ""

# Function to run command with logging
run_command() {
    local description="$1"
    local command="$2"
    local optional="${3:-false}"
    
    echo -e "${BLUE}=== $description ===${NC}"
    echo -e "${CYAN}Command:${NC} $command"
    echo ""
    
    if eval "$command"; then
        echo -e "${GREEN}✓ Success:${NC} $description"
        echo ""
        return 0
    else
        local exit_code=$?
        if [ "$optional" = "true" ]; then
            echo -e "${YELLOW}⚠ Warning:${NC} $description failed but continuing (optional step)"
            echo ""
            return 0
        else
            echo -e "${RED}✗ Failed:${NC} $description"
            echo "Command failed with exit code: $exit_code"
            echo "You may need to run this step manually later."
            echo ""
            return $exit_code
        fi
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to prompt user for continuation
prompt_continue() {
    local message="$1"
    echo -e "${YELLOW}$message${NC}"
    echo -n "Continue? [Y/n]: "
    read -r response
    case "$response" in
        [nN]|[nN][oO])
            echo "Setup cancelled by user."
            exit 0
            ;;
        *)
            return 0
            ;;
    esac
}

# Initial sudo check and privilege caching
echo -e "${BLUE}=== Checking Sudo Privileges ===${NC}"
echo "This script requires sudo privileges for some operations."
echo "You will be prompted for your password to cache sudo privileges."
echo ""

if ! sudo -v; then
    echo -e "${RED}✗ Failed to obtain sudo privileges${NC}"
    echo "Please ensure you have sudo access and try again."
    exit 1
fi

echo -e "${GREEN}✓ Sudo privileges obtained${NC}"
echo ""

# Keep sudo alive during the script
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

prompt_continue "Ready to begin setup process?"

echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║                           Phase 1: Manual Commands                  ║${NC}"
echo -e "${MAGENTA}║                      (Can be run in any order)                      ║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Install Xcode Command Line Tools
if ! command_exists xcode-select || ! xcode-select -p >/dev/null 2>&1; then
    run_command "Installing Xcode Command Line Tools" \
                "xcode-select --install" \
                "true"
    echo -e "${YELLOW}Note: Xcode installation may require manual interaction in a popup window.${NC}"
    echo -e "${YELLOW}Please complete the Xcode installation if prompted, then press Enter to continue.${NC}"
    read -r
else
    echo -e "${GREEN}✓ Xcode Command Line Tools already installed${NC}"
    echo ""
fi

# Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    run_command "Installing oh-my-zsh" \
                'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
else
    echo -e "${GREEN}✓ oh-my-zsh already installed${NC}"
    echo ""
fi

# Install tmux plugin manager (tpm)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    run_command "Installing tmux plugin manager (tpm)" \
                "git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
else
    echo -e "${GREEN}✓ tmux plugin manager (tpm) already installed${NC}"
    echo ""
fi

echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║                     Phase 2: Push Configurations                    ║${NC}"
echo -e "${MAGENTA}║                    (Automated with ACCEPT_ALL=1)                    ║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Run push.sh with ACCEPT_ALL=1
if [ -f "$SCRIPT_DIR/push.sh" ]; then
    run_command "Pushing configuration files to system" \
                "cd '$REPO_ROOT' && ACCEPT_ALL=1 '$SCRIPT_DIR/push.sh'"
else
    echo -e "${RED}✗ push.sh script not found${NC}"
    echo "Please ensure push.sh exists in the utilities directory."
    exit 1
fi

echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║                    Phase 3: Final Setup Commands                    ║${NC}"
echo -e "${MAGENTA}║              (Should be done last, only once per machine)           ║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Install Nix package manager
if ! command_exists nix; then
    echo -e "${YELLOW}Installing Nix package manager...${NC}"
    echo -e "${YELLOW}This will require you to follow the installation prompts.${NC}"
    prompt_continue "Ready to install Nix?"
    
    run_command "Installing Nix package manager" \
                "sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)"
    
    echo -e "${YELLOW}Nix installation complete. You may need to restart your terminal or source your shell configuration.${NC}"
    echo -e "${YELLOW}Attempting to source Nix...${NC}"
    
    # Try to source nix
    if [ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
        source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" || true
    fi
else
    echo -e "${GREEN}✓ Nix package manager already installed${NC}"
    echo ""
fi

# Run Nix Darwin flake configuration
if command_exists nix && [ -f "$HOME/.config/nix/flake.nix" ]; then
    echo -e "${YELLOW}Applying Nix Darwin flake configuration...${NC}"
    echo -e "${YELLOW}This may take several minutes and will install many packages.${NC}"
    prompt_continue "Ready to apply Nix configuration?"
    
    run_command "Applying Nix Darwin flake configuration" \
                "nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake ~/.config/nix/"
else
    echo -e "${YELLOW}⚠ Warning: Cannot apply Nix configuration${NC}"
    if ! command_exists nix; then
        echo "  - Nix is not available in PATH"
    fi
    if [ ! -f "$HOME/.config/nix/flake.nix" ]; then
        echo "  - flake.nix not found at ~/.config/nix/flake.nix"
    fi
    echo "You may need to restart your terminal and run this step manually:"
    echo "  nix run nix-darwin --extra-experimental-features 'nix-command flakes' -- switch --flake ~/.config/nix/"
    echo ""
fi

echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║                    Phase 4: Install Global Commands                 ║${NC}"
echo -e "${MAGENTA}║                   (Make commands available everywhere)               ║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Install global commands
if [ -f "$SCRIPT_DIR/install_commands.sh" ]; then
    echo -e "${YELLOW}Installing global dotfiles commands...${NC}"
    echo -e "${CYAN}This will make dotfiles-pull, dotfiles-push, and dotfiles-setup available from anywhere.${NC}"
    prompt_continue "Install global commands?"
    
    run_command "Installing global dotfiles commands" \
                "cd '$REPO_ROOT' && '$SCRIPT_DIR/install_commands.sh'"
else
    echo -e "${YELLOW}⚠ Warning: install_commands.sh not found${NC}"
    echo "Global commands will not be installed."
    echo "You can install them later by running: ./utilities/install_commands.sh"
    echo ""
fi

echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║                           Setup Complete!                           ║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}🎉 Your dotfiles setup is complete!${NC}"
echo ""
echo -e "${CYAN}Next Steps:${NC}"
echo "• Restart your terminal or open a new terminal session"
echo "• Run 'tmux' and press 'prefix + I' (usually Ctrl+b + I) to install tmux plugins"
echo "• Verify your configurations are working as expected"
echo ""
echo -e "${CYAN}Global Commands Available:${NC}"
echo "• ${YELLOW}dotfiles-pull${NC}   - Pull latest configs from system to repo"
echo "• ${YELLOW}dotfiles-push${NC}   - Push configs from repo to system"
echo "• ${YELLOW}dotfiles-setup${NC}  - Re-run complete setup (if needed)"
echo ""
echo -e "${CYAN}Local Commands (if global install failed):${NC}"
echo "• Pull latest configs: ./utilities/pull.sh"
echo "• Push configs to system: ./utilities/push.sh"
echo "• Re-run setup: ./utilities/setup.sh"
echo ""
echo -e "${YELLOW}Note: Some changes may require a full terminal restart or system reboot to take effect.${NC}" 