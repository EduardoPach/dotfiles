{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    mac-app-util.url = "github:hraban/mac-app-util"; # fixes Spothlight indexing problem
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, mac-app-util, nix-homebrew}:
  let
    configuration = { pkgs, ... }: {
      # needed to install unfree apps like Cursor; Obsidian, etc
      nixpkgs.config.allowUnfree = true;
	
      # macOS System Settings
      system.defaults = {
        dock = {
          autohide = true;                # Enable auto-hide for the dock
          autohide-delay = 0.0;           # Remove delay for showing dock
          autohide-time-modifier = 0.0;   # Remove animation time
          show-recents = false;           # Hide recent applications
          static-only = false;            # Only show running applications
          persistent-apps = [
            "/System/Applications/System\ Settings.app"
            # "/Applications/Nix\ Apps/Arc.app" # Arc is unmaintened therefore can not be distributed by Nix
            "/Applications/Slack.app"
            "/Applications/Nix\ Apps/Cursor.app"
          ];
          orientation = "bottom";         # Place dock at the bottom
          mineffect = "scale";           # Minimize animation effect
        };
        
        # Global settings including dark mode and scroll direction
        NSGlobalDomain = {
          ApplePressAndHoldEnabled = false; # Disable press and hold for all keys
          InitialKeyRepeat = 20; # 20ms delay for first key repeat
          KeyRepeat = 5; # 5ms between key repeats
          AppleInterfaceStyle = "Dark";  # Dark mode
          "com.apple.swipescrolldirection" = false;  # Regular scrolling direction
          NSAutomaticCapitalizationEnabled = false; # Disable automatic capitalization
          NSAutomaticDashSubstitutionEnabled = false; # Disable automatic dash substitution
          NSAutomaticPeriodSubstitutionEnabled = false; # Disable automatic period substitution
          NSAutomaticQuoteSubstitutionEnabled = false; # Disable automatic quote substitution
          NSAutomaticSpellingCorrectionEnabled = false; # Disable automatic spelling correction
        };
      };

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ 
          pkgs.vim
          pkgs.tmux
          pkgs.code-cursor
          # pkgs.arc-browser # Arc is unmaintened therefore can not be distributed by Nix
          pkgs.poetry # Poetry python package manager
          pkgs.kitty
          pkgs.ffmpeg
          pkgs.wget
          pkgs.docker # Still need to download Docker Desktop
          pkgs.mactop
          pkgs.asitop
        ];

      system.primaryUser = "eduardo";
       homebrew = {
        enable = true;
        brews = [ 
          "mas" # Mac App Store CLI
          "git" # Git CLI
          "swift-format" # Swift format for Swift code
          "whisperkit-cli" # Argmax WhisperKit CLI
          "powerlevel10k" # Powerlevel10k zsh theme
          "tree" # Tree command for directory listing
          "huggingface-cli" # Hugging Face CLI
          "pre-commit" # Pre-commit hooks for git
          "zsh-autosuggestions" # Autosuggestions for zsh
          "zsh-syntax-highlighting" # Syntax highlighting for zsh
          "texlive" # TeX Live for LaTeX -> necessary for VSCode/Cursor to render LaTeX
          "portaudio" # Portaudio for audio input/output -> necessary for whisperkittools
        ];        # CLI tools from Homebrew
        casks = [ 
          "raycast" # Raycast -> better Spotlight
          "karabiner-elements" # Karabiner -> Keyboard remapping
          "notion" # Notion -> Note-taking
          "stats" # Stats -> System monitor
          "font-meslo-lg-nerd-font" # Meslo Nerd Font -> Better font for terminal
          "mactex" # MacTeX -> LaTeX for macOS
        ];        # GUI apps from Homebrew Casks
        masApps = {
        };
        taps = [ ];                  # Optional: extra taps
        onActivation.cleanup = "zap"; # Optional: cleanup removed brews/casks
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
	
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Eduardos-MacBook-Pro
    darwinConfigurations."Eduardos-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration 
        mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "eduardo";

          };
        }
      ];
    };
  };
}
