#!/bin/zsh

##
# Zsh runs .zshrc for each interactive shell, after .zprofile
#


# Set these first, so history is preserved, no matter what happens.
XDG_DATA_HOME=~/.local/share
if [[ $VENDOR == apple ]]; then
  HISTFILE=~/Library/Mobile\ Documents/com\~apple\~CloudDocs/zsh_history
else
  HISTFILE=$XDG_DATA_HOME/zsh/history
fi
SAVEHIST=$(( 50 * 1000 ))       # For readability
HISTSIZE=$(( 1.2 * SAVEHIST ))  # Zsh recommended value


for __file__ in $ZDOTDIR/zshrc.d/*.zsh; do
  . $__file__
done
unset __file__
