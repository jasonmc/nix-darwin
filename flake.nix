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
  };

  outputs = inputs@{ self, nix-darwin, home-manager, nixpkgs, nix-rosetta-builder, }: {

    darwinConfigurations = {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Jasons-MacBook-Pro
      "Jasons-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          # { nix.linux-builder.enable = true; }
          nix-rosetta-builder.darwinModules.default
          {
            # see available options in module.nix's `options.nix-rosetta-builder`
            nix-rosetta-builder = {
              enable = true;
              onDemand = true;
            };
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
        specialArgs = { inherit inputs; };
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Jasons-MacBook-Pro".pkgs;
    };
  };
}
