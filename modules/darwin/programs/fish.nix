{ lib, ... }:

{
  programs.fish = {
    shellInit = lib.mkAfter ''
      ulimit -n 524288 10485760 2>/dev/null
    '';

    functions.layout = {
      description = "Set up aerospace window layout";
      argumentNames = [ "variant" ];
      body = ''
        set -l external M28U
        set -l builtin "Built-in Retina Display"

        # apps: "<app>:<workspace>", monitors: "<monitor>|<workspaces>"
        switch "$variant"
            case 1
                set apps Helium:1 Ghostty:2 "Zed Preview:2" Spotify:3 Slack:10 Telegram:10
                set monitors "$external|1 2 3 4 5 6 7 8 9" "$builtin|10"
            case 2
                set apps Helium:1 Ghostty:2 "Zed Preview:2" Slack:3 Telegram:3 Spotify:4
                set monitors "$builtin|1 2 3 4 5 6 7 8 9 10"
            case '*'
                echo "Invalid variant. Use 1-2." >&2
                return 1
        end

        set -l initial_workspace (aerospace list-workspaces --focused | string trim)

        # Open apps that aren't running
        set -l existing_windows (aerospace list-windows --all --format '%{app-name}')
        for item in $apps
            set -l app (string split -r -m1 : -- $item)[1]
            if not contains -- $app $existing_windows
                echo "Opening $app..."
                open -g -a $app 2>/dev/null; or echo "  Warning: $app not found, skipping..."
            end
        end

        # Wait for windows to appear
        echo "Waiting for windows..."
        for item in $apps
            set -l app (string split -r -m1 : -- $item)[1]
            for attempt in (seq 30)
                contains -- $app (aerospace list-windows --all --format '%{app-name}'); and break
                sleep 0.1
            end
        end

        # Move windows to workspaces
        echo "Moving windows to workspaces..."
        for item in $apps
            set -l parts (string split -r -m1 : -- $item)
            for line in (aerospace list-windows --all --format '%{window-id} %{app-name}')
                set -l window (string split -m1 ' ' -- $line)
                if test "$window[2]" = "$parts[1]"
                    aerospace move-node-to-workspace --window-id $window[1] $parts[2]
                end
            end
        end

        # Assign workspaces to monitors (must focus workspace first to move it)
        echo "Assigning workspaces to monitors..."
        for item in $monitors
            set -l parts (string split -m1 '|' -- $item)
            for ws in (string split ' ' -- $parts[2])
                aerospace workspace $ws
                aerospace move-workspace-to-monitor $parts[1]
            end
        end

        # Restore focus to initial workspace
        aerospace workspace $initial_workspace

        echo "Layout complete!"
      '';
    };
  };
}
