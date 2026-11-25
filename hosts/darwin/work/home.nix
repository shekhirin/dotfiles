{
  lib,
  pkgs,
  inputs,
  ...
}:

let
  pyrex = inputs.pyrex.packages.${pkgs.stdenv.hostPlatform.system}.pyrex;
  # Rex's CLI ships with its server rather than on the PATH.
  rexBinDir = "$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS";
in
{
  programs.git.settings.user.email = lib.mkForce "alexey@tempo.xyz";
  programs.jujutsu.settings.user.email = lib.mkForce "alexey@tempo.xyz";

  home = {
    file.".ideavimrc".text = ''
      set scrolloff=5
      set clipboard+=unnamed
    '';

    packages = [ pyrex ];

    # `pyrex setup` writes the binary's store path into ~/.config/rex/init.lua: point Rex's palette at this build.
    activation.pyrexSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ -x "${rexBinDir}/rex" ]; then
        PATH="${rexBinDir}:$PATH" run ${lib.getExe pyrex} setup \
          || warnEcho "pyrex setup failed: run it in a Rex shell"
      fi
    '';
  };
}
