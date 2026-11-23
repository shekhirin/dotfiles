{ lib, ... }:

{
  programs.git.settings.user.email = lib.mkForce "alexey@tempo.xyz";
  programs.jujutsu.settings.user.email = lib.mkForce "alexey@tempo.xyz";

  home.file.".ideavimrc".text = ''
    set scrolloff=5
    set clipboard+=unnamed
  '';
}
