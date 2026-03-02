{ pkgs, ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "start"; # autostart VMs marked with virsh autostart
  };

  programs.virt-manager.enable = true;
}
