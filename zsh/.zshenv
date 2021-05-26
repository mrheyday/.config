#!/bin/zsh
# Executed for each new shell, even non-interactive ones.
# Ergo, nothing here needs to be exported, unless we want it to be available to external commands.

XDG_CONFIG_HOME=~/.config
XDG_DATA_HOME=~/.local/share
ZDOTDIR=$XDG_CONFIG_HOME/zsh
