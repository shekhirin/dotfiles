_:

let
  # User group for media access
  group = "media";
in
{
  # Create media group for shared access
  users.groups."${group}" = { };

  # Sonarr service configuration
  services.sonarr = {
    enable = true;
    openFirewall = true;
    group = "${group}";
  };
}
