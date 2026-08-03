{
  config,
  pkgs,
  lib,
  ...
}:

{
  home = {
    packages = with pkgs; [
      # GPG
      gnupg
      pinentry_mac
    ];

    file.".gnupg/gpg-agent.conf".text = ''
      pinentry-program ${lib.getExe pkgs.pinentry_mac}
    '';

    activation.fixGpgHomePermissions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -d ${lib.escapeShellArg "${config.home.homeDirectory}/.gnupg"} ]; then
        chmod 700 ${lib.escapeShellArg "${config.home.homeDirectory}/.gnupg"}
      fi
    '';
  };
}
