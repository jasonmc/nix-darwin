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
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niks3 = {
      url = "github:Mic92/niks3";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fixepub = {
      url = "github:jasonmc/fixepub";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      home-manager,
      nixpkgs,
      agenix,
      niks3,
      fixepub,
      ...
    }:
    let
      system = "aarch64-darwin";
      syncHelper = import ./modules/sync-flake-lock-from-darwin.nix { inherit inputs; };
      fixepubOverlay = final: _: {
        fixepub = fixepub.packages.${final.stdenv.hostPlatform.system}.default;
      };
      overlays = [
        syncHelper.overlay
        fixepubOverlay
      ];
      builderModules = [
        ./modules/build-machines.nix
      ];
      baseModules = [
        { nixpkgs.overlays = overlays; }
        ./darwin.nix
        agenix.darwinModules.default
        niks3.darwinModules.niks3-auto-upload
        ./modules/niks3.nix
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.jason = import ./home.nix;
          };
          # https://github.com/nix-community/home-manager/issues/4026
          users.users.jason.home = "/Users/jason";
        }
      ];
      mkDarwin =
        {
          extraModules ? [ ],
        }:
        nix-darwin.lib.darwinSystem {
          inherit system;
          modules = baseModules ++ extraModules;
          specialArgs = { inherit inputs; };
        };
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;

      darwinConfigurations = {
        # Build darwin flake using:
        # $ darwin-rebuild build --flake .#Jasons-MacBook-Pro
        "Jasons-MacBook-Pro" = mkDarwin { extraModules = builderModules; };
        # Builder-free configuration used by the GitHub workflow.
        "Jasons-MacBook-Pro-noRosetta" = mkDarwin { };
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Jasons-MacBook-Pro".pkgs;
    };
}
