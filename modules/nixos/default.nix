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

    # Media services
    ./services/jellyfin.nix

    # System services
    ./services/openssh.nix
    ./services/mosh.nix
  ];
}
