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

# Deploy to box using Colmena
deploy-box:
    colmena apply --on box

# Deploy to box using Colmena (verbose)
deploy-box-verbose:
    colmena apply --on box --verbose

# Build box configuration with Colmena (without deploying)
build-box:
    colmena build --on box

# Check box configuration
check-box:
    colmena eval --on box config.system.build.toplevel

# Deploy to all nodes (currently just box)
deploy-all:
    colmena apply

# Update and deploy to box
update-box:
    nix flake update
    colmena apply --on box
