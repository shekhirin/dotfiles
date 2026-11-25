{ pkgs }:

pkgs.runCommand "tuist-4.210.0"
  {
    src = pkgs.fetchurl {
      url = "https://github.com/tuist/tuist/releases/download/4.210.0/tuist.zip";
      hash = "sha256-MkIOv2XFtKHvsRg52FWwTH2K1VYy8nPzYlqjf90dMaw=";
    };
    nativeBuildInputs = [ pkgs.unzip ];
  }
  ''
    mkdir -p "$out/bin" "$out/libexec/tuist"
    unzip -q "$src" -d "$out/libexec/tuist"
    ln -s "$out/libexec/tuist/tuist" "$out/bin/tuist"
  ''
