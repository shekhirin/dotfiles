{ inputs, pkgs, ... }:

{
  # System packages specific to NixOS
  environment.systemPackages = with pkgs; [
    ghostty.terminfo
    inputs.rex.packages.${stdenv.hostPlatform.system}.rex
  ];
}
