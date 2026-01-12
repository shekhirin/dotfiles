{
  config,
  lib,
  pkgs,
  ...
}:

let
  packageVersion = lib.getVersion config.programs.jujutsu.package;
  schemaUrl = "https://docs.jj-vcs.dev/v${packageVersion}/config-schema.json";

  configDir =
    if pkgs.stdenv.isDarwin && !(lib.versionAtLeast packageVersion "0.29.0") then
      "${config.home.homeDirectory}/Library/Application Support"
    else
      config.xdg.configHome;
  jjConfigPath = "${configDir}/jj/config.toml";
in
{
  programs.jujutsu = {
    enable = true;
    settings = {
      aliases = {
        tug = [
          "bookmark"
          "move"
          "--from"
          "heads(::@- & bookmarks())"
          "--to"
          "@"
        ];
        tug- = [
          "bookmark"
          "move"
          "--from"
          "heads(::@- & bookmarks())"
          "--to"
          "@-"
        ];
      };
      git = {
        fetch = [
          "upstream"
          "origin"
        ];
        push = "origin";
      };
      remotes = {
        origin = {
          auto-track-bookmarks = "glob:alexey/*";
        };
        upstream = {
          auto-track-bookmarks = "main";
        };
      };
      revset-aliases = {
        "trunk()" = "main@upstream";
      };
      signing = {
        behavior = "own";
        backend = "gpg";
      };
      ui = {
        default-command = "log";
        diff-formatter = [
          "${pkgs.difftastic}/bin/difft"
          "--color=always"
          "$left"
          "$right"
        ];
      };
      user = {
        name = "Alexey Shekhirin";
        email = "github@shekhirin.com";
      };
    };
  };

  home.activation.validateJujutsuConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ -f ${lib.escapeShellArg jjConfigPath} ]; then
      echo "Validating jj config with schema: ${schemaUrl}"
      RUST_LOG=warn ${pkgs.taplo}/bin/taplo check --schema ${lib.escapeShellArg schemaUrl} ${lib.escapeShellArg jjConfigPath}
    fi
  '';
}
