{ inputs }:

final: prev: {
  rudy-lldb = final.rustPlatform.buildRustPackage {
    pname = "rudy-lldb";
    version = "git";
    src = inputs.rudy-src;

    buildAndTestSubdir = "rudy-lldb";

    cargoPatches = [ ../pkgs/rudy/Cargo.lock.patch ];
    cargoHash = "sha256-AY82Fh3Mtjry9sI9OYXJ14iWSZoZWe+1CInZpZLAtG4=";

    postInstall = ''
      install -Dm644 rudy-lldb/python/rudy_lldb.py \
        $out/share/lldb/rudy_lldb.py
    '';
  };
}