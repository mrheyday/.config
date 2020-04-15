export ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=( end-of-line vi-end-of-line vi-add-eol )
export ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(
  forward-char forward-word emacs-forward-word down-line
)
export ZSH_AUTOSUGGEST_STRATEGY=( histdb_top completion )
# `COLLATE UTF8_GENERAL_CI` makes it case insensitive.
_zsh_autosuggest_strategy_histdb_top() {
    local query="select commands.argv from
history left join commands on history.command_id = commands.rowid
left join places on history.place_id = places.rowid
where commands.argv COLLATE UTF8_GENERAL_CI LIKE '$(sql_escape $1)%'
group by commands.argv
order by places.dir != '$(sql_escape $PWD)', count(*) desc limit 1"
    suggestion=$(_histdb_query "$query")
}

# Duplicates must be saved for histdb to work.
unsetopt HIST_IGNORE_DUPS

# Remove comments and insignificant whitespace.
setopt HIST_REDUCE_BLANKS

# macOS compatibility fix
export HISTDB_TABULATE_CMD=(sed -e $'s/\x1f/\t/g')

# Performance optimization
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
export ZSH_AUTOSUGGEST_COMPLETION_IGNORE="brew *"
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1
export ZSH_AUTOSUGGEST_USE_ASYNC=1
