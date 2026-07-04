_:

{
  imports = [
    # Blockchain
    ./monero.nix

    # Media
    ./jellyfin.nix

    # Desktop
    ./desktop.nix

    # Orchestration
    ./k3s.nix

    # System
    ./openssh.nix
    ./mosh.nix
  ];
}
