_:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableNushellIntegration = true;
    config.global = {
      hide_env_diff = true;
    };
  };
}
