{ pkgs, ... }:

{
  # ProtonMail Bridge service
  launchd.agents.protonmail-bridge = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.protonmail-bridge}/bin/protonmail-bridge"
        "--noninteractive"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/protonmail-bridge.stdout.log";
      StandardErrorPath = "/tmp/protonmail-bridge.stderr.log";
    };
  };
}
