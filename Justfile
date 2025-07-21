default: switch

switch:
    sudo darwin-rebuild switch --flake nix-darwin/

build:
    sudo darwin-rebuild build --flake nix-darwin/

update:
    cd nix-darwin && nix flake update
    sudo darwin-rebuild switch --flake nix-darwin/
    brew upgrade --cask --greedy
