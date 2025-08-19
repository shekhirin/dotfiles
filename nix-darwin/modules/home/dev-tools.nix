{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # tools
    bat
    eza
    just
    vim
    git
    git-lfs
    gh
    ripgrep
    fd
    fastfetch
    glow
    kubectl
    starship
    kubectx
    btop
    claude-code
    direnv
    yt-dlp
    foundry

    # nix
    nil
    nixd
    nixfmt-rfc-style

    # rust
    rustup
    lldb

    # go
    go

    # zig
    zls

    # build tools
    cmake
    protobuf
    ccache
    pkg-config
    ffmpeg

    # containerization
    docker

    # package managers
    bun

    # python
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
    protonmail-bridge
  ];

  home.activation.rustupToolchains = lib.hm.dag.entryAfter [ "installPackages" ] ''
    ${lib.getExe pkgs.rustup} toolchain install stable nightly
    ${lib.getExe pkgs.rustup} default stable
    ${lib.getExe pkgs.rustup} component add --toolchain nightly rust-analyzer
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
