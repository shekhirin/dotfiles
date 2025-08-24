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

  # Get qBittorrent exporter configuration
  qbittorrentExporterEnabled = config.services.qbittorrent-exporter.enable or false;
  qbittorrentExporterPort =
    if qbittorrentExporterEnabled then toString config.services.qbittorrent-exporter.port else null;

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

  # Helper function to process Grafana dashboard JSON files
  # - Normalizes any "datasource" field (string or object) to null using jq
  # - Applies any additional sed tweaks passed via extraSedCommands
  processDashboard =
    name: src: extraSedCommands:
    pkgs.runCommand "${name}-dashboard.json"
      {
        inherit src;
      }
      ''
        # First, use jq to recursively set all .datasource fields to null
        ${pkgs.jq}/bin/jq '
          def normalize:
            if type == "object" then
              # Set any datasource fields to null to use Grafana defaults
              (.datasource? = null)
              # Fix reth dashboard variable: replace ''${VAR_INSTANCE_LABEL} with "instance"
              | (if (.query? // null) == "''\${VAR_INSTANCE_LABEL}" then .query = "instance" else . end)
              # Recurse
              | with_entries(.value |= normalize)
            elif type == "array" then
              map(normalize)
            else
              .
            end;
          normalize
        ' "$src" \
        ${lib.optionalString (extraSedCommands != [ ])
          ("| ${pkgs.gnused}/bin/sed -E "
            + lib.concatMapStringsSep " " (cmd: "-e '${cmd}'") extraSedCommands)
        } \
        > "$out"
      '';
in
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
    ++ lib.optionals qbittorrentExporterEnabled [
      {
        job_name = "qbittorrent";
        static_configs = [
          {
            targets = [ "localhost:${qbittorrentExporterPort}" ];
            labels = {
              instance = "qbittorrent-exporter";
            };
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

  # Use Grafana admin password from SOPS
  sops.secrets.grafana-password = {
    owner = config.users.users.grafana.name;
  };

  # Grafana service for visualization
  services.grafana = {
    enable = true;

    settings = {
      security = {
        admin_password = "$__file{${config.sops.secrets.grafana-password.path}}";
      };

      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        domain = config.networking.hostName;
        root_url = "http://${config.networking.hostName}:3000";
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
    "grafana-dashboards/node.json".source = processDashboard "node" (builtins.fetchurl {
      url = "https://grafana.com/api/dashboards/1860/revisions/41/download";
      name = "node.json";
      sha256 = "sha256:0fwm95q12pjsc342ckdbvbixv8p7s87riliv314073xj8v220b0k";
    }) [ ];

    "grafana-dashboards/reth.json".source =
      processDashboard "reth"
        (builtins.fetchurl {
          url = "https://grafana.com/api/dashboards/22941/revisions/3/download";
          name = "reth.json";
          sha256 = "sha256:032i5q7vb4v2k5kwsnpyw9m2blmqy5k852l2qizh9jyymayxjqxk";
        })
        [ ];

    "grafana-dashboards/qbittorrent.json".source = processDashboard "qbittorrent" (builtins.fetchurl {
      url = "https://grafana.com/api/dashboards/15116/revisions/3/download";
      name = "qbittorrent.json";
      sha256 = "sha256:1a0gh607x15xni7f5m96wlym4m2a6ism1zpk7npv2b6pc8g928gm";
    }) [ ];
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
