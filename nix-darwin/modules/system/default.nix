{ config, pkgs, lib, user, ... }:

{
  ## Core system
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;
  
  system.activationScripts.postActivation.text = ''
    printf "Disabling Spotlight on /nix... "
    touch /nix/.metadata_never_index
    echo "ok"
  '';

  ## Nix settings
  # Let Determinate Nix handle Nix configuration
  nix.enable = false;
  nix.settings.experimental-features = "nix-command flakes";
  nix.extraOptions = ''
    extra-platforms = aarch64-darwin
  '';

  ## Users
  users.users.${user} = {
    uid = 501;
    home = "/Users/${user}";
  };

  ## Touch‑ID sudo
  security.pam.services.sudo_local.touchIdAuth = true;
}