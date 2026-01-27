{
  pkgs,
  lib,
  llm-agents,
  ...
}:

let
  llm-agents-pkgs = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
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

      argo-workflows
      docker
      kubectl
      kubectx

      llm-agents-pkgs.claude-code
      llm-agents-pkgs.amp
      llm-agents-pkgs.opencode
    ];

    activation.rustupToolchains = lib.hm.dag.entryAfter [ "installPackages" ] ''
      ${lib.getExe pkgs.rustup} toolchain install stable nightly
      ${lib.getExe pkgs.rustup} default stable
      ${lib.getExe pkgs.rustup} component add --toolchain nightly rust-analyzer
    '';
  };
}
