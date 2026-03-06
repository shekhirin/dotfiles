{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Core tools
    vim
    git
    git-lfs
    gh
    just

    # CLI utilities
    bat
    eza
    ripgrep
    fd
    btop
    direnv
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
