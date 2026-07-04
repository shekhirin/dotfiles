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
    ./envfs.nix
    ./openssh.nix
    ./mosh.nix
  ];
}
