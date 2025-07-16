{
  description = "Alexey's macOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";


    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    foundry.url = "github:shazow/foundry.nix";

    rudy-src = {
      url = "github:samscott89/rudy";
      flake = false;
    };

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
      nix-homebrew,
      foundry,
      dock-module,
      ...
    }:
    let
      system = "aarch64-darwin";
      user = "shekhirin";

      pkgs = import nixpkgs {
        inherit system;

        overlays = [ 
          (import ./overlays/rudy.nix { inherit inputs; })
          (import ./overlays/signal-desktop-bin.nix)
          (import ./overlays/spotify.nix)
          (import ./overlays/notion.nix)
          (import ./overlays/protonvpn.nix)
          foundry.overlay
        ];
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      darwinConfigurations."${user}" = nix-darwin.lib.darwinSystem {
        inherit system pkgs;
        specialArgs = { inherit inputs user; };

        modules = [
          # System configuration
          ./modules/system/default.nix
          
          # Homebrew
          nix-homebrew.darwinModules.nix-homebrew
          ./modules/system/homebrew.nix

          # Dock configuration
          "${dock-module}/modules/darwin/dock"


          # Home-Manager
          home-manager.darwinModules.home-manager
          {
            nixpkgs = { inherit system; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.sharedModules = [ ];
            home-manager.users.${user} = import ./modules/home/default.nix;
          }
          
          # Set system revision for rebuild tracking
          {
            system.configurationRevision = self.rev or self.dirtyRev or null;
          }
        ];
      };

      packages."${system}" = {
        rudy-lldb = pkgs.rudy-lldb;
      };
    };
}
