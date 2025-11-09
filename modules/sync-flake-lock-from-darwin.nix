{ inputs }:

let
  lockEvaluatorText = ''
    { centralLockPath, targetFlakeDir }:

    let
      inherit (builtins) readFile fromJSON toJSON;

      centralLock = fromJSON (readFile centralLockPath);
      targetLock  = fromJSON (readFile (targetFlakeDir + "/flake.lock"));

      newLock = targetLock // {
        nodes = targetLock.nodes // {
          nixpkgs = centralLock.nodes.nixpkgs;
        };
      };
    in
    toJSON newLock
  '';

  mkPackage = pkgs:
    let
      lockEvaluator = pkgs.writeText "sync-from-darwin-lock.nix" lockEvaluatorText;
      scriptText = ''
        set -euo pipefail

        TARGET_DIR="''${1:-.}"

        if [ ! -f "$TARGET_DIR/flake.lock" ]; then
          echo "error: $TARGET_DIR/flake.lock not found" >&2
          echo "       run 'nix flake lock' there once first" >&2
          exit 1
        fi

        tmp="$TARGET_DIR/flake.lock.tmp"

        nix eval --raw \
          --file ${lockEvaluator} \
          --argstr centralLockPath "${inputs.self}/flake.lock" \
          --argstr targetFlakeDir "$TARGET_DIR" \
          > "$tmp"

        mv "$tmp" "$TARGET_DIR/flake.lock"

        echo "Updated $TARGET_DIR/flake.lock nixpkgs from nix-darwin flake.lock"
      '';
    in
    pkgs.writeShellApplication {
      name = "sync-flake-lock-from-darwin";
      text = scriptText;
    };

  module = { config, pkgs, lib, ... }:
    let
      cfg = config.programs.syncFlakeLockFromDarwin;
    in
    {
      options.programs.syncFlakeLockFromDarwin = {
        enable = lib.mkEnableOption ''
          Install the sync-flake-lock-from-darwin helper so other flakes can pull in
          the nix-darwin nixpkgs revision.
        '';

        package = lib.mkOption {
          type = lib.types.package;
          default = mkPackage pkgs;
          defaultText = "pkgs.writeShellApplication \"sync-flake-lock-from-darwin\" …";
          description = "Package providing the sync helper executable.";
        };
      };

      config = lib.mkIf cfg.enable {
        home.packages = [ cfg.package ];
      };
    };
in
{
  inherit mkPackage module;
}
