#!/bin/zsh

##
# Zsh runs .zshenv for _each_ new shell, even non-interactive ones, before all other dotfiles.
# Ergo, nothing here needs to be exported, unless we want it to be available to external commands.
#

# _After_ setting `autonamedirs`, each param set to an absolute path becomes a ~named dir.
# That's why we need to set it here, before any params are set.
setopt autonamedirs
TMPDIR=$TMPDIR:A  # Needed to make ~TMPDIR work with autonamedirs + chaselinks

XDG_CONFIG_HOME=~/.config
ZDOTDIR=$XDG_CONFIG_HOME/zsh
