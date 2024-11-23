{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, }:
    let
      configuration = { pkgs, ... }: {
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = [
          pkgs.vim
          pkgs.tailscale
          pkgs.tmux
          pkgs.zellij
          pkgs.broot
          pkgs.git
          pkgs.fzf
          pkgs.fish
          pkgs.qemu
          pkgs.htop
          pkgs.mosh
          pkgs.ripgrep
          pkgs.ripgrep-all
          pkgs.curl
          pkgs.stack
          pkgs.xplr
          pkgs.rsync
          pkgs.glow
          pkgs.zoxide
          pkgs.gping
          pkgs.tig
          pkgs.age
          pkgs.dotnet-sdk_8
          pkgs.pandoc
          pkgs.difftastic
          pkgs.bottom
          pkgs.btop
          pkgs.mdcat
          pkgs.du-dust
          pkgs.oh-my-fish
          pkgs.pwgen
          pkgs.procs
          pkgs.bottom
          pkgs.ncdu
          pkgs.yt-dlp
          pkgs.rustc
          pkgs.cargo
          pkgs.gh
          pkgs.broot
          pkgs.texlive.combined.scheme-small
          pkgs.nushell
          pkgs.eza
          pkgs.lsd
          pkgs.bat
          pkgs.emacs29
          pkgs.tree
          pkgs.fd
          pkgs.wget
          pkgs.gron
          pkgs.tor
          pkgs.haskell-language-server
          pkgs.tealdeer
          pkgs.nushell
          pkgs.rust-petname
          pkgs.httpie
          pkgs.speedtest-cli
          pkgs.speedtest-go
          pkgs.nmap
          pkgs.doctl
          pkgs.scaleway-cli
          pkgs.yubikey-manager
          pkgs.pv
          pkgs.fswatch
          pkgs.aspellDicts.en
          pkgs.aspell
          pkgs.kalker
          pkgs.rust-analyzer
          pkgs.rustfmt
          pkgs.starship
          pkgs.libgen-cli
          pkgs.circumflex
          pkgs.wezterm
          pkgs.viu
          pkgs.fsrx
          pkgs.jless
          pkgs.wthrr
          pkgs.fishPlugins.grc
          pkgs.grc
          pkgs.openssh
          pkgs.any-nix-shell
          pkgs.delta
          pkgs.nil
          pkgs.dua
          pkgs.nixfmt-classic
          pkgs.statix
        ];

        fonts = { packages = [ pkgs.jetbrains-mono pkgs.noto-fonts ]; };

        # Auto upgrade nix package and the daemon service.
        services.nix-daemon.enable = true;
        # nix.package = pkgs.nix;

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Enable alternative shell support in nix-darwin.
        programs.fish.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 5;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
      };
    in {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Jasons-MacBook-Pro
      darwinConfigurations."Jasons-MacBook-Pro" =
        nix-darwin.lib.darwinSystem { modules = [ configuration ]; };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Jasons-MacBook-Pro".pkgs;
    };
}
