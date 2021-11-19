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
    '^[s'   'git status' \
    '^[l'   'git log' \
    '^[[5~' 'git push && git fetch --all' \
    '^[[6~' 'git fetch --all && git pull --autostash' \
    '^[c'   'code .'
code() {
  command code ${@:/./${${$( git rev-parse --git-dir 2>/dev/null ):P:h}:-.}}
}

if [[ $VENDOR == apple ]]; then
  bindkey \
      '^[[H' beginning-of-buffer  '^[OH' beginning-of-buffer \
      '^[[F' end-of-buffer        '^[OF' end-of-buffer
  bind '^[o' 'open .'
else
  bind '^[o' 'nautilus . &> /dev/null &|'
fi

# Replace some default keybindings with better built-in widgets.
bindkey \
    '^[^_'  copy-prev-shell-word \
    '^[q'   push-line-or-edit \
    '^V'    vi-quoted-insert

# Alt-V: Show the next key combo's terminal code and state what it does.
bindkey '^[v' describe-key-briefly

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
