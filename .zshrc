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

alias l='exa'
alias la='exa -a'
alias ll='exa -lah'
alias ls='exa --color=auto'

alias cat='bat --paging=never'

alias cd='z'

alias k=kubectl
complete -F __start_kubectl k

alias speed='npx speed-cloudflare-cli'

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
