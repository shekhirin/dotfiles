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

# A name is a flake input, or the <name>-src or <name>-flake one (`just update boxctl`).
# Flags are passed to switch.
# Update all flake inputs, or the named ones, and switch current machine
update *ARGS:
    #!/usr/bin/env bash
    set -euo pipefail
    inputs=" $(nix eval --impure --raw --expr \
        'builtins.concatStringsSep " " (builtins.attrNames (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.root.inputs)') "
    update=()
    switch=()
    for arg in {{ARGS}}; do
        if [[ "$arg" == -* ]]; then
            switch+=("$arg")
            continue
        fi
        found=
        for input in "$arg" "$arg-src" "$arg-flake"; do
            if [[ "$inputs" == *" $input "* ]]; then
                found=$input
                break
            fi
        done
        if [ -z "$found" ]; then
            echo "No flake input for '$arg'. Inputs:$inputs" >&2
            exit 1
        fi
        update+=("$found")
    done
    nix flake update ${update[@]+"${update[@]}"}
    just switch ${switch[@]+"${switch[@]}"}
