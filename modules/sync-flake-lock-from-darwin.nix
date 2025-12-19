{ inputs }:

let
  selfPath = inputs.self.outPath or (builtins.toString inputs.self);

  mkPackage =
    pkgs:
    let
      jq = pkgs.jq;
      scriptText = ''
        set -euo pipefail

        TARGET_DIR="''${1:-.}"

        if [ ! -f "$TARGET_DIR/flake.lock" ]; then
          echo "error: $TARGET_DIR/flake.lock not found" >&2
          echo "       run 'nix flake lock' there once first" >&2
          exit 1
        fi

        tmp="$TARGET_DIR/flake.lock.tmp"
        target_lock="$TARGET_DIR/flake.lock"
        central_lock="${selfPath}/flake.lock"

        ${jq}/bin/jq \
          --slurpfile central "$central_lock" \
          '.nodes.nixpkgs = $central[0].nodes.nixpkgs' \
          "$target_lock" > "$tmp"

        mv "$tmp" "$TARGET_DIR/flake.lock"

        echo "Updated $TARGET_DIR/flake.lock nixpkgs from nix-darwin flake.lock"
      '';
    in
    pkgs.writeShellApplication {
      name = "sync-flake-lock-from-darwin";
      text = scriptText;
    };

  overlay = final: prev: { syncFlakeLockFromDarwin = mkPackage final; };
in
{
  inherit mkPackage overlay;
}
