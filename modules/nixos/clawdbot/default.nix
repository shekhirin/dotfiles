{ inputs, config, pkgs, ... }:

{
  imports = [
    inputs.nix-clawdbot.homeManagerModules.clawdbot
    ./sync.nix
  ];

  # Add docker to clawdbot-gateway service PATH and grant docker socket access
  systemd.user.services.clawdbot-gateway.Service = {
    Environment = [
      "PATH=${pkgs.docker}/bin:/run/current-system/sw/bin:$PATH"
    ];
    SupplementaryGroups = [ "docker" ];
  };

  programs.clawdbot = {
    # Documents managed separately in private repo: github.com/shekhirin/clawdbot-documents
    # Bidirectional sync via systemd timer (pulls remote, pushes local changes)
    # Using workspaceDir instead of documents to avoid build-time validation

    # Disable macOS-only plugins
    firstParty.peekaboo.enable = false;
    firstParty.summarize.enable = false;

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
      agent.model = "openai-codex/gpt-5.2";

      # Override wizard settings
      configOverrides = {
        gateway.mode = "local";
        # Run all sessions in Docker sandbox
        agents.defaults.sandbox.mode = "all";
      };
    };
  };
}
