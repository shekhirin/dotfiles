{ ... }:
{
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--tls-san box" # Tailscale MagicDNS hostname
      "--tls-san 100.122.53.116" # Tailscale IP
      "--default-local-storage-path /mnt/nvme/k3s/storage"
      "--write-kubeconfig-mode 644"
    ];
  };

  # Allow k3s API server via Tailscale interface only
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 6443 ];

  # Trust k3s CNI interface (flannel)
  networking.firewall.trustedInterfaces = [
    "flannel.1"
    "cni0"
  ];
}
