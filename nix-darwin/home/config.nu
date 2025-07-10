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

def --wrapped yolo [...rest] {
    cd ~/Projects/oss/claude-workspaces/claude-yolo
    ^docker compose run --rm claude-yolo ...$rest
}

# Git helper functions
def git_current_branch [] {
  git branch --show-current | str trim -c "\n"
}

def ggpull [] {
  git pull origin (git_current_branch)
}

def ggpush [] {
  git push origin (git_current_branch)
}

def ggsup [] {
  git branch --set-upstream-to=origin/(git_current_branch)
}

def gpsup [] {
  git push --set-upstream origin (git_current_branch)
}

def gpoat [...tags] {
  git push origin --all
  git push origin --tags ...$tags
}

def gpristine [] {
  git reset --hard
  git clean -dfx
}

def grt [] {
  cd (git rev-parse --show-toplevel or echo ".")
}

def gtv [] {
  git tag | sort
}

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
