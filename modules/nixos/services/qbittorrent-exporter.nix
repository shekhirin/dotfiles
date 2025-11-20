{ config, ... }:

{
  # SOPS secret for qBittorrent password
  sops.secrets.qbittorrent-password = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  # Enable qBittorrent exporter
  services.qbittorrent-exporter = {
    enable = true;
    port = 9042;
    qbittorrentHost = "localhost";
    qbittorrentPort = 8080;
    qbittorrentUsername = "admin";
    enableHighCardinality = true;
    environmentFile = config.sops.secrets.qbittorrent-password.path;
  };
}
