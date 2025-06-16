# dotfiles

Repository for versioning my `dotfiles` i.e. configuration files for my working environment. Everything that is in here should be a mere copy of what I'm currently using as my work env. 

My goals with this repository are simple:

- One button to setup working env for new machines (some manual work is expected)
- Every manual step necessary should be documented here
- Utilities to push `dotfiles` to there place of existence on my machine
- Utilitis to pull from `dotifiles` from there place of existence on my machine

All configuration files will be saved under a `configuration` directory under their respective tool/group name e.g. under `configuration/zsh/` we will have files like `.p10k.zsh` and `.zshrc` that are related to the overall `zsh` group. 

All utilities scripts (these scripts will be `.sh`) will live under `utilities` direcotry and in there we will have the `pull.sh`, `push.sh` and `setup.sh` scripts where:

- `pull.sh` -> Will copy all configuration files to this repo. This is useful in case I make any change that I want to keep and commit
- `push.sh` -> Will set all configuration files in the machine to be the same as the ones from this repo. This is useful in case I'm setting up or want to revert modifications or previous states.
- `setup.sh` -> Will setup a machine by performing manual steps (and logging every step along the way), push configs from this repo to their correspondent locations on the machine. This will likely be used only once but it will guarantee reproducibility in case I always follow this

---

# Versioned Files

## Summary Table

| File / Directory | Location | Description |
|------|----------|-------------|
|flake.nix      | $HOME/.config/nix          |The flake file that builds 80% of my working env with very few commands             |
|flake.lock      | $HOME/.config/nix          |The .lock file representing state of my flake             |
|.tmux      | $HOME          |A directory containing a directory inside named `plugins` with all my tmux plugins - need to clone `tpm` there|
|.tmux.conf      | $HOME          |A configuration for tmux containing some modifications for better usage             |
|.zshrc      |$HOME          |My zsh configuration file containing a bunch of important modifications             |
|.p10k.zsh      |$HOME          |power level 10k conifugration for a beautiful terminal look             |
|kitty      |$HOME/.config/kitty          |A directory containing all important files to configure kitty terminal             |
|karabiner      |$HOME/.config/karabiner          |A directory containing all the important files to setup my karabiner modifications             |

## Nix

Files related to `nix` are very important as `nix` is package manager that I use for a declarative and reproducible working environment setup. While `nix` unfortunetely can't fulfill 100% of my env setup it can get it up to around 80%-90% with just a few extra manual steps needed.

The `nix` related files live at `$HOME/.config/nix/` and have the following tree structure.

```bash
> tree ~/.config/nix/
/Users/eduardo/.config/nix/
├── flake.lock
└── flake.nix

1 directory, 2 files
```

## Tmux

I use `tmux` as terminal multiplexer and to manage different sessions of work such that I can get back easily to where I was, moreover it is pretty useful when `ssh`ing into a machine to keep the session alive even if connection is lost so always using it is a way to know how to use it when `ssh` is needed.

There are two main things related to `tmux` for correct confugration:  
1. The `.tmux.conf` configuration file that lives at `$HOME`
2. The `.tmux` directory contaning the `plugings` directory where inside of this dir we have clones of repos of the plugins.

For our purpose `.tmux.conf` is the only file we need to keep track of, but for appropriate use we will need a to automate the creation and population of `.tmux` with the `tmux-package-manger` aka `[tpm](https://github.com/tmux-plugins/tpm)` which basically means we need to clone `tpm` into `$HOME/.tmux/plugins/` with a simple command like `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`

## Zsh

`zsh` is the terminal I use there are others like `bash` and `fish`. The files related to `zsh` are `.zshrc` and `.p10k.zsh`. In the former we have things that modify the terminal session behavior and overall configuration while the latter is a style configuration. One thing we need is `oh-my-zsh` which is not automated with `nix`, but it is pretty straightforward to get by simply running `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"`. Both of these files live under `$HOME`

`p10k` installation is automated though `nix`

## Kitty

`kitty` is the terminal emulator I use which is pretty fast and easy to customize. For `kitty` all configurations live at `$HOME/.config/kitty/` and this is how the dir structure looks like:

```bash
> tree ~/.config/kitty/
/Users/eduardo/.config/kitty/
├── current-theme.conf
├── kitty.conf
└── kitty.conf.bak

1 directory, 3 files
```

`kitty` installation is automated through `nix`

## Karabiner

It's a keyboard configuration software for mapping keys to a different behaviour like the usage of a `hyper` key or combination of key stroke behavior. The configuration files for `karabiner` live at `$HOME/.config/karabiner/` and this is the structure of the directory:

```bash
tree ~/.config/karabiner/
/Users/eduardo/.config/karabiner/
├── assets
│   └── complex_modifications
├── automatic_backups
│   └── karabiner_20250602.json
└── karabiner.json

4 directories, 2 files
```

# Manual Commands:

Besides installing work related software like `Slack` or `Tuple` (which can be automated through `nix` but I faced some issues) a few commands are also necessary like:

> NOTE: Regardless of the order
- `xcode-select --install` to install `Xcode`
- `sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"` for `oh-my-zsh` installation as previously mentioned in the [zsh](#zsh) section
- `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`

> NOTE: Should be the last thing to do when setting up for the first time
- `sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)` to install `nix` package manager
- `nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/.config/nix/` to set my flake configuration