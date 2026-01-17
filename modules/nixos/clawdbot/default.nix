{ inputs, config, ... }:

{
  imports = [
    inputs.nix-clawdbot.homeManagerModules.clawdbot
    ./sync.nix
  ];

  programs.clawdbot = {
    # Documents managed separately in private repo: github.com/shekhirin/clawdbot-documents
    # Bidirectional sync via systemd timer (pulls remote, pushes local changes)
    # Using workspaceDir instead of documents to avoid build-time validation
    instances.default = {
      enable = true;
      workspaceDir = "${config.home.homeDirectory}/clawdbot-documents";
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
