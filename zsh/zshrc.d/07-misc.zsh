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
