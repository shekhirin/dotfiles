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

def --wrapped yolo [...rest] {
    cd ~/Projects/oss/claude-workspaces/claude-yolo
    let container_status = (^docker ps -q -f name=claude-yolo | complete)
    if ($container_status.stdout | str trim) == "" {
        ^docker compose up -d
    }
    ^docker exec -it claude-yolo bash -c $'export PATH="/home/claude/.foundry/bin:/home/claude/.cargo/bin:/home/claude/.npm-global/bin:/home/claude/.local/bin:$PATH" && source /home/claude/.cargo/env && claude --dangerously-skip-permissions ($rest | str join " ")'
}

# Git helper functions
def git_current_branch [] {
  git branch --show-current | str trim -c "\n"
}

def git_main_branch [] {
  # Check if we're in a git repo
  if (git rev-parse --git-dir | complete).exit_code != 0 {
    return ""
  }
  
  # List of possible main branch names to check
  let refs = [
    "refs/heads/main"
    "refs/heads/trunk" 
    "refs/heads/mainline"
    "refs/heads/default"
    "refs/heads/stable"
    "refs/heads/master"
    "refs/remotes/origin/main"
    "refs/remotes/origin/trunk"
    "refs/remotes/origin/mainline" 
    "refs/remotes/origin/default"
    "refs/remotes/origin/stable"
    "refs/remotes/origin/master"
    "refs/remotes/upstream/main"
    "refs/remotes/upstream/trunk"
    "refs/remotes/upstream/mainline"
    "refs/remotes/upstream/default" 
    "refs/remotes/upstream/stable"
    "refs/remotes/upstream/master"
  ]
  
  # Check each ref to see if it exists
  for ref in $refs {
    if (git show-ref --verify $ref | complete).exit_code == 0 {
      return ($ref | split row "/" | last)
    }
  }
  
  # Fallback to master
  "master"
}

def gcm [] {
  git checkout (git_main_branch)
}

def gmom [] {
  git merge $"origin/(git_main_branch)"
}

def glum [] {
  git pull upstream (git_main_branch)
}

def gmum [] {
  git merge $"upstream/(git_main_branch)"
}

def grbm [] {
  git rebase (git_main_branch)
}

def grbom [] {
  git rebase $"origin/(git_main_branch)"
}

def gswm [] {
  git switch (git_main_branch)
}

def gupom [] {
  git pull --rebase origin (git_main_branch)
}

def gupomi [] {
  git pull --rebase=interactive origin (git_main_branch)
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

# Add cargo bin to PATH
# TODO: This should ideally be done in home.nix via home.sessionPath or home.sessionVariables
# but home manager's PATH management doesn't seem to work properly with nushell
$env.PATH = ($env.PATH | append $"($env.HOME)/.cargo/bin")

