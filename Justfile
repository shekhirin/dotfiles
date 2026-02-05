# Display available commands
default:
    @just --list

# Detect flake target and rebuild command based on hostname
[private]
detect:
    #!/usr/bin/env bash
    hostname=$(hostname -s)
    case "$hostname" in
        shekhirin)
            echo "darwin:personal"
            ;;
        shekhirin-tempo)
            echo "darwin:work"
            ;;
        box)
            echo "nixos:box"
            ;;
        *)
            echo "Unknown hostname: $hostname" >&2
            exit 1
            ;;
    esac

# Switch current machine
switch *ARGS:
    #!/usr/bin/env bash
    set -e
    info=$(just detect)
    type="${info%%:*}"
    target="${info##*:}"
    if [ "$type" = "darwin" ]; then
        sudo darwin-rebuild switch --flake ".#$target" {{ARGS}}
    else
        sudo nixos-rebuild switch --flake ".#$target" {{ARGS}}
    fi

# Build current machine
build *ARGS:
    #!/usr/bin/env bash
    set -e
    info=$(just detect)
    type="${info%%:*}"
    target="${info##*:}"
    if [ "$type" = "darwin" ]; then
        sudo darwin-rebuild build --flake ".#$target" {{ARGS}}
    else
        sudo nixos-rebuild build --flake ".#$target" {{ARGS}}
    fi

# Update flake and switch current machine
update *ARGS:
    #!/usr/bin/env bash
    set -e
    nix flake update
    info=$(just detect)
    type="${info%%:*}"
    target="${info##*:}"
    if [ "$type" = "darwin" ]; then
        sudo darwin-rebuild switch --flake ".#$target" {{ARGS}}
    else
        sudo nixos-rebuild switch --flake ".#$target" {{ARGS}}
    fi
