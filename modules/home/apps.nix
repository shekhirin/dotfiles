{ pkgs, lib, ... }:

{
  # GUI applications and macOS-specific packages
  home.packages = with pkgs; [
    # Apps from nixpkgs
    signal-desktop-bin
    slack
    anki-bin
    spotify
    notion-app # using overlay for version 4.15.3 to fix auto-update
    # _1password-gui # Commented out: needs to be in /Applications to work properly
    # Error: "1Password is not installed inside of /Applications. Please move 1Password and restart the app."
    tailscale
    protonvpn
    protonmail-bridge
  ];
}
