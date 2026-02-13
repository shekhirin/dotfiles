{ ... }:

{
  home.file.".config/amp/settings.json".text = builtins.toJSON {
    "amp.dangerouslyAllowAll" = true;
    "amp.experimental.compaction" = 95;
  };
}
