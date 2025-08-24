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
    webui = null;
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
      hashedPasswordFile = config.sops.secrets.jellyfin-password.path;
    };

    plugins = [
      {
        name = "Shokofin";
        url = "https://github.com/ShokoAnime/Shokofin/releases/download/v5.0.4/shoko_5.0.4.0.zip";
        version = "5.0.4";
        sha256 = "sha256:2e59ea22c3588790a356a88ac8c6cbbd1f2867225570a24e74f38ecd8c7bf91d";
      }
    ];
  };

  # Configure Jellyfin user to access media directory
  systemd.services.jellyfin.serviceConfig = {
    SupplementaryGroups = [ "${group}" ];
  };
}
