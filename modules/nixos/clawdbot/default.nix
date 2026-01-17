{ inputs, config, ... }:

{
  imports = [
    inputs.nix-clawdbot.homeManagerModules.clawdbot
    ./sync.nix
  ];

  programs.clawdbot = {
    # Documents managed separately in private repo: github.com/shekhirin/clawdbot-documents
    # Bidirectional sync via systemd timer (pulls remote, pushes local changes)
    documents = "${config.home.homeDirectory}/clawdbot-documents";
    instances.default = {
      enable = true;
      providers.telegram = {
        enable = true;
        botTokenFile = "/run/secrets/clawdbot/telegram-bot-token";
        allowFrom = [ 74417822 ];
        groups = {
          "*" = {
            requireMention = true;
          };
        };
      };
      # ChatGPT OAuth via Codex
      # Run on box: clawdbot onboard --auth-choice openai-codex
      agent.model = "openai-codex/gpt-4.1";
    };
  };
}
