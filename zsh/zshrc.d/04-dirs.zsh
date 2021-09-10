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
