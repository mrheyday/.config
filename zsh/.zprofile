#!/bin/zsh

##
# Zsh runs .zprofile once for each new login shell, after .zshenv, but before .zshrc. Everything
# here should be exported, so it's available in new shells started from the login shell.
#
# NOTE: In VTE-based terminals, such as Gnome Terminal & Tilix, you have to explicitly set in each
# profile that a new window/tab opens a login shell. Otherwise, .zprofile will not get sourced!
#

# zmodload zsh/zprof
# typeset -F SECONDS

export LANG=en_US.UTF-8    # Need to set this manually on macOS.
export LC_COLLATE=C.UTF-8  # Other UTF-8 locales on Linux give weird whitespace sorting.

export XDG_CONFIG_HOME     # Value is set in .zshenv
export XDG_CACHE_HOME=~/.cache
export XDG_DATA_HOME=~/.local/share

export HOMEBREW_BAT=1
export HOMEBREW_COLOR=1
export HOMEBREW_NO_AUTO_UPDATE=1
path=( /home/linuxbrew/.linuxbrew/bin(N) $path[@] )
() {
  local brew_shellenv=~/.local/bin/brew-shellenv
  [[ -r brew_shellenv ]] ||
      brew shellenv >| $brew_shellenv
  source $brew_shellenv
}

export ANDROID_SDK_ROOT=$HOMEBREW_PREFIX/share/android-commandlinetools
export GRADLE_USER_HOME=$XDG_CONFIG_HOME/gradle

export PYENV_VERSION=3.7.10
export PYENV_ROOT=~/.pyenv
export PIPX_BIN_DIR=~/.local/bin

[[ $VENDOR == apple ]] &&
    export JAVA_HOME=$( /usr/libexec/java_home -v 1.8 )
export CATALINA_HOME=$HOMEBREW_PREFIX/opt/tomcat@9/libexec
export CATALINA_BASE=~/Tomcat9

# We need to set $path here and not in .zshenv, else /etc/zprofile will override it.
export -U PATH path FPATH fpath MANPATH manpath  # -U remove duplicates.
export -TU INFOPATH infopath

# (N) omits the item if it doesn't exist.
path=(
    $PIPX_BIN_DIR(N)
    $PYENV_ROOT/{bin,shims}(N)
    $ANDROID_SDK_ROOT/{emulator,platform-tools}(N)
    $HOMEBREW_PREFIX/opt/{mariadb@10.3,ncurses,tomcat@9}/bin(N)
    /opt/local/{,s}bin(N) # MacPorts
    $path[@]
    .
)
fpath=(
    $HOMEBREW_PREFIX/share/zsh/site-functions
    $fpath[@]
)

export VISUAL=code
export EDITOR=micro
export READNULLCMD=bat
export PAGER=less
export MANPAGER='bat -l man'
[[ $VENDOR == apple ]] &&
    MANPAGER="col -bpx | $MANPAGER"

export LESS='-FiMr -j.5 --incsearch'
export LESSHISTFILE=$XDG_DATA_HOME/less/lesshst
export QUOTING_STYLE=escape # Used by GNU ls

[[ $VENDOR == apple ]] &&
    export SHELL_SESSIONS_DISABLE=1
[[ $VENDOR == ubuntu ]] &&
    export skip_global_compinit=1
