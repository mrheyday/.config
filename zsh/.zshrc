#!/bin/zsh
# Executed for each interactive shell, after .zprofile.


##
# History settings
# Set these before calling any commands, so history doesn't get lost when something breaks.
#
HISTFILE=$XDG_DATA_HOME/zsh/history
SAVEHIST=$(( 100 * 1000 ))
HISTSIZE=$(( 1.2 * SAVEHIST ))  # Zsh recommended value
setopt histfcntllock histignorealldups histsavenodups sharehistory


##
# Plugin manager
#
zstyle ':znap:*' default-server git@github.com: # Use SSH instead of HTTPS.
source ~/Git/zsh-snap/znap.zsh


##
# Instant prompt
# The code below gets the left side of the primary prompt visible in less than 40ms.
#

znap source marlonrichert/zcolors
znap eval zcolors "zcolors ${(q)LS_COLORS}" # Generate theme colors.
znap prompt sindresorhus/pure # Show prompt.


##
# Miscellaneous shell options
#
setopt NO_caseglob extendedglob globstarshort numericglobsort
setopt NO_autoparamslash interactivecomments rcquotes


##
# Directory config
#

setopt autocd autopushd cdsilent chaselinks pushdignoredups pushdminus pushdsilent

# Load dir stack from file, excl. current dir, temp dirs & non-existing dirs.
zmodload -F zsh/parameter p:dirstack
typeset -gaU dirstack=(
    ${(u)^${(f@Q)"$( < $XDG_DATA_HOME/zsh/chpwd-recent-dirs )"}[@]:#($PWD|${TMPDIR:A}/*)}(N-/)
)

# Apple attaches their function to the wrong hook in /etc/zshrc_Apple_Terminal.
if type -f update_terminal_cwd &>/dev/null; then
  add-zsh-hook -d precmd update_terminal_cwd  # Doesn't need to run before each prompt.
  add-zsh-hook chpwd update_terminal_cwd      # Run it only when we change dirs...
  update_terminal_cwd                         # ...and once on startup.
fi


##
# External commands
#

# Link commands into ~/.local/bin
ln -fns ~[aureliojargas/clitest]/clitest ~/.local/bin/clitest
ln -fns ~[github-markdown-toc]/gh-md-toc ~/.local/bin/gh-md-toc
# ~[dynamically-named dirs] provided by Znap

# Include full path, so when it changes, Znap invalidates cache.
znap eval pyenv-init ${${:-=pyenv}:A}' init -'

# Completions
# Include shell-specific Python version as comment, so when it changes, Znap invalidates cache.
znap eval pip-completion "pip completion --zsh  # $PYENV_VERSION"
znap eval pipx-completion "register-python-argcomplete pipx  # $PYENV_VERSION"
znap eval pipenv-completion "pipenv --completion  # $PYENV_VERSION"
fpath+=(
    ~[zsh-users/zsh-completions]/src
)


##
# Plugins
#

# Real-time auto-completion
znap source marlonrichert/zsh-autocomplete

# Better line editing tools
znap source marlonrichert/zsh-edit
zstyle ':edit:*' word-chars '*?~\'

# History editing tools
znap source marlonrichert/zsh-hist

# In-line suggestions
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=()
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=( forward-char forward-word end-of-line )
ZSH_AUTOSUGGEST_STRATEGY=( history )
ZSH_AUTOSUGGEST_HISTORY_IGNORE=$'(*\n*|?(#c80,))'
znap source zsh-users/zsh-autosuggestions

# Command-line syntax highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
znap source zsh-users/zsh-syntax-highlighting
# znap source zdharma/fast-syntax-highlighting

##
# Key bindings
#

setopt NO_flowcontrol  # Enable ^Q and ^S.

# Replace some default widgets with better ones.
bindkey '^[^_'  copy-prev-shell-word
bindkey '^[q'   push-line-or-edit
bindkey '^V'    vi-quoted-insert

# Alt-H: Open `man` page of current command.
unalias run-help
autoload -Uz run-help{,-{git,ip,openssl,p4,sudo,svk,svn}}

# Alt-Shift-/: Show definition of current command.
unalias which-command
autoload -Uz which-command
zle -N which-command

# -c flag added by zsh-edit
bindkey -c '^Xp' '@cd .'
bindkey -c '^Xo' '@open .'
bindkey -c '^Xc' '@code .'
bindkey -c '^Xs' '+git status --show-stash'
bindkey -c '^Xl' '@git log'

# $key table populated by /etc/zshrc & zsh-autocomplete
bindkey -c "^[$key[Up]"   'git push'
bindkey -c "^[$key[Down]" 'git fetch && git pull --autostash'
bindkey "$key[Home]" beginning-of-buffer
bindkey "$key[End]"  end-of-buffer


##
# Aliases & functions
#

# File type associations
alias -s {md,patch,txt}="$PAGER"
alias -s {log,out}='open -a Console'
alias -s gz='gzip -l'

alias \$= %=  # Enable pasting of command line examples.

# Pattern matching support for `cp`, `ln` and `mv`
# See http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#index-zmv
autoload -Uz zmv
alias zmv='\zmv -v' zcp='\zmv -Cv' zln='\zmv -Lv'
# Tip: Use -n for no execution. (Print what would happen, but don’t do it.)

# Paging & colors for `ls`
ls() {
  gls --width=$COLUMNS "$@" | $PAGER
  return $pipestatus[1]  # Exit status of `ls`
}
alias ls='\ls --color=always --group-directories-first -AFXx'

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
    print Moving $(eval ls -d ${(q)items[@]%/}) to Trash.
    items=( '(POSIX file "'${^items[@]:A}'")' )
    osascript -e 'tell application "Finder" to delete every item of {'${(j:, :)items}'}' >/dev/null
    ret=$?
  fi
  return ret
}
