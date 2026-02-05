{ pkgs, llm-agents, ... }@inputs:

let
  user = "shekhirin";
in
{
  imports = [
    ../../../modules/shared
  ];

  _module.args = { inherit user; };

  ## Core system
  nixpkgs.hostPlatform = "aarch64-darwin";
  networking.hostName = "shekhirin-tempo";
  system = {
    stateVersion = 6;
    primaryUser = user;
  };

  ## Nix settings
  nix.enable = false;

  ## Users
  users.users.${user} = {
    uid = 501;
    home = "/Users/${user}";
  };

  ## Touch‑ID sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  home-manager = {
    extraSpecialArgs = { inherit inputs llm-agents; };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.shekhirin = {
      imports = [
        ../../../modules/shared/home.nix
        ../../../modules/darwin
      ];

      home.stateVersion = "25.05";
    };
  };
}
