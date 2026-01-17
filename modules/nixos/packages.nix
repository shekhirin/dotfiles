{ pkgs, ... }:

{
  # System packages specific to NixOS
  environment.systemPackages = with pkgs; [
    ghostty.terminfo
  ];

  # Docker for clawdbot sandboxing
  virtualisation.docker = {
    enable = true;
    # Enable rootless docker so user services can access docker without root
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
}
