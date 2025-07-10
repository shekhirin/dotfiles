{ config, pkgs, lib, user, inputs, ... }:

{
  nix-homebrew = {
    inherit user;

    # Install Homebrew under the default prefix
    enable = true;
    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = true;
    # Automatically migrate existing Homebrew installations
    autoMigrate = true;
  };

  homebrew = {
    inherit user;

    enable = true;
    global.autoUpdate = false;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };
    brews = [ ];
    casks = [
      "orbstack"
      "spotify"
      "telegram"
      "thebrowsercompany-dia"
      # Notion kept in homebrew due to https://github.com/nix-community/nixpkgs-update/issues/468
      "notion"
    ];
  };
}