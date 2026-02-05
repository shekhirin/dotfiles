{
  description = "Alexey's multi-machine configuration";

  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [ "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=" ];
  };

  inputs = {
    # Core packages
    # Pinned to avoid Swift build failure with clang 21 (NixOS/nixpkgs#483584)
    nixpkgs.url = "github:NixOS/nixpkgs/70801e06d9730c4f1704fbd3bbf5b8e11c03a2a7";

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

    # Shared utilities
    systems.url = "github:nix-systems/default";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Ethereum.nix for blockchain node configurations
    ethereum-nix = {
      url = "github:nix-community/ethereum.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "systems";
    };

    # Declarative Jellyfin configuration
    jellarr = {
      url = "github:venkyr77/jellarr";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "systems";
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
      inputs.flake-parts.follows = "flake-parts";
    };

    # AeroSpace custom fork with tabs support
    aerospace-flake = {
      url = "github:shekhirin/AeroSpace/release";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # jj-starship
    jj-starship = {
      url = "github:dmmulroy/jj-starship";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    # LLM coding agents (daily updated)
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
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
      jellarr,
      sops-nix,
      dock-module,
      zed-editor-flake,
      aerospace-flake,
      jj-starship,
      llm-agents,
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
            prev.oniguruma
          ]
          ++ prev.lib.optionals prev.stdenv.hostPlatform.isDarwin [
            prev.apple-sdk_15
          ];

          RUSTONIG_SYSTEM_LIBONIG = true;
        };
      };

      overlays = [
        mescOverlay
        jj-starship.overlays.default
      ];

      darwinPkgs = import nixpkgs {
        system = "aarch64-darwin";
        overlays = overlays ++ [
          (final: prev: {
            inherit (zed-editor-flake.packages.aarch64-darwin) zed-editor-preview-bin;
            inherit (aerospace-flake.packages.aarch64-darwin) aerospace;
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
      # macOS configuration (personal)
      darwinConfigurations.personal = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        pkgs = darwinPkgs;
        specialArgs = { inherit inputs dock-module llm-agents; };

        modules = [
          ./hosts/darwin/personal/default.nix

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

      # macOS configuration (work)
      darwinConfigurations.shekhirin-tempo = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        pkgs = darwinPkgs;
        specialArgs = { inherit inputs; };

        modules = [
          ./hosts/darwin/work/default.nix

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
          jellarr.nixosModules.default
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

      # Checks for each system
      checks = {
        aarch64-darwin = {
          fmt = darwinPkgs.runCommand "fmt-check" { } ''
            export HOME=$TMPDIR
            ${darwinPkgs.lib.getExe self.formatter.aarch64-darwin} --ci ${./.}
            touch $out
          '';
          statix = darwinPkgs.runCommand "statix-check" { } ''
            ${darwinPkgs.lib.getExe darwinPkgs.statix} check ${./.}
            touch $out
          '';
        };
        x86_64-linux = {
          fmt = boxPkgs.runCommand "fmt-check" { } ''
            export HOME=$TMPDIR
            ${boxPkgs.lib.getExe self.formatter.x86_64-linux} --ci ${./.}
            touch $out
          '';
          statix = boxPkgs.runCommand "statix-check" { } ''
            ${boxPkgs.lib.getExe boxPkgs.statix} check ${./.}
            touch $out
          '';
        };
      };
    };
}
