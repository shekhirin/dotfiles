{ inputs, pkgs, ... }:

let
  iets = inputs.iets.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Classic mode: iets answers to the Nix command names and runs Determinate
  # Nix for whatever it does not implement. Determinate owns nix.package
  # (nix.enable = false), so the iets NixOS module's nix.package swap does not
  # apply here, and the links go in the user profile, ahead of Determinate.
  classic = pkgs.symlinkJoin {
    name = "iets-classic";
    paths = [ iets ];
    postBuild = ''
      for n in nix nix-build nix-instantiate nix-shell nix-eval-jobs; do
        ln -s ${iets}/bin/iets $out/bin/$n
      done
    '';
  };
in
{
  home = {
    packages = [ classic ];
    # The real Nix that classic mode falls back to.
    sessionVariables.IETS_NIX_BIN_DIR = "/nix/var/nix/profiles/default/bin";
  };
}
