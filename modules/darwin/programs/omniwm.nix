{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.local.omniwm;
  defaultKeybindings = import ./omniwm-keybindings.nix;

  uuidFor =
    seed:
    let
      hash = builtins.hashString "sha256" "local.omniwm:${seed}";
    in
    builtins.concatStringsSep "-" [
      (builtins.substring 0 8 hash)
      (builtins.substring 8 4 hash)
      "5${builtins.substring 13 3 hash}"
      "8${builtins.substring 17 3 hash}"
      (builtins.substring 20 12 hash)
    ];

  keybindings = defaultKeybindings // cfg.keybindings;
  activeKeybindings = lib.filterAttrs (_: binding: binding != "Unassigned") keybindings;
  hotkeys = lib.mapAttrsToList (id: binding: { inherit id binding; }) activeKeybindings;

  activeBindings = map (hotkey: hotkey.binding) (
    lib.filter (hotkey: hotkey.binding != "Unassigned") hotkeys
  );
  duplicateBindings = lib.unique (
    lib.filter (binding: lib.count (candidate: candidate == binding) activeBindings > 1) activeBindings
  );

  appRules = map (bundleId: {
    inherit bundleId;
    id = uuidFor "app:${bundleId}";
    layout = "float";
  }) cfg.floatingApps;

  workspaces = lib.imap0 (
    index: workspace:
    let
      name = toString (index + 1);
    in
    {
      inherit name;
      id = uuidFor "workspace:${name}";
      layoutType = workspace.layout;
      monitorAssignment.type = workspace.monitor;
    }
    // lib.optionalAttrs (workspace.displayName != null) {
      inherit (workspace) displayName;
    }
  ) cfg.workspaces;

  generatedSettings = {
    borders.enabled = cfg.borders.enable;
    inherit appRules hotkeys workspaces;
  };
in
{
  imports = [ "${inputs.omniwm-nix}/modules/home/omniwm.nix" ];

  options.local.omniwm = {
    enable = lib.mkEnableOption "OmniWM with declarative defaults and concise overrides";

    borders.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to draw a border around the focused window.";
    };

    keybindings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Hotkey bindings keyed by OmniWM action ID and merged over the defaults.";
    };

    floatingApps = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Application bundle IDs that should always float.";
    };

    workspaces = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            layout = lib.mkOption {
              type = lib.types.enum [
                "default"
                "niri"
                "dwindle"
              ];
              default = "niri";
              description = "Layout used by the workspace.";
            };

            monitor = lib.mkOption {
              type = lib.types.enum [
                "main"
                "secondary"
              ];
              default = "main";
              description = "Monitor assignment for the workspace.";
            };

            displayName = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Optional label shown instead of the sequential workspace number.";
            };
          };
        }
      );
      default = [ ];
      description = "Sequential workspaces; array position determines the one-based workspace number.";
    };

    extraSettings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Additional raw OmniWM settings recursively merged over generated settings.";
    };

    launchd.keepAlive = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether launchd should restart OmniWM after it exits.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = duplicateBindings == [ ];
        message = "Duplicate OmniWM hotkey bindings: ${lib.concatStringsSep ", " duplicateBindings}";
      }
      {
        assertion = builtins.length cfg.floatingApps == builtins.length (lib.unique cfg.floatingApps);
        message = "local.omniwm.floatingApps contains duplicate bundle IDs";
      }
      {
        assertion = cfg.workspaces != [ ];
        message = "local.omniwm.workspaces must contain at least one workspace";
      }
    ];

    programs.aerospace.enable = lib.mkForce false;
    programs.omniwm = {
      enable = true;
      package = pkgs.callPackage "${inputs.omniwm-nix}/pkgs/omniwm.nix" { };
      settings = lib.recursiveUpdate generatedSettings cfg.extraSettings;
      launchd = {
        enable = true;
        inherit (cfg.launchd) keepAlive;
      };
    };
  };
}
