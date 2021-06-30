#!/bin/zsh
# Executed for each new shell, even non-interactive ones.
# Ergo, nothing here needs to be exported, unless we want it to be available to external commands.

# _After_ setting autonamedirs, each param set to an absolute path becomes a ~named dir.
setopt autonamedirs
hash -d TMPDIR=$TMPDIR:A  # Add ~TMPDIR

XDG_CONFIG_HOME=~/.config
ZDOTDIR=$XDG_CONFIG_HOME/zsh
