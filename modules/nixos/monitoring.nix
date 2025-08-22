{
  config,
  pkgs,
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

  # Get lighthouse metrics configuration
  lighthouseConfig = config.services.ethereum.lighthouse-beacon.mainnet or null;
  lighthouseMetricsEnabled =
    lighthouseConfig != null && lighthouseConfig.enable && lighthouseConfig.args.metrics.enable;
  lighthouseMetricsAddr =
    if lighthouseMetricsEnabled then lighthouseConfig.args.metrics.address else null;
  lighthouseMetricsPort =
    if lighthouseMetricsEnabled then toString lighthouseConfig.args.metrics.port else null;
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
    scrapeConfigs = [
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
              chain = "mainnet";
            };
          }
        ];
      }
    ]
    ++ lib.optionals lighthouseMetricsEnabled [
      {
        job_name = "lighthouse";
        static_configs = [
          {
            targets = [
              "${
                if lighthouseMetricsAddr == "0.0.0.0" then "localhost" else lighthouseMetricsAddr
              }:${lighthouseMetricsPort}"
            ];
            labels = {
              instance = "lighthouse-mainnet";
              chain = "mainnet";
            };
          }
        ];
      }
    ];
  };

  # Grafana service for visualization
  services.grafana = {
    enable = true;

    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        domain = config.networking.hostName;
        root_url = "http://${config.networking.hostName}:3000";
      };

      # Allow anonymous access for local viewing
      "auth.anonymous" = {
        enabled = true;
        org_role = "Viewer";
      };

      # Disable user sign up
      users = {
        allow_sign_up = false;
      };
    };

    # Configure Prometheus as datasource
    provision = {
      enable = true;

      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://localhost:${prometheusPort}";
          isDefault = true;
          jsonData = {
            timeInterval = "15s";
          };
        }
      ];

      # Provision dashboards
      dashboards.settings.providers = [
        {
          name = "default";
          orgId = 1;
          folder = "";
          type = "file";
          disableDeletion = false;
          updateIntervalSeconds = 10;
          options = {
            path = "/etc/grafana-dashboards";
            foldersFromFilesStructure = true;
          };
        }
      ];
    };
  };

  environment.etc = {
    "grafana-dashboards/node.json".source = builtins.fetchurl {
      url = "https://grafana.com/api/dashboards/1860/revisions/41/download";
      name = "node.json";
      sha256 = "sha256:0fwm95q12pjsc342ckdbvbixv8p7s87riliv314073xj8v220b0k";
    };
    "grafana-dashboards/reth.json".source =
      pkgs.runCommand "reth-dashboard.json"
        {
          src = builtins.fetchurl {
            url = "https://grafana.com/api/dashboards/22941/revisions/3/download";
            name = "reth.json";
            sha256 = "sha256:032i5q7vb4v2k5kwsnpyw9m2blmqy5k852l2qizh9jyymayxjqxk";
          };
        }
        ''
          ${pkgs.gnused}/bin/sed 's/"query": "$''\{VAR_INSTANCE_LABEL}",/"query": "instance",/' $src > $out
        '';
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

  # Create dashboard directory with proper permissions
  systemd.tmpfiles.rules = [
    "d /var/lib/grafana/dashboards 0755 grafana grafana -"
  ];

  # Firewall configuration for monitoring services
  networking.firewall.allowedTCPPorts = [
    config.services.grafana.settings.server.http_port # Grafana
  ];

  # Ensure services start in correct order
  systemd.services.grafana = {
    after = [ "prometheus.service" ];
    wants = [ "prometheus.service" ];
  };

  systemd.services.prometheus = {
    after = [ "prometheus-node-exporter.service" ];
    wants = [ "prometheus-node-exporter.service" ];
  };
}
