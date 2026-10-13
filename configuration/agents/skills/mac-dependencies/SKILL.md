---
name: mac-dependencies
description: How software gets installed on Eduardo's Mac. Everything system-level is declared in one nix-darwin flake that manages nixpkgs, Homebrew formulae, casks, taps and Mac App Store apps. Use this whenever a task needs a CLI tool, library, GUI app, font or App Store app installed, upgraded or removed, when a command is "not found", before running `brew install`, `brew install --cask`, `nix profile install`, `nix-env -i`, `mas install` or any global `npm -g` / `pip install` / `cargo install`, and whenever editing ~/.config/nix/flake.nix.
---

# Installing software on this Mac

Everything installed system-wide is **declared** in a nix-darwin flake. Don't install anything imperatively. The flake also manages Homebrew with `homebrew.onActivation.cleanup = "zap"`. At the next `darwin-rebuild switch`, any brew formula, cask or tap missing from the flake is uninstalled, and a removed cask's data is wiped too. So a quick `brew install foo` silently disappears later.

| what | where |
|---|---|
| live config, the one that gets built | `~/.config/nix/flake.nix` (+ `flake.lock`), host `Eduardos-MacBook-Pro` |
| versioned copy | `~/dotfiles/configuration/nix/` (git repo, PRs to `main`) |
| apply (needs sudo) | `nix-sync`, an alias for `sudo darwin-rebuild switch --flake ~/.config/nix` |
| validate (no sudo) | `darwin-rebuild build --flake ~/.config/nix` |

## Pick the right place

Follow the existing lists in the flake. When the right place isn't obvious, ask Eduardo instead of guessing.

| kind of software | flake attribute | entry looks like |
|---|---|---|
| CLI tool or library (the default) | `homebrew.brews` | `"ffmpeg" # FFmpeg for video and audio processing` |
| formula from a third-party tap | `homebrew.taps` + `homebrew.brews` | `{ name = "anemll/tap"; trusted = true; }`, then `"anemll-profile"` |
| GUI app or font | `homebrew.casks` | `"obsidian" # Obsidian Desktop -> Note-taking` |
| Mac App Store app | `homebrew.masApps` | `"Xcode" = 497799835;` |
| core tools pinned with the flake lock | `environment.systemPackages` | `pkgs.neovim # Neovim editor` |

- **Homebrew is the default.** Most CLIs live in `brews`, and ffmpeg was moved there from nix. Use nixpkgs for what is already there (vim, neovim, tmux, kitty, Cursor, poetry, docker) or when the package should be pinned by `flake.lock`. Unfree packages are allowed.
- **Taps must be trusted.** Homebrew 6 refuses formulae from untrusted non-official taps and aborts the whole activation. Every tap entry needs `trusted = true`.
- **Self-updating GUI apps prefer casks.** An app installed from nixpkgs is copied into `/Applications/Nix Apps`, and its CLI points into the read-only `/nix/store`. If such an app updates itself (Squirrel/ShipIt for Electron, Sparkle), it rewrites the store copy and the two drift apart. If a self-updating app must come from nix, turn its updater off. Cursor is the precedent: it has `"update.mode": "none"` in `~/Library/Application Support/Cursor/User/settings.json`.
- **App Store apps** need the App Store ID: `mas search <name>` or `mas info <id>`. The Apple ID signed into the App Store must already own the app. Removing an entry from `masApps` does **not** uninstall the app, so remove it by hand if that's wanted.
- **Not system-level:** project dependencies stay in the project (`uv` for Python, the project's own `package.json`, etc.). One-off Python CLIs that Eduardo doesn't want installed are `uvx` aliases in `~/.zshrc` (see `fluidtop`, `cookiecutter`), which lives in dotfiles at `configuration/zsh/.zshrc`.

## Procedure

1. **Check it isn't already there.** Run `command -v <tool>`, `brew list | grep <name>`, `mas list` and `grep -n <name> ~/.config/nix/flake.nix`.
2. **Confirm the exact name exists.** Use `brew info <name>`, `brew info --cask <name>`, `nix eval --raw nixpkgs#<attr>.version` or `mas search <name>`. This matters because step 4 doesn't check Homebrew names. A typo there only fails during the switch.
3. **Edit `~/.config/nix/flake.nix`.** Add one entry to the right list with a trailing `# Name -> why` comment, like the existing entries.
4. **Build it without sudo:** `darwin-rebuild build --flake ~/.config/nix`. This evaluates the whole config and builds the nix side.
5. **Hand the switch to Eduardo.** Agents have no sudo. Ask Eduardo to run `nix-sync` **in their own terminal window**. Claude Code's `!` prefix doesn't work for this, because it has no TTY for sudo's password prompt.
6. **Verify after the switch.** Run `command -v <tool>` and `<tool> --version`, or check that the app is in `/Applications` (casks, App Store) or `/Applications/Nix Apps` (nixpkgs).
7. **Version it.** Copy `flake.nix`, plus `flake.lock` if it changed, into `~/dotfiles/configuration/nix/`. Commit on a branch and open a PR with `gh pr create`. Never commit to `main`. Don't use `make pull` for this, because it copies every config and can sweep unrelated work into the commit. Leave other uncommitted changes in `~/dotfiles` alone.

## Upgrading and removing

- **nixpkgs packages** move only when the lock moves. Run `nix flake update nixpkgs nix-darwin` in `~/.config/nix`, then build, then switch. Leave `nix-homebrew` and `brew-src` alone unless Homebrew itself needs an update. A Homebrew bump has broken activation before (macOS 27, Homebrew 6).
- **Homebrew packages** are not upgraded during a switch (`onActivation.upgrade` is off). Running `brew upgrade <name>` by hand is fine. It doesn't conflict with the flake.
- **Removing:** delete the line, build, switch. `zap` uninstalls brews, casks and taps. App Store apps stay installed.

## Known gotchas

- `mac-app-util` was removed because SBCL can't run on macOS 27. Nix GUI apps are plain copies in `/Applications/Nix Apps`, refreshed only on switch, and LaunchServices also registers the `/nix/store` path. If a launcher opens a different version than the terminal, compare `plutil -extract CFBundleShortVersionString raw <app>/Contents/Info.plist` for both.
- The live flake can carry Eduardo's uncommitted work-in-progress. Run `diff ~/.config/nix/flake.nix ~/dotfiles/configuration/nix/flake.nix` before copying, and mention anything unexpected.
