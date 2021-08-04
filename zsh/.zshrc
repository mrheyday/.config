#!/bin/zsh

##
# Zsh runs .zshrc for each interactive shell, after .zprofile
#


##
# Essentials
#

# Set these first, so history is preserved, no matter what happens.
HISTFILE=$XDG_DATA_HOME/zsh/history
SAVEHIST=$(( 50 * 1000 ))       # For readability
HISTSIZE=$(( 1.2 * SAVEHIST ))  # Zsh recommended value

# Plugin manager
source ~/Git/zsh-snap/znap.zsh

# Shell options
setopt histfcntllock histignorealldups histsavenodups sharehistory
setopt extendedglob globstarshort numericglobsort
setopt NO_autoparamslash interactivecomments


##
# Prompt config
#

# Call this hook whenever we change dirs...
autoload -Uz add-zsh-hook
add-zsh-hook chpwd .prompt.chpwd
.prompt.chpwd() {
  zle && zle -I # Invalidate the prompt, in case this gets called while the ZLE is active.
  print -P -- '\n%F{12}%~%f/'
  RPS1=
  (
    local upstream
    upstream=${$( git rev-parse --abbrev-ref @{u} 2> /dev/null )%%/*} &&
        git fetch -t $upstream '+refs/heads/*:refs/remotes/'$upstream'/*' &> /dev/null &&
        git remote set-branches $upstream '*' &> /dev/null
  ) &|
}
.prompt.chpwd               # ...and once on startup, immediately.
setopt cdsilent pushdsilent # Suppress built-in output of cd and pushd.

PS1='%F{%(?,10,9)}%#%f '
# znap prompt                 # Make the left side of the primary prompt visible, immediately.

ZLE_RPROMPT_INDENT=0        # Right prompt margin
setopt transientrprompt     # Auto-remove the right side of each prompt.

# Reduce prompt latency by fetching git status asynchronously.
autoload -Uz add-zsh-hook
add-zsh-hook precmd .prompt.git-status.async
zle -N .prompt.git-status.callback
.prompt.git-status.async() {
  local fd
  exec {fd}< <( .prompt.git-status )
  zle -Fw "$fd" .prompt.git-status.callback
}
.prompt.git-status.callback() {
  local fd=$1 REPLY
  {
    zle -F "$fd"  # Unhook this callback.
    [[ $2 != (|hup) ]] &&
        return  # Error occured.
    read -ru $fd
    .prompt.git-status.update "$REPLY"
  } always {
    exec {fd}<&-  # Close file descriptor.
  }
}

# Periodically sync git status in prompt.
TMOUT=2  # Update interval in seconds
trap .prompt.git-status.update ALRM
.prompt.git-status.update() {
  local rps1=${1-$( .prompt.git-status )}
  [[ $rps1 == $RPS1 ]] &&
      return 1
  RPS1=$rps1
  zle && zle .reset-prompt
}

.prompt.git-status() {
  local MATCH MBEGIN MEND
  local -a lines
  if ! lines=( ${(f)"$( git status -sbu 2> /dev/null )"} ); then
    print
    return
  fi
  local -aU symbols=( ${(@MSu)lines[2,-1]##[^[:blank:]]##} )
  print -r -- "${${lines[1]/'##'/$symbols}//(#m)$'\C-[['[;[:digit:]]#m/%{${MATCH}%\}}"
}

# Shown after output that doesn't end in a newline.
PROMPT_EOL_MARK='%F{cyan}%S%#%f%s'

# Continuation prompt
() {
  local -a indent=( '%('{1..36}'_,  ,)' )
  PS2="${(j::)indent}" RPS2='%F{11}%^'
}

# Debugging prompt
() {
  local -a indent=( '%('{1..36}"e,$( echoti cuf 2 ),)" )
  local i=$'\t'${(j::)indent}
  PS4=$'\r%(?,,'$i$'  -> %F{9}%?%f\n)%{\e[2m%}%F{10}%1N%f\r'$i$'%I%b %(1_,%F{11}%_%f ,)'
}


##
# Directory config
#
setopt autocd autopushd chaselinks pushdignoredups pushdminus

# Load dir stack from file, excl. current dir, temp dirs & non-existing dirs.
() {
  zmodload -F zsh/parameter p:dirstack
  local cdr=$XDG_DATA_HOME/zsh/chpwd-recent-dirs

  [[ -r $cdr ]] ||
      return

  typeset -gaU dirstack=( ${(u)^${(f@Q)"$( < $cdr )"}[@]:#($PWD|${TMPDIR:-/tmp}/*)}(N-/) )
}

# Needed by VTE-based terminals (Gnome Terminal, Tilix) to preserve $PWD on new windows/tabs.
[[ $VENDOR == ubuntu ]] &&
    source /etc/profile.d/vte-*.*.sh

# Both Apple & VTE attach their function to the wrong hook!
() {
  local f=$precmd_functions[(R)(__vte_osc7|update_terminal_cwd)]
  if [[ -n $f ]]; then
    add-zsh-hook -d precmd $f  # Does not need to run before each prompt.
    add-zsh-hook chpwd $f      # Run it when we change dirs...
    $f                         # ...and once for our initial dir.
  fi
}


##
# Completion config
#

# Additional completions
fpath+=( ~[zsh-users/zsh-completions]/src )

# Real-time auto-completion
znap source marlonrichert/zsh-autocomplete

# Include Python version as comment, for cache invalidation.
znap eval    pip-completion "pip completion --zsh             # $PYENV_VERSION"
znap eval   pipx-completion "register-python-argcomplete pipx # $PYENV_VERSION"
znap eval pipenv-completion "pipenv --completion              # $PYENV_VERSION"


##
# Key bindings
#
zmodload -F zsh/parameter p:functions p:functions_source  # Used below

setopt NO_flowcontrol  # Enable ^Q and ^S.

# Better command line editing tools
znap source marlonrichert/zsh-edit
zstyle ':edit:*' word-chars '*?\'

bindkey "$key[Home]" beginning-of-buffer
bindkey "$key[End]"  end-of-buffer

bind '^Xp' 'cd .'
bind '^Xo' 'open .'
bind '^Xc' 'code .'
bind '^Xs' 'git status -Mu --show-stash'
bind '^Xl' 'git log'
bind "$key[PageUp]"   'git push && git fetch'
bind "$key[PageDown]" 'git fetch && git pull --autostash'

# Replace some default keybindings with better built-in widgets.
bindkey '^[^_'  copy-prev-shell-word
bindkey '^[q'   push-line-or-edit
bindkey '^V'    vi-quoted-insert

# Alt-H: Open `man` page (or other help) for current command.
alias run-help > /dev/null &&
    unalias run-help
autoload +X -Uz run-help
autoload -Uz $functions_source[run-help]-*~*.zwc

# Alt-Shift-/: Show definition of current command.
alias which-command > /dev/null &&
    unalias which-command
autoload -Uz which-command
zle -N which-command

##
# Miscellaneous
#

# Generate theme colors for Git & Zsh.
znap source marlonrichert/zcolors
znap eval zcolors "zcolors ${(q)LS_COLORS}"

# In-line suggestions
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=()
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=( forward-char forward-word end-of-line )
ZSH_AUTOSUGGEST_STRATEGY=( history )
ZSH_AUTOSUGGEST_HISTORY_IGNORE=$'(*\n*|?(#c80,)|*\\#:hist:push-line:)'
znap source zsh-users/zsh-autosuggestions

# Command-line syntax highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
znap source zsh-users/zsh-syntax-highlighting
# znap source zdharma/fast-syntax-highlighting


##
# Commands, aliases & functions
#

znap eval pyenv-init ${${:-=pyenv}:A}' init -'  # Abs path for cache invalidation

# History editing tools
znap source marlonrichert/zsh-hist
zstyle ':hist:*' expand-aliases yes

# File type associations
alias -s {gradle,json,md,patch,properties,txt,xml,yml}=$PAGER
alias -s gz='gzip -l'
if [[ $OSTYPE == darwin* ]]; then
    alias -s {log,out}='open -a Console'
else
    alias -s {log,out}='tail -f'
    alias -s deb='sudo apt install'
fi

alias \$= %=  # For pasting command line examples
alias grep='\grep --color' make='\make -j' nano=$EDITOR

# Pattern matching support for `cp`, `ln` and `mv`
# See http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#index-zmv
# Tip: Use -n for no execution. (Print what would happen, but don’t do it.)
autoload -Uz zmv
alias zmv='\zmv -v' zcp='\zmv -Cv' zln='\zmv -Lv'

# Paging & colors for `ls`
[[ $OSTYPE != linux-gnu ]] &&
    hash ls==gls  # GNU coreutils ls
ls() {
  command ls --group-directories-first --width=$COLUMNS --color -AFvx "$@" | $PAGER
  return $pipestatus[1]  # Return exit status of ls, not $PAGER
}
zstyle ':completion:*:ls:*:options' ignored-patterns \
    --group-directories-first --width --color -A -F -v -x

# Safer alternatives to `rm`
if [[ $OSTYPE == darwin* ]]; then
  trash() {
    local -aU items=( $^@(N) )
    local -aU missing=( ${@:|items} )
    (( $#missing )) &&
        print -u2 "trash: no such file(s): $missing"
    (( $#items )) ||
        return 66
    print Moving $( eval ls -d ${(q)items[@]%/} ) to Trash.
    items=( '(POSIX file "'${^items[@]:A}'")' )
    osascript -e 'tell application "Finder" to delete every item of {'${(j:, :)items}'}' \
        > /dev/null
  }
elif command -v gio > /dev/null; then
  # gio is available for macOS, but gio trash DOES NOT WORK correctly there.
  alias trash='gio trash'
fi
