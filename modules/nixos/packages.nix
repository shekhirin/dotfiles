{ pkgs, ... }:

{
  # System packages specific to NixOS
  environment.systemPackages = with pkgs; [
    ghostty.terminfo
  ];
}