{
  config,
  pkgs,
  lib,
  ...
}:

{
  home = {
    packages = with pkgs; [
      gnupg
      pinentry-curses
    ];

    file.".gnupg/gpg-agent.conf".text = ''
      pinentry-program ${lib.getExe pkgs.pinentry-curses}
    '';

    activation.fixGpgHomePermissions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -d ${lib.escapeShellArg "${config.home.homeDirectory}/.gnupg"} ]; then
        chmod 700 ${lib.escapeShellArg "${config.home.homeDirectory}/.gnupg"}
      fi
    '';
  };
}
