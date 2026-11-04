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
  # Antithesis CLI, built from the release tag pinned in flake.nix with its own package.nix.
  snouty = (pkgs.callPackage "${inputs.snouty-src}/package.nix" { }).overrideAttrs {
    version = "0.9.1";
    doCheck = false;
  };
in
{
  home.packages = [
    mercator
    snouty
  ];

  programs.git.settings.user.email = lib.mkForce "alexey@tempo.xyz";
  programs.jujutsu.settings.user.email = lib.mkForce "alexey@tempo.xyz";

  home.file.".ideavimrc".text = ''
    set scrolloff=5
    set clipboard+=unnamed
  '';
}
