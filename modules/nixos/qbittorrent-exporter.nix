{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.services.qbittorrent-exporter;
in
{
  options.services.qbittorrent-exporter = {
    enable = mkEnableOption "qBittorrent Prometheus exporter";

    port = mkOption {
      type = types.port;
      default = 9042;
      description = "Port to expose metrics on";
    };

    qbittorrentHost = mkOption {
      type = types.str;
      default = "localhost";
      description = "qBittorrent host address";
    };

    qbittorrentPort = mkOption {
      type = types.port;
      default = 8080;
      description = "qBittorrent web UI port";
    };

    qbittorrentUsername = mkOption {
      type = types.str;
      default = "admin";
      description = "qBittorrent username";
    };

    qbittorrentPassword = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "qBittorrent password (consider using environmentFile for security)";
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Environment file containing QBITTORRENT_PASSWORD=<password>";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open firewall port for the exporter";
    };

    enableHighCardinality = mkOption {
      type = types.bool;
      default = false;
      description = "Enable high cardinality metrics (qbittorrent_torrent_info, qbittorrent_tracker_info)";
    };

    extraArgs = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "Extra command line arguments for the exporter";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.qbittorrent-exporter = {
      description = "qBittorrent Prometheus Exporter";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = {
        QBITTORRENT_BASE_URL = "http://${cfg.qbittorrentHost}:${toString cfg.qbittorrentPort}";
        QBITTORRENT_USERNAME = cfg.qbittorrentUsername;
        EXPORTER_PORT = toString cfg.port;
        ENABLE_HIGH_CARDINALITY = if cfg.enableHighCardinality then "true" else "false";
      }
      // (
        if cfg.qbittorrentPassword != null then
          {
            QBITTORRENT_PASSWORD = cfg.qbittorrentPassword;
          }
        else
          { }
      );

      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        ExecStart = "${pkgs.qbittorrent-exporter}/bin/qbit-exp";
        Restart = "on-failure";
        RestartSec = 5;
        EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;

        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallFilter = "@system-service";
        SystemCallErrorNumber = "EPERM";
      };
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];
  };
}
