{ pkgs, lib, ... }:

{
  imports = [
    # Common modules (shared between all machines)
    ../common/packages.nix
    ../common/shell.nix

    # Darwin-specific modules
    ../darwin/development.nix
    ../darwin/gpg.nix
    ../darwin/apps.nix
  ];

  home.stateVersion = "25.05";

  home.sessionVariables = {
    # Append brew to PATH. We're not using `home.sessionPath` because it's prepending, and we want nix binaries to take precedence.
    # TODO: Remove when fully migrated to nix pkgs
    PATH = "$PATH:/opt/homebrew/bin:/opt/homebrew/sbin";
  };
}
