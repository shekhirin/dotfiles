_:

{
  imports = [
    # Blockchain
    ./monero.nix
    ./reth.nix

    # Monitoring
    ./prometheus.nix
    ./grafana.nix
    ./tempo.nix

    # Media
    ./jellyfin.nix

    # Orchestration
    ./k3s.nix

    # System
    ./openssh.nix
    ./mosh.nix
  ];
}
