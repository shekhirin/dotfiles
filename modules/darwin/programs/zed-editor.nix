{ pkgs, lib, ... }:

{
  programs.zed-editor = {
    enable = true;
    package = pkgs.zed-editor-preview-bin;
    extensions = [
      "html"
      "catpuccin"
      "toml"
      "dockerfile"
      "make"
      "zig"
      "nix"
      "justfile"
      "nu"
      "solidity"
      "helm"
    ];
    userSettings = {
      auto_update = false;
      agent = {
        default_profile = "write";
        always_allow_tool_actions = false;
        default_model = {
          provider = "zed.dev";
          model = "claude-opus-4";
        };
        model_parameters = [ ];
        inline_assistant_model = {
          provider = "zed.dev";
          model = "claude-opus-4";
        };
      };
      vim_mode = true;
      ui_font_size = 14;
      buffer_font_size = 12;
      buffer_font_features = {
        calt = false;
      };
      buffer_font_fallbacks = [ "JetBrains Mono" ];
      theme = {
        mode = "system";
        light = "Catppuccin Latte - No Italics";
        dark = "Catppuccin Mocha - No Italics";
      };
      lsp = {
        nil = {
          settings = {
            nix.flake.autoArchive = true;
            formatting = {
              command = [ "${lib.getExe pkgs.nixfmt}" ];
            };
          };
        };
        rust-analyzer = {
          initialization_options = {
            cargo = {
              targetDir = true;
              features = "all";
            };
            check = {
              command = "clippy";
              extraArgs = [ "--no-deps" ];
              features = "all";
            };
            rustfmt = {
              extraArgs = [ "+nightly" ];
            };
            workspace = {
              symbol = {
                search = {
                  kind = "all_symbols";
                };
              };
            };
          };
        };
      };
      languages = {
        TOML = {
          language_servers = [ "!Taplo" ];
        };
      };
      file_types = {
        Dockerfile = [ "Dockerfile*" ];
      };
      autosave = "on_focus_change";
      terminal = {
        shell = {
          program = "nu";
        };
      };
      sticky_scroll = {
        enabled = true;
      };
      use_system_window_tabs = true;
    };
  };
}
