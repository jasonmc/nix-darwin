{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkForce;
  user = config.system.primaryUser;

  rosettaConstants = import "${inputs.nix-rosetta-builder.outPath}/constants.nix";
  rosettaLinuxSystem =
    builtins.replaceStrings [ "darwin" ] [ "linux" ]
      pkgs.stdenv.hostPlatform.system;
in
{
  nix.buildMachines = mkForce [
    {
      hostName = "athenabuilder";
      systems = [ "x86_64-linux" ];
      sshUser = user;
      protocol = "ssh-ng";
      maxJobs = 8;
      speedFactor = 10;
      supportedFeatures = [
        "benchmark"
        "big-parallel"
        "kvm"
        "nixos-test"
      ];
    }
    {
      hostName = rosettaConstants.name;
      maxJobs = config.nix-rosetta-builder.cores;
      protocol = "ssh-ng";
      supportedFeatures = [
        "benchmark"
        "big-parallel"
        "kvm"
        "nixos-test"
      ];
      systems = [ rosettaLinuxSystem ];
    }
  ];

  programs.ssh.extraConfig = ''
    Host athenabuilder
      HostName athena.fibo
      IdentityAgent /Users/jason/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
      ControlMaster auto
      ControlPersist 10m
      ControlPath /tmp/ssh-%r@%h:%p
  '';
}
