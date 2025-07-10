{
  description = "Alexey's macOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    mac-app-util.url = "github:hraban/mac-app-util";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    rudy-src = {
      url = "github:samscott89/rudy";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
      home-manager,
      mac-app-util,
      nix-homebrew,
      ...
    }:
    let
      system = "aarch64-darwin";
      user = "shekhirin";

      pkgs = import nixpkgs {
        inherit system;

        overlays = [ 
          (import ./overlays/rudy.nix { inherit inputs; })
          (import ./overlays/spotify.nix)
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

          # Fix .app application files
          mac-app-util.darwinModules.default

          # Home-Manager
          home-manager.darwinModules.home-manager
          {
            nixpkgs = { inherit system; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.sharedModules = [ mac-app-util.homeManagerModules.default ];
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
