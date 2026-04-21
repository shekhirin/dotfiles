{ pkgs, ... }:

{
  programs.vim = {
    enable = true;
    defaultEditor = true;
    packageConfigurable = pkgs.vim;

    extraConfig = ''
      set clipboard=unnamed
    '';
  };
}
