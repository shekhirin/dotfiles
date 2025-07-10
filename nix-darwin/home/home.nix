{
  pkgs,
  lib,
  ...
}:
{
  home.stateVersion = "25.05";

  home.sessionVariables = {
    # Append brew to PATH. We're not using `home.sessionPath` because it's prepending, and we want nix binaries to take precedence.
    # TODO: Remove when fully migrated to nix pkgs
    PATH = "$PATH:/opt/homebrew/bin:/opt/homebrew/sbin";
  };

  home.packages = with pkgs; [
    # tools
    bat
    eza
    just
    vim
    git

    # nix
    nil
    nixd
    nixfmt-rfc-style

    # rust
    rustup

    docker

    # GPG
    gnupg
    pinentry_mac

    bun
    uv
  ];

  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${lib.getExe pkgs.pinentry_mac}
  '';

  home.activation.rustupToolchains = lib.hm.dag.entryAfter [ "installPackages" ] ''
    ${lib.getExe pkgs.rustup} toolchain install stable nightly
    ${lib.getExe pkgs.rustup} default stable
    ${lib.getExe pkgs.rustup} component add --toolchain nightly rust-analyzer
  '';

  programs.nushell = {
    enable = true;

    shellAliases = {
      cd = "z";
    };
    configFile.source = ./config.nu;
    environmentVariables = {
      EDITOR = "vim";
    };
  };

  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    enableCompletion = true;
    dotDir = ".config/zsh";
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "docker"
        "docker-compose"
      ];
    };

    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        export HOMEBREW_NO_ENV_HINTS=yes
        source ~/.env.secrets

        bindkey "\e[1;3D" backward-word
        bindkey "\e[1;3C" forward-word
      '')
      (lib.mkAfter ''
        zellij_tab_name_update() {
          if [[ -n $ZELLIJ ]]; then
            local current_dir=$PWD
            [[ $current_dir == $HOME ]] && current_dir="~" || current_dir=''${current_dir##*/}
            command nohup zellij action rename-tab $current_dir >/dev/null 2>&1
          fi
        }

        zellij_tab_name_update
        chpwd_functions+=(zellij_tab_name_update)

        yolo () {
          (cd ~/Projects/oss/claude-workspaces/claude-yolo && docker compose run --rm claude-yolo "$@")
        }

        eval "$(starship init zsh)"
        if [[ -z "$CLAUDECODE" ]]; then
          eval "$(zoxide init --cmd cd zsh)"
        fi
      '')
    ];
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

  programs.zellij = {
    enable = true;

    settings = {
      default_shell = "nu";
      keybinds = {
        tab = {
          "bind \"i\"" = {
            MoveTab = "Left";
          };
          "bind \"o\"" = {
            MoveTab = "Right";
          };
        };

        session = {
          # Conflicts with vim
          unbind = "Ctrl o";
        };

        "shared_except \"locked\"" = {
          unbind = [
            # Conflicts with zsh word jump keybinds
            "Alt Left"
            "Alt Right"
            # Tmux
            "Ctrl b"
          ];

          "bind \"Alt h\"" = {
            MoveFocusOrTab = "Left";
          };
          "bind \"Alt l\"" = {
            MoveFocusOrTab = "Right";
          };
        };

        "shared_except \"session\" \"locked\"" = {
          # Conflicts with vim
          unbind = "Ctrl o";
        };
      };

      plugins = { };
      # Choose the theme that is specified in the themes section.
      theme = "catppuccin-mocha";
      # The name of the default layout to load on startup
      default_layout = "compact";
      # Toggle having pane frames around the panes
      pane_frames = false;
      # Whether sessions should be serialized to the cache folder
      # (including their tabs/panes, cwds and running commands) so that they can later be resurrected
      session_serialization = false;
      # Whether to show tips on startup
      show_startup_tips = false;
    };
  };

  programs.zoxide = {
    enable = true;

    enableNushellIntegration = true;
  };

  programs.git = {
    enable = true;
    delta.enable = true;
    extraConfig = {
      core = {
        editor = "vim";
      };
    };
  };
}
