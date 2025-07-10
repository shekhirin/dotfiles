$env.config.show_banner = false
$env.config.highlight_resolved_externals = true

$env.config.hooks = {
    pre_execution: [{
        append {
            let context = if (commandline | is-not-empty) {
                commandline | split row ' ' | take 1
            } else {
                basename $env.LAST_PWD
            }
            zellij action rename-tab $"($context)"
        }
    }]
    env_change: {
        PWD: [{|before, after|
            $env.LAST_PWD = $after
            zellij action rename-tab $"(basename $after)"
        }]
    }
}

def yolo [...args] {
    cd ~/Projects/oss/claude-workspaces/claude-yolo
    ^docker compose run --rm claude-yolo ...$args
}

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
