default: switch

switch:
    sudo darwin-rebuild switch --flake nix-darwin/

build:
    sudo darwin-rebuild build --flake nix-darwin/
