{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # GPG
    gnupg
    pinentry_mac
  ];

  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program ${lib.getExe pkgs.pinentry_mac}
  '';
}
