export ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=( end-of-line )
export ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=( forward-char emacs-forward-word )
export ZSH_AUTOSUGGEST_STRATEGY=( histdb_top_here completion )
_zsh_autosuggest_strategy_histdb_top_here() {
    local query="select commands.argv from
history left join commands on history.command_id = commands.rowid
left join places on history.place_id = places.rowid
where places.dir LIKE '$(sql_escape $PWD)%'
and commands.argv LIKE '$(sql_escape $1)%'
group by commands.argv order by count(*) desc limit 1"
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
