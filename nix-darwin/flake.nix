{
  description = "Alexey's macOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      nix-homebrew,
      ...
    }:
    let
      system = "aarch64-darwin";
      user = "shekhirin";

      pkgs = import nixpkgs {
        inherit system;
        overlays = [ ];
        config = {
          allowUnfree = true;
        };
      };

      configuration =
        { ... }:
        {
          ## Core system
          nixpkgs.hostPlatform = "aarch64-darwin";
          system.stateVersion = 6;
          system.configurationRevision = self.rev or self.dirtyRev or null;

          ## Nix settings
          # Let Determinate Nix handle Nix configuration
          nix.enable = false;
          nix.settings.experimental-features = "nix-command flakes";
          nix.extraOptions = ''
            extra-platforms = aarch64-darwin
          '';

          ## Users
          users.users.${user} = {
            uid = 501;
            home = "/Users/${user}";
          };

          ## Touch‑ID sudo
          security.pam.services.sudo_local.touchIdAuth = true; # new path :contentReference[oaicite:0]{index=0}
        };
    in
    {
      darwinConfigurations."${user}" = nix-darwin.lib.darwinSystem {
        inherit system pkgs;
        specialArgs = { inherit inputs; };

        modules = [
          configuration

          ## Home‑Manager
          home-manager.darwinModules.home-manager
          {
            nixpkgs = { inherit system; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.shekhirin = import ./home/home.nix;
          }

          nix-homebrew.darwinModules.nix-homebrew
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
              ];
            };
          }
        ];
      };
    };
}
