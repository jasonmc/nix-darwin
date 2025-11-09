#!/usr/bin/env bash
set -euo pipefail

TARGET_DIR="${1:-.}"

if [ ! -f "$TARGET_DIR/flake.lock" ]; then
  echo "error: $TARGET_DIR/flake.lock not found" >&2
  echo "       run 'nix flake lock' there once first" >&2
  exit 1
fi

tmp="$TARGET_DIR/flake.lock.tmp"

nix eval --raw \
  --file "__SYNC_FROM_DARWIN_LOCK__" \
  --argstr centralLockPath "__CENTRAL_LOCK_PATH__" \
  --argstr targetFlakeDir "$TARGET_DIR" \
  > "$tmp"

mv "$tmp" "$TARGET_DIR/flake.lock"

echo "Updated $TARGET_DIR/flake.lock nixpkgs from nix-darwin flake.lock"
