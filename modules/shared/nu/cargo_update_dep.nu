# Update all occurrences of a git dependency in Cargo.toml to a new rev or branch
#
# Usage:
#   cargo-update-dep https://github.com/paradigmxyz/reth main
#   cargo-update-dep https://github.com/paradigmxyz/reth abc123def --type rev
#   cargo-update-dep https://github.com/paradigmxyz/reth develop --type branch
export def cargo-update-dep [
    git_url: string,      # Git repository URL (e.g., https://github.com/paradigmxyz/reth)
    new_value: string,    # New rev or branch value
    --type (-t): string = "rev"  # Type of reference: "rev" or "branch"
] {
    let cargo_toml = "Cargo.toml"

    if not ($cargo_toml | path exists) {
        error make { msg: $"($cargo_toml) not found in current directory" }
    }

    # Parse TOML to count matching dependencies
    let toml = open $cargo_toml

    def count-matching-deps [deps, git_url: string] {
        if ($deps | is-empty) { return 0 }
        $deps | items { |name, spec|
            if ($spec | describe | str starts-with "record") and ($spec | get -o git | default "") == $git_url { 1 } else { 0 }
        } | math sum
    }

    mut count = 0
    $count = $count + (count-matching-deps ($toml | get -o workspace.dependencies | default {}) $git_url)
    $count = $count + (count-matching-deps ($toml | get -o dependencies | default {}) $git_url)
    $count = $count + (count-matching-deps ($toml | get -o dev-dependencies | default {}) $git_url)
    $count = $count + (count-matching-deps ($toml | get -o build-dependencies | default {}) $git_url)

    if $count == 0 {
        print $"No occurrences of ($git_url) found in ($cargo_toml)"
        return
    }

    # Use regex replacement to preserve formatting
    let content = open $cargo_toml --raw
    let escaped_url = $git_url | str replace --all '/' '\/' | str replace --all '.' '\.'
    let ref_pattern = '(rev|branch)'

    # Pattern 1: git = "...", rev = "..."
    let pattern1 = $'git = "($escaped_url)", ($ref_pattern) = "[^"]+"'
    let replacement1 = $'git = "($git_url)", ($type) = "($new_value)"'

    # Pattern 2: rev = "...", git = "..."
    let pattern2 = $'($ref_pattern) = "[^"]+", git = "($escaped_url)"'
    let replacement2 = $'($type) = "($new_value)", git = "($git_url)"'

    $content
        | str replace --all --regex $pattern1 $replacement1
        | str replace --all --regex $pattern2 $replacement2
        | save --force $cargo_toml
    print $"Updated ($count) dependencies from ($git_url) to ($type) = \"($new_value)\""
}
