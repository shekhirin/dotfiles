{
  pkgs,
  lib,
  ...
}:

{
  home = {
    packages = with pkgs; [
      rustup
      lldb
      go
      uv
      bun

      cmake
      protobuf
      ccache
      pkg-config

      docker
      kubectl
      kubectx

      claude-code
    ];

    activation.rustupToolchains = lib.hm.dag.entryAfter [ "installPackages" ] ''
      ${lib.getExe pkgs.rustup} toolchain install stable nightly
      ${lib.getExe pkgs.rustup} default stable
      ${lib.getExe pkgs.rustup} component add --toolchain nightly rust-analyzer
    '';
  };
}
