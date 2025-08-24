{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "qbittorrent-exporter";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "martabal";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-ADsR3QIXvn5QgV312kBvxY5USNC474ddiJ9YsozsfFU=";
  };
  sourceRoot = "${src.name}/src";

  vendorHash = "sha256-P0QhV7vvyuCF/XEKH67v+Fp55VqXSAQ9W0GSnQwaUwg=";

  ldflags = [
    "-s"
    "-w"
  ];

  doCheck = false;

  meta = with lib; {
    description = "A fast and lightweight Prometheus exporter for qBittorrent.";
    homepage = "https://github.com/martabal/qbittorrent-exporter";
    license = licenses.mit;
    mainProgram = "qbit-exp";
  };
}
