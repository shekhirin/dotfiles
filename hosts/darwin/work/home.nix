{ pkgs, ... }:

let
  layoutNu = ./layout.nu;
in
{
  home.packages = with pkgs; [
    minio-client
  ];

  programs.nushell.extraConfig = ''
    use ${layoutNu} *
  '';
}
