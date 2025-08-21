# Display available commands
default:
    @just --list

# Switch macbook
switch-macbook:
    sudo darwin-rebuild switch --flake .#macbook

# Build macbook
build-macbook:
    sudo darwin-rebuild build --flake .#macbook

# Update macbook
update-macbook:
    nix flake update
    sudo darwin-rebuild switch --flake .#macbook
    brew upgrade --cask --greedy

# Switch and deploy box via SSH
switch-box:
    nixos-rebuild switch --flake .#box --target-host shekhirin@box --use-remote-sudo

# Build box
build-box:
    nixos-rebuild build --flake .#box

# Update and deploy to box
update-box:
    nix flake update
    nixos-rebuild switch --flake .#box --target-host shekhirin@box --use-remote-sudo
