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
source ~/Git/zsh-snap/znap.zsh


##
# Prompt and other theming
#

# `znap prompt` gets the left side of the primary prompt visible in less than 40ms.
znap prompt sindresorhus/pure

znap source marlonrichert/zcolors
znap eval zcolors "zcolors ${(q)LS_COLORS}" # Generate theme colors.

setopt printexitvalue
REPORTMEMORY=80 # min kB
REPORTTIME=1    # min seconds
TIMEFMT=$'zsh: %E %MkB\t%J'


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
() {
  local cdr=$XDG_DATA_HOME/zsh/chpwd-recent-dirs

  [[ -r $cdr ]] ||
      return

  zmodload -F zsh/parameter p:dirstack
  typeset -gaU dirstack=(
      ${(u)^${(f@Q)"$( < $cdr )"}[@]:#($PWD|${TMPDIR:A}/*)}(N-/)
  )
}

# Apple attaches their function to the wrong hook in /etc/zshrc_Apple_Terminal.
if type -f update_terminal_cwd &>/dev/null; then
  add-zsh-hook -d precmd update_terminal_cwd  # Doesn't need to run before each prompt.
  add-zsh-hook chpwd update_terminal_cwd      # Run it only when we change dirs...
  update_terminal_cwd                         # ...and once on startup.
fi

# Necessary for VTE-based terminals (Gnome Terminal, Tilix) in Ubuntu to preserve $PWD when opening
# new windows/tabs.
[[ $VENDOR == ubuntu && -n $VTE_VERSION ]] &&
    source /etc/profile.d/vte-*.*.sh


##
# Initialization for external commands
#

# Include full path, so when it changes, Znap invalidates cache.
znap eval pyenv-init ${${:-=pyenv}:A}' init -'

# Include shell-specific Python version as comment, so when it changes, Znap invalidates cache.
znap eval pip-completion "pip completion --zsh  # $PYENV_VERSION"
znap eval pipx-completion "register-python-argcomplete pipx  # $PYENV_VERSION"
znap eval pipenv-completion "pipenv --completion  # $PYENV_VERSION"


##
# Additional completions
#
fpath+=(
    ~[zsh-users/zsh-completions]/src
)


##
# Plugins
#

# Real-time auto-completion
znap source marlonrichert/zsh-autocomplete

# Better command line editing tools
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

# Replace some default keybindings with better widgets.
bindkey '^[^_'  copy-prev-shell-word
bindkey '^[q'   push-line-or-edit
bindkey '^V'    vi-quoted-insert

# Alt-H: Open `man` page of current command.
alias run-help > /dev/null &&
    unalias run-help
autoload -Uz run-help{,-{git,ip,openssl,p4,sudo,svk,svn}}

# Alt-Shift-/: Show definition of current command.
alias which-command > /dev/null &&
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
alias -s gz='gzip -l'
if [[ $OSTYPE == darwin* ]]; then
  alias -s {log,out}='open -a Console'
else
  alias -s {log,out}='tail -f'
fi

alias \$= %=  # Enable pasting of command line examples.

alias grep='grep --color'

# Pattern matching support for `cp`, `ln` and `mv`
# See http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#index-zmv
# Tip: Use -n for no execution. (Print what would happen, but don’t do it.)
autoload -Uz zmv
alias zmv='\zmv -v' zcp='\zmv -Cv' zln='\zmv -Lv'

# Paging & colors for `ls`
[[ $OSTYPE != linux-gnu ]] &&
    hash ls==gls  # GNU coreutils ls
ls() {
  command ls --width=$COLUMNS "$@" | $PAGER
  return $pipestatus[1]  # Return exit status of ls, not $PAGER
}
alias ls='\ls --group-directories-first --color -AFXx'

# Safer alternatives to `rm`
if command -v gio > /dev/null; then
  alias trash='gio trash'
elif command -v osascript > /dev/null; then
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
      osascript -e 'tell application "Finder" to delete every item of {'${(j:, :)items}'}' \
          > /dev/null
      ret=$?
    fi
    return ret
  }
fi
