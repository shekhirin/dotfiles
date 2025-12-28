{ config, ... }:

let
  group = "media";
in
{
  users.groups."${group}" = { };

  systemd.tmpfiles.rules = [
    "d /mnt/nvme/media 0775 root ${group} -"
    "Z /mnt/nvme/media 0775 root ${group} -"
  ];

  sops.secrets.jellarr-api-key = { };
  sops.secrets.jellyfin-password = { };

  sops.templates.jellarr-env = {
    content = ''
      JELLARR_API_KEY=${config.sops.placeholder.jellarr-api-key}
    '';
    owner = config.services.jellarr.user;
    group = config.services.jellarr.group;
  };

  services.jellarr = {
    enable = true;
    environmentFile = config.sops.templates.jellarr-env.path;

    bootstrap = {
      enable = true;
      apiKeyFile = config.sops.secrets.jellarr-api-key.path;
    };

    config = {
      base_url = "http://localhost:8096";
      users = [
        {
          name = "admin";
          passwordFile = config.sops.secrets.jellyfin-password.path;
          policy = {
            IsAdministrator = true;
          };
        }
      ];
    };
  };
}
