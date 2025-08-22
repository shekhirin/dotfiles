{ pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    # Heavy development tools (macOS only)
    rustup
    lldb
    go

    # Build tools
    cmake
    protobuf
    ccache
    pkg-config
    ffmpeg

    # Deployment and orchestration
    colmena
    kubectl
    kubectx

    # Specialized tools
    foundry
    uv
    bun
    yt-dlp

    # Containerization
    docker

    # Additional CLI tools
    claude-code
  ];

  home.activation.rustupToolchains = lib.hm.dag.entryAfter [ "installPackages" ] ''
    ${lib.getExe pkgs.rustup} toolchain install stable nightly
    ${lib.getExe pkgs.rustup} default stable
    ${lib.getExe pkgs.rustup} component add --toolchain nightly rust-analyzer
  '';
}
