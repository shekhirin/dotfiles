{ pkgs, lib, ... }:

{
  imports = [
    ./shell.nix
    ./dev-tools.nix
    ./apps.nix
    ./gpg.nix
  ];

  home.stateVersion = "25.05";

  launchd.agents.protonmail-bridge = {
    enable = true;
    config = {
      ProgramArguments = [ "${pkgs.protonmail-bridge}/bin/protonmail-bridge" "--noninteractive" ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "/tmp/protonmail-bridge.stdout.log";
      StandardErrorPath = "/tmp/protonmail-bridge.stderr.log";
    };
  };

  home.sessionVariables = {
    # Append brew to PATH. We're not using `home.sessionPath` because it's prepending, and we want nix binaries to take precedence.
    # TODO: Remove when fully migrated to nix pkgs
    PATH = "$PATH:/opt/homebrew/bin:/opt/homebrew/sbin";
  };
}