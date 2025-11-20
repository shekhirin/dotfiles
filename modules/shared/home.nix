{ ... }:

{
  # Home-Manager-level shared configuration
  # Import this in home-manager user configurations
  imports = [
    ./packages.nix
    ./programs
  ];
}
