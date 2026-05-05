{ pkgs, llm-agents, ... }@inputs:

let
  user = "shekhirin";
in
{
  imports = [
    ../../../modules/shared
    ../../../modules/darwin/determinate-nix.nix
    ../../../modules/darwin/fonts.nix
  ];

  _module.args = { inherit user; };

  ## Core system
  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "shekhirin-tempo";
  system = {
    stateVersion = 6;
    primaryUser = user;
    defaults = {
      NSGlobalDomain.ApplePressAndHoldEnabled = false;
      screencapture.location = "~/Pictures/Screenshots";
      dock.autohide = true;
    };
  };

  ## Nix settings
  nix.enable = false;

  ## Launchd limits
  launchd = {
    daemons.ulimit-maxfiles = {
      command = "/bin/launchctl limit maxfiles unlimited unlimited";
      serviceConfig = {
        RunAtLoad = true;
      };
    };

    user.agents.ulimit-maxfiles = {
      command = "/bin/launchctl limit maxfiles unlimited unlimited";
      serviceConfig = {
        RunAtLoad = true;
      };
    };
  };

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
      { path = "/Applications/Helium.app"; }
      { path = "/Applications/Notion Calendar.app"; }
      { path = "/Applications/Discord.app"; }
      { path = "/Applications/Slack.app"; }
      { path = "/Applications/Telegram.app"; }
      { path = "/Applications/Linear.app"; }
      { path = "${pkgs.ghostty-bin}/Applications/Ghostty.app"; }
      { path = "${pkgs.zed-editor-preview-bin}/Applications/Zed Preview.app"; }
      { path = "/System/Applications/System Settings.app"; }
    ];
  };

  home-manager = {
    extraSpecialArgs = { inherit inputs llm-agents; };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.shekhirin = {
      imports = [
        ../../../modules/shared/home.nix
        ../../../modules/darwin
        ./home.nix
      ];

      home.stateVersion = "25.05";
    };
  };
}
