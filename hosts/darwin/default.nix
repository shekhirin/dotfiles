{ pkgs, ... }:

let
  user = "shekhirin";
in
{
  imports = [
    ../../modules/shared
  ];

  _module.args = { inherit user; };
  ## Core system
  nixpkgs.hostPlatform = "aarch64-darwin";
  system = {
    stateVersion = 6;
    primaryUser = user;
    defaults = {
      screencapture.location = "~/Pictures/Screenshots";
      dock.autohide = true;
    };
  };

  ## Nix settings
  # Let Determinate Nix handle Nix configuration
  nix.enable = false;
  nix.extraOptions = ''
    extra-platforms = aarch64-darwin
  '';

  ## Users
  users.users.${user} = {
    uid = 501;
    home = "/Users/${user}";
  };

  ## Touch‑ID sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  ## Dock configuration
  local.dock = {
    enable = true;
    username = user;
    entries = [
      { path = "/Applications/Brave Browser.app"; }
      { path = "/System/Applications/Mail.app"; }
      { path = "/System/Applications/Calendar.app"; }
      { path = "/System/Applications/Messages.app"; }
      { path = "/Applications/Signal.app"; }
      { path = "/Applications/Slack.app"; }
      { path = "/Applications/Telegram.app"; }
      { path = "/Applications/Spotify.app"; }
      { path = "/Applications/Linear.app"; }
      { path = "${pkgs.ghostty-bin}/Applications/Ghostty.app"; }
      { path = "${pkgs.zed-editor}/Applications/Zed.app"; }
      { path = "/Applications/Anki.app"; }
      { path = "/System/Applications/System Settings.app"; }
    ];
  };
}
