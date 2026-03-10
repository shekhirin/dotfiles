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

  home.file.".ideavimrc".text = ''
    set scrolloff=5
    set clipboard+=unnamed
  '';
}
