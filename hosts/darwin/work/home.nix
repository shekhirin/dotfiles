{ pkgs, ... }:

{
  home.packages = with pkgs; [
    minio-client
  ];

  home.file.".ideavimrc".text = ''
    set scrolloff=5
    set clipboard+=unnamed
  '';
}
