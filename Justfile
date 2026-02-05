# Display available commands
default:
    @just --list

# Switch personal macbook
switch-personal *ARGS:
    sudo darwin-rebuild switch --flake .#personal {{ARGS}}

# Build personal macbook
build-personal *ARGS:
    sudo darwin-rebuild build --flake .#personal {{ARGS}}

# Update and switch personal macbook
update-personal *ARGS:
    nix flake update
    sudo darwin-rebuild switch --flake .#personal {{ARGS}}

# Switch work macbook
switch-work *ARGS:
    sudo darwin-rebuild switch --flake .#shekhirin-tempo {{ARGS}}

# Build work macbook
build-work *ARGS:
    sudo darwin-rebuild build --flake .#shekhirin-tempo {{ARGS}}

# Update and switch work macbook
update-work *ARGS:
    nix flake update
    sudo darwin-rebuild switch --flake .#shekhirin-tempo {{ARGS}}

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
