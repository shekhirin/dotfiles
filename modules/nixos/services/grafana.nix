{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Dynamically get ports from service configurations
  prometheusPort = toString config.services.prometheus.port;
  tempoPort = toString config.services.tempo.settings.server.http_listen_port;

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
        ${
          lib.optionalString (extraSedCommands != [ ]) (
            "| ${pkgs.gnused}/bin/sed -E " + lib.concatMapStringsSep " " (cmd: "-e '${cmd}'") extraSedCommands
          )
        } \
        > "$out"
      '';
in
{
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
        {
          name = "Tempo";
          type = "tempo";
          access = "proxy";
          url = "http://localhost:${tempoPort}";
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

  # Use Grafana admin password from SOPS
  sops.secrets.grafana-password = {
    owner = config.users.users.grafana.name;
  };

  environment.etc = {
    "grafana-dashboards/node.json".source = processDashboard "node" (builtins.fetchurl {
      url = "https://grafana.com/api/dashboards/1860/revisions/41/download";
      name = "node.json";
      sha256 = "sha256:0fwm95q12pjsc342ckdbvbixv8p7s87riliv314073xj8v220b0k";
    }) [ ];

    "grafana-dashboards/reth.json".source = processDashboard "reth" (builtins.fetchurl {
      url = "https://grafana.com/api/dashboards/22941/revisions/4/download";
      name = "reth.json";
      sha256 = "sha256:1cz2xl61bvf3qq6ywx832vpgw49x618m17gadvvmpimsp49r86vk";
    }) [ ];

    "grafana-dashboards/qbittorrent.json".source = processDashboard "qbittorrent" (builtins.fetchurl {
      url = "https://grafana.com/api/dashboards/15116/revisions/3/download";
      name = "qbittorrent.json";
      sha256 = "sha256:1a0gh607x15xni7f5m96wlym4m2a6ism1zpk7npv2b6pc8g928gm";
    }) [ ];
  };

  systemd = {
    # Create dashboard directory with proper permissions
    tmpfiles.rules = [ "d /var/lib/grafana/dashboards 0755 grafana grafana -" ];

    # Ensure services start in correct order
    services.grafana = {
      after = [ "prometheus.service" ];
      wants = [ "prometheus.service" ];
    };
  };

  # Firewall configuration for Grafana
  networking.firewall.allowedTCPPorts = [
    config.services.grafana.settings.server.http_port # Grafana
  ];
}
