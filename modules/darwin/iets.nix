{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  iets = inputs.iets.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Classic mode: iets answers to the Nix command names and runs Determinate
  # Nix for whatever it does not implement. Determinate owns nix.package
  # (nix.enable = false), so the iets NixOS module's nix.package swap does not
  # apply here. The links live in their own directory, which the shell puts in
  # front of Determinate's bin.
  classic = pkgs.runCommand "iets-classic" { } ''
    mkdir -p $out/bin
    for n in nix nix-build nix-instantiate nix-shell nix-eval-jobs; do
      ln -s ${iets}/bin/iets $out/bin/$n
    done
  '';
in
{
  home = {
    packages = [ iets ];
    # The real Nix that classic mode falls back to.
    sessionVariables.IETS_NIX_BIN_DIR = "/nix/var/nix/profiles/default/bin";
  };

  # After nix-daemon.fish, which moves /nix/var/nix/profiles/default/bin to the
  # front of PATH.
  programs.fish.shellInit = lib.mkAfter ''
    fish_add_path --global --move --prepend ${classic}/bin
  '';
}
