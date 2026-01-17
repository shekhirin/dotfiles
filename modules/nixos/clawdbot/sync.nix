{ pkgs, config, ... }:

let
  repoUrl = "git@github.com:shekhirin/clawdbot-documents.git";
  repoDir = "${config.home.homeDirectory}/clawdbot-documents";
in
{
  # Systemd user service to bidirectionally sync clawdbot documents
  systemd.user.services.clawdbot-documents-sync = {
    Unit = {
      Description = "Sync clawdbot documents with private repo";
    };
    Service = {
      Type = "oneshot";
      ExecStart = toString (
        pkgs.writeShellScript "clawdbot-documents-sync" ''
          set -euo pipefail
          GIT="${pkgs.git}/bin/git"

          if [ ! -d "${repoDir}" ]; then
            $GIT clone "${repoUrl}" "${repoDir}"
            exit 0
          fi

          cd "${repoDir}"

          # Commit any local changes first
          if [ -n "$($GIT status --porcelain)" ]; then
            $GIT add -A
            $GIT commit -m "Auto-sync from box"
          fi

          # Pull remote changes (rebase to keep local commits on top)
          $GIT pull --rebase

          # Push local commits
          $GIT push
        ''
      );
    };
  };

  systemd.user.timers.clawdbot-documents-sync = {
    Unit = {
      Description = "Sync clawdbot documents every 15 minutes";
    };
    Timer = {
      OnBootSec = "1min";
      OnUnitActiveSec = "15min";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}
