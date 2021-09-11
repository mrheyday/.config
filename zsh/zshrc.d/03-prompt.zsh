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
          REPLY+="%F{1}${${$( git branch --points-at=@ )##*\((no branch, |)}%\)*}"
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
