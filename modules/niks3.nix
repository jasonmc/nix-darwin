{
  config,
  lib,
  pkgs,
  ...
}:

let
  ageWithSecureEnclave = pkgs.writeShellScript "age-with-secure-enclave" ''
    export PATH=${lib.makeBinPath [ pkgs.age-plugin-se ]}
    exec ${lib.getExe pkgs.age} "$@"
  '';
in
{
  age = {
    ageBin = toString ageWithSecureEnclave;
    identityPaths = [ "/var/lib/agenix/niks3-system-se-identity.txt" ];
    secrets.niks3ApiToken = {
      file = ../secrets/niks3-api-token.age;
      owner = "root";
      group = "wheel";
      mode = "0400";
    };
  };

  nix.settings = {
    extra-substituters = [ "http://athena.fibo:5751" ];
    extra-trusted-public-keys = [
      "athena-nix-cache-1:/jEEav6kB/+ArCu40JQGXsNbh1zkzhDtlvFBQLWy+r4="
    ];
  };

  services.niks3-auto-upload = {
    enable = true;
    serverUrl = "http://athena.fibo:5751";
    authTokenFile = config.age.secrets.niks3ApiToken.path;
  };
}
