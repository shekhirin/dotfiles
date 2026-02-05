{ lib, pkgs, ... }:

{
  environment.etc = {
    "nix/nix.custom.conf" = {
      knownSha256Hashes = [
        "3bd68ef979a42070a44f8d82c205cfd8e8cca425d91253ec2c10a88179bb34aa"
      ];
      text = ''
      # Parallel evaluation (developer preview)
      # Parallelizes nix eval, nix flake check, nix flake show, etc.
      # Set to 0 to use all cores, 1 to disable
      eval-cores = 0
    '';
    };

    "determinate/config.json".text = builtins.toJSON {
      garbageCollector = {
        strategy = "automatic";
      };
      builder = {
        state = "enabled";
        memoryBytes = 8589934592; # 8 GiB
        cpuCount = 1;
      };
    };
  };
}
