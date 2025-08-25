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
    "d /mnt/nvme/media 0775 root ${group} -"
    "Z /mnt/nvme/media 0775 root ${group} -"
  ];

  # Enable Docker for containers
  virtualisation.docker.enable = true;

  # Shoko using Docker container
  virtualisation.oci-containers = {
    backend = "docker";
    containers.shoko = {
      image = "shokoanime/server:daily";
      ports = [ "8111:8111" ];
      volumes = [
        "/mnt/nvme/media:/media:rw"
        "shoko-config:/home/shoko/.shoko"
      ];
      environment = {
        TZ = "UTC";
        PUID = "1000";
        PGID = "1000";
      };
      extraOptions = [
        "--restart=unless-stopped"
      ];
    };
  };

  # Prowlarr service configuration
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  # Sonarr service configuration
  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  # Configure Sonarr to access media directory
  systemd.services.sonarr.serviceConfig = {
    SupplementaryGroups = [ "${group}" ];
  };

  # Bazarr service configuration
  services.bazarr = {
    enable = true;
    openFirewall = true;
  };

  # Configure Bazarr to access media directory
  systemd.services.bazarr.serviceConfig = {
    SupplementaryGroups = [ "${group}" ];
  };

  # qBittorrent service configuration
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        WebUI = {
          Username = "admin";
          Password_PBKDF2 = "j5UlZYIvzsAsBS/KNRLm4w==:oGQ8qydG5D4Vydo8nImOvPIzYZtNzlOUUe4WllKLqAyNCNK55AOh9h6YTFNPZxO2cT3OVq/Ysi7xK5ynmP1Ymg==";
        };
      };
    };
  };

  # Configure qbittorrent user to access media directory
  systemd.services.qbittorrent.serviceConfig = {
    SupplementaryGroups = [ "${group}" ];
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

  # Open firewall for Shoko
  networking.firewall.allowedTCPPorts = [ 8111 ];
}
