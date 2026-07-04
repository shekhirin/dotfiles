{ pkgs, ... }:

{
  services.xserver.enable = true;

  services.desktopManager.plasma6.enable = true;
  services.displayManager = {
    defaultSession = "plasma";
    sddm = {
      enable = true;
      enableHidpi = true;
    };
  };

  services.xrdp = {
    enable = true;
    audio.enable = true;
    defaultWindowManager = "${pkgs.kdePackages.plasma-workspace}/bin/startplasma-x11";
    openFirewall = false;
    port = 3389;
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 3389 ];

  hardware.graphics.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    mesa-demos
    wl-clipboard
    xclip
    xdg-utils
  ];
}
