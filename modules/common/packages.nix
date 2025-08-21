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

    # Nix development
    nil
    nixd
    nixfmt
    nixfmt-tree
  ];

  programs.git = {
    enable = true;
    delta.enable = true;
    extraConfig = {
      core = {
        editor = "vim";
      };
    };
  };
}