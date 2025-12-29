{ pkgs, lib, ... }:

let
  # Language/tool version modules to disable (all display "via <version>")
  disabledLanguagePrompts = [
    "buf"
    "bun"
    "c"
    "cmake"
    "cobol"
    "crystal"
    "daml"
    "dart"
    "deno"
    "elixir"
    "elm"
    "erlang"
    "fennel"
    "gleam"
    "golang"
    "gradle"
    "haskell"
    "haxe"
    "helm"
    "julia"
    "kotlin"
    "lua"
    "nim"
    "nodejs"
    "ocaml"
    "odin"
    "opa"
    "perl"
    "php"
    "purescript"
    "quarto"
    "raku"
    "red"
    "rlang"
    "ruby"
    "rust"
    "scala"
    "swift"
    "terraform"
    "typst"
    "vagrant"
    "vlang"
    "zig"
  ];
in
{
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = {
      directory = {
        truncate_to_repo = false;
      };
      docker_context = {
        disabled = true;
      };
      custom = {
        jj = {
          command = "jj-starship";
          detect_folders = [
            ".jj"
            ".git"
          ];
          shell = [ "sh" ];
          format = "$output ";
        };
      };
      git_branch.disabled = true;
      git_status.disabled = true;
      package.disabled = true;
    }
    // lib.genAttrs disabledLanguagePrompts (_: {
      disabled = true;
    });
  };

  home.packages = with pkgs; [
    jj-starship
  ];
}
