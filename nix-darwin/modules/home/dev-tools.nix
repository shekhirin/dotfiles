{ pkgs, lib, ... }:

let
  rudy = pkgs.rudy-lldb;
in
{
  home.packages = with pkgs; [
    # tools
    bat
    eza
    just
    vim
    git

    # nix
    nil
    nixd
    nixfmt-rfc-style

    # rust
    rustup
    lldb
    rudy-lldb

    docker

    bun
    uv
    
  ];

  home.activation.rustupToolchains = lib.hm.dag.entryAfter [ "installPackages" ] ''
    ${lib.getExe pkgs.rustup} toolchain install stable nightly
    ${lib.getExe pkgs.rustup} default stable
    ${lib.getExe pkgs.rustup} component add --toolchain nightly rust-analyzer
  '';

  home.file.".lldb/rudy_lldb.py".source = "${rudy}/share/lldb/rudy_lldb.py";
  home.file.".lldbinit".text = ''
    command script import ~/.lldb/rudy_lldb.py
  '';

  programs.git = {
    enable = true;
    delta.enable = true;
    extraConfig = {
      core = {
        editor = "vim";
      };
    };
  };
}