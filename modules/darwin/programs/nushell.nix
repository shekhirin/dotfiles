_:

let
  layoutNu = ../nu/layout.nu;
in
{
  programs.nushell.extraConfig = ''
    use ${layoutNu} *
  '';
}
