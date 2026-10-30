{
  pkgs,
  llm-agents,
  ...
}:

let
  llm-agents-pkgs = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home = {
    packages = with pkgs; [
      lldb
      go
      uv
      bun

      cmake
      protobuf
      # nixpkgs adds Linux-only elfutils to ccache's test dependencies on Darwin.
      ((ccache.override { elfutils = null; }).overrideAttrs (old: {
        preCheck = old.preCheck + ''
          # The compiler wrapper adds flags unused by preprocessing-only tests.
          export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -Wno-unused-command-line-argument"
        '';
      }))
      pkg-config

      argo-workflows
      docker
      kubectl
      kubectx

      llm-agents-pkgs.amp
      llm-agents-pkgs.claude-code
      llm-agents-pkgs.codex
    ];

  };
}
