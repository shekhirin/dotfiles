{ lib, ... }:

{
  # Extend nushell configuration with NixOS-specific config
  programs.nushell = {
    configFile.text = lib.mkAfter ("\n" + builtins.readFile ./config.nu);
    extraEnv = ''
      $env.DOCKER_HOST = "unix:///run/user/1000/docker.sock"
    '';
  };
}
