# Zinit config

echo ""
pfetch

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"


eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

alias cd="z"
alias vim="nvim"

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit snippet OMZP::git

autoload -U compinit && compinit

zinit cdreplay -q

bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

HISTSIZE=10000
HISTFILE=~/.histfile
SAVEHIST=$HISTSIZE
HISTDUP=erase

setopt appendhistory
setopt share_history

setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:completion:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

alias ls='ls --color'

# FZF
eval "$(fzf --zsh)"

# bun completions
[ -s "/home/archery/.bun/_bun" ] && source "/home/archery/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket

# Updating locales
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LC_NUMERIC=en_US.UTF-8
export LC_COLLATE=en_US.UTF-8
export LC_TIME=en_US.UTF-8
export LC_MESSAGES=en_US.UTF-8
export LC_MONETARY=en_US.UTF-8
export LC_ADDRESS=en_US.UTF-8
export LC_IDENTIFICATION=en_US.UTF-8
export LC_MEASUREMENT=en_US.UTF-8
export LC_PAPER=en_US.UTF-8
export LC_TELEPHONE=en_US.UTF-8
export LC_NAME=en_US.UTF-8
