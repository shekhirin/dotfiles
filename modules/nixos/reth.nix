{ pkgs, ... }:

{
  # Create reth data directories with correct permissions
  systemd.tmpfiles.rules = [
    "d /mnt/nvme/reth/mainnet 0755 reth-mainnet reth-mainnet -"
    "Z /mnt/nvme/reth/mainnet 0755 reth-mainnet reth-mainnet -"
  ];

  # Create static reth user
  users.users.reth-mainnet = {
    isSystemUser = true;
    group = "reth-mainnet";
    home = "/var/lib/reth-mainnet";
    createHome = true;
  };
  users.groups.reth-mainnet = { };

  # Reth service
  services.ethereum.reth.mainnet = {
    enable = true;
    package = pkgs.reth; # Explicitly specify the package
    args = {
      datadir = "/mnt/nvme/reth/mainnet";
      chain = "mainnet";
      http = {
        enable = true;
        addr = "0.0.0.0";
        port = 8545;
        api = [
          "eth"
          "net"
          "web3"
        ];
      };
      authrpc = {
        addr = "127.0.0.1";
        port = 8551;
        jwtsecret = "/mnt/nvme/reth/mainnet/jwt.hex";
      };
      metrics = {
        enable = true;
        addr = "0.0.0.0";
        port = 9001;
      };
    };
    openFirewall = false;
  };

  # Override systemd security settings for reth
  systemd.services.reth-mainnet.serviceConfig = {
    DynamicUser = false;
    ProtectSystem = "yes"; # Less restrictive than "strict"
    User = "reth-mainnet";
  };
}
