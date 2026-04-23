{ pkgs, ... }:

let
  kubectlAliasesFish = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/ahmetb/kubectl-aliases/master/.kubectl_aliases.fish";
    sha256 = "1xdgmyz0ykcq4gxpwzsfclcsdbs64kzf2ql7q6rwx8klmcxi871j";
  };
in
{
  programs.fish = {
    enable = true;

    shellAliases = {
      cat = "bat";
    };
    shellInit = ''
      # Source nix environment
      if test -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish
      end

      set -gx ETH_RPC_URL "https://ethereum.reth.rs/rpc"

      # Add cargo bin to PATH
      fish_add_path $HOME/.cargo/bin
    '';
    interactiveShellInit = ''
      source ${kubectlAliasesFish}

      set -g fish_greeting

      # Catppuccin Mocha theme
      fish_config theme choose catppuccin-mocha

      # Zellij tab renaming hooks
      if set -q ZELLIJ
        function __zellij_preexec --on-event fish_preexec
          set -l cmd (string trim -- $argv[1])
          set -l parts (string split ' ' -- $cmd)
          set -l binary (path basename $parts[1])
          set -l title $binary
          for arg in $parts[2..]
            set -l test_title "$title $arg"
            if test (string length -- $test_title) -le 30
              set title $test_title
            else
              break
            end
          end
          zellij action rename-tab $title
        end

        function __zellij_preprompt --on-event fish_prompt
          if test (pwd) = $HOME
            set -l dir "~"
          else
            set -l dir (path basename (pwd))
          end
          zellij action rename-tab $dir
        end
      end
    '';
    functions = {
      cargo-update-dep = {
        description = "Update all occurrences of a git dependency in Cargo.toml to a new rev or branch";
        argumentNames = [
          "git_url"
          "new_value"
        ];
        body = ''
          set -l type rev
          if set -q _flag_type
            set type $_flag_type
          end

          set -l cargo_toml Cargo.toml
          if not test -f $cargo_toml
            echo "$cargo_toml not found in current directory" >&2
            return 1
          end

          set -l content (cat $cargo_toml)
          set -l escaped_url (string replace --all '/' '\\/' -- $git_url | string replace --all '.' '\\.' --)

          set -l pattern1 "git = \"$git_url\", (rev|branch) = \"[^\"]+\""
          set -l replacement1 "git = \"$git_url\", $type = \"$new_value\""
          set -l pattern2 "(rev|branch) = \"[^\"]+\", git = \"$git_url\""
          set -l replacement2 "$type = \"$new_value\", git = \"$git_url\""

          string replace --all --regex $pattern1 $replacement1 -- $content \
            | string replace --all --regex $pattern2 $replacement2 \
            > $cargo_toml

          echo "Updated dependencies from $git_url to $type = \"$new_value\""
        '';
      };
      gl = {
        description = "git pull";
        body = "git pull $argv";
      };

    };
  };
}
