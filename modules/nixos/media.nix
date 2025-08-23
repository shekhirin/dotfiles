{ pkgs, ... }:

{
  # Create media directory with correct permissions
  systemd.tmpfiles.rules = [
    "d /mnt/nvme/media 0755 root media -"
    "Z /mnt/nvme/media 0755 root media -"
  ];

  # Create media group for shared access
  users.groups.media = { };

  # Media services configuration
  services.shoko = {
    enable = true;
    package = pkgs.shoko;
    webui = null;
    openFirewall = true;
  };

  services.declarative-jellyfin = {
    enable = true;
    openFirewall = true;
  };

  # Configure Jellyfin user to access media directory
  systemd.services.jellyfin.serviceConfig = {
    SupplementaryGroups = [ "media" ];
  };
}
