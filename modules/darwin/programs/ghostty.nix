{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty-bin;

    installBatSyntax = true;
    settings = {
      auto-update = "off";

      theme = "dark:Catppuccin Mocha,light:Catppuccin Latte";

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
      shell-integration-features = "sudo,ssh-env,ssh-terminfo";

      keybind = [
        "ctrl+q=esc:q"
        "cmd+q=ignore"
        "alt+left=unbind"
        "alt+right=unbind"
        "shift+enter=text:\\n"
      ];
    };
  };
}
