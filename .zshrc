# Zsh
source ~/zsh-snap/znap.zsh

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
    git
    zsh-autosuggestions
    docker
    docker-compose
)

source $ZSH/oh-my-zsh.sh

export HOMEBREW_NO_ENV_HINTS=yes

alias l='eza'
alias la='eza -a'
alias ll='eza -lah'
alias ls='eza --color=auto'

alias cat='bat --paging=never'

alias cd='z'

alias k=kubectl
complete -F __start_kubectl k

alias speed='npx speed-cloudflare-cli'

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
    yabai -m query --windows | jq -e '.[] | select(.app == "Discord")."is-native-fullscreen"' && (yabai -m query --windows | jq '.[] | select(.app == "Discord").id' | xargs -I{} yabai -m window {} --toggle native-fullscreen && sleep 1)
    yabai -m query --windows | jq -e '.[] | select(.app == "Telegram")."is-native-fullscreen"' && (yabai -m query --windows | jq '.[] | select(.app == "Telegram").id' | xargs -I{} yabai -m window {} --toggle native-fullscreen && sleep 1)
    yabai -m query --windows | jq -e '.[] | select(.app == "Messages")."is-native-fullscreen"' && (yabai -m query --windows | jq '.[] | select(.app == "Messages").id' | xargs -I{} yabai -m window {} --toggle native-fullscreen && sleep 1)
    yabai -m query --windows | jq -e '.[] | select(.app == "Discord")."is-visible" | not' && open /Applications/Discord.app
    yabai -m query --windows | jq -e '.[] | select(.app == "Telegram")."is-visible" | not' && open /Applications/Telegram.localized/Telegram.app
    yabai -m query --windows | jq -e '.[] | select(.app == "Messages")."is-visible" | not' && open /System/Applications/Messages.app
    yabai -m query --windows | jq '.[] | select(.app == "Discord").id' | xargs -I{} yabai -m window {} --display east --warp west
    yabai -m query --windows | jq '.[] | select(.app == "Telegram").id' | xargs -I{} yabai -m window {} --display east --warp east
    yabai -m query --windows | jq '.[] | select(.app == "Messages").id' | xargs -I{} yabai -m window {} --display east --warp east
    yabai -m query --windows | jq '.[] | select(.app == "Telegram").id' | xargs -I{} yabai -m window {} --resize bottom:0:$(yabai -m query --windows | jq '.[] | 562 - select(.app == "Telegram").frame.h')
    yabai -m query --windows | jq '.[] | select(.app == "Discord").id' | xargs -I{} yabai -m window {} --resize right:$(yabai -m query --windows | jq '.[] | 1200 - select(.app == "Discord").frame.w'):0
    yabai -m query --windows | jq -e '.[] | select(.app == "Discord")."split-type" == "horizontal"' && yabai -m query --windows | jq '.[] | select(.app == "Discord").id' | xargs -I{} yabai -m window {} --toggle split
    # Main monitor
    yabai -m query --windows | jq -e '.[] | select(.app == "Arc")."is-native-fullscreen"' && (yabai -m query --windows | jq '.[] | select(.app == "Arc").id' | xargs -I{} yabai -m window {} --toggle native-fullscreen && sleep 1)
    yabai -m query --windows | jq -e '.[] | select(.app == "Ghostty")."is-native-fullscreen"' && (yabai -m query --windows | jq '.[] | select(.app == "Ghostty").id' | xargs -I{} yabai -m window {} --toggle native-fullscreen && sleep 1)
    yabai -m query --windows | jq -e '.[] | select(.app == "Messages")."split-type" == "vertical"' && yabai -m query --windows | jq '.[] | select(.app == "Messages").id' | xargs -I{} yabai -m window {} --toggle split
    yabai -m query --windows | jq -e '.[] | select(.app == "Arc")."is-visible" | not' && open /Applications/Arc.app
    yabai -m query --windows | jq -e '.[] | select(.app == "Ghostty")."is-visible" | not' && open /Applications/Ghostty.app
    yabai -m query --windows | jq -e '.[] | select(.app == "Ghostty")."split-type" == "horizontal"' && yabai -m query --windows | jq '.[] | select(.app == "Ghostty").id' | xargs -I{} yabai -m window {} --toggle split
    yabai -m query --windows | jq '.[] | select(.app == "Ghostty").id' | xargs -I{} yabai -m window {} --display west --warp east
    yabai -m query --windows | jq '.[] | select(.app == "Arc").id' | xargs -I{} yabai -m window {} --display west --warp west
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
    # Open Arc and Ghostty if they are not visible
    yabai -m query --windows | jq -e '.[] | select(.app == "Arc")."is-visible" | not' && open /Applications/Arc.app
    yabai -m query --windows | jq -e '.[] | select(.app == "Ghostty")."is-visible" | not' && open /Applications/Ghostty.app
    # Make Arc fullscreen first, so it goes further down the list of spaces
    yabai -m query --windows | jq '.[] | select(.app == "Arc")."is-native-fullscreen" | not' && (yabai -m query --windows | jq '.[] | select(.app == "Arc").id' | xargs -I{} yabai -m window {} --toggle native-fullscreen && sleep 1)
    # Then, make Ghostty fullscreen
    yabai -m query --windows | jq '.[] | select(.app == "Ghostty")."is-native-fullscreen" | not' && (yabai -m query --windows | jq '.[] | select(.app == "Ghostty").id' | xargs -I{} yabai -m window {} --toggle native-fullscreen && sleep 1)
    yabai --stop-service
}

export GPG_TTY=$(tty)

export GOPATH="$HOME/go"


export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

source ~/.env.secrets

export LDFLAGS="-L/opt/homebrew/opt/llvm@13/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm@13/include"

. /opt/homebrew/opt/asdf/libexec/asdf.sh

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PYENV_ROOT="$HOME/.pyenv"

eval "$(pyenv init -)"

alias get_idf='. $HOME/Projects/esp-idf/export.sh'
export EDITOR=nvim

export BAT_THEME=ansi

# eval "$(atuin init zsh)"
eval "$(zoxide init zsh)"

# ghostty word jumps
bindkey "\e[1;3D" backward-word
bindkey "\e[1;3C" forward-word

# ZVM
export ZVM_INSTALL="$HOME/.zvm/self"

# Kurtosis
eval "$(kurtosis completion zsh)"

# PATH
export PATH="$PATH:$HOME/.zvm/bin"
export PATH="$PATH:$ZVM_INSTALL/"
export PATH="$HOME/Library/Python/3.8/bin:$PATH"
export PATH="$GOPATH/bin:$PATH"
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="$PATH:$HOME/.foundry/bin"
export PATH="/opt/homebrew/opt/llvm@13/bin:$PATH"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$HOME/zls:$PATH"
export PATH=$PATH:$HOME/.zokrates/bin
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="/Applications/Ghostty.app/Contents/MacOS:$PATH"
export PATH="/opt/homebrew/opt/make/libexec/gnubin:$PATH"
export PATH="/opt/homebrew/opt/llvm@17/bin:$PATH"
export PATH="/opt/homebrew/opt/curl/bin:$PATH"
