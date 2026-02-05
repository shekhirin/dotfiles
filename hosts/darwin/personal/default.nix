{ pkgs, llm-agents, ... }@inputs:

let
  user = "shekhirin";
in
{
  imports = [
    ../../../modules/shared
    ../../../modules/darwin/determinate-nix.nix
  ];

  _module.args = { inherit user; };
  ## Core system
  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "shekhirin";
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
      { path = "/Applications/Proton Mail.app"; }
      { path = "/System/Applications/Calendar.app"; }
      { path = "/System/Applications/Messages.app"; }
      { path = "/Applications/Signal.app"; }
      { path = "/Applications/Slack.app"; }
      { path = "/Applications/Telegram.app"; }
      { path = "/Applications/Spotify.app"; }
      { path = "/Applications/Linear.app"; }
      { path = "${pkgs.ghostty-bin}/Applications/Ghostty.app"; }
      { path = "${pkgs.zed-editor-preview-bin}/Applications/Zed Preview.app"; }
      { path = "/Applications/Anki.app"; }
      { path = "/System/Applications/System Settings.app"; }
    ];
  };

  home-manager = {
    # Allow shared modules to access flake inputs
    extraSpecialArgs = { inherit inputs llm-agents; };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.shekhirin = {
      imports = [
        # Shared home-manager configuration (packages and programs)
        ../../../modules/shared/home.nix
        # Darwin-specific configuration
        ../../../modules/darwin
      ];

      home.stateVersion = "25.05";
    };
  };
}
