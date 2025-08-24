{ ... }:

{
  imports = [
    ./packages.nix
    ./services.nix
    ./monero.nix
    ./reth.nix
    ./lighthouse.nix
    ./monitoring.nix
    ./media.nix
    ./sops.nix
  ];
}
