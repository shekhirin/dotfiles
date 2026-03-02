{ pkgs, ... }:
{
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "start";
  };

  networking.firewall.trustedInterfaces = [ "virbr0" ];

  systemd.services.libvirtd-default-network = {
    description = "Define and start libvirt default network";
    wantedBy = [ "multi-user.target" ];
    after = [ "libvirtd.service" ];
    requires = [ "libvirtd.service" ];
    path = [ pkgs.libvirt ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if ! virsh net-info default &>/dev/null; then
        virsh net-define /dev/stdin <<EOF
      <network>
        <name>default</name>
        <forward mode='nat'/>
        <bridge name='virbr0' stp='on' delay='0'/>
        <ip address='192.168.122.1' netmask='255.255.255.0'>
          <dhcp>
            <range start='192.168.122.2' end='192.168.122.254'/>
          </dhcp>
        </ip>
      </network>
      EOF
      fi
      virsh net-autostart default
      virsh net-start default || true
    '';
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/libvirt/boot 0755 root root -"
  ];

  programs.virt-manager.enable = true;
}
