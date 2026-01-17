{ pkgs, ... }:

{
  # System packages specific to NixOS
  environment.systemPackages = with pkgs; [
    ghostty.terminfo
  ];

  # Docker for clawdbot sandboxing
  virtualisation.docker.enable = true;
}
