{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    gnupg
    pinentry-curses
  ];

  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${lib.getExe pkgs.pinentry-curses}
  '';
}
