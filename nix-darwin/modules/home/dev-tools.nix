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
    git-lfs
    ripgrep
    fd
    fastfetch
    kubectl
    kubectx
    btop

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
    
    # Apps from nixpkgs
    signal-desktop-bin
    slack
    anki-bin
    spotify
    notion-app # using overlay for version 4.15.3 to fix auto-update
    # _1password-gui # Commented out: needs to be in /Applications to work properly
                    # Error: "1Password is not installed inside of /Applications. Please move 1Password and restart the app."
    tailscale
    protonvpn
    
    # Foundry tools (nightly)
    foundry-bin
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