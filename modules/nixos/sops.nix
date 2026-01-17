_:

{
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = ./secrets.yaml;

  # Clawdbot secrets
  sops.secrets."clawdbot/telegram-bot-token" = {
    owner = "shekhirin";
  };
}
