{ pkgs }:

# Prebuilt release: an Electron app with its CLI. Not in nixpkgs.
# `terminal-browser upgrade` can't replace a store path: bump version and hash here instead.
pkgs.runCommand "terminal-browser-0.16.3"
  {
    src = pkgs.fetchurl {
      url = "https://github.com/zenbu-labs/terminal-browser/releases/download/v0.16.3/terminal-browser-darwin-arm64.tar.gz";
      hash = "sha256-QuiUpBH1TKmlUjf2xlTJx6kPRZZv901NmzauDWCNvoc=";
    };
  }
  ''
    mkdir -p "$out/bin" "$out/libexec/terminal-browser"
    tar -xzf "$src" -C "$out/libexec/terminal-browser" --strip-components 1
    # The launcher follows symlinks to find the app next to it.
    ln -s "$out/libexec/terminal-browser/bin/terminal-browser" "$out/bin/terminal-browser"
  ''
