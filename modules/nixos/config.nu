# NixOS box-specific aliases and functions

def u [] {
  sudo nix flake prefetch github:shekhirin/dotfiles --refresh
  sudo nixos-rebuild switch --flake github:shekhirin/dotfiles#box
}
