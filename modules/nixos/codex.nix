{ inputs, pkgs, ... }:

let
  llm-agents-pkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = [
    llm-agents-pkgs.codex
  ];
}
