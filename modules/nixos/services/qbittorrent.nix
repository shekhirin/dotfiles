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

  # qBittorrent service configuration
  services.qbittorrent = {
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
}
