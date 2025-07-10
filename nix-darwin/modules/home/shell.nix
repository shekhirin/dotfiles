{ pkgs, lib, ... }:

{
  programs.nushell = {
    enable = true;

    shellAliases = {
      cd = "z";
      cat = "bat";
      
      # Git aliases
      s = "git status -sb";
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gapa = "git add --patch";
      gau = "git add --update";
      gav = "git add --verbose";
      gap = "git apply";
      gapt = "git apply --3way";
      gb = "git branch";
      gba = "git branch -a";
      gbd = "git branch -d";
      gbD = "git branch -D";
      gbl = "git blame -b -w";
      gbnm = "git branch --no-merged";
      gbr = "git branch --remote";
      gbs = "git bisect";
      gbsb = "git bisect bad";
      gbsg = "git bisect good";
      gbsr = "git bisect reset";
      gbss = "git bisect start";
      gc = "git commit -v";
      "gc!" = "git commit -v --amend";
      gca = "git commit -v -a";
      "gca!" = "git commit -v -a --amend";
      gcam = "git commit -a -m";
      "gcan!" = "git commit -v -a --no-edit --amend";
      "gcans!" = "git commit -v -a -s --no-edit --amend";
      gcb = "git checkout -b";
      gcd = "git checkout develop";
      gcf = "git config --list";
      gcl = "git clone --recursive";
      gclean = "git clean -fd";
      gcm = "git checkout master";
      gcmsg = "git commit -m";
      gcas = "git commit -a -s";
      gcasm = "git commit -a -s -m";
      "gcn!" = "git commit -v --no-edit --amend";
      gco = "git checkout";
      gcor = "git checkout --recurse-submodules";
      gcount = "git shortlog -sn";
      gcp = "git cherry-pick";
      gcpa = "git cherry-pick --abort";
      gcpc = "git cherry-pick --continue";
      gcs = "git commit -S";
      gcsm = "git commit -s -m";
      gd = "git diff";
      gdca = "git diff --cached";
      gdcw = "git diff --cached --word-diff";
      gds = "git diff --staged";
      gdt = "git diff-tree --no-commit-id --name-only -r";
      gdw = "git diff --word-diff";
      gf = "git fetch";
      gfa = "git fetch --all --prune";
      gfo = "git fetch origin";
      gg = "git gui citool";
      gga = "git gui citool --amend";
      ggpur = "ggu";
      ghh = "git help";
      gignore = "git update-index --assume-unchanged";
      gk = "gitk --all --branches";
      gl = "git pull";
      glg = "git log --stat";
      glgg = "git log --graph";
      glgga = "git log --graph --decorate --all";
      glgm = "git log --graph --max-count=10";
      glgp = "git log --stat -p";
      glo = "git log --oneline --decorate";
      glog = "git log --oneline --decorate --graph";
      gloga = "git log --oneline --decorate --graph --all";
      glol = "git log --graph --pretty=%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset --abbrev-commit";
      glola = "git log --graph --pretty=%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset --abbrev-commit --all";
      glum = "git pull upstream master";
      gm = "git merge";
      gmom = "git merge origin/master";
      gmt = "git mergetool --no-prompt";
      gmtvim = "git mergetool --no-prompt --tool=vimdiff";
      gmum = "git merge upstream/master";
      gma = "git merge --abort";
      gp = "git push";
      gpd = "git push --dry-run";
      gpf = "git push --force-with-lease";
      "gpf!" = "git push --force";
      gpu = "git push upstream";
      gpv = "git push -v";
      gr = "git remote";
      gra = "git remote add";
      gpr = "git pull --rebase";
      grb = "git rebase";
      grba = "git rebase --abort";
      grbc = "git rebase --continue";
      grbi = "git rebase -i";
      grbm = "git rebase master";
      grbd = "git rebase develop";
      grbom = "git rebase origin/master";
      grbo = "git rebase --onto";
      grbs = "git rebase --skip";
      grh = "git reset HEAD";
      grhh = "git reset HEAD --hard";
      grev = "git revert";
      grm = "git rm";
      grmc = "git rm --cached";
      grmv = "git remote rename";
      grrm = "git remote remove";
      grset = "git remote set-url";
      grs = "git restore";
      grss = "git restore --source";
      grst = "git restore --staged";
      gru = "git reset --";
      grup = "git remote update";
      grv = "git remote -v";
      gsb = "git status -sb";
      gsd = "git svn dcommit";
      gsi = "git submodule init";
      gsh = "git show";
      gsps = "git show --pretty=short --show-signature";
      gsr = "git svn rebase";
      gss = "git status -s";
      gst = "git status";
      gsta = "git stash save";
      gstu = "git stash --include-untracked";
      gstall = "git stash --all";
      gstaa = "git stash apply";
      gstc = "git stash clear";
      gstd = "git stash drop";
      gstl = "git stash list";
      gstp = "git stash pop";
      gsts = "git stash show --text";
      gsu = "git submodule update";
      gsw = "git switch";
      gswc = "git switch -c";
      gswm = "git switch master";
      gswd = "git switch develop";
      gts = "git tag -s";
      gunignore = "git update-index --no-assume-unchanged";
      gup = "git pull --rebase";
      gupv = "git pull --rebase -v";
      gupa = "git pull --rebase --autostash";
      gupav = "git pull --rebase --autostash -v";
      gupom = "git pull --rebase origin master";
      gupomi = "git pull --rebase=interactive origin master";
      gam = "git am";
      gamc = "git am --continue";
      gams = "git am --skip";
      gama = "git am --abort";
      gamscp = "git am --show-current-patch";
      gwch = "git whatchanged -p --abbrev-commit --pretty=medium";
    };
    configFile.source = ../../home/config.nu;
    environmentVariables = {
      EDITOR = "vim";
    };
  };

  programs.zsh = {
    enable = true;

    autosuggestion.enable = true;
    enableCompletion = true;
    dotDir = ".config/zsh";
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "docker"
        "docker-compose"
      ];
    };

    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        export HOMEBREW_NO_ENV_HINTS=yes
        source ~/.env.secrets

        bindkey "\e[1;3D" backward-word
        bindkey "\e[1;3C" forward-word
      '')
      (lib.mkAfter ''
        zellij_tab_name_update() {
          if [[ -n $ZELLIJ ]]; then
            local current_dir=$PWD
            [[ $current_dir == $HOME ]] && current_dir="~" || current_dir=''${current_dir##*/}
            command nohup zellij action rename-tab $current_dir >/dev/null 2>&1
          fi
        }

        zellij_tab_name_update
        chpwd_functions+=(zellij_tab_name_update)

        yolo () {
          (cd ~/Projects/oss/claude-workspaces/claude-yolo && docker compose run --rm claude-yolo "$@")
        }

        eval "$(starship init zsh)"
        if [[ -z "$CLAUDECODE" ]]; then
          eval "$(zoxide init --cmd cd zsh)"
        fi
      '')
    ];
  };

  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
  };
}