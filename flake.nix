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

    # AeroSpace custom fork with tabs support
    aerospace-flake = {
      url = "github:shekhirin/AeroSpace/release";
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
      aerospace-flake,
      ...
    }:
    let
      # System-specific package sets
      mescOverlay = final: prev: {
        mesc = prev.rustPlatform.buildRustPackage rec {
          pname = "mesc";
          version = "0.3.0";

          src = prev.fetchFromGitHub {
            owner = "paradigmxyz";
            repo = "mesc";
            rev = version;
            hash = "sha256-5aejGa1RR4Vvqyd8kQyUfKaD8yQLdQrS0PosSW9TrIU=";
          };

          sourceRoot = "${src.name}/rust";
          cargoHash = "sha256-kwr0InBMFyrsAM43X1PGIIviIlsFQcGow/y2E+nPyoU=";

          nativeBuildInputs = [ prev.pkg-config ];
          buildInputs = [
            prev.openssl
          ]
          ++ prev.lib.optionals prev.stdenv.hostPlatform.isDarwin [
            prev.apple-sdk_15
          ];
        };
      };

      overlays = [
        mescOverlay
      ];

      darwinPkgs = import nixpkgs {
        system = "aarch64-darwin";
        overlays = overlays ++ [
          (final: prev: {
            zed-editor-preview-bin = zed-editor-flake.packages.aarch64-darwin.zed-editor-preview-bin;
            aerospace = aerospace-flake.packages.aarch64-darwin.aerospace;
          })
        ];
        config.allowUnfree = true;
      };

      boxPkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = overlays ++ [
          ethereum-nix.overlays.default
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

          # Set system revision
          {
            system.configurationRevision = self.rev or self.dirtyRev or null;
          }
        ];
      };

      # NixOS configuration for the box
      nixosConfigurations.box = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        pkgs = boxPkgs;
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
