{ pkgs, lib, ... }:

{
  programs.nushell = {
    enable = true;

    shellAliases = {
      cd = "z";
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