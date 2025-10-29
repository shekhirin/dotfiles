# Display available commands
default:
    @just --list

# Switch macbook
switch-macbook *ARGS:
    sudo darwin-rebuild switch --flake .#macbook {{ARGS}}

# Build macbook
build-macbook *ARGS:
    sudo darwin-rebuild build --flake .#macbook {{ARGS}}

# Update and switch macbook
update-macbook *ARGS:
    nix flake update
    sudo darwin-rebuild switch --flake .#macbook {{ARGS}}

# Switch box
switch-box *ARGS:
    sudo nixos-rebuild switch --flake .#box {{ARGS}}

# Build box
build-box *ARGS:
    sudo nixos-rebuild build --flake .#box {{ARGS}}

# Update and switch box
update-box *ARGS:
    nix flake update
    sudo nixos-rebuild switch --flake .#box {{ARGS}}
