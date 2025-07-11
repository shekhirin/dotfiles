{ lib, stdenv, fetchurl, undmg }:

# TODO: Add auto-update functionality using nix-update
# Can be enabled by:
# 1. Adding nix-update to dev-tools.nix
# 2. Adding passthru.updateScript = [ "nix-update" "--flake" ];
# 3. Adding nix-update command to justfile update sequence

stdenv.mkDerivation rec {
  pname = "protonvpn";
  version = "5.0.0";

  src = fetchurl {
    url = "https://github.com/ProtonVPN/ios-mac-app/releases/download/mac%2F${version}/ProtonVPN_mac_v${version}.dmg";
    sha256 = "10anz8q1121jnscbkccf8y7ak965w92hayf7kd5364rr817ar0wp";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -r ProtonVPN.app $out/Applications/
  '';

  meta = with lib; {
    description = "ProtonVPN app for macOS";
    homepage = "https://protonvpn.com/";
    license = licenses.unfree;
    platforms = platforms.darwin;
    maintainers = with maintainers; [ ];
  };
}