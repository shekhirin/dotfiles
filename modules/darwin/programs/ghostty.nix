{ pkgs, ... }:

{
  home.file.".hushlogin".text = "";

  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;

    installBatSyntax = true;
    settings = {
      auto-update = "off";
      auto-update-channel = "tip";

      theme = "dark:Catppuccin Mocha,light:Catppuccin Latte";

      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;
      font-feature = "-calt";

      clipboard-paste-protection = false;
      mouse-hide-while-typing = true;
      resize-overlay = "never";

      macos-option-as-alt = "left";

      command = "${pkgs.fish}/bin/fish --login --interactive";
      shell-integration-features = "sudo,ssh-env,ssh-terminfo";

      keybind = [
        "ctrl+q=esc:q"
        "cmd+q=ignore"
        "ctrl+shift+enter=toggle_split_zoom"
        "ctrl+shift+h=goto_split:left"
        "ctrl+shift+j=goto_split:bottom"
        "ctrl+shift+k=goto_split:top"
        "ctrl+shift+l=goto_split:right"
        "ctrl+shift+u=scroll_page_up"
        "ctrl+shift+d=scroll_page_down"
        "super+enter=unbind"
        "alt+left=unbind"
        "alt+right=unbind"
        "shift+enter=text:\\n"
      ];
    };
  };
}
