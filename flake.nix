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

    # macOS-specific
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    
    dock-module = {
      url = "github:dustinlyons/nixos-config";
      flake = false;
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    nixpkgs-stable,
    nix-darwin,
    home-manager,
    nix-homebrew,
    dock-module,
    ...
  }: 
  let
    # Common variables
    user = "shekhirin";
    
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
      specialArgs = { inherit inputs user dock-module; };
      
      modules = [
        ./machines/macbook/default.nix
        
        # Homebrew
        nix-homebrew.darwinModules.nix-homebrew
        ./machines/macbook/homebrew.nix
        
        # Dock configuration
        "${dock-module}/modules/darwin/dock"
        
        # Home-Manager
        home-manager.darwinModules.home-manager
        {
          nixpkgs = { system = "aarch64-darwin"; };
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.${user} = import ./modules/home/default.nix;
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
      specialArgs = { inherit inputs user; };
      
      modules = [
        ./machines/box/hardware-configuration.nix
        ./machines/box/default.nix
      ];
    };
  };
}