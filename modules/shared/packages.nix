{ inputs, pkgs, ... }:

let
  boxctl = pkgs.callPackage ./boxctl.nix { src = inputs.boxctl-src; };
in
{
  home.packages = with pkgs; [
    # Core tools
    git
    git-lfs
    gh
    just

    # Kubernetes
    k9s

    # CLI utilities
    boxctl
    bat
    eza
    ripgrep
    fd
    btop
    hwatch
    starship
    fastfetch
    glow
    dust
    foundry

    # Terminal multiplexer
    tmux

    # Nix development
    nil
    nixd
    statix
  ];
}
