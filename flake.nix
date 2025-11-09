{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-rosetta-builder = {
      url = "github:cpick/nix-rosetta-builder";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fixepub = {
      url = "github:jasonmc/fixepub";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nixpkgs, nix-rosetta-builder, fixepub, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
      syncScript = builtins.readFile ./sync-flake-lock-from-darwin.sh;
      syncFlakeLockFromDarwin = pkgs.writeShellApplication {
        name = "sync-flake-lock-from-darwin";
        text = builtins.replaceStrings
          [
            "__SYNC_FROM_DARWIN_LOCK__"
            "__CENTRAL_LOCK_PATH__"
          ]
          [
            "${./sync-from-darwin-lock.nix}"
            "${self}/flake.lock"
          ]
          syncScript;
      };
      rosettaModules = [
        # { nix.linux-builder.enable = true; }
        nix-rosetta-builder.darwinModules.default
        {
          # see available options in module.nix's `options.nix-rosetta-builder`
          nix-rosetta-builder = {
            enable = true;
            onDemand = true;
          };
        }
      ];
      baseModules = [
        {
          nixpkgs.overlays = [
            (final: prev: {
              fixepub = fixepub.packages.${final.system}.default;
            })
          ];
        }
        ./darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.jason = import ./home.nix;
          };
          users.users.jason.home =
            "/Users/jason"; # https://github.com/nix-community/home-manager/issues/4026
        }
      ];
      mkDarwin = { extraModules ? [] }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          modules = baseModules ++ extraModules;
          specialArgs = { inherit inputs; };
        };
    in {
      packages.${system}.syncFlakeLockFromDarwin = syncFlakeLockFromDarwin;

      darwinConfigurations = {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Jasons-MacBook-Pro
      "Jasons-MacBook-Pro" = mkDarwin {extraModules = rosettaModules; };
      "Jasons-MacBook-Pro-noRosetta" = mkDarwin {  };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Jasons-MacBook-Pro".pkgs;
    };
  };
}
