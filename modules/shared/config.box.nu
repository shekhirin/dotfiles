# NixOS box-specific aliases and functions

def u [] {
  nix flake prefetch github:shekhirin/dotfiles
  sudo nixos-rebuild switch --flake github:shekhirin/dotfiles#box
}
