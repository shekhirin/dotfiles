{ lib, ... }:

{
  # Extend nushell configuration with NixOS-specific config
  programs.nushell = {
    configFile.text = lib.mkAfter ("\n" + builtins.readFile ./config.nu);
  };
}
