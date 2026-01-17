{
  pkgs,
  inputs,
  ...
}:

let
  user = "shekhirin";
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/shared
    inputs.home-manager.nixosModules.home-manager
    inputs.ethereum-nix.nixosModules.default
    # NixOS system-level modules (services, packages, sops, etc.)
    ../../modules/nixos/services
    ../../modules/nixos/packages.nix
    ../../modules/nixos/sops.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking = {
    hostName = "box";
    networkmanager.enable = true;
    firewall.allowedTCPPorts = [ 22 ];
  };

  # Locale and timezone
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # File systems
  fileSystems."/mnt/nvme" = {
    device = "/dev/nvme0n1p1";
    fsType = "ext4";
  };
  fileSystems."/mnt/lightroom" = {
    device = "/dev/nvme1n1p2";
    fsType = "ext4";
  };

  # X11 keymap
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # User configuration
  users.users.${user} = {
    isNormalUser = true;
    description = "Alexey Shekhirin";
    shell = pkgs.nushell;
    extraGroups = [
      "media"
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = [
      # Darwin
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHCSyqxtDQZqLp6tguxYXTo7pdZ691XmD7fur06pjurd"
      # Termius
      "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBIZbD5Ma00EMi+rMkWC89m6nh3bzO8njIuq1H6ptJdlmfmT/SdhDUt4xCHq/F4e8PLfzJPOaMDVbPuDS2PiP2w4="
    ];
  };

  # Allow passwordless sudo for deployment
  security.sudo.wheelNeedsPassword = false;

  # Home Manager configuration
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${user} = {
      imports = [
        # Shared home-manager configuration (packages and programs)
        ../../modules/shared/home.nix

        # NixOS-specific home-manager configuration (shell)
        ../../modules/nixos/shell.nix

        # Clawdbot (Telegram AI assistant)
        ../../modules/nixos/clawdbot
      ];
      home.stateVersion = "25.05";
    };
  };

  # Workaround for nix-clawdbot using hardcoded /bin paths
  # TODO: report upstream
  system.activationScripts.binCompat = ''
    mkdir -p /bin
    ln -sfn ${pkgs.coreutils}/bin/mkdir /bin/mkdir
    ln -sfn ${pkgs.coreutils}/bin/ln /bin/ln
    ln -sfn ${pkgs.coreutils}/bin/cat /bin/cat
    ln -sfn ${pkgs.coreutils}/bin/rm /bin/rm
    ln -sfn ${pkgs.coreutils}/bin/chmod /bin/chmod
  '';

  # State version
  system.stateVersion = "25.05";
}
