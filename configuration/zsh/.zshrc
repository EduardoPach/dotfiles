# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=10000
HISTSIZE=10000
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

# completion using arrow keys (based on history)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Load autocompletion
autoload -Uz compinit && compinit
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

################### ENVIRONMENT VARIABLES ###################
export NIX_DIR="$HOME/.config/nix" # Nix configuration directory
export ARGMAX_DIR="$HOME/argmax" # Argmax directory
export ZSHRC_FILE="$HOME/.zshrc" # Zshrc file
export DOTFILES_REPO_DIR="$HOME/dotfiles" # Dotfiles repository directory
################### ENVIRONMENT VARIABLES ###################

# SSH Agent Configuration
# Check if SSH agent is running by looking for its socket environment variable
if [ -z "$SSH_AUTH_SOCK" ]; then
    # Start a new SSH agent and set up the environment variables (silently)
    eval "$(ssh-agent -s)" >/dev/null
fi

# GitHub SSH Key Management
# Verify the GitHub SSH key exists in the expected location
if [ -f "$HOME/.ssh/id_ed25519_github" ]; then
    # Check if any SSH keys are currently loaded (-l lists keys, exit code 1 means no keys)
    ssh-add -l &>/dev/null
    if [ $? -eq 1 ]; then
        # No keys loaded, so add the GitHub key (silently)
        ssh-add "$HOME/.ssh/id_ed25519_github" &>/dev/null
    fi
fi

# UV Python -> Workaround to fix issue related to TAB completion not working for python files 
# See for more details: https://github.com/astral-sh/uv/issues/8432
# Workaround mentioned at https://github.com/astral-sh/uv/issues/8432#issuecomment-2965692994
_uv_run_mod() {
    if [[ "$words[2]" == "run" && "$words[CURRENT]" != -* ]]; then
        _arguments '*:filename:_files -g "*.py"'
    else
        _uv "$@"
    fi
}
compdef _uv_run_mod uv