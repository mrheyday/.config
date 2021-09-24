##
# Keybindings
#
zmodload -F zsh/parameter p:functions_source

setopt NO_flowcontrol  # Enable ^Q and ^S.

# Better command line editing tools
znap source marlonrichert/zsh-edit
zstyle ':edit:*' word-chars '*?\'

bind \
    '^[p'   'cd .' \
    '^[c'   'code .' \
    '^[s'   'git status' \
    '^[l'   'git log' \
    '^[[5~' 'git push && git fetch' \
    '^[[6~' 'git fetch && git pull --autostash'

if [[ $VENDOR == apple ]]; then
  bindkey \
      '^[[H' beginning-of-buffer  '^[OH' beginning-of-buffer \
      '^[[F' end-of-buffer        '^[OF' end-of-buffer
  bind \
      '^[o' 'open .'
else
  bind \
      '^[o' 'nemo . &|'
fi

# Replace some default keybindings with better built-in widgets.
bindkey \
    '^[^_'  copy-prev-shell-word \
    '^[q'   push-line-or-edit \
    '^V'    vi-quoted-insert

# Alt-H: Open `man` page (or other help) for current command.
unalias run-help 2> /dev/null
autoload +X -Uz run-help
autoload -Uz $functions_source[run-help]-*~*.zwc

# Alt-Shift-/: Show description and origin of current command.
unalias which-command 2> /dev/null
zle -C  which-command list-choices which-command
which-command() {
  zle -I
  whatis      -- $words[@] 2> /dev/null
  whence -aSv -- $words[@] 2> /dev/null
  compstate[insert]=
  compstate[list]=
}
