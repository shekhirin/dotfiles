_:

{
  # Monero node service
  services.monero = {
    enable = true;

    # Data directory on the NVMe drive
    dataDir = "/mnt/nvme/monero";

    # Mining configuration (disabled by default)
    mining.enable = false;

    # Enable pruning to save disk space (keeps ~50GB instead of full ~150GB+)
    prune = true;
  };

  # Create monero data directory with correct permissions
  systemd.tmpfiles.rules = [
    "d /mnt/nvme/monero 0755 monero monero -"
    "Z /mnt/nvme/monero 0755 monero monero -"
  ];

  # Open firewall ports for Monero P2P
  networking.firewall.allowedTCPPorts = [ 18080 ];
}
