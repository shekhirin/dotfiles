{
  lib,
  pkgs,
  inputs,
  llm-agents,
  ...
}:

let
  user = "shekhirin";
  tailscalePackage = pkgs.tailscale-gui;
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
    activationScripts.applications.text = lib.mkAfter ''
      install -o root -g wheel -m0555 -d "/Applications/Tailscale.app"
      rsyncFlags=(
        --checksum
        --copy-unsafe-links
        --archive
        --delete
        --chmod=-w
        --no-group
        --no-owner
      )
      ${lib.getExe pkgs.rsync} "''${rsyncFlags[@]}" \
        ${tailscalePackage}/Applications/Tailscale.app/ /Applications/Tailscale.app
    '';
    defaults = {
      NSGlobalDomain.ApplePressAndHoldEnabled = false;
      screencapture.location = "~/Pictures/Screenshots";
      dock.autohide = true;
    };
  };

  ## Nix settings
  nix.enable = false;

  # The GUI provides its own System Extension and must be installed in /Applications.
  services.tailscale.enable = lib.mkForce false;

  ## Launchd limits
  launchd = {
    daemons.ulimit-maxfiles = {
      command = "/bin/launchctl limit maxfiles 128000 524288";
      serviceConfig = {
        RunAtLoad = true;
      };
    };

    user.agents.ulimit-maxfiles = {
      command = "/bin/launchctl limit maxfiles 128000 524288";
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
      { path = "/Applications/ChatGPT.app"; }
      { path = "${pkgs.ghostty-bin}/Applications/Ghostty.app"; }
      { path = "${pkgs.zed-editor-preview-bin}/Applications/Zed Preview.app"; }
      { path = "/System/Applications/System Settings.app"; }
    ];
  };

  home-manager = {
    extraSpecialArgs = {
      inherit inputs llm-agents;
    };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.shekhirin = {
      imports = [
        ../../../modules/shared/home.nix
        ../../../modules/darwin
        ./home.nix
      ];

      local.omniwm = {
        enable = true;
        borders.enable = false;

        keybindings = {
          "focus.left" = "Option+H";
          "focus.down" = "Option+J";
          "focus.up" = "Option+K";
          "focus.right" = "Option+L";

          "move.left" = "Option+Shift+H";
          "move.down" = "Option+Shift+J";
          "move.up" = "Option+Shift+K";
          "move.right" = "Option+Shift+L";

          focusMonitorPrevious = "Option+S";
          focusMonitorNext = "Option+G";
          "moveWindowToMonitor.left" = "Option+Shift+S";
          "moveWindowToMonitor.right" = "Option+Shift+G";

          "setContainerPrimarySpan.decrease10Percent" = "Control+Option+H";
          "setContainerPrimarySpan.increase10Percent" = "Control+Option+L";
          "setWindowSecondarySpan.decrease10Percent" = "Control+Option+J";
          "setWindowSecondarySpan.increase10Percent" = "Control+Option+K";
          balanceSizes = "Control+Option+B";

          expandContainerToAvailablePrimarySpan = "Unassigned";
          toggleFocusedWindowFloating = "Control+Option+F";
          toggleWorkspaceLayout = "Unassigned";
        };

        floatingApps = [
          "com.apple.iCal"
          "com.apple.finder"
          "com.apple.mail"
          "com.apple.MobileSMS"
          "org.whispersystems.signal-desktop"
          "com.1password.1password"
          "com.cron.electron"
          "com.linear"
        ];

        workspaces = [
          { }
          { }
          { }
          { }
          { }
        ];

        extraSettings.general.ipcEnabled = true;
      };

      home.stateVersion = "25.05";
    };
  };
}
