{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  mercatorPackage = inputs.mercator.packages.${pkgs.stdenv.hostPlatform.system}.default;
  mercator = pkgs.writeShellApplication {
    name = "mercator";
    text = ''
      export NO_UPDATE_NOTIFIER=1

      if [[ $# -eq 0 ]]; then
        exec ${mercatorPackage}/bin/mercator --help
      fi

      exec ${mercatorPackage}/bin/mercator "$@"
    '';
  };
in
{
  home.packages = [
    mercator
    pkgs.minio-client
  ];

  programs.git.settings.user.email = lib.mkForce "alexey@tempo.xyz";
  programs.jujutsu.settings.user.email = lib.mkForce "alexey@tempo.xyz";

  home.file.".ideavimrc".text = ''
    set scrolloff=5
    set clipboard+=unnamed
  '';
}
