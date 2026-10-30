{
  buildGo126Module,
  installShellFiles,
  src,
}:

buildGo126Module {
  pname = "boxctl";
  version = "0-unstable-${builtins.substring 0 7 src.rev}";

  inherit src;
  vendorHash = "sha256-DNGFgTNl8ZSj3fGbm1jyDhtFsBg8Wa+hkf2me67UY34=";
  subPackages = [ "cmd/boxctl" ];
  ldflags = [
    "-s"
    "-w"
  ];

  nativeBuildInputs = [ installShellFiles ];

  postInstall = ''
    installShellCompletion --cmd boxctl --fish <($out/bin/boxctl completion fish)
  '';

  meta.mainProgram = "boxctl";
}
