{ pkgs, ... }:

{
  programs.jujutsu = {
    enable = true;
    settings = {
      signing = {
        backend = "gpg";
      };
      ui = {
        diff-formatter = [
          "${pkgs.difftastic}/bin/difft"
          "--color=always"
          "$left"
          "$right"
        ];
      };
      user = {
        name = "Alexey Shekhirin";
        email = "github@shekhirin.com";
      };
    };
  };
}
