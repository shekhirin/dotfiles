let
  group = "media";
in
{
  users.groups."${group}" = { };

  systemd.tmpfiles.rules = [
    "d /mnt/nvme/media 0775 root ${group} -"
    "Z /mnt/nvme/media 0775 root ${group} -"
  ];

  services.jellyfin = {
    enable = true;
    openFirewall = true;
    group = "${group}";
  };
}
