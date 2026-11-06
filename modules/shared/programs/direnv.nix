{ inputs, ... }:

{
  programs.direnv = {
    enable = true;
    # `use flake` goes through `iets print-dev-env` instead of nix-direnv.
    nix-direnv.enable = false;
    stdlib = builtins.readFile "${inputs.iets}/nix/direnvrc";
    enableFishIntegration = true;
    config.global = {
      hide_env_diff = true;
    };
  };
}
