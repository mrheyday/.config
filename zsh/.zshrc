#!/bin/zsh
# Executed for each interactive shell, after .zprofile.


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

# Plugin manager
zstyle ':znap:*' default-server git@github.com: # Use SSH instead of HTTPS.
source ~/Git/zsh-snap/znap.zsh

# Set cd/pushd options.
setopt autocd autopushd cdsilent chaselinks pushdignoredups pushdminus pushdsilent

# Load dir stack from file (excl. non-existing dirs).
zmodload -F zsh/parameter p:dirstack
dirstack=( ${${(f@Q)^"$( < $XDG_DATA_HOME/zsh/chpwd-recent-dirs )"}[@]:#${TMPDIR:A}/*}(N-/) )
cd -q $dirstack[1]  # Continue where we left off.


##
# Instant prompt
# The code below gets the left side of the primary prompt visible in less than 40ms.
#

# Add ~shorthands for common dirs.
setopt autonamedirs
hash -d TMPDIR=$TMPDIR:A

znap prompt sindresorhus/pure # Show prompt.


##
# Basic shell settings
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

[[ -o shinstdin ]] &&
{
  xcode-select --install 2> /dev/null ||
          brew update --quiet &&
          brew upgrade --fetch-HEAD --quiet
} &|

znap eval pyenv-init ${${:-=pyenv}:A}' init -'

# `hash` adds invidual commands, without modifying $path.
# ~[dynamically-named dirs] are provided by Znap.
hash catalina=$CATALINA_HOME/bin/catalina.sh
hash clitest=~[aureliojargas/clitest]/clitest
hash gh-md-toc=~[github-markdown-toc]/gh-md-toc
hash ls==gls  # GNU coreutils

# Completions
znap eval pip-completion 'pip completion --zsh'
znap eval pipx-completion 'register-python-argcomplete pipx'
znap eval pipenv-completion 'pipenv --completion'
fpath+=(
  ~[zsh-users/zsh-completions]/src  # Made possible by Znap
  $HOMEBREW_PREFIX/share/zsh/site-functions
)
rm -f $HOMEBREW_PREFIX/share/zsh/site-functions/{_git{,.zwc},git-completion.bash}


##
# Plugins
#

# Real-time auto-completion
znap source marlonrichert/zsh-autocomplete

# Better line editing tools
WORDCHARS='*?~\ '
znap source marlonrichert/zsh-edit
bindkey -c '^S'  'git status --show-stash'
bindkey -c '^G'  'git log'
bindkey -c '^O'  'git log --oneline'
bindkey -c "^[$key[Up]"   'git push'
bindkey -c "^[$key[Down]" 'git pull --autostash'

# History editing tools
znap source marlonrichert/zsh-hist

# Auto-generated completion colors
znap source marlonrichert/zcolors
znap eval zcolors "zcolors ${(q)LS_COLORS}"

# In-line suggestions
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=()
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=( forward-char forward-word end-of-line )
ZSH_AUTOSUGGEST_STRATEGY=( history )
ZSH_AUTOSUGGEST_HISTORY_IGNORE=$'*\n*'
znap source zsh-users/zsh-autosuggestions

# Command-line syntax highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
znap source zsh-users/zsh-syntax-highlighting


##
# Additional keyboard settings
#

setopt NO_flowcontrol # Enable ^Q and ^S.

# Make Control-U do the same as in Bash/Readline.
# Zsh's default kills the whole line.
bindkey '^U' backward-kill-line

# Add same Redo keybinding as in Prezto/Emacs-undo-tree.
# Zsh does not have a default keybinding for this.
bindkey '^[_' redo

# Replace some default widgets with better ones.
zle -A copy-prev-{shell-,}word
zle -A push-line{-or-edit,}
zle -A {vi-,}quoted-insert

# `zsh-edit` adds `bindkey -c`, which lets you bind arbitrary commands.
# $key table is defined by /etc/zshrc & `zsh-autocomplete`.

# Alt-H: Open `man` page of current command.
unalias run-help
autoload -Uz  run-help{,-{git,ip,openssl,p4,sudo,svk,svn}}

# Alt-Shift-/: Show definition of current command.
autoload -Uz which-command
zle -N which-command
unalias which-command 2>/dev/null


##
# Aliases & functions
#

# File type associations
alias -s {md,patch,txt}="$PAGER"
alias -s {log,out}='open -a Console'

# Pattern matching support for `cp`, `ln` and `mv`
# See http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#index-zmv
autoload -Uz zmv
alias zcp='zmv -Cv' zln='zmv -Lv' zmv='zmv -Mv'

# Paging & colors for 'ls'
ls() {
  gls --width=$COLUMNS -x "$@" | less # `gls` needs `--width` and `-x` when piped.
  return $pipestatus[1]  # Exit status of `gls`
}
alias ls='ls --color=always --group-directories-first --sort=extension -AF'

# Safer alternative to `rm`
trash() {
  local -aU items=() missing=()
  local i; for i in $@; do
    if [[ -e $i ]]; then
      items+=( $i )
    else
      missing+=( $i )
    fi
  done
  local -i ret=66
  (( $#missing > 0 )) &&
    print -u2 "trash: no such file(s): $missing"
  if (( $#items > 0 )); then
    print Moving $(eval ls -d ${(q)items[@]}) to Trash.
    items=( '(POSIX file "'${^items[@]:A}'")' )
    osascript -e 'tell application "Finder" to delete every item of {'${(j:, :)items}'}' >/dev/null
    ret=$?
  fi
  return ret
}
