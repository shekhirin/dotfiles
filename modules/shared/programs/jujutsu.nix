{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.jujutsu;
  packageVersion = lib.getVersion cfg.package;
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
      remotes = {
        origin = {
          auto-track-bookmarks = "glob:alexey/*";
        };
        upstream = {
          auto-track-bookmarks = "main";
        };
      };
      signing = {
        behavior = "own";
        backend = "gpg";
      };
      ui = {
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
