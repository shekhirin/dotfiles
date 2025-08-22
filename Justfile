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
    brew upgrade --cask --greedy

# Switch box
switch-box *ARGS:
    colmena apply --on box {{ARGS}}

# Build box
build-box *ARGS:
    colmena build --on box {{ARGS}}

# Update flake and switch box
update-box *ARGS:
    nix flake update
    colmena apply --on box {{ARGS}}

# Switch both macbook and box
switch-all: && switch-macbook switch-box

# Build both macbook and box
build-all: && build-macbook build-box

# Update flake and switch both macbook and box
update-all: && update-macbook update-box
