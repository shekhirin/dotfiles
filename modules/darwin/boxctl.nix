{ buildGo126Module, src }:

buildGo126Module {
  pname = "boxctl";
  version = "0-unstable-${builtins.substring 0 7 src.rev}";

  inherit src;
  vendorHash = "sha256-yJmGEAwDSAUeHJw7tmlESKeUJA8wGvTRRFPboRYQ9+c=";
  subPackages = [ "cmd/boxctl" ];
  ldflags = [
    "-s"
    "-w"
  ];

  meta.mainProgram = "boxctl";
}
