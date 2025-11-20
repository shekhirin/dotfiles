{ ... }:

{
  imports = [
    ./nix-settings.nix

    # Services
    ./services/tailscale.nix
  ];
}
