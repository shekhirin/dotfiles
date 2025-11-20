{ ... }:

{
  imports = [
    ./packages.nix
    ./sops.nix

    # Blockchain services
    ./monero.nix
    ./reth.nix
    ./lighthouse.nix

    # Monitoring services
    ./services/prometheus.nix
    ./services/grafana.nix
    ./services/tempo.nix
    ./services/qbittorrent-exporter.nix

    # Media services
    ./services/prowlarr.nix
    ./services/sonarr.nix
    ./services/bazarr.nix
    ./services/qbittorrent.nix
    ./services/jellyfin.nix
    ./services/shoko.nix

    # System services
    ./services/openssh.nix
    ./services/mosh.nix
  ];
}
