# iets, or the flake-pinned one before the first switch installs it
iets := if `command -v iets || true` != "" { "iets" } else { "nix run --inputs-from . iets --" }

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
    system_config=$(just build {{ARGS}})
    sudo nix-env -p /nix/var/nix/profiles/system --set "$system_config"
    if [ "$type" = "darwin" ]; then
        sudo "$system_config/sw/bin/darwin-rebuild" activate
    else
        sudo "$system_config/bin/switch-to-configuration" switch
    fi

# Build current machine and print its system path
build *ARGS:
    #!/usr/bin/env bash
    set -e
    info=$(just detect)
    type="${info%%:*}"
    target="${info##*:}"
    if [ "$type" = "darwin" ]; then
        attr="darwinConfigurations.$target.system"
    else
        attr="nixosConfigurations.$target.config.system.build.toplevel"
    fi
    {{iets}} build -o result ".#$attr" {{ARGS}} >/dev/null
    readlink -f result

# Run the flake checks for this system
check *ARGS:
    {{iets}} build .#checks {{ARGS}}

# Update flake and switch current machine
update *ARGS:
    nix flake update
    just switch {{ARGS}}
