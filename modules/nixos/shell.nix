_:

{
  # Extend fish configuration with NixOS-specific config
  programs.fish = {
    shellInit = ''
      set -gx DOCKER_HOST "unix:///var/run/docker.sock"
    '';
  };
}
