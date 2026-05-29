{ lib, pkgs, ... }:

let
  layoutNu = ../nu/layout.nu;
in
{
  programs.fish = {
    shellInit = lib.mkAfter ''
      ulimit -n 524288 10485760 2>/dev/null
    '';

    functions.layout = {
      description = "Set up aerospace window layout (runs nushell layout script)";
      argumentNames = [ "variant" ];
      body = ''
        ${pkgs.nushell}/bin/nu -c "use ${layoutNu} *; layout $variant"
      '';
    };
  };
}
