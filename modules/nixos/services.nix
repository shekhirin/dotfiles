{ ... }:

{
  # Services specific to NixOS
  services.openssh.enable = true;
  services.tailscale.enable = true;

  # Programs
  programs.mosh.enable = true;
}
