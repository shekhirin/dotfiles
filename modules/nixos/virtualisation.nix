{ pkgs, ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "start"; # autostart VMs marked with virsh autostart
    qemu.ovmf.enable = true;
  };

  programs.virt-manager.enable = true;
}
