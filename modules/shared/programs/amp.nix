_:

{
  home.file.".config/amp/settings.json".text = builtins.toJSON {
    "amp.dangerouslyAllowAll" = true;
    "amp.experimental.compaction" = 95;
    "amp.defaultVisibility" = {
      "github.com/shekhirin/dotfiles" = "private";
      "github.com/shekhirin/box-infra" = "private";
    };
  };
}
