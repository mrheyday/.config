##
# Environment variables
#

export LANG=en_US.UTF-8    # Need to set this manually on macOS.
export LC_COLLATE=C.UTF-8  # Other UTF-8 locales on Linux give weird whitespace sorting.

export HOMEBREW_BAT=1
export HOMEBREW_COLOR=1
export HOMEBREW_NO_AUTO_UPDATE=1
path=( /home/linuxbrew/.linuxbrew/bin(N) $path[@] )

brew_shellenv=~/.local/bin/brew-shellenv
[[ -r brew_shellenv ]] ||
    brew shellenv >| $brew_shellenv
source $brew_shellenv
unset brew_shellenv

export ANDROID_SDK_ROOT=$HOMEBREW_PREFIX/share/android-commandlinetools
export GRADLE_USER_HOME=$XDG_CONFIG_HOME/gradle

export PYENV_VERSION=3.7.10
export PYENV_ROOT=~/.pyenv
export PIPX_BIN_DIR=~/.local/bin

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
export QUOTING_STYLE=escape # Used by GNU ls
export LESS='-FiMr -j.5 --incsearch'
export LESSHISTFILE=$XDG_DATA_HOME/less/lesshst
export PAGER=less
export MANPAGER='bat -l man'

if [[ $VENDOR == apple ]]; then
  MANPAGER="col -bpx | $MANPAGER"
  export JAVA_HOME=$( /usr/libexec/java_home -v 1.8 )
fi
