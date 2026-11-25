{ inputs, pkgs, ... }:

{
  # System packages specific to NixOS
  environment.systemPackages = with pkgs; [
    ghostty.terminfo
    inputs.asc.packages.${stdenv.hostPlatform.system}.default
    inputs.rex.packages.${stdenv.hostPlatform.system}.rex
  ];
}
