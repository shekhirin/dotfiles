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

  systemd.services.openclaw-tunnel = {
    description = "SSH tunnel to OpenClaw dashboard in VM";
    wantedBy = [ "multi-user.target" ];
    after = [
      "network-online.target"
      "libvirtd.service"
    ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.openssh}/bin/ssh -N -i /home/shekhirin/.ssh/openclaw_tunnel -o StrictHostKeyChecking=no -o ServerAliveInterval=30 -L 0.0.0.0:18789:localhost:18789 openclaw@192.168.122.25";
      Restart = "always";
      RestartSec = 5;
      User = "shekhirin";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/libvirt/boot 0755 root root -"
  ];

  programs.virt-manager.enable = true;
}
