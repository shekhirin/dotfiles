{
  config,
  lib,
  ...
}:

let
  # Dynamically get ports from service configurations
  nodeExporterPort = toString config.services.prometheus.exporters.node.port;
  prometheusPort = toString config.services.prometheus.port;

  # Get reth metrics configuration
  rethConfig = config.services.ethereum.reth.mainnet or null;
  rethMetricsEnabled = rethConfig != null && rethConfig.enable && rethConfig.args.metrics.enable;
  rethMetricsAddr = if rethMetricsEnabled then rethConfig.args.metrics.addr else null;
  rethMetricsPort = if rethMetricsEnabled then toString rethConfig.args.metrics.port else null;
in
{
  # Prometheus service for metrics collection
  services.prometheus = {
    enable = true;
    port = 9090;

    # Configure data retention
    retentionTime = "30d";

    # Global scrape configuration
    globalConfig = {
      scrape_interval = "15s";
      evaluation_interval = "15s";
    };

    # Scrape configurations for various services
    scrapeConfigs =
      [
        {
          job_name = "node";
          static_configs = [
            {
              targets = [ "localhost:${nodeExporterPort}" ];
              labels = {
                instance = config.networking.hostName;
              };
            }
          ];
        }
        {
          job_name = "prometheus";
          static_configs = [
            {
              targets = [ "localhost:${prometheusPort}" ];
            }
          ];
        }
      ]
      ++ lib.optionals rethMetricsEnabled [
        {
          job_name = "reth";
          static_configs = [
            {
              targets = [
                "${if rethMetricsAddr == "0.0.0.0" then "localhost" else rethMetricsAddr}:${rethMetricsPort}"
              ];
              labels = {
                instance = "reth-mainnet";
              };
            }
            {
              targets = [ "localhost:9002" ];
              labels = {
                instance = "tmp";
              };
            }
          ];
        }
      ];
  };

  # Node Exporter for system metrics
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;

    enabledCollectors = [
      "cpu"
      "diskstats"
      "filesystem"
      "loadavg"
      "meminfo"
      "netdev"
      "stat"
      "time"
      "uname"
      "systemd"
      "logind"
      "interrupts"
      "ksmd"
      "processes"
      "hwmon"
      "thermal_zone"
    ];

    extraFlags = [
      "--collector.filesystem.mount-points-exclude=^/(dev|proc|sys|run|tmp|var/lib/(docker|lxc|containers))($|/)"
      "--collector.netdev.device-exclude=^(veth|br|docker|virbr|lo).*"
    ];
  };

  # Ensure services start in correct order
  systemd.services.prometheus = {
    after = [ "prometheus-node-exporter.service" ];
    wants = [ "prometheus-node-exporter.service" ];
  };
}
