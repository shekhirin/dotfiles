{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Core tools
    vim
    git
    git-lfs
    gh
    just

    # Kubernetes
    k9s

    # CLI utilities
    bat
    eza
    ripgrep
    fd
    btop
    starship
    fastfetch
    glow
    dust
    foundry
    mesc

    # Terminal multiplexer
    tmux

    # Nix development
    nil
    nixd
    statix
  ];
}
