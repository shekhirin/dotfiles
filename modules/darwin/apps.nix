{ pkgs, ... }:

{
  # GUI applications and macOS-specific packages
  home.packages = with pkgs; [
    tailscale
    protonvpn
    protonmail-bridge
  ];
}
