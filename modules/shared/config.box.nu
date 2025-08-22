# NixOS box-specific aliases and functions

def u [] {
  sudo nixos-rebuild switch --flake github:shekhirin/dotfiles#box --refresh
}
