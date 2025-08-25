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

  virtualisation = {
    # Enable Docker for containers
    docker.enable = true;

    # Shoko using Docker container
    oci-containers = {
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
      };
    };
  };

  services = {
    # Prowlarr service configuration
    prowlarr = {
      enable = true;
      openFirewall = true;
    };

    # Sonarr service configuration
    sonarr = {
      enable = true;
      openFirewall = true;
      group = "${group}";
    };

    # Bazarr service configuration
    bazarr = {
      enable = true;
      openFirewall = true;
      group = "${group}";
    };

    # qBittorrent service configuration
    qbittorrent = {
      enable = true;
      openFirewall = true;
      group = "${group}";
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

    declarative-jellyfin = {
      enable = true;
      openFirewall = true;
      group = "${group}";

      users.admin = {
        mutable = false;
        permissions.isAdministrator = true;
        hashedPasswordFile = config.sops.secrets.jellyfin-password.path;
      };
    };
  };

  # Use Jellyfin admin password from SOPS
  sops.secrets.jellyfin-password = {
    owner = config.services.jellyfin.user;
  };

  # Open firewall for Shoko
  networking.firewall.allowedTCPPorts = [ 8111 ];
}
