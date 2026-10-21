{ inputs, pkgs, ... }:

let
  boxctl = pkgs.callPackage ./boxctl.nix { src = inputs.boxctl-src; };
in
{
  home.packages = [
    boxctl
    pkgs._1password-cli
  ];
}
