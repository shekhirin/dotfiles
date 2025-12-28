{ pkgs, ... }:

{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "Alexey Shekhirin";
        email = "5773434+shekhirin@users.noreply.github.com";
      };
      ui = {
        diff-formatter = [
          "${pkgs.difftastic}/bin/difft"
          "--color=always"
          "$left"
          "$right"
        ];
      };
    };
  };
}
