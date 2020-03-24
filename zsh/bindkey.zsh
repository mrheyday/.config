typeset -g -A key
key[Alt]="^["
key[Up]="^[OA"
key[Down]="^[OB"
key[ForwardWord]="^[f"
key[Backspace]="^?"
key[BackwardDeleteWord]="^W"
key[BackwardDeleteLine]="^U"
key[ControlSpace]="^@"
key[Tab]="^I"
key[BackTab]="^[[Z" # shift-tab
key[Enter]="^M"

# Bash/readline compatibility; zsh's default kills the whole line
bindkey "${key[BackwardDeleteLine]}" backward-kill-line

# Automatically correct misspelled words.
bindkey " " autocorrecting-space

bindkey "${key[Up]}" up-line-or-fzf-history
bindkey "${key[Down]}" down-line-or-complete-word
bindkey "${key[Alt]}${key[Up]}" fzf-history-widget
bindkey "${key[Alt]}${key[Down]}" complete-word

# Using forward-word + another action in a widget function doesn't work.
bindkey "${key[BackTab]}" clear-list
bindkey -s "${key[Tab]}" "${key[ForwardWord]}${key[BackTab]}"
bindkey -M menuselect -s "${key[Tab]}" "^D"

bindkey "${key[ControlSpace]}" expand-or-fzf-complete
bindkey -M menuselect "${key[ControlSpace]}" accept-and-menu-complete

autocorrecting-space() {
  # No chars to the right and last char to the left is a word char
  if (( ${#RBUFFER} == 0 && ${#LBUFFER[-1]%[[:WORD:]]} == 0 )); then
    zle spell-word
  fi
  zle autopair-insert
}
zle -N autocorrecting-space

up-line-or-fzf-history() {
  if (( BUFFERLINES > 1 )); then
    zle up-line
  else
    zle fzf-history-widget
  fi
}
zle -N up-line-or-fzf-history

down-line-or-complete-word() {
  if (( BUFFERLINES > 1 )); then
    zle down-line
  else
    zle complete-word
  fi
}
zle -N down-line-or-complete-word

expand-or-fzf-complete() {
  zle _expand_alias || zle expand-word || zle fzf-completion
}
zle -N expand-or-fzf-complete

clear-list() {
  zle -Rc
}
zle -N clear-list
