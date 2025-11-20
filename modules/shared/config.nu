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
