_:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableFishIntegration = true;
    config.global = {
      hide_env_diff = true;
    };
  };
}
