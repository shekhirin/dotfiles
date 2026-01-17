{ pkgs, ... }:

{
  # System packages specific to NixOS
  environment.systemPackages = with pkgs; [
    ghostty.terminfo
  ];

  # Docker for clawdbot sandboxing (rootless only, no system daemon)
  virtualisation.docker = {
    enable = false;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
}
