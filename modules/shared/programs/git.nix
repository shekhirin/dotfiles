_:

{
  programs.git = {
    enable = true;
    settings = {
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
