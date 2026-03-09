{
  pkgs,
  ...
}:

{
  systemd.services.cloudflared-flashgrab = {
    description = "Cloudflare Quick Tunnel for AnkiConnect";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --url http://localhost:8765";
      Restart = "on-failure";
      DynamicUser = true;
    };
  };
}
