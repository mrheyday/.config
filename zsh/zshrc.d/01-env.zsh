##
# Environment variables
#

# _After_ setting `autonamedirs`, each parameter set to an absolute path becomes a ~named dir.
# That's why we need to set it here, _before_ any parameters are set.
setopt autonamedirs

# Convert to absolute paths to make them work with autonamedirs + chaselinks.
# Need to check for non-zero, because ${:P} == $HOME !
[[ -n $TMPDIR ]] &&
    TMPDIR=$TMPDIR:P
[[ -n $TMPPREFIX ]] &&
    TMPPREFIX=$TMPPREFIX:P

export LANG=en_US.UTF-8 # Not set on macOS.

[[ $OSTYPE == linux-gnu ]] &&
    export LC_COLLATE=C.UTF-8 # Other UTF-8 locales on Linux give weird whitespace sorting.

export HOMEBREW_BAT=1 HOMEBREW_COLOR=1 HOMEBREW_NO_AUTO_UPDATE=1
path=( /home/linuxbrew/.linuxbrew/bin(N) $path[@] )

# Cache this.
brew_shellenv=~/.local/bin/brew-shellenv
[[ -r brew_shellenv ]] ||
    brew shellenv >| $brew_shellenv
source $brew_shellenv
unset brew_shellenv

export GRADLE_USER_HOME=$XDG_CONFIG_HOME/gradle

export PYENV_ROOT=~/Git/pyenv
export PYENV_VERSION=3.7.10
export PIPX_BIN_DIR=~/.local/bin

export CATALINA_BASE=~/Tomcat9 CATALINA_HOME=$HOMEBREW_PREFIX/opt/tomcat@9/libexec

# Set $path here and not in .zshenv, else /etc/zprofile will override it.
export -U PATH path FPATH fpath MANPATH manpath  # -U removes duplicates.
export -TU INFOPATH infopath

# (N) omits the item if it doesn't exist.
path=(
    $PIPX_BIN_DIR(N)
    $PYENV_ROOT/{bin,shims}(N)
    $HOMEBREW_PREFIX/opt/{mariadb@10.3,ncurses,tomcat@9}/bin(N)
    /opt/local/{,s}bin(N) # MacPorts
    $path[@]
)
fpath=(
    $HOMEBREW_PREFIX/share/zsh/site-functions
    $fpath[@]
)

export VISUAL=code EDITOR=nano PAGER=less MANPAGER='bat -l man' READNULLCMD=bat

export LESS='-FiMr -j.5 --incsearch' LESSHISTFILE=$XDG_DATA_HOME/less/lesshst
mkdir -pm 0700 $LESSHISTFILE:h

export QUOTING_STYLE=escape # Used by GNU ls

if [[ $VENDOR == apple ]]; then
  MANPAGER="col -bpx | $MANPAGER"
  export JAVA_HOME=$( /usr/libexec/java_home -v 1.8 )
fi

# Turn this off again, so we don't get random named dirs.
unsetopt autonamedirs
