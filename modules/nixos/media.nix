{ pkgs, ... }:

{
  # Media services configuration
  services.shoko = {
    enable = true;
    package = pkgs.shoko;
    webui = null;
    openFirewall = true;
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
}
