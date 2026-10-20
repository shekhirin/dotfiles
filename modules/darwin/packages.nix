{ inputs, pkgs, ... }:

let
  boxctl = pkgs.callPackage ./boxctl.nix { src = inputs.boxctl-src; };
  openlogi = inputs.nixpkgs-openlogi.legacyPackages.${pkgs.stdenv.hostPlatform.system}.openlogi;
in
{
  home.packages = [
    boxctl
    openlogi
    pkgs._1password-cli
  ];
}
