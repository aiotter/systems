insert-bar() {
  # when just after completion
  if [[ $LASTWIDGET == (expand-or-complete|complete-word|menu-complete|expand-or-complete-prefix|_main_complete) ]]; then
    # disable removing the last space in the completion
    LBUFFER="$LBUFFER|"
  else
    zle self-insert
  fi
}

zle -N insert-bar
bindkey '|' insert-bar
