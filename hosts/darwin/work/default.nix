{ pkgs, ... }@inputs:

let
  user = "shekhirin";
in
{
  _module.args = { inherit user; };

  ## Core system
  nixpkgs.hostPlatform = "aarch64-darwin";
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
    extraSpecialArgs = { inherit inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    users.shekhirin = {
      home.stateVersion = "25.05";
    };
  };
}
