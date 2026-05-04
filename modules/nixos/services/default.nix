_:

{
  imports = [
    # Blockchain
    ./monero.nix

    # Media
    ./jellyfin.nix

    # Orchestration
    ./k3s.nix

    # System
    ./openssh.nix
    ./mosh.nix
  ];
}
