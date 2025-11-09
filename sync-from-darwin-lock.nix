# sync-from-darwin-lock.nix
{ centralLockPath, targetFlakeDir }:

let
  inherit (builtins) readFile fromJSON toJSON;

  centralLock = fromJSON (readFile centralLockPath);
  targetLock  = fromJSON (readFile (targetFlakeDir + "/flake.lock"));

  # Replace only the nixpkgs node
  newLock = targetLock // {
    nodes = targetLock.nodes // {
      nixpkgs = centralLock.nodes.nixpkgs;
    };
  };
in
toJSON newLock

