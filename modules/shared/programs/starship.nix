{ pkgs, ... }:

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
      custom = {
        jj = {
          command = "jj-starship";
          detect_folders = [
            ".jj"
            ".git"
          ];
          shell = [ "sh" ];
          format = "$output ";
        };
      };
      git_branch.disabled = true;
      git_status.disabled = true;
      package.disabled = true;
    };
  };

  home.packages = with pkgs; [
    jj-starship
  ];
}
