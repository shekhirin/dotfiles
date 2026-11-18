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
  # pyr, built with both of its binaries (pyr and pyramid-tui) from the whole checkout:
  # the flake's package builds only pyramid-tui, and its source filter drops build.rs and distros/.
  pyr = inputs.pyrvim.packages.${pkgs.stdenv.hostPlatform.system}.pyramid-tui.overrideAttrs {
    src = inputs.pyrvim;
    cargoBuildFlags = [
      "-p"
      "pyramid-tui"
    ];
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
    pyr
    snouty
  ];

  programs.git.settings.user.email = lib.mkForce "alexey@tempo.xyz";
  programs.jujutsu.settings.user.email = lib.mkForce "alexey@tempo.xyz";

  home.file.".ideavimrc".text = ''
    set scrolloff=5
    set clipboard+=unnamed
  '';
}
