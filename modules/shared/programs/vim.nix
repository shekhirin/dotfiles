{ pkgs, ... }:

{
  programs.vim = {
    enable = true;
    defaultEditor = true;
    packageConfigurable = pkgs.vim;

    extraConfig = ''
      set clipboard=unnamed

      " Suppress jjdescription syntax error in Vim 9.2.0340 (`:g` typo in shipped syntax file)
      autocmd BufRead *.jjdescription set filetype=gitcommit
    '';
  };
}
