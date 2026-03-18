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
      ccache
      pkg-config

      argo-workflows
      docker
      kubectl
      kubectx

      llm-agents-pkgs.amp
      llm-agents-pkgs.claude-code
      llm-agents-pkgs.codex
      llm-agents-pkgs.opencode
    ];

  };
}
