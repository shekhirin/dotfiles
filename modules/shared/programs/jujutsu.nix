{ pkgs, ... }:

{
  programs.jujutsu = {
    enable = true;
    settings = {
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
