# Associative array `key` is defined in /etc/zshrc
key[Up]='^[[A'
key[Down]='^[[B'
key[Right]='^[[C'
key[Left]='^[[D'
key[Return]='^M'
key[LineFeed]='^J'
key[Tab]='^I'
key[ShiftTab]='^[[Z'
key[ControlSpace]='^@'
key[ForwardWord]='^[f'
key[SendBreak]='^G'

# Bash/Readline compatibility
# zsh's default kills the whole line.
bindkey '^U' backward-kill-line

# Prezto/Emacs-undo-tree compatibility
# zsh does not have a default keybinding for this.
bindkey '^[_' redo

# Automatically correct misspelled words.
bindkey ' ' auto-correct-space
bindkey '^[ ' self-insert-unmeta

bindkey "${key[Up]}" up-line-or-fuzzy-history
bindkey "^[${key[Up]}" fzf-history-widget
bindkey "${key[Down]}" down-line-or-complete-word
bindkey "^[${key[Down]}" complete-word

# Workaround: forward-word + complete inside the same widget doesn't work.
bindkey -s "${key[Tab]}" "${key[ForwardWord]}^[~^X~"
bindkey '^[~' auto-complete
bindkey '^X~' auto-list
bindkey "${key[ShiftTab]}" fuzzy-complete
bindkey "${key[ControlSpace]}" expand-alias-or-fuzzy-find

# Completion menu behavior
bindkey -M menuselect " " accept-line
bindkey -M menuselect "${key[Tab]}" accept-and-hold
bindkey -M menuselect -s "${key[Return]}" "${key[LineFeed]}^X~"
bindkey -M menuselect -s "${key[ShiftTab]}" "${key[SendBreak]}${key[ShiftTab]}"
bindkey -M menuselect -s "${key[ControlSpace]}" '^C'

# Wrap existing modification widgets to provide auto-completion.
zle -N self-insert
self-insert() {
  zle .self-insert
  auto-list
}
zle -N self-insert-unmeta
self-insert-unmeta() {
  zle .self-insert-unmeta
  zle -Rc
}
zle -N delete-char
delete-char() {
  zle .delete-char
  auto-list
  predict
}
zle -N backward-delete-char
backward-delete-char() {
  zle .backward-delete-char
  auto-list
  predict
}
zle -N kill-word
kill-word() {
  zle .kill-word
  auto-list
  predict
}
zle -N backward-kill-word
backward-kill-word() {
  zle .backward-kill-word
  auto-list
  predict
}

setopt EXTENDED_GLOB
setopt GLOB_COMPLETE
setopt GLOB_DOTS
setopt NO_CASE_GLOB

setopt COMPLETE_IN_WORD
setopt CORRECT
unsetopt LIST_BEEP

zstyle ':completion:*' ignored-patterns '[_.+]*' '[[:punct:]]zinit-*' '-zinit-*'
zstyle ':completion:*' list-suffixes
autoload zmathfunc && zmathfunc && \
zstyle -e ':completion:*' max-errors 'reply=$(( min(7, ($#PREFIX + $#SUFFIX) / 3) ))'
zstyle ':completion:*' select-scroll 0
zstyle ':completion:*' show-ambiguity true

zstyle ':completion:*' \
  completer _oldlist _expand _complete _ignored _correct _approximate
zstyle ':completion:auto-correct*:*' \
  completer _expand _complete _ignored _correct
zstyle ':completion:fuzzy-complete:*' \
  completer _expand _complete _match _ignored _approximate

zstyle ':completion:*' \
  matcher-list 'l:?|=[ _-.] l:|=*' '+m:{[:lower:]-}={[:upper:]_}'
zstyle ':completion:fuzzy-complete:*' \
  matcher-list 'l:?|=[ _-.] l:|=* m:{[:lower:]-}={[:upper:]_} r:|?=**'

zstyle ':completion:*'                menu yes select
zstyle ':completion:auto-complete:*'  menu auto

zstyle ':completion:auto-co*:*' accept-exact true
zstyle ':completion:auto-*:*' original true

export ZSH_AUTOCOMPLETE_IGNORE='brew'
export ZSH_AUTOCOMPLETE_MAX_LINES=.4
export ZSH_AUTOCOMPLETE_MIN_CHARS=3
export RESERVED_WORDS='do|done|esac|then|elif|else|fi|for|case|if|while|function|repeat|time|until|select|coproc|nocorrect|foreach|end|\!|\[\[|\{|\}|declare|export|float|integer|local|readonly|typeset'
export COMMAND_TERMINATORS=';&|
'
export GLOB_CHARS='*()|<>[]?^#'
export EXPANSION_DESIGNATORS='$=:'

zle -N auto-complete
auto-complete() {
  if [[ $LBUFFER[-1] == [[:WORD:]] ]]
  then
    local -a +h comppostfuncs=( accept-exact-only do-not-list )
    zle _auto_complete
  else
    zle auto-list
  fi
  if [[ $LBUFFER[-3,-1] == [[:space:]]-[[:space:]] ]]
  then
    zle auto-suffix-remove
  fi
}

zle -C _auto_complete complete-word _auto_complete
_auto_complete() {
  if [[ $RBUFFER[1] == [[:IFS:]]#
     && ${${=LBUFFER}[-1]} != [-+][[:alnum:]]##
     && ${${=LBUFFER}[-1]} != *[${(b)GLOB_CHARS}]*
     && ${LBUFFER##*[${(b)COMMAND_TERMINATORS}${(b)EXPANSION_DESIGNATORS}${(b)GLOB_CHARS}][[:IFS:]]#}
        != (${~RESERVED_WORDS}|${~ZSH_AUTOCOMPLETE_IGNORE})[[:IFS:]]##*
     ]]
  then
    setopt LOCAL_OPTIONS REC_EXACT
    _generic
  else
    zle -Rc
  fi
}

zle -N auto-correct-space
auto-correct-space() {
  if [[ $LBUFFER[-1] == [\ /[:digit:]${(b)COMMAND_TERMINATORS}] ]]
  then
    zle auto-suffix-retain
  else
    zle -l autosuggest-clear && zle autosuggest-clear
    zle _auto_complete
  fi
  if [[ $LBUFFER[-1] != [[:space:]] ]]
  then
    zle self-insert
  fi
  zle auto-list
}

zle -N auto-list
auto-list() {
  if (( $PENDING == 0 && $KEYS_QUEUED_COUNT == 0 ))
  then
    zle -Rc
    local cmd=${LBUFFER##*[${(b)COMMAND_TERMINATORS}${(b)EXPANSION_DESIGNATORS}${(b)GLOB_CHARS}][[:IFS:]]#}${#RBUFFER%%[[:space:]]##*}
    if [[ ${#cmd} -gt $ZSH_AUTOCOMPLETE_MIN_CHARS
       && $cmd != (${~RESERVED_WORDS}|${~ZSH_AUTOCOMPLETE_IGNORE})[[:IFS:]]##* ]]
    then
      local -a +h comppostfuncs=( limit-list do-not-insert )
      zle _auto_list
    fi
    predict
  fi
}

zle -C _auto_list list-choices _generic

zle -N down-line-or-complete-word
down-line-or-complete-word() {
  zle -Rc
  if (( ${#RBUFFER} > 0 && $BUFFERLINES > 1 )); then
    zle down-line || zle end-of-line
  else
    zle complete-word
  fi
}

zle -N up-line-or-fuzzy-history
up-line-or-fuzzy-history() {
  if (( ${#LBUFFER} > 0 && $BUFFERLINES > 1 )); then
    zle up-line || zle beginning-of-line
    zle -Rc
  else
    zle fzf-history-widget
  fi
}

zle -N fuzzy-complete
fuzzy-complete() {
  zle _fuzzy_complete
}
zle -C _fuzzy_complete complete-word _generic

zle -N expand-alias-or-fuzzy-find
expand-alias-or-fuzzy-find() {
  zle -Rc
  zle _expand_alias || fuzzy-find
}

zle -N fuzzy-find
fuzzy-find() {
  FZF_TMUX_HEIGHT=$(( ${LINES} - 2 ))
  FZF_DEFAULT_OPTS="--height=$FZF_TMUX_HEIGHT -i --bind=ctrl-space:abort --exact --info=inline \
                    --layout=reverse --multi --tiebreak=length,begin,end"
  if [[ $RBUFFER[1] == [[:graph:]] ]]
  then
    zle forward-word
  fi
  LBUFFER="${${=LBUFFER}[1,-2]} ${${=LBUFFER}[-1]//[$GLOB_CHARS]##([[:punct:]]##[$GLOB_CHARS]##)#/}"
  zle fzf-completion
}

accept-exact-only() {
  compstate[exact]=accept
  if [[ -v compstate[exact_string] ]]
  then
    if (( compstate[nmatches] == 1))
    then
      compstate[insert]=1
    fi
  else
    compstate[insert]=
  fi
}

do-not-insert() {
  compstate[insert]=
}

do-not-list() {
  compstate[list]=
}

limit-list() {
  if (( compstate[list_lines] > ( ZSH_AUTOCOMPLETE_MAX_LINES * LINES )
     || ( compstate[list_max] != 0 && compstate[nmatches] > compstate[list_max] ) ))
  then
    compstate[list]=
  fi
  if [[ -z compstate[list] || nmatches == 0 ]]
  then
    zle -Rc
  fi
}

predict() {
  if [[ $RBUFFER == [[:IFS:]]## ]]
  then
    zle kill-line
  fi
  if (( $#RBUFFER == 0 ))
  then
    zle -l autosuggest-fetch && zle autosuggest-fetch
  elif (( $#POSTDISPLAY > 0 ))
  then
    zle -l autosuggest-clear && zle autosuggest-clear
  fi
}
