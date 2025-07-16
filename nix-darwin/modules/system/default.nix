{ user, ... }:

{
  ## Core system
  nixpkgs.hostPlatform = "aarch64-darwin";
  system.stateVersion = 6;

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

  ## Tailscale
  services.tailscale = {
    enable = true;
  };

  ## Touch‑ID sudo
  security.pam.services.sudo_local.touchIdAuth = true;
}
