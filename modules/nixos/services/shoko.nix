_:

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

  # Open firewall for Shoko
  networking.firewall.allowedTCPPorts = [ 8111 ];
}
