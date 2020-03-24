ZINIT[COMPINIT_OPTS]=-C
zicompinit
zicdreplay
zmodload zsh/complist

setopt COMPLETE_ALIASES

# Do not automatically insert expansions for glob patterns, but list them instead.
setopt GLOB_COMPLETE

# Consider dotfiles when doing completion.
setopt GLOB_DOTS

# Insertion of "unambiguous" completions is a bit too eager. Prefer to show the list.
unsetopt LIST_AMBIGUOUS

# Use variable-width columns to make the list more compact.
setopt LIST_PACKED

zstyle ":completion:*" completer _expand _complete _match _approximate

# Don't show warnings.
zstyle -d ':completion:*:warnings' format

# Use colors in the completion list.
zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"

zstyle ":completion:*" list-dirs-first true

# If the list doesn't fit on screen, ask before showing it.
unset LISTPROMPT
zstyle -d ':completion:*:default' list-prompt
zstyle ':completion:*:default' select-prompt '%S%M matches%s'

# Lowercase input can match uppercase results.
# '-' in input can match '_' in results.
# '.', '_', '-' and uppercase letters count as word boundaries for completion.
zstyle ":completion:*" matcher-list "m:{[:lower:]-}={[:upper:]_} r:|[._-[:upper:]]=* r:|=* l:|=*"
