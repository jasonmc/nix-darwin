{
  config,
  pkgs,
  ...
}:

let
  user = config.system.primaryUser;
in
{
  nix.linux-builder = {
    enable = true;
    package = pkgs.darwin.linux-builder-vz;
    systems = [
      "aarch64-linux"
      "x86_64-linux"
    ];
    maxJobs = 2;
    # Nested virtualization is disabled in the stock VZ guest.
    supportedFeatures = [
      "benchmark"
      "big-parallel"
    ];
    config.virtualisation = {
      cores = 8;
      darwin-builder.memorySize = 6 * 1024;
      darwin-builder.diskSize =  100 * 1024;
    };
  };

  # Let nix-darwin add the local VM with its SSH credentials and host key.
  nix.buildMachines = [
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
  ];

  programs.ssh.extraConfig = ''
    Host athenabuilder
      HostName athena.fibo
      IdentityAgent /Users/jason/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
      ControlMaster auto
      ControlPersist 10m
      # Keep user SSH sessions separate from the root Nix builder.
      ControlPath ~/.ssh/cm-%C
  '';
}
