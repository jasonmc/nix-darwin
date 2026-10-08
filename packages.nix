{ pkgs }:

# Machine-wide networking, login shell, and diagnostics.
[
  pkgs.tailscale
  pkgs.fish
  pkgs.mosh
  pkgs.openssh
  #pkgs.oh-my-fish
  # pkgs.tealdeer
]
