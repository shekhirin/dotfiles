# Display available commands
default:
    @just --list

# Switch macbook locally
switch-macbook *ARGS:
    sudo darwin-rebuild switch --flake .#macbook {{ARGS}}

# Build macbook configuration
build-macbook *ARGS:
    sudo darwin-rebuild build --flake .#macbook {{ARGS}}

# Update and switch macbook
update-macbook *ARGS:
    nix flake update
    sudo darwin-rebuild switch --flake .#macbook {{ARGS}}
    brew upgrade --cask --greedy

# Switch box using Colmena
switch-box *ARGS:
    colmena apply --on box {{ARGS}}

# Build box configuration using Colmena
build-box *ARGS:
    colmena build --on box {{ARGS}}

# Update flake and switch box using Colmena
update-box *ARGS:
    nix flake update
    colmena apply --on box {{ARGS}}
