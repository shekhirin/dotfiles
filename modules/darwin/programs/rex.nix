{ lib, pkgs, ... }:

{
  targets.darwin.defaults."com.superlogical.rex" = {
    "Workspace.darkThemeID" = "custom-9A134C9B-0BAF-4AA6-84DB-912A0BC9D950";
    "Workspace.lightThemeID" = "custom-DA334BCF-B9BC-455C-9B09-AC0580C58387";
    "Workspace.terminalFontName" = "JetBrainsMono Nerd Font Mono";
    "Workspace.terminalFontPointSize" = 12;
    "Workspace.terminalAllowsLigatures" = false;
    "Workspace.terminalStartupCommand" = "${pkgs.fish}/bin/fish --login --interactive";
  };

  # Rex stores imported Ghostty palettes as JSON-encoded NSData, not a plist array.
  # Preserve the imported GitHub Dark/Light Default palettes and their selection IDs.
  home.activation.rexThemes = lib.hm.dag.entryAfter [ "setDarwinDefaults" ] ''
    run /usr/bin/defaults write com.superlogical.rex Workspace.customThemes \
      -data "$(${pkgs.xxd}/bin/xxd -p -c 0 ${./rex-themes.json})"
  '';

  programs.fish.interactiveShellInit = lib.mkAfter ''
    # Nix resets PATH during shell startup; retain Rex's bundled CLI.
    if set -q REX_BIN_DIR
      fish_add_path --path --prepend --move $REX_BIN_DIR
    end
  '';
}
