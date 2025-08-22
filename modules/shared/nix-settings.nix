{ pkgs, ... }:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Set nixfmt-tree as the system-wide Nix formatter
  environment.systemPackages = [ pkgs.nixfmt-tree ];
}
