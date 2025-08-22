{
  description = "Alexey's multi-machine configuration";

  inputs = {
    # Core packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Darwin support
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Colmena for deployment - pinned to 0.4.0 for compatibility
    colmena = {
      url = "github:zhaofengli/colmena/v0.4.0";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # macOS-specific
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    dock-module = {
      url = "github:dustinlyons/nixos-config";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,
      nix-darwin,
      home-manager,
      colmena,
      nix-homebrew,
      dock-module,
      ...
    }:
    let

      # System-specific package sets
      darwinPkgs = import nixpkgs {
        system = "aarch64-darwin";
        overlays = [
          (import ./overlays/signal-desktop-bin.nix)
          (import ./overlays/spotify.nix)
          (import ./overlays/notion.nix)
          (import ./overlays/protonvpn.nix)
        ];
        config.allowUnfree = true;
      };

      nixosPkgs = import nixpkgs-stable {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
    {
      # macOS configuration
      darwinConfigurations.macbook = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        pkgs = darwinPkgs;
        specialArgs = { inherit inputs dock-module; };

        modules = [
          ./hosts/darwin/default.nix

          # Homebrew
          nix-homebrew.darwinModules.nix-homebrew
          ./modules/darwin/homebrew.nix

          # Dock configuration
          "${dock-module}/modules/darwin/dock"

          # Home-Manager
          home-manager.darwinModules.home-manager
          {
            nixpkgs = {
              system = "aarch64-darwin";
            };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.shekhirin = {
              imports = [
                # Common modules (shared between all machines)
                ./modules/shared/packages.nix
                ./modules/shared/shell.nix

                # Darwin-specific modules
                ./modules/darwin/development.nix
                ./modules/darwin/gpg.nix
                ./modules/darwin/apps.nix
              ];

              home.stateVersion = "25.05";
            };
          }

          # Set system revision
          {
            system.configurationRevision = self.rev or self.dirtyRev or null;
          }
        ];
      };

      # NixOS configuration for the box
      nixosConfigurations.box = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        pkgs = nixosPkgs;
        specialArgs = { inherit inputs; };

        modules = [
          ./hosts/nixos/default.nix
        ];
      };

      # Colmena deployment configuration (NixOS only)
      colmenaHive = colmena.lib.makeHive {
        meta = {
          nixpkgs = nixosPkgs;
          specialArgs = { inherit inputs; };
        };

        # Remote NixOS box
        box = {
          deployment = {
            targetHost = "box";
            targetUser = "shekhirin";
            buildOnTarget = true;
          };

          imports = [
            ./hosts/nixos/default.nix
          ];
        };
      };

      # Formatters for each system
      formatter = {
        aarch64-darwin = darwinPkgs.nixfmt-tree;
        x86_64-linux = nixosPkgs.nixfmt-tree;
      };
    };
}
