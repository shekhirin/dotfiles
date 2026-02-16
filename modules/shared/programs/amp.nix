{ ... }:

{
  home.file.".config/amp/settings.json".text = builtins.toJSON {
    "amp.dangerouslyAllowAll" = true;
    "amp.experimental.compaction" = 95;
    "amp.internal.model" = {
      "deep" = "openai:gpt-5.3-codex-api-preview";
    };
  };
}
