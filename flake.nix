{
  description = "Alexey's multi-machine configuration";

  inputs = {
    # Core packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # nixpkgs with codex packages (from PR #435576)
    nixpkgs-codex = {
      # Tracks the PR branch; used only to source codex packages
      url = "github:NixOS/nixpkgs/pull/435576/head";
    };

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
      nix-darwin,
      home-manager,
      ethereum-nix,
      declarative-jellyfin,
      sops-nix,
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
            # Allow shared modules to access flake inputs
            home-manager.extraSpecialArgs = { inherit inputs; };
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
          (
            { ... }:
            {
              home-manager.extraSpecialArgs = { inherit inputs; };
            }
          )
        ];
      };

      # Formatters for each system
      formatter = {
        aarch64-darwin = darwinPkgs.nixfmt-tree;
        x86_64-linux = (import nixpkgs { system = "x86_64-linux"; }).nixfmt-tree;
      };
    };
}
