{ lib, ... }:

{
  home.activation.idasenConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.idasen.json" ]; then
      echo '${
        builtins.toJSON {
          position_min = 9;
          position_max = 48;
        }
      }' > "$HOME/.idasen.json"
    fi
  '';
}
