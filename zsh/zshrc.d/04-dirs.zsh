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

# Needed by VTE-based terminals (Gnome Terminal, Tilix) to propagate $PWD to new windows/tabs.
[[ $VENDOR == ubuntu ]] &&
    source /etc/profile.d/vte-*.*.sh

# Both Apple & VTE attach their function to the wrong hook!
func=$precmd_functions[(R)(__vte_osc7|update_terminal_cwd)]
if [[ -n $func ]]; then
  add-zsh-hook -d precmd $func  # Does not need to run before each prompt.
  add-zsh-hook chpwd $func      # Run it when we change dirs...
  $func                         # ...and once for our initial dir.
fi
unset func
