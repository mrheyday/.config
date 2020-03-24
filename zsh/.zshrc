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


# Sensible defaults
zstyle ":prezto:*:*" color "yes"
zinit for \
  https://github.com/sorin-ionescu/prezto/blob/master/modules/environment/init.zsh \
  https://github.com/sorin-ionescu/prezto/blob/master/modules/editor/init.zsh \
  https://github.com/sorin-ionescu/prezto/blob/master/modules/history/init.zsh \
  https://github.com/sorin-ionescu/prezto/blob/master/modules/directory/init.zsh

# Environment variables
path=(
  /usr/local/opt/ncurses/bin
  /usr/local/{bin,sbin}
  $path
)
export LANG='en_US.UTF-8'
export WORDCHARS="*?~&;!$^<>|"
export VISUAL='atom'
export EDITOR='nano'
export PAGER='less'
export LESS='-g -i -M -R -S -w -z-4'

# Performance optimization
setopt HIST_FCNTL_LOCK

# Enable alt-h help function.
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

# Color grep
alias grep="grep --color=always"

# Better ls and tree
# Requires `brew install exa`.
alias ls="exa --color=always --color-scale -s=extension --group-directories-first --git -Fa"
ll() {
  ls --time-style=long-iso -lghm $@ | $PAGER
}
alias tree='ll -T -I=".git" -L=2'

# Better find
# Requires `brew install fd`.
find() {
  fd -HI $@
}

# Syntax highlighting in less
# Requires `brew install bat`.
alias less='bat --pager "$PAGER $LESS" --style=snip,header --color=always'

# Log file highlighting in tail
# Requires `brew install multitail`
alias tail="multitail -Cs --follow-all"

# Fast, asynchronous prompt
zinit light-mode for sindresorhus/pure

# Automatic Pyenv init and Pipenv shell
# Requires `brew install pyenv` and `brew install pipenv`
zinit light-mode for davidparsson/zsh-pyenv-lazy MichaelAquilina/zsh-autoswitch-virtualenv

# We need to draw the prompt before *and* after zsh-autoswitch-virtualenv.
# Otherwise, starting a shell inside a Python folder messes up the prompt.
zinit light-mode for sindresorhus/pure


# Everything ABOVE this line we want immediately when the prompt shows.
# Everything BELOW this line can wait to reduce startup time.


# Colors for 'ls' and completions
# Requires `brew install coreutils`.
zinit wait lucid light-mode for atclone"gdircolors -b LS_COLORS > clrs.zsh" atpull'%atclone' \
  pick"clrs.zsh" nocompile'!' trapd00r/LS_COLORS

# Better `cd` command
# Duplicates must be saved for this to work.
unsetopt PUSHD_IGNORE_DUPS
zinit wait lucid light-mode for atpull'!git checkout -- .' run-atpull atinit'zinit cclear' \
  b4b4r07/enhancd

# Fuzzy search
# Requires `brew install fzf`.
zinit wait lucid light-mode for \
  https://github.com/junegunn/fzf/blob/master/shell/completion.zsh \
  atload'source ~/.config/zsh/fzf.zsh' \
    https://github.com/junegunn/fzf/blob/master/shell/key-bindings.zsh \

# Faster Homebrew command-not-found
# Requires `brew tap homebrew/command-not-found`.
zinit wait lucid light-mode for Tireg/zsh-macos-command-not-found

# Completions
zinit wait lucid light-mode for \
  blockf atpull'zinit creinstall -q .' zsh-users/zsh-completions \
  atload'source ~/.config/zsh/completion.zsh' \
    https://github.com/sorin-ionescu/prezto/blob/master/modules/completion/init.zsh

# Automatic insertion of closing brackets and quotes
# Must be AFTER completions.
zinit wait lucid light-mode for atload'source ~/.config/zsh/bindkey.zsh' hlissner/zsh-autopair

# Command-line syntax highlighting
# Must be AFTER after keybindings and completions.
zinit wait lucid light-mode for \
  atload'source ~/.config/zsh/autosuggest.zsh' \
  zsh-users/zsh-syntax-highlighting

# Automatic suggestions while you type, based on occurence frequency in history.
# Must be AFTER syntax highlighting.
zinit wait lucid light-mode for \
  atload'add-zsh-hook precmd histdb-update-outcome' src"sqlite-history.zsh" larkery/zsh-histdb \
  atload'_zsh_autosuggest_start' zsh-users/zsh-autosuggestions
