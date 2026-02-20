_:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Alexey Shekhirin";
        email = "github@shekhirin.com";
      };
      core = {
        editor = "vim";
      };
      url = {
        "git@github.com:" = {
          insteadOf = "https://github.com/";
        };
      };
    };
  };
}
