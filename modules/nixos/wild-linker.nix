{ pkgs, ... }:

{
  # Make wild available system-wide
  environment.systemPackages = with pkgs; [
    wild
  ];

  # Configure cargo to use wild linker by default
  home-manager.users.shekhirin = {
    home.file.".cargo/config.toml".text = ''
      [target.x86_64-unknown-linux-gnu]
      linker = "clang"
      rustflags = ["-C", "link-arg=-fuse-ld=${pkgs.wild}/bin/wild"]
    '';
  };
}