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

  overlay = final: prev: {
    syncFlakeLockFromDarwin = mkPackage final;
  };
in
{
  inherit mkPackage overlay;
}
