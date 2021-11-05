# misc options
setopt correct # try autocorrect mistakes
setopt extendedglob # extended globbing. Allows regex with *
setopt nocaseglob # case insensitive globbing
setopt nocheckjobs # don't warn about running processes when exiting
setopt numericglobsort # sort filenames numerically when it makes sense
setopt nobeep # no beep
setopt appendhistory # append history instead of overwriting
setopt histignorealldups # if a new command is a duplicate, remove the older one
setopt autocd # if only directory path is entered, cd there
set -k # Allow comments in shell

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # colored completion
zstyle ':completion:*' rehash true # automatically find new executables in path 
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
mkdir -p "$HOME/.local/share/zsh"
HISTFILE="$HOME/.local/share/zsh/history"
HISTSIZE=10000
SAVEHIST=5000
WORDCHARS=${WORDCHARS//\/[&.;]} # Don't consider certain characters part of the word
zmodload zsh/terminfo
printf "\e[4q" # underline

# aliases
alias ..='cd ..'
alias rm='echo nö benutze bitte trash-cli'
alias mv='mv -i'
alias cp='cp -i'
alias ls='exa --color=always --group-directories-first --icons'
alias tp='trash-put'
alias vim='NVIM_LISTEN_ADDRESS=/tmp/nvimsocket nvim'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias ra='ranger --choosedir=$HOME/.config/rangerdir.txt; LASTDIR=`cat $HOME/.config/rangerdir.txt`; cd "$LASTDIR"'
alias u='cd /run/media/$USER/glitnir/uni'

alias v='NVIM_LISTEN_ADDRESS=/tmp/nvimsocket nvim'
alias t='todo.sh'

# color man pages
export LESS_TERMCAP_mb=$'\E[01;32m'
export LESS_TERMCAP_md=$'\E[01;32m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;47;34m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;36m'
export LESS=-r

# plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source /usr/share/fzf/completion.zsh
source /usr/share/fzf/key-bindings.zsh

# bind up/down to history, control left/right to move by word
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[A' history-substring-search-up			
bindkey '^[[B' history-substring-search-down
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# env vars
export EDITOR="NVIM_LISTEN_ADDRESS=/tmp/nvimsocket nvim"
export VISUAL="NVIM_LISTEN_ADDRESS=/tmp/nvimsocket nvim"

# directory as window title
precmd() {
    printf '\033]0;%s\007' "$(dirs)"
}

# epic fzf history on Control+r
fzf-history() {
    $(fzf --height=20% --prompt='> ' --pointer='>' --preview='echo {}' \
        --color=fg:4,bg:-1,bg+:-1,info:7,prompt:10,pointer:10 \
        < "$HISTFILE")
}

zle -N fzf-history
bindkey '^R' fzf-history

# ~/.local/bin is where I keep scripts but it isn't in PATH by default on some distros
export PATH="$HOME/.local/bin:$PATH"

# use z and starship
eval "$(lua /usr/share/z.lua/z.lua --init bash)"
eval "$(starship init zsh)"

