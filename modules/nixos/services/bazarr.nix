_:

let
  # User group for media access
  group = "media";
in
{
  # Create media group for shared access
  users.groups."${group}" = { };

  # Bazarr service configuration
  services.bazarr = {
    enable = true;
    openFirewall = true;
    group = "${group}";
  };
}
