{ config, pkgs, ... }:

let
  # User group for media access
  group = "media";
in
{

  # Create media group for shared access
  users.groups."${group}" = { };

  # Create media directory with correct permissions
  systemd.tmpfiles.rules = [
    "d /mnt/nvme/media 0755 root ${group} -"
    "Z /mnt/nvme/media 0755 root ${group} -"
  ];

  # Media services configuration
  services.shoko = {
    enable = true;
    package = pkgs.shoko;
    openFirewall = true;
  };

  # Use Jellyfin admin password from SOPS
  sops.secrets.jellyfin-password = {
    owner = config.services.jellyfin.user;
  };

  services.declarative-jellyfin = {
    enable = true;
    openFirewall = true;

    users.admin = {
      mutable = false;
      permissions.isAdministrator = true;
      hashedPasswordFile = config.sops.secrets.jellyfin-password.path;
    };
  };

  # Configure Jellyfin user to access media directory
  systemd.services.jellyfin.serviceConfig = {
    SupplementaryGroups = [ "${group}" ];
  };
}
