{ pkgs, lib, ... }:

{
  programs = {
    nushell = {
      enable = true;

      shellAliases = {
        cd = "z";
        cat = "bat";
      };
      configFile.text = builtins.readFile ./config.nu;
      extraConfig = ''
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/ack/ack-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/adb/adb-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/aerospace/aerospace-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/bat/bat-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/cargo/cargo-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/curl/curl-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/fastboot/fastboot-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/gh/gh-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/git/git-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/just/just-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/make/make-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/man/man-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/nix/nix-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/npm/npm-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/pass/extensions/pass-otp/pass-otp-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/pass/pass-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/pnpm/pnpm-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/poetry/poetry-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/rg/rg-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/rustup/rustup-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/tar/tar-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/tcpdump/tcpdump-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/uv/uv-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/custom-completions/yarn/yarn-v4-completions.nu *
        use ${pkgs.nu_scripts}/share/nu_scripts/modules/git/git.nu *
        # Aliases go after git module to take precedence over it
        use ${pkgs.nu_scripts}/share/nu_scripts/aliases/git/git-aliases.nu *

        export alias gl = git pull
      '';
      environmentVariables = {
        EDITOR = "${lib.getExe pkgs.vim}";
      };
    };

    starship = {
      enable = true;
      enableNushellIntegration = true;
      settings = {
        directory = {
          truncate_to_repo = false;
        };
        docker_context = {
          disabled = true;
        };
      };
    };

    zoxide = {
      enable = true;
      enableNushellIntegration = true;
    };

    direnv = {
      enable = true;
      enableNushellIntegration = true;
      nix-direnv.enable = true;
      config = {
        global = {
          hide_env_diff = true;
        };
      };
    };
  };
}
