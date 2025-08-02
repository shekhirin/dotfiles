{
  user,
  pkgs,
  config,
  lib,
  ...
}:

{
  ## Core system
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;
  system.primaryUser = user;

  ## Nix settings
  # Let Determinate Nix handle Nix configuration
  nix.enable = false;
  nix.settings.experimental-features = "nix-command flakes";
  nix.extraOptions = ''
    extra-platforms = aarch64-darwin
  '';

  ## Users
  users.users.${user} = {
    uid = 501;
    home = "/Users/${user}";
  };

  ## Tailscale
  services.tailscale = {
    enable = true;
  };

  ## Touch‑ID sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  ## System defaults
  system.defaults = {
    screencapture.location = "~/Pictures/Screenshots";
    dock.autohide = true;
  };

  ## Dock configuration
  local.dock = {
    enable = true;
    username = user;
    entries = [
      { path = "/Applications/Dia.app"; }
      { path = "/System/Applications/Mail.app"; }
      { path = "/System/Applications/Calendar.app"; }
      { path = "/System/Applications/Messages.app"; }
      { path = "${pkgs.signal-desktop-bin}/Applications/Signal.app"; }
      { path = "${pkgs.slack}/Applications/Slack.app"; }
      { path = "/Applications/Telegram.app"; }
      { path = "${pkgs.spotify}/Applications/Spotify.app"; }
      { path = "${pkgs.notion-app}/Applications/Notion.app"; }
      { path = "${pkgs.ghostty-bin}/Applications/Ghostty.app"; }
      { path = "${pkgs.zed-editor}/Applications/Zed.app"; }
      { path = "${pkgs.anki-bin}/Applications/Anki.app"; }
      { path = "/System/Applications/System Settings.app"; }
    ];
  };
}
