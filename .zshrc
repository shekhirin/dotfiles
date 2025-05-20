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

mptb() {
    cast from-rlp "$1" | \
        jq '.[0:17] |
        to_entries |
        map({key: ["0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f","value"][.key], value: .value}) |
    from_entries'
}

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
