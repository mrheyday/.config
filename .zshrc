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

function infocmp-csv { infocmp $@ | sed $'s/=/,/' | sed $'s/\t//' | sed -E $'s/\\\\\\E/^[/g' }
alias infocmp-csv="infocmp-csv -1"
alias bindkey-csv='bindkey -L | sed -E "s/(^.+\") /\1,/" | sed "s/bindkey \"/,\"/" | sed -E "s/(bindkey )(-.)( )(\")/\2,\4/"'

# Environment
export BROWSER='open'
export EDITOR='Atom'
export VISUAL='Atom'
export PAGER='less'
export LANG='en_US.UTF-8'
export LESS='-g -i -M -R -S -w -z-4'
autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic
autoload -Uz url-quote-magic
zle -N self-insert url-quote-magic

# Prompt
zinit light mafredri/zsh-async
zinit light sindresorhus/pure
zinit light MichaelAquilina/zsh-autoswitch-virtualenv
zinit light sindresorhus/pure # workaround to fix the prompt

# Key bindings
WORDCHARS='*?[]~=&;!#$%^(){}<>' # what punctuation is considered part of a word
stty -ixon <$TTY >$TTY  # enable ^Q and ^S
HELPDIR="/usr/share/zsh/5.7.1/help"
unalias run-help
autoload -Uz run-help
autoload -Uz run-help-git
autoload -Uz run-help-ip
autoload -Uz run-help-openssl
autoload -Uz run-help-p4
autoload -Uz run-help-sudo
autoload -Uz run-help-svk
autoload -Uz run-help-svn
function expand-all {
  zle _expand_alias
  zle expand-word
  zle magic-space
}
zle -N expand-all
bindkey "^[[Z" reverse-menu-complete  # shift-tab
bindkey " " magic-space
bindkey "^[K" backward-kill-line # ctrl-backspace
bindkey "^[(" kill-word # alt-delete
bindkey "^W" kill-region
bindkey "^Q" push-line-or-edit
bindkey "^[^_" copy-prev-shell-word
bindkey "^[-" redo
bindkey "^[ " expand-all  # alt-space
bindkey "^[e" expand-cmd-path

# Colors
alias dircolors='gdircolors'
alias grep="grep --color=auto"
function ls { gls $@ | less }
alias ls="ls --color=always --group-directories-first -AFhXl"
zinit ice atclone"dircolors -b LS_COLORS > clrs.zsh" atpull'%atclone' pick"clrs.zsh" ocompile'!' \
    atload'zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"'
zinit light trapd00r/LS_COLORS
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

# Completions
zinit ice blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions
zinit snippet PZT::modules/completion/init.zsh
setopt GLOB_DOTS  # Do not require a leading ‘.’ in a filename to be matched explicitly.
zstyle ':completion:*' completer _complete _correct _approximate _match
zstyle ':completion:*' matcher-list 'm:{[:lower:]-}={[:upper:]_} l:|=* r:|[[:upper:][:punct:]]=**'
zstyle ':completion:*' show-completer true
zstyle ':completion:*' sort match

# Must be AFTER anything that affects syntax highlighting
zinit ice atinit"zpcompinit; zpcdreplay"
zinit light zsh-users/zsh-syntax-highlighting

# Everything above this line we want immediately when the prompt shows.
# Everything below this line can wait so we can start faster.

# Must be AFTER syntax highlighting
zinit ice wait lucid \
    atload"bindkey '${key[Up]}' history-substring-search-up;bindkey '${key[Down]}' history-substring-search-down"
zinit light zsh-users/zsh-history-substring-search
HISTORY_SUBSTRING_SEARCH_FUZZY=1
setopt EXTENDED_HISTORY
setopt SHARE_HISTORY

zinit ice wait lucid atload"zinit cclear" atpull'!git checkout -- .' run-atpull
zinit light b4b4r07/enhancd

zinit ice wait lucid atload"add-zsh-hook precmd histdb-update-outcome" src"sqlite-history.zsh"
zinit light larkery/zsh-histdb
HISTDB_TABULATE_CMD=(sed -e $'s/\x1f/\t/g') # macOS compatibility workaround
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

# Must be last
zinit ice wait lucid atload"_zsh_autosuggest_start"
zinit light zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=( end-of-line )
ZSH_AUTOSUGGEST_CLEAR_WIDGETS=(
	history-search-forward
	history-search-backward
	history-beginning-search-forward
	history-beginning-search-backward
	history-substring-search-up
	history-substring-search-down
	up-line-or-beginning-search
	down-line-or-beginning-search
	up-line-or-history
	down-line-or-history
	accept-line
	copy-previous-word
  copy-previous-shell-word
)
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(
		forward-word
    forward-char
)
