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

# Additional git helper functions
def ggf [] {
  git push --force origin (git_current_branch)
}

def ggfl [] {
  git push --force-with-lease origin (git_current_branch)
}

def ggl [] {
  git pull origin (git_current_branch)
}

def ggp [] {
  git push origin (git_current_branch)
}

def ggpnp [] {
  ggl
  ggp
}

def ggu [] {
  git pull --rebase origin (git_current_branch)
}

def groh [] {
  git reset origin/(git_current_branch) --hard
}

def gluc [] {
  git pull upstream (git_current_branch)
}

def gccd [...args] {
  git clone --recurse-submodules ...$args
  let repo_name = ($args | last | path basename | str replace ".git" "")
  cd $repo_name
}

def gignored [] {
  git ls-files -v | grep "^[[:lower:]]"
}

def gunwip [] {
  if (git log -n 1 | grep -q "--wip--") {
    git reset HEAD~1
  }
}

def gwip [] {
  git add -A
  let deleted_files = (git ls-files --deleted | complete)
  if $deleted_files.exit_code == 0 {
    git rm ...(git ls-files --deleted | lines)
  }
  git commit --no-verify --no-gpg-sign -m "--wip-- [skip ci]"
}

mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
