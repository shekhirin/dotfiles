{ pkgs, ... }:

{
  # Create lighthouse data directories with correct permissions
  systemd.tmpfiles.rules = [
    "d /mnt/nvme/lighthouse/mainnet 0755 lighthouse-mainnet lighthouse-mainnet -"
    "Z /mnt/nvme/lighthouse/mainnet 0755 lighthouse-mainnet lighthouse-mainnet -"
  ];

  # Create static lighthouse user
  users.users.lighthouse-mainnet = {
    isSystemUser = true;
    group = "lighthouse-mainnet";
    home = "/var/lib/lighthouse-mainnet";
    createHome = true;
  };
  users.groups.lighthouse-mainnet = { };

  # Lighthouse beacon service
  services.ethereum.lighthouse-beacon.mainnet = {
    enable = true;
    package = pkgs.lighthouse; # Explicitly specify the package
    args = {
      network = "mainnet";
      datadir = "/mnt/nvme/lighthouse/mainnet";
      http = {
        enable = true;
        address = "0.0.0.0";
        port = 5052;
      };
      metrics = {
        enable = true;
        address = "0.0.0.0";
        port = 5054;
      };
      execution-endpoint = "http://127.0.0.1:8551";
      execution-jwt = "/mnt/nvme/reth/mainnet/jwt.hex";
      checkpoint-sync-url = "https://sync-mainnet.beaconcha.in";
      user = "lighthouse-mainnet";
    };
    extraArgs = [ "--purge-db-force" ];
    openFirewall = false;
  };

  # Override systemd security settings for lighthouse
  systemd.services.lighthouse-beacon-mainnet.serviceConfig = {
    DynamicUser = false;
    ProtectSystem = "yes"; # Less restrictive than "strict"
  };
}
