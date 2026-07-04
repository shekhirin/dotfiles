{ pkgs, ... }:

{
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    displayManager.lightdm.enable = true;
  };
  services.displayManager.defaultSession = "xfce";

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    IdleAction = "ignore";
  };

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };

  services.xrdp = {
    enable = true;
    audio.enable = true;
    defaultWindowManager = "${pkgs.xfce4-session}/bin/startxfce4";
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
