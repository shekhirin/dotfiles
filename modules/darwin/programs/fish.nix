{ pkgs, ... }:

let
  layoutNu = ../nu/layout.nu;
in
{
  programs.fish.functions.layout = {
    description = "Set up aerospace window layout (runs nushell layout script)";
    argumentNames = [ "variant" ];
    body = ''
      ${pkgs.nushell}/bin/nu -c "use ${layoutNu} *; layout $variant"
    '';
  };
}
