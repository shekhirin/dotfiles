_:

{
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
}
