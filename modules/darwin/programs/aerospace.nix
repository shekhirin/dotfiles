{ pkgs, lib, ... }:

{
  # Reload aerospace config on activation
  home.activation.aerospaceReload = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if /usr/bin/pgrep -x "AeroSpace" > /dev/null; then
      run ${lib.getExe pkgs.aerospace} reload-config
    fi
  '';

  programs.aerospace = {
    enable = true; # installs & configures AeroSpace
    launchd.enable = true; # manage it via launchd (autostart)

    settings =
      let
        # List of always floating apps
        floaters = [
          "calendar"
          "finder"
          "mail"
          "messages"
          "signal"
          "1password"
        ];
        # Number of workspaces that you can switch between
        workspaceCount = 9;

        keybindsForWorkspaces = builtins.listToAttrs (
          builtins.concatLists (
            builtins.genList (
              n:
              let
                num = toString (n + 1);
              in
              [
                {
                  name = "alt-${num}";
                  value = "workspace ${num}";
                }
                {
                  name = "alt-shift-${num}";
                  value = "move-node-to-workspace ${num} --focus-follows-window";
                }
              ]
            ) workspaceCount
          )
        );
      in
      assert workspaceCount < 10;
      {
        start-at-login = true;
        after-login-command = [ ];
        after-startup-command = [ ];

        enable-normalization-flatten-containers = true;
        enable-normalization-opposite-orientation-for-nested-containers = true;
        default-root-container-layout = "tiles";
        default-root-container-orientation = "auto";
        on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
        automatically-unhide-macos-hidden-apps = false;

        on-window-detected = map (app: {
          "if" = {
            app-name-regex-substring = app;
          };
          run = "layout floating";
        }) floaters;

        enable-tabs-for-apps = [
          "com.mitchellh.ghostty"
          "dev.zed.Zed-Preview"
          "dev.zed.Zed"
        ];

        key-mapping.preset = "qwerty";

        gaps = {
          inner.horizontal = 0;
          inner.vertical = 0;
          outer = {
            left = 0;
            bottom = 0;
            top = 0;
            right = 0;
          };
        };

        mode = {
          main.binding = keybindsForWorkspaces // {
            alt-slash = "layout tiles horizontal vertical";

            alt-h = "focus left";
            alt-j = "focus down";
            alt-k = "focus up";
            alt-l = "focus right";

            alt-s = "focus-monitor prev";
            alt-g = "focus-monitor next";

            alt-shift-h = "move left";
            alt-shift-j = "move down";
            alt-shift-k = "move up";
            alt-shift-l = "move right";

            alt-ctrl-left = "join-with left";
            alt-ctrl-down = "join-with down";
            alt-ctrl-up = "join-with up";
            alt-ctrl-right = "join-with right";

            alt-ctrl-shift-f = "fullscreen";
            alt-ctrl-f = "layout floating tiling";

            alt-shift-s = "move-node-to-monitor prev";
            alt-shift-g = "move-node-to-monitor next";

            alt-minus = "resize smart -50";
            alt-equal = "resize smart +50";
            alt-shift-e = "balance-sizes";

            alt-t = "exec-and-forget open -a ${pkgs.ghostty-bin}/Applications/Ghostty.app";
            alt-z = "exec-and-forget open -a \"${pkgs.zed-editor-preview-bin}/Applications/Zed Preview.app\"";

            alt-shift-semicolon = "mode service";
          };

          service.binding = {
            esc = [
              "reload-config"
              "mode main"
            ];
          };
        };
      };
  };
}
