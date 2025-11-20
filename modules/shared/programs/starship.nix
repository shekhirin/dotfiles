_:

{
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = {
      directory = {
        truncate_to_repo = false;
      };
      docker_context = {
        disabled = true;
      };
    };
  };
}
