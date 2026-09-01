{ inputs, pkgs, ... }:

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

  home.file.".ideavimrc".text = ''
    set scrolloff=5
    set clipboard+=unnamed
  '';
}
