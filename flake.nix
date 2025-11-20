{
  description = "Alexey's multi-machine configuration";

  inputs = {
    # Core packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

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

    # Ethereum.nix for blockchain node configurations
    ethereum-nix = {
      url = "github:nix-community/ethereum.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative Jellyfin configuration
    declarative-jellyfin = {
      url = "github:Sveske-Juice/declarative-jellyfin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secret management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # macOS-specific
    dock-module = {
      url = "github:dustinlyons/nixos-config";
      flake = false;
    };

    # Zed Editor preview builds
    zed-editor-flake = {
      url = "github:shekhirin/zed-editor-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      ethereum-nix,
      declarative-jellyfin,
      sops-nix,
      dock-module,
      zed-editor-flake,
      ...
    }:
    let
      # System-specific package sets
      darwinPkgs = import nixpkgs {
        system = "aarch64-darwin";
        overlays = [
          (import ./overlays/spotify.nix)
          (import ./overlays/protonvpn.nix)
          (final: prev: {
            zed-editor-preview-bin = zed-editor-flake.packages.aarch64-darwin.zed-editor-preview-bin;
          })
          # TODO: Remove after https://github.com/NixOS/nixpkgs/pull/461779 is resolved upstream.
          (_self: super: {
            fish = super.fish.overrideAttrs (oldAttrs: {
              doCheck = false;
              checkPhase = "";
              cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
                "-DBUILD_TESTING=OFF"
              ];
            });
          })
        ];
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

          # Dock configuration
          "${dock-module}/modules/darwin/dock"

          # Home-Manager
          home-manager.darwinModules.home-manager
          {
            nixpkgs = {
              system = "aarch64-darwin";
            };
            home-manager = {
              # Allow shared modules to access flake inputs
              extraSpecialArgs = { inherit inputs; };
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "backup";
              users.shekhirin = {
                imports = [
                  # Common modules (shared between all machines)
                  ./modules/shared/packages.nix

                  # Shared programs
                  ./modules/shared/programs/git.nix
                  ./modules/shared/programs/delta.nix
                  ./modules/shared/programs/zellij.nix
                  ./modules/shared/programs/nushell.nix
                  ./modules/shared/programs/starship.nix
                  ./modules/shared/programs/zoxide.nix
                  ./modules/shared/programs/direnv.nix

                  # Darwin-specific modules
                  ./modules/darwin/development.nix
                  ./modules/darwin/gpg.nix
                  ./modules/darwin/apps.nix

                  # Darwin programs
                  ./modules/darwin/programs/aerospace.nix
                  ./modules/darwin/programs/ghostty.nix
                  ./modules/darwin/programs/zed-editor.nix

                  # Darwin services
                  ./modules/darwin/services/protonmail-bridge.nix
                ];

                home.stateVersion = "25.05";
              };
            };
          }

          # Set system revision
          {
            system.configurationRevision = self.rev or self.dirtyRev or null;
          }
        ];
      };

      # NixOS configuration for the box
      nixosConfigurations.box = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [
            ethereum-nix.overlays.default
            (final: prev: {
              qbittorrent-exporter = final.callPackage ./pkgs/qbittorrent-exporter.nix { };
            })
          ];
          config.allowUnfree = true;
        };
        specialArgs = { inherit inputs; };

        modules = [
          ./hosts/nixos/default.nix
          declarative-jellyfin.nixosModules.default
          sops-nix.nixosModules.sops
          # Pass inputs to Home Manager in NixOS as well
          (_: {
            home-manager.extraSpecialArgs = { inherit inputs; };
          })
        ];
      };

      # Formatters for each system
      formatter = {
        aarch64-darwin = darwinPkgs.nixfmt-tree;
        x86_64-linux = (import nixpkgs { system = "x86_64-linux"; }).nixfmt-tree;
      };
    };
}
