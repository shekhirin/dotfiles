const MONITOR_EXTERNAL = "M28U"
const MONITOR_BUILTIN = "Built-in Retina Display"

const LAYOUTS = [
    {
        monitors: [
            { monitor: $MONITOR_EXTERNAL, workspaces: 1..9 }
            { monitor: $MONITOR_BUILTIN, workspace: 10 }
        ]
        workspaces: [
            { workspace: 1, app: "Brave Browser" }
            { workspace: 2, apps: ["Ghostty", "Zed Preview"] }
            { workspace: 3, app: "Spotify" }
            { workspace: 10, apps: ["Slack", "Telegram"] }
        ]
    }
    {
        monitors: [
            { monitor: $MONITOR_BUILTIN, workspaces: 1..10 }
        ]
        workspaces: [
            { workspace: 1, app: "Brave Browser" }
            { workspace: 2, apps: ["Ghostty", "Zed Preview"] }
            { workspace: 3, apps: ["Slack", "Telegram"] }
            { workspace: 4, app: "Spotify" }
        ]
    }
]

export def layout [variant: int] {
    if $variant < 1 or $variant > ($LAYOUTS | length) {
        error make { msg: $"Invalid variant. Use 1-($LAYOUTS | length)." }
    }
    let initial_workspace = aerospace list-workspaces --focused | str trim
    let config = $LAYOUTS | get ($variant - 1)

    # Expand workspaces config to flat list of {app, workspace}
    let apps_flat = $config.workspaces | each { |item|
        let app_list = if ($item | get -o apps | is-not-empty) {
            $item.apps
        } else {
            [$item.app]
        }
        $app_list | each { |a| { app: $a, workspace: $item.workspace } }
    } | flatten

    # Open apps that aren't running
    let existing_windows = aerospace list-windows --all --format '%{app-name}' | lines
    for item in $apps_flat {
        if not ($existing_windows | any { |w| $w == $item.app }) {
            print $"Opening ($item.app)..."
            try {
                ^open -g -a $item.app
            } catch {
                print $"  Warning: ($item.app) not found, skipping..."
            }
        }
    }

    # Wait for windows to appear
    print "Waiting for windows..."
    for item in $apps_flat {
        mut attempts = 0
        while $attempts < 30 {
            let windows = aerospace list-windows --all --format '%{app-name}' | lines
            if ($windows | any { |w| $w == $item.app }) {
                break
            }
            sleep 100ms
            $attempts = $attempts + 1
        }
    }

    # Move windows to workspaces
    print "Moving windows to workspaces..."
    for item in $apps_flat {
        let window_ids = aerospace list-windows --all --format '%{window-id} %{app-name}'
            | lines
            | parse '{id} {app}'
            | where app == $item.app
            | get id

        for window_id in $window_ids {
            aerospace move-node-to-workspace --window-id $window_id $item.workspace
        }
    }

    # Assign workspaces to monitors (must focus workspace first to move it)
    print "Assigning workspaces to monitors..."
    for item in $config.monitors {
        let workspaces = if ($item | get -o workspaces | is-not-empty) {
            $item.workspaces
        } else {
            [$item.workspace]
        }
        for ws in $workspaces {
            aerospace workspace $ws
            aerospace move-workspace-to-monitor $item.monitor
        }
    }

    # Restore focus to initial workspace
    aerospace workspace $initial_workspace

    print "Layout complete!"
}
