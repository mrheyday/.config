#!/bin/zsh

##
# Zsh runs .zshrc for each interactive shell, after .zprofile
#


# zmodload zsh/zprof
# typeset -F SECONDS


# Set these first, so history is preserved, no matter what happens.
XDG_DATA_HOME=~/.local/share
HISTFILE=$XDG_DATA_HOME/zsh/history
SAVEHIST=$(( 50 * 1000 ))       # For readability
HISTSIZE=$(( 1.2 * SAVEHIST ))  # Zsh recommended value


for __file__ in $ZDOTDIR/zshrc.d/*.zsh; do
  . $__file__
done
unset __file__


##
# Essentials
#

source ~/Git/zsh-snap/znap.zsh  # Plugin manager

# Shell options
setopt histfcntllock histignorealldups histsavenodups sharehistory
setopt extendedglob globstarshort numericglobsort
setopt NO_autoparamslash interactivecomments


##
# Prompt config
#
autoload -Uz add-zsh-hook

add-zsh-hook precmd  .prompt.cursor.blinking-bar
.prompt.cursor.blinking-bar()       { print -n '\e[5 q' }
add-zsh-hook preexec .prompt.cursor.blinking-underline
.prompt.cursor.blinking-underline() { print -n '\e[3 q' }
.prompt.cursor.blinking-bar

# Call this hook whenever we change dirs...
add-zsh-hook chpwd .prompt.chpwd
.prompt.chpwd() {
  zle &&
      zle -I  # Prepare the line editor for our output.
  print -P -- '\n%F{12}%~%f/'
  RPS1=

  # If the primary prompt is already showing, then update the git status.
  zle && [[ $CONTEXT == start ]] &&
      .prompt.git-status.async
}
.prompt.chpwd # ...and once on startup, immediately.

setopt cdsilent pushdsilent  # Suppress built-in output of cd and pushd.

PS1='%F{%(?,10,9)}%#%f '
znap prompt  # Make the left side of the primary prompt visible immediately.
# print $SECONDS

ZLE_RPROMPT_INDENT=0     # Right prompt margin
setopt transientrprompt  # Auto-remove the right side of each prompt.

# Reduce prompt latency by fetching git status asynchronously.
add-zsh-hook precmd .prompt.git-status.async
.prompt.git-status.async() {
  local fd=
  exec {fd}< <(
    () {
      local -a lines=() symbols=()
      local -i ahead= behind=
      local REPLY= MATCH= MBEGIN= MEND= head= gitdir= push= upstream=
      {
        gitdir="$( git rev-parse --git-dir )" ||
            return

        if upstream=$( git rev-parse --abbrev-ref @{u} ); then
            git remote set-branches $upstream:h '*'
            git config --local \
                remote.$upstream:h.fetch '+refs/heads/*:refs/remotes/'$upstream:h'/*'
        fi
        [[ -z $gitdir/FETCH_HEAD(Nmm-1) ]] &&
            git fetch -qt  # Fetch if there's no FETCH_HEAD or it is at least 1 minute old.


        # Capture the left-most group of non-blank characters on each line.
        lines=( ${(f)"$( git status -sunormal )"} )
        REPLY=${(SMj::)lines[@]##[^[:blank:]]##}

        # Split on color reset escape code, discard duplicates and sort.
        symbols=( ${(ps:\e[m:ui)REPLY//'??'/?} )

        REPLY=${(pj:\e[m :)symbols}$'\e[m'  # Join with color resets.
        REPLY+=" %F{12}${$( git rev-parse --show-toplevel ):t}%f:"  # Add repo root dir

        head=$( git rev-parse --abbrev-ref @ )
        if [[ $head == HEAD ]]; then
          REPLY+="%F{1}${${$( git branch --points-at=@ )#*\(no branch, }%\)*}"
        else
          REPLY+="%F{14}$head%f"

          if [[ -n $upstream ]]; then
            upstream=${${upstream%/$head}#upstream/}
            behind=$( git rev-list --count --right-only @...@{u} )
            REPLY+=" ${${behind:#0}:+%B%F{13\}}$behind%f<"

            push=$( git rev-parse --abbrev-ref @{push} )
            push=${${push%/$head}#origin/}
            if [[ $push != $upstream ]]; then
              ahead=$( git rev-list --count --left-only @...@{push} )
              REPLY+="%F{13}$upstream%b%f ${${ahead:#0}:+%B%F{14\}}$ahead%f>%F{13}$push"
            else
              ahead=$( git rev-list --count --left-only @...@{u} )
              REPLY+="%b%f ${${ahead:#0}:+%B%F{14\}}$ahead%f> %F{13}$upstream"
            fi
          fi
        fi
        REPLY+='%b%f' # Don't leak colors to command output.

        # Wrap ANSI codes in %{prompt escapes%}, so they're not counted as printable characters.
        REPLY="${REPLY//(#m)$'\e['[;[:digit:]]#m/%{${MATCH}%\}}"
      } always {
        print -r -- "$REPLY"
      }
    } 2> /dev/null  # Suppress all error output.
  )
  zle -Fw "$fd" .prompt.git-status.callback
}

zle -N .prompt.git-status.callback
.prompt.git-status.callback() {
  local fd=$1 REPLY
  {
    zle -F "$fd"            # Unhook this callback to avoid being called repeatedly.
    read -ru $fd
    [[ $RPS1 == $REPLY ]] &&
        return              # Avoid repainting when there's no change.
    RPS1=$REPLY
    zle && [[ $CONTEXT == start ]] &&
        zle .reset-prompt   # Repaint only if $RPS1 is actually visible.
  } always {
    exec {fd}<&-            # Close the file descriptor.
  }
}

# Shown after output that doesn't end in a newline.
PROMPT_EOL_MARK='%F{cyan}%S%#%f%s'

# Continuation prompt
indent=( '%('{1..36}'_,  ,)' )
PS2="${(j::)indent}" RPS2='%F{11}%^'

# Debugging prompt
indent=( '%('{1..36}"e,$( echoti cuf 2 ),)" )
i=${(j::)indent}
PS4=$'%(?,,\t\t-> %F{9}%?%f\n)'
PS4+=$'%2<< %{\e[2m%}%e%14<<             %F{10}%N%<<%f %3<<  %I%<<%b %(1_,%F{11}%_%f ,)'

unset indent


##
# Directory config
#
zmodload -F zsh/parameter p:dirstack
setopt autocd autopushd chaselinks pushdignoredups pushdminus

# Load dir stack from file, excl. current dir, temp dirs & non-existing dirs.
cdr=$XDG_DATA_HOME/zsh/chpwd-recent-dirs
[[ -r $cdr ]] &&
    typeset -gaU dirstack=( ${(u)^${(f@Q)"$( < $cdr )"}[@]:#($PWD|${TMPDIR:-/tmp}/*)}(N-/) )
unset cdr

# Needed by VTE-based terminals (Gnome Terminal, Tilix) to preserve $PWD on new windows/tabs.
[[ $VENDOR == ubuntu ]] &&
    source /etc/profile.d/vte-*.*.sh

# Both Apple & VTE attach their function to the wrong hook!
__func__=$precmd_functions[(R)(__vte_osc7|update_terminal_cwd)]
if [[ -n $__func__ ]]; then
  add-zsh-hook -d precmd $__func__  # Does not need to run before each prompt.
  add-zsh-hook chpwd $__func__      # Run it when we change dirs...
  $__func__                         # ...and once for our initial dir.
fi
unset __func__


##
# Completion config
#

# Real-time auto-completion
znap source marlonrichert/zsh-autocomplete

# Auto-installed by Brew, but far worse than the one supplied by Zsh
rm -f $HOMEBREW_PREFIX/share/zsh/site-functions/_git{,.zwc}

# Include absolute path for `znap eval` cache invalidation.
znap eval pyenv-init ${${:-=pyenv}:P}' init - --no-rehash'

# Include Python version as comment, for `znap eval` cache invalidation.
znap eval    pip-completion "pip completion --zsh             # $PYENV_VERSION"
znap eval   pipx-completion "register-python-argcomplete pipx # $PYENV_VERSION"
znap eval pipenv-completion "pipenv --completion              # $PYENV_VERSION"


##
# Keybindings
#
zmodload -F zsh/parameter p:functions_source

setopt NO_flowcontrol  # Enable ^Q and ^S.

# Better command line editing tools
znap source marlonrichert/zsh-edit
zstyle ':edit:*' word-chars '*?\'

bind \
    '^[p' 'cd .' \
    '^[c' 'code .' \
    '^[s' 'git branch -vv --points-at=@ && git status -s && git log --oneline @...@{push}' \
    '^[l' 'git log' \
    "$key[PageUp]"    'git push && git fetch' \
    "$key[PageDown]"  'git fetch && git pull --autostash'

if [[ $VENDOR == apple ]]; then
  bindkey \
      "$key[Home]" beginning-of-buffer \
      "$key[End]" end-of-buffer
  bind \
      '^[o' 'open .'
else
  bind \
      '^[o' 'nemo . &|'
fi

# Replace some default keybindings with better built-in widgets.
bindkey \
    '^[^_'  copy-prev-shell-word \
    '^[q'   push-line-or-edit \
    '^V'    vi-quoted-insert

# Alt-H: Open `man` page (or other help) for current command.
unalias run-help 2> /dev/null
autoload +X -Uz run-help
autoload -Uz $functions_source[run-help]-*~*.zwc

# Alt-Shift-/: Show description and origin of current command.
unalias which-command 2> /dev/null
zle -C  which-command list-choices which-command
which-command() {
  zle -I
  whatis      -- $words[@] 2> /dev/null
  whence -aSv -- $words[@] 2> /dev/null
  compstate[insert]=
  compstate[list]=
}


##
# Miscellaneous
#

# Generate theme colors for Git & Zsh.
znap source marlonrichert/zcolors
znap eval zcolors zcolors

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

znap source marlonrichert/zsh-hist  # History editing tools

alias \
    diff='diff --color' \
    grep='grep --color' \
    make='make -j' \
    {\$,%}=  # For pasting command line examples

# File type associations
alias -s \
    gz='gzip -l' \
    {gradle,json,md,patch,properties,txt,xml,yml}=$PAGER
if [[ $VENDOR == apple ]]; then
  alias -s \
      {log,out}='open -a Console'
else
  alias -s \
      {log,out}='code' \
      deb='sudo apt install'
fi

# Pattern matching support for `cp`, `ln` and `mv`
# See http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#index-zmv
# Tip: Use -n for no execution. (Print what would happen, but don’t do it.)
autoload -Uz zmv
alias \
    zmv='zmv -v' \
    zcp='zmv -Cv' \
    zln='zmv -Lv'

# Paging & colors for `ls`
ls() {
  command ${${OSTYPE:#linux-gnu}:+g}ls --width=$COLUMNS "$@" | $PAGER
  return $pipestatus[1]  # Return exit status of ls, not $PAGER
}
zstyle ':completion:*:ls:*:options' ignored-patterns --width
alias \
    ls='ls --group-directories-first --color -AFvx'

# Safer alternatives to `rm`
if [[ $VENDOR == apple ]]; then
  trash() {
    local -aU items=( $^@(N) )
    local -aU missing=( ${@:|items} )
    (( $#missing )) &&
        print -u2 "trash: no such file(s): $missing"
    (( $#items )) ||
        return 66
    print Moving $( eval ls -d -- ${(q)items[@]%/} ) to Trash.
    items=( '(POSIX file "'${^items[@]:A}'")' )
    osascript -e 'tell application "Finder" to delete every item of {'${(j:, :)items}'}' \
        > /dev/null
  }
elif command -v gio > /dev/null; then
  # gio is available for macOS, but gio trash DOES NOT WORK correctly there.
  alias \
      trash='gio trash'
fi


# zprof() {
#   zprof() {
#     unfunction zprof
#     builtin zprof
#     print $SECONDS
#     echoti sc
#     add-zle-hook-widget -d line-init zprof
#   }
#   add-zsh-hook -d precmd zprof
#   add-zle-hook-widget line-init zprof
# }
# add-zsh-hook precmd zprof
