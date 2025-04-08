export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(
    git
    zsh-autosuggestions
    docker
    docker-compose
)
source $ZSH/oh-my-zsh.sh

function source_bee_init_on_linux_dir() {
    if [[ "$PWD" == /Volumes/Linux/linux* ]]; then
        source bee-init
    fi
}
autoload -U add-zsh-hook
add-zsh-hook chpwd source_bee_init_on_linux_dir

export HOMEBREW_NO_ENV_HINTS=yes

source ~/.env.secrets

# ghostty word jumps
bindkey "\e[1;3D" backward-word
bindkey "\e[1;3C" forward-word

alias ls=eza
alias cd=z

sugoi () {
    yabai --start-service
    # Hide all windows
    osascript <<END
activate application "Finder"
tell application "System Events"
  set visible of processes where name is not "Finder" to false
end tell
tell application "Finder" to set collapsed of windows to true
END
    # Laptop
    yabai -m query --windows | jq -e '.[] | select(.app == "Slack")."is-native-fullscreen"' && (yabai -m query --windows | jq '.[] | select(.app == "Slack").id' | xargs -I{} yabai -m window {} --toggle native-fullscreen && sleep 1)
    yabai -m query --windows | jq -e '.[] | select(.app == "Slack")."is-visible" | not' && open /Applications/Slack.app
    yabai -m query --windows | jq '.[] | select(.app == "Slack").id' | xargs -I{} yabai -m window {} --display east --warp east
    yabai -m query --windows | jq '.[] | select(.app == "Slack").id' | xargs -I{} yabai -m window {} --resize right:$(yabai -m query --windows | jq '.[] | 1200 - select(.app == "Slack").frame.w'):0
    yabai -m query --windows | jq -e '.[] | select(.app == "Slack")."split-type" == "horizontal"' && yabai -m query --windows | jq '.[] | select(.app == "Slack").id' | xargs -I{} yabai -m window {} --toggle split
    # Main monitor
    yabai -m query --windows | jq -e '.[] | select(.app == "Google Chrome")."is-native-fullscreen"' && (yabai -m query --windows | jq '.[] | select(.app == "Google Chrome").id' | xargs -I{} yabai -m window {} --toggle native-fullscreen && sleep 1)
    yabai -m query --windows | jq -e '.[] | select(.app == "Ghostty")."is-native-fullscreen"' && (yabai -m query --windows | jq '.[] | select(.app == "Ghostty").id' | xargs -I{} yabai -m window {} --toggle native-fullscreen && sleep 1)
    yabai -m query --windows | jq -e '.[] | select(.app == "Google Chrome")."is-visible" | not' && open /Applications/Google\ Chrome.app
    yabai -m query --windows | jq -e '.[] | select(.app == "Ghostty")."is-visible" | not' && open /Applications/Ghostty.app
    yabai -m query --windows | jq -e '.[] | select(.app == "Ghostty")."split-type" == "horizontal"' && yabai -m query --windows | jq '.[] | select(.app == "Ghostty").id' | xargs -I{} yabai -m window {} --toggle split
    yabai -m query --windows | jq '.[] | select(.app == "Ghostty").id' | xargs -I{} yabai -m window {} --display west --warp west
    yabai -m query --windows | jq '.[] | select(.app == "Google Chrome").id' | xargs -I{} yabai -m window {} --display west --warp west
    yabai -m query --windows | jq '.[] | select(.app == "Ghostty") | .space' | xargs -I{} yabai -m space {} --balance
}
kirei () {
    yabai --start-service
    # Hide all windows
    osascript <<END
activate application "Finder"
tell application "System Events"
  set visible of processes where name is not "Finder" to false
end tell
tell application "Finder" to set collapsed of windows to true
END
    # Open Google Chrome and Ghostty if they are not visible
    yabai -m query --windows | jq -e '.[] | select(.app == "Google Chrome")."is-visible" | not' && open /Applications/Google\ Chrome.app
    yabai -m query --windows | jq -e '.[] | select(.app == "Ghostty")."is-visible" | not' && open /Applications/Ghostty.app
    # Make Google Chrome fullscreen first, so it goes further down the list of spaces
    yabai -m query --windows | jq '.[] | select(.app == "Google Chrome")."is-native-fullscreen" | not' && (yabai -m query --windows | jq '.[] | select(.app == "Google Chrome").id' | xargs -I{} yabai -m window {} --toggle native-fullscreen && sleep 1)
    # Then, make Ghostty fullscreen
    yabai -m query --windows | jq '.[] | select(.app == "Ghostty")."is-native-fullscreen" | not' && (yabai -m query --windows | jq '.[] | select(.app == "Ghostty").id' | xargs -I{} yabai -m window {} --toggle native-fullscreen && sleep 1)
    yabai --stop-service
}

mptb() {
    cast from-rlp "$1" | \
        jq '.[0:17] |
        to_entries |
        map({key: ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f","value"][.key], value: .value}) |
    from_entries'
}

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
