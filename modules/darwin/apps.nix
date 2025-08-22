{ pkgs, ... }:

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

  # ProtonMail Bridge service
  launchd.agents.protonmail-bridge = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.protonmail-bridge}/bin/protonmail-bridge"
        "--noninteractive"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/protonmail-bridge.stdout.log";
      StandardErrorPath = "/tmp/protonmail-bridge.stderr.log";
    };
  };

  programs.aerospace = {
    enable = true; # installs & configures AeroSpace
    launchd.enable = true; # manage it via launchd (autostart)

    userSettings =
      let
        # List of always floating apps
        floaters = [
          "calendar"
          "finder"
          "mail"
          "messages"
          "signal"
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

            alt-c = "exec-and-forget open -a /Applications/Google\\ Chrome.app";
            alt-t = "exec-and-forget open -a /Applications/Ghostty.app";
            alt-z = "exec-and-forget open -a /Applications/Zed.app";

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

  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;

    installBatSyntax = true;
    settings = {
      auto-update-channel = "tip";
      theme = "dark:catppuccin-mocha,light:catppuccin-latte";

      font-family = "JetBrains Mono";
      font-family-bold = "JetBrains Mono";
      font-family-italic = "JetBrains Mono";
      font-family-bold-italic = "JetBrains Mono";
      font-size = 12;
      font-feature = "-calt";

      clipboard-paste-protection = false;
      mouse-hide-while-typing = true;
      resize-overlay = "never";

      macos-option-as-alt = "left";

      command = "/bin/zsh -l -c 'zellij attach main || zellij -s main'";
      shell-integration-features = "sudo";

      keybind = [
        "ctrl+q=esc:q"
        "cmd+q=ignore"
        "alt+left=unbind"
        "alt+right=unbind"
        "shift+enter=text:\\n"
      ];
    };
  };

  programs.zed-editor = {
    enable = true;
    userSettings = {
      agent = {
        default_profile = "write";
        always_allow_tool_actions = false;
        default_model = {
          provider = "zed.dev";
          model = "claude-opus-4";
        };
        model_parameters = [ ];
        inline_assistant_model = {
          provider = "zed.dev";
          model = "claude-opus-4";
        };
      };
      vim_mode = true;
      ui_font_size = 14;
      buffer_font_size = 12;
      buffer_font_features = {
        calt = false;
      };
      buffer_font_fallbacks = [ "JetBrains Mono" ];
      theme = {
        mode = "system";
        light = "Catppuccin Latte - No Italics";
        dark = "Catppuccin Mocha - No Italics";
      };
      lsp = {
        rust-analyzer = {
          initialization_options = {
            cargo = {
              targetDir = true;
              features = "all";
            };
            check = {
              command = "clippy";
              extraArgs = [ "--no-deps" ];
              features = "all";
            };
            rustfmt = {
              extraArgs = [ "+nightly" ];
            };
            workspace = {
              symbol = {
                search = {
                  kind = "all_symbols";
                };
              };
            };
          };
        };
      };
      languages = {
        TOML = {
          language_servers = [ "!Taplo" ];
        };
      };
      file_types = {
        Dockerfile = [ "Dockerfile*" ];
      };
      autosave = "on_focus_change";
      terminal = {
        shell = {
          program = "nu";
        };
      };
    };
  };
}
