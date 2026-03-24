_:

{
  # Extend fish configuration with NixOS-specific config
  programs.fish = {
    shellInit = ''
      set -gx DOCKER_HOST "unix:///var/run/docker.sock"
    '';
    functions = {
      u = {
        description = "Update NixOS from dotfiles";
        body = ''
          sudo nix flake prefetch github:shekhirin/dotfiles --refresh
          sudo nixos-rebuild switch --flake github:shekhirin/dotfiles#box
        '';
      };
    };
  };
}
