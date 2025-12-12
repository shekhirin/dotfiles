$env.config.show_banner = false
$env.config.highlight_resolved_externals = true

$env.config.hooks = {
    # Show the command that is about to run
    pre_execution: [
        {||
            if "ZELLIJ" in $env {
                let cmd = (commandline | str trim)
                let title = if ($cmd | str length) > 0 {
                    let parts = ($cmd | split row ' ')
                    let binary = ($parts | first | path basename)
                    let args = ($parts | skip 1)

                    # Start with just the binary name
                    mut result = $binary

                    # Add arguments one by one while staying under 30 characters
                    for arg in $args {
                        let test_result = $"($result) ($arg)"
                        if ($test_result | str length) <= 30 {
                            $result = $test_result
                        } else {
                            break
                        }
                    }

                    $result
                } else {
                    $cmd
                }
                ^zellij action rename-tab $title
            }
        }
    ]

    # After the command finishes, show the working directory
    pre_prompt: [
        {||
            if "ZELLIJ" in $env {
                let dir = if (pwd) == ($env.HOME) { "~" } else { (pwd | path basename) }
                # uncomment next line to include the last exit code
                # let dir = $"($dir) [($env.LAST_EXIT_CODE)]"
                ^zellij action rename-tab $dir
            }
        }
    ]
}

# Add cargo bin to PATH
# TODO: This should ideally be done in home.nix via home.sessionPath or home.sessionVariables
# but home manager's PATH management doesn't seem to work properly with nushell
$env.PATH = ($env.PATH | append $"($env.HOME)/.cargo/bin")

# Update all occurrences of a git dependency in Cargo.toml to a new rev or branch
#
# Usage:
#   cargo-update-dep https://github.com/paradigmxyz/reth main
#   cargo-update-dep https://github.com/paradigmxyz/reth abc123def --type rev
#   cargo-update-dep https://github.com/paradigmxyz/reth develop --type branch
def cargo-update-dep [
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
