#!/bin/zsh

XDG_DATA_HOME=~/.local/share

##
# History settings
# Set these first, so history doesn't get lost when something breaks.
#
HISTFILE=$XDG_DATA_HOME/zsh/history
SAVEHIST=$(( 100 * 1000 ))
HISTSIZE=$(( 1.2 * SAVEHIST ))  # Zsh recommended value
setopt histfcntllock histignorealldups histsavenodups sharehistory


##
# Initialization
#

source ~/Git/zsh-snap/znap.zsh  # Plugin manager

# Load dir stack from file and continue where we left off.
setopt autocd autopushd cdsilent chaselinks pushdignoredups pushdminus pushdsilent
() {
  local dirs=( ${(f@Q)$(< $XDG_DATA_HOME/zsh/chpwd-recent-dirs)} )
  cd $dirs[1]
  dirs $dirs[@] >/dev/null
}


##
# Instant prompt
# The code below gets the left side of the primary prompt visible in less than 40ms.
#

# Add shortcuts for common dirs.
setopt autonamedirs
hash -d TMPDIR=$TMPDIR:A

znap prompt sindresorhus/pure # Show prompt.


##
# Miscellanous
#
setopt NO_caseglob extendedglob globstarshort numericglobsort
setopt NO_autoparamslash interactivecomments rcquotes

# Apple attaches their function to the wrong hook.
# This doesn't need to run before each prompt; just when we change dirs.
if type -f update_terminal_cwd &>/dev/null; then
  autoload -Uz add-zsh-hook
  add-zsh-hook -d precmd update_terminal_cwd
  add-zsh-hook chpwd update_terminal_cwd
  update_terminal_cwd
fi


##
# External commands
#

typeset -U PATH path FPATH fpath MANPATH manpath # Remove duplicates.
LANG='en_US.UTF-8'

EDITOR='code' VISUAL='code'
READNULLCMD='bat'
PAGER='less' MANPAGER='col -bpx | bat --language man'
export LESS='--ignore-case --quit-if-one-screen --raw-control-char'
export GREP_OPTIONS='--color=auto'

export HOMEBREW_NO_AUTO_UPDATE=1
{
  xcode-select --install 2> /dev/null ||
    brew update --quiet &> /dev/null &&
    brew upgrade --fetch-HEAD --quiet &> /dev/null
} &|
znap eval brew-shellenv 'brew shellenv'

znap eval pyenv-init ${${:-=pyenv}:A}' init -'

JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
path=(
  $HOMEBREW_CELLAR/tomcat@8/*/libexec/bin
  $HOMEBREW_PREFIX/opt/ncurses/bin
  ~/.local/bin  # pipx, pipenv
  $path[@]
  .
)

# Completions
znap eval pip-completion 'pip completion --zsh'
znap eval pipx-completion 'register-python-argcomplete pipx'
znap eval pipenv-completion 'pipenv --completion'
fpath+=(
  ~[zsh-users/zsh-completions]/src  # Made possible by Znap
  $HOMEBREW_PREFIX/share/zsh/site-functions
)
rm -f $HOMEBREW_PREFIX/share/zsh/site-functions/{_git,git-completion.bash,_git.zwc}


# Real-time auto-completion
# Get it from https://github.com/marlonrichert/zsh-autocomplete
znap source zsh-autocomplete

# In-line suggestions
znap source zsh-autosuggestions
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=( "${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[@]:#*forward-char}" )
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=( forward-char vi-forward-char )

# Better line editing tools
# Get them from https://github.com/marlonrichert/zsh-edit
znap source zsh-edit
WORDCHARS='*?\'

# History editing tools
# Get them from https://github.com/marlonrichert/zsh-hist
znap source zsh-hist
bindkey '^[q' push-line-or-edit

# Bash/Readline compatibility
# Zsh's default kills the whole line.
bindkey '^U' backward-kill-line

# Prezto/Emacs-undo-tree compatibility
# Zsh does not have a default keybinding for this.
bindkey '^[_' redo

# Enable alt-h help function.
unalias run-help
autoload -Uz  run-help    run-help-git  run-help-ip   run-help-openssl \
              run-help-p4 run-help-sudo run-help-svk  run-help-svn

# Pattern matching support for `cp`, `ln` and `mv`
# See http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#index-zmv
autoload -Uz zmv
alias zcp='zmv -Civ'
alias zln='zmv -Liv'
alias zmv='zmv -Miv'

# Safer alternative to `rm`
alias trash='trash -F'

# Color `grep`
alias grep='grep --color=always'

# Colors for 'ls' and completions
znap eval dircolors 'gdircolors -b'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
alias ls='ls -AFH'

# Command-line syntax highlighting
export ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
znap source zsh-syntax-highlighting
# znap source fast-syntax-highlighting

# zprof
