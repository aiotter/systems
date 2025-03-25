#!/usr/bin/env zsh

# https://superuser.com/questions/446594/separate-up-arrow-lookback-for-local-and-global-zsh-history
bindkey "${terminfo[kcuu1]}" up-line-or-local-history
bindkey '^[[A' up-line-or-local-history
bindkey '^P' up-line-or-local-history
bindkey "${terminfo[kcud1]}" down-line-or-local-history
bindkey '^[[B' down-line-or-local-history
bindkey '^N' down-line-or-local-history

up-line-or-local-history() {
    zle set-local-history 1
    zle up-line-or-history
    zle set-local-history 0
}
zle -N up-line-or-local-history

down-line-or-local-history() {
    zle set-local-history 1
    zle down-line-or-history
    zle set-local-history 0
}
zle -N down-line-or-local-history
