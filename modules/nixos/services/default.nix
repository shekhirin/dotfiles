{ ... }:

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

    # System
    ./openssh.nix
    ./mosh.nix
  ];
}
