#!/bin/zsh
# Executed once for each new login shell, after .zshenv, but before .zshrc.
# In macOS's Terminal.app, the first shell in each tab/window is a login shell.
# Everything here should be exported, so it's available in new shells started from the login shell.

# We need to set $path here and not in .zshenv, else /etc/zprofile will override it.
export -U PATH path FPATH fpath MANPATH manpath  # Remove duplicates.
export -TU INFOPATH infopath

export HOMEBREW_BAT=1
export HOMEBREW_COLOR=1
export HOMEBREW_NO_AUTO_UPDATE=1
eval "$( brew shellenv )"

export PYENV_ROOT=~/.pyenv
export PYENV_VERSION=3.7.10
export PIPX_BIN_DIR=~/.local/bin

path=(
  $PIPX_BIN_DIR
  $PYENV_ROOT/{bin,shims}
  $HOMEBREW_PREFIX/opt/{mariadb@10.3,ncurses,tomcat@9}/bin
  /opt/local/{bin,sbin} # MacPorts
  $path[@]
  .
)

export JAVA_HOME=$( /usr/libexec/java_home -v 1.8 )
export CATALINA_HOME=$HOMEBREW_PREFIX/opt/tomcat@9/libexec
export CATALINA_BASE=~/Tomcat9

export LANG='en_US.UTF-8'
export VISUAL='code'
export EDITOR='nano'
export READNULLCMD='bat'
export PAGER='less'
export MANPAGER='col -bpx | bat -l man'
export LESS='-FiMr -j.5 --incsearch'
export LESSHISTFILE=$XDG_DATA_HOME/less/lesshst

export SHELL_SESSIONS_DISABLE=1  # Disable Apple's Save/Restore Shell State feature.
