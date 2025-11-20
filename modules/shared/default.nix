{ ... }:

{
  # System-level shared configuration
  # This module is imported at the system level, so only include
  # system configuration options here (not home-manager options)
  imports = [
    ./nix-settings.nix
    ./services/tailscale.nix
  ];
}
