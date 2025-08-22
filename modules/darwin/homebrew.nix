{ user, ... }:

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
      cleanup = "zap";
    };
    brews = [ ];
    casks = [
      "bambu-studio"
      "orbstack"
      "telegram"
      "thebrowsercompany-dia"
      "vuescan"
    ];
    masApps = {
      "Xcode" = 497799835;
    };
  };
}
