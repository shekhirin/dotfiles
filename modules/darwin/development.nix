{
  pkgs,
  lib,
  ...
}:

{
  home = {
    packages =
      # Pull codex from the nixpkgs PR input for the current system
      with pkgs; [
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
        codex
        amp-cli
      ];

    sessionVariables = {
      # Append brew to PATH. We're not using `home.sessionPath` because it's prepending, and we want nix binaries to take precedence.
      # TODO: Remove when fully migrated to nix pkgs
      PATH = "$PATH:/opt/homebrew/bin:/opt/homebrew/sbin";
    };

    activation.rustupToolchains = lib.hm.dag.entryAfter [ "installPackages" ] ''
      ${lib.getExe pkgs.rustup} toolchain install stable nightly
      ${lib.getExe pkgs.rustup} default stable
      ${lib.getExe pkgs.rustup} component add --toolchain nightly rust-analyzer
    '';
  };
}
