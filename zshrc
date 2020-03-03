### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma/zinit)…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
        print -P "%F{160}▓▒░ The clone has failed.%f"
fi
source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit installer's chunk

# Prompt
zinit light-mode for mafredri/zsh-async sindresorhus/pure

# Automatic Pipenv
zinit light MichaelAquilina/zsh-autoswitch-virtualenv

# Workaround: Redraw the prompt
zinit light sindresorhus/pure

# Sensible defaults
zinit for \
  https://github.com/sorin-ionescu/prezto/blob/master/modules/environment/init.zsh \
  https://github.com/sorin-ionescu/prezto/blob/master/modules/editor/init.zsh \
  https://github.com/sorin-ionescu/prezto/blob/master/modules/completion/init.zsh \
  https://github.com/zimfw/environment/blob/master/init.zsh \
  https://github.com/zimfw/utility/blob/master/init.zsh

# Environment variables
path=(
  /usr/local/opt/ncurses/bin
  /usr/local/{bin,sbin}
  $path
)
export LANG='en_US.UTF-8'
export VISUAL='atom'
export EDITOR='nano'
export PAGER='less'
export LESS='-g -i -M -R -S -w -z-4'
export READNULLCMD=$PAGER
WORDCHARS="*?[]~&;!#$%^(){}<>:|"

# Options
setopt CORRECT
setopt GLOB_DOTS
setopt MENU_COMPLETE

# Set up alt-h help function
HELPDIR="/usr/local/Cellar/zsh/$ZSH_VERSION/share/man/man1"
unalias run-help
autoload -Uz run-help
autoload -Uz run-help-git
autoload -Uz run-help-ip
autoload -Uz run-help-openssl
autoload -Uz run-help-p4
autoload -Uz run-help-sudo
autoload -Uz run-help-svk
autoload -Uz run-help-svn

# Aliases and functions
function infocmp-csv {
  infocmp $@ | sed $'s/=/,/' | sed $'s/\t//' | sed -E $'s/\\\\\\E/^[/g'
}
alias infocmp-csv="infocmp-csv -1"
alias bindkey-csv='bindkey -L | sed -E "s/(^.+\") /\1,/" | sed "s/bindkey \"/,\"/" | \
  sed -E "s/(bindkey )(-.)( )(\")/\2,\4/"'
function print-key {
   print -r -- ${(qqqq)key[$@]}
}
function print-all-keys {
  for k v in ${(kv)key}; do
    print -r -- "$k -> ${(qqqq)v}"
  done
}
function print-terminfo {
   print -r -- ${(qqqq)terminfo[$@]}
}
alias grep="grep --color=always"

# Requires `brew install exa`.
function ls {
  exa -lFaghm@ --color=always --color-scale --sort=extension --group-directories-first \
    --time-style=long-iso --git $@ | $PAGER
}
alias tree="ls -T"

# Requires `brew install fd`.
function find {
  fd -HI --max-depth=5 --color=always $@ | $PAGER
}

# Colors
# Requires `brew install coreutils`.
# Compile with dircolors only when we update.
zinit for atclone"gdircolors -b LS_COLORS > clrs.zsh" atpull'%atclone' pick"clrs.zsh" \
  nocompile'!' atload'zstyle ":completion:*" list-colors “${(s.:.)LS_COLORS}”' light-mode \
  trapd00r/LS_COLORS

# Fuzzy search
# Requires `brew install fzf`.
export FZF_DEFAULT_OPTS="--height 40% --reverse"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_COMPLETION_TRIGGER=''

# Everything ABOVE this line we want immediately when the prompt shows.
# Everything BELOW this line can wait so we can start faster.

# Additional completions
zinit wait lucid blockf atpull'zinit creinstall -q .' for light-mode zsh-users/zsh-completions

# Better `cd` command

# Undo file deletions, so we can git rebase.
unsetopt PUSHD_IGNORE_DUPS
zinit wait lucid for atload"
  zinit cclear # Discard included Fish completions.
  bindkey '^I' fzf-completion" \
  atpull'!git checkout -- .' run-atpull light-mode b4b4r07/enhancd

# Faster brew command-not-found
# Requires `brew tap homebrew/command-not-found`.
zinit wait lucid for light-mode Tireg/zsh-macos-command-not-found

# Command-line syntax highlighting
# Must be AFTER anything that affects it (colors, completions).
zinit wait lucid for atinit"zpcompinit; zpcdreplay" light-mode zsh-users/zsh-syntax-highlighting

# Better history search
# Must be AFTER zsh-syntax-highlighting.
# Requires `brew install fzy`.
zinit wait lucid atload"
  bindkey '^[OA' history-substring-search-up
  bindkey '^[OB' history-substring-search-down" \
  for light-mode zsh-users/zsh-history-substring-search

# Automatic suggestions while you type, based on frequent occurences in history.
# Must be LAST.
unsetopt HIST_IGNORE_DUPS
HISTDB_TABULATE_CMD=(sed -e $'s/\x1f/\t/g') # Workaround: macOS compatibility
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=( end-of-line )
ZSH_AUTOSUGGEST_STRATEGY=( histdb_top completion )
_zsh_autosuggest_strategy_histdb_top() {
    local query="select commands.argv from
history left join commands on history.command_id = commands.rowid
left join places on history.place_id = places.rowid
where commands.argv LIKE '$(sql_escape $1)%'
group by commands.argv
order by places.dir != '$(sql_escape $PWD)', count(*) desc limit 1"
    suggestion=$(_histdb_query "$query")
}
zinit wait lucid for \
  atload"add-zsh-hook precmd histdb-update-outcome" src"sqlite-history.zsh" \
    light-mode larkery/zsh-histdb \
  atload"_zsh_autosuggest_start" light-mode zsh-users/zsh-autosuggestions
