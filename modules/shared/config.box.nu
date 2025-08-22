# NixOS box-specific aliases and functions

def u [] {
  nix-collect-garbage
  sudo nixos-rebuild switch --flake github:shekhirin/dotfiles/main#box --option tarball-ttl 0
}
