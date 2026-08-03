{ pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      desktopManager.xfce.enable = true;
      displayManager.lightdm.enable = true;
    };
    displayManager.defaultSession = "xfce";

    logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchDocked = "ignore";
      HandleLidSwitchExternalPower = "ignore";
      IdleAction = "ignore";
    };

    xrdp = {
      enable = true;
      audio.enable = true;
      defaultWindowManager = "${pkgs.xfce4-session}/bin/startxfce4";
      openFirewall = false;
      port = 3389;
    };

    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
  };

  systemd.sleep.settings.Sleep = {
    AllowSuspend = "no";
    AllowHibernation = "no";
    AllowHybridSleep = "no";
    AllowSuspendThenHibernate = "no";
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 3389 ];

  hardware.graphics.enable = true;

  security.rtkit.enable = true;
  environment.systemPackages = with pkgs; [
    mesa-demos
    wl-clipboard
    xclip
    xdg-utils
  ];
}
