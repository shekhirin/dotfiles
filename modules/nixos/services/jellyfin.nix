{ config, ... }:

let
  # User group for media access
  group = "media";
in
{
  # Create media group for shared access
  users.groups."${group}" = { };

  # Create media directory with correct permissions
  systemd.tmpfiles.rules = [
    "d /mnt/nvme/media 0775 root ${group} -"
    "Z /mnt/nvme/media 0775 root ${group} -"
  ];

  services.declarative-jellyfin = {
    enable = true;
    openFirewall = true;
    group = "${group}";

    users.admin = {
      mutable = false;
      permissions.isAdministrator = true;
      hashedPasswordFile = config.sops.secrets.jellyfin-password.path;
    };
  };

  # Use Jellyfin admin password from SOPS
  sops.secrets.jellyfin-password = {
    owner = config.services.jellyfin.user;
  };
}
