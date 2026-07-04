_:

{
  # Extend fish configuration with NixOS-specific config
  programs.fish = {
    shellInit = ''
      set -gx DOCKER_HOST "unix:///var/run/docker.sock"
    '';
    functions = {
      mount-personal-projects = {
        description = "Mount personal laptop projects";
        body = ''
          set -l mountpoint "$HOME/projects"
          mkdir -p "$mountpoint"

          if mountpoint -q "$mountpoint"
            echo "$mountpoint is already mounted"
            return 0
          end

          sshfs \
            -o reconnect \
            -o ServerAliveInterval=15 \
            -o ServerAliveCountMax=3 \
            shekhirin@100.80.35.112:/Users/shekhirin/projects/box \
            "$mountpoint"
        '';
      };

      umount-personal-projects = {
        description = "Unmount personal laptop projects";
        body = ''
          set -l mountpoint "$HOME/projects"

          if not mountpoint -q "$mountpoint"
            echo "$mountpoint is not mounted"
            return 0
          end

          fusermount3 -u "$mountpoint"
        '';
      };

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
