{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = import ./packages.nix { inherit pkgs; };

  fonts = { packages = [ pkgs.jetbrains-mono pkgs.noto-fonts ]; };

  # Use a custom configuration.nix location.
  environment.darwinConfig = "$HOME/code/nix-darwin";

  ids.gids.nixbld = 30000;

  nix = {
    enable = true;
    package = pkgs.nix;
    settings = { "extra-experimental-features" = [ "nix-command" "flakes" ]; };

    gc = {
      automatic = true;
      # Run every day at 03:15
      interval = { Hour = 3; Minute = 15; };
      # Keep only generations newer than 14 days
      options = "--delete-older-than 14d";
    };

    optimise = {
      automatic = true;
      # Stagger to 04:00 to avoid overlap with GC
      interval = { Hour = 4; Minute = 0; };
    };
  };

  programs = {
    fish.enable = true; # Enable alternative shell support in nix-darwin.
  };

  system.primaryUser = "jason";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 5;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = config.rev or config.dirtyRev or null;

  homebrew = {
    enable = false;
    casks = [ "firefox" ];
  };

  system.defaults = {
    dock = {
      autohide = true;
      orientation = "left";
      static-only = false;
    };
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
    };
  };
}
