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

# Things that change the path must come BEFORE p10k instant prompt.
path=( /usr/local/opt/tomcat@8/bin /usr/local/opt/ncurses/bin $path )
zinit light-mode for id-as'brew/shellenv' atclone'brew shellenv > brew-shellenv.zsh' \
  atpull'!%atclone' run-atpull src'brew-shellenv.zsh' zdharma/null
zinit light-mode for id-as'zoxide/program' from'gh-r' as'program' mv'zoxide* -> zoxide' \
  pick'zoxide' nocompile'!' ajeetdsouza/zoxide

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Lazy `pyenv init`
# Requires `brew install pyenv`.
zinit light-mode for davidparsson/zsh-pyenv-lazy

# Automatic `pipenv shell`
# Must come AFTER initializing the prompt, but as soon as possible.
# Requires `brew install pipenv`.
zinit light-mode for MichaelAquilina/zsh-autoswitch-virtualenv

# Sensible defaults
zstyle ':prezto:*:*' color 'yes'
zinit light-mode for \
  https://github.com/sorin-ionescu/prezto/blob/master/modules/environment/init.zsh \
  https://github.com/sorin-ionescu/prezto/blob/master/modules/history/init.zsh \
  https://github.com/sorin-ionescu/prezto/blob/master/modules/directory/init.zsh

# Performance optimization
setopt HIST_FCNTL_LOCK

# Environment variables
export LANG='en_US.UTF-8'
export WORDCHARS='*?'
export VISUAL='atom'
export EDITOR='nano'
export PAGER='less'
export LESS='-g -i -M -R -S -w -z-4'

# Better `cd`
# Duplicates must be saved for this to work correctly.
unsetopt PUSHD_IGNORE_DUPS
zinit light-mode for id-as'zoxide/init' atclone'zoxide init zsh > zoxide-init.zsh' \
  atpull'!%atclone' run-atpull src'zoxide-init.zsh' zdharma/null
alias cd='z'

# Better `find`
# Requires `brew install fd`.
alias find='fd -HI -E=".git" -c=always $@'

# Color `grep`
alias grep='grep --color=always'

# Syntax highlighting in `less`
# Requires `brew install bat`.
alias less='bat --pager "$PAGER $LESS" --style=snip,header --color=always'

# Better `ls` and `tree`
# Requires `brew install exa`.
alias ls='exa -aF --git --color=always --color-scale -s=extension --group-directories-first'
ll() {
  ls -ghlm --time-style=long-iso $@ | $PAGER
}
alias tree='ll -T -L=2'

# Log file highlighting in `tail`
# Requires `brew install multitail`.
alias tail='multitail -Cs --follow-all'

# Safer alternative to `rm`
# Requires `brew install trash`.
alias trash='trash -F'

# Additional completions
# Does not include calls to `compdef`.
zmodload -i zsh/complist
zinit light-mode for blockf atpull'zinit creinstall -q .' zsh-users/zsh-completions
ZINIT[COMPINIT_OPTS]=-C
zicompinit
zicdreplay

# Fuzzy search
# Requires `brew install fzf`.
source ~/.config/zsh/fzf.zsh
zinit light-mode for https://github.com/junegunn/fzf/blob/master/shell/completion.zsh \
                     https://github.com/junegunn/fzf/blob/master/shell/key-bindings.zsh

# Enable alt-h help function.
export HELPDIR=$MANPATH
unalias run-help
autoload -Uz  run-help    run-help-git  run-help-ip   run-help-openssl \
              run-help-p4 run-help-sudo run-help-svk  run-help-svn

# Auto-suggest how to install missing commands.
zinit light-mode for is-snippet \
  https://github.com/Homebrew/homebrew-command-not-found/blob/master/handler.sh

# Colors for 'ls' and completions
# Requires `brew install coreutils`.
zinit light-mode for atclone'gdircolors -b LS_COLORS > clrs.zsh' atpull'%atclone' pick'clrs.zsh' \
  nocompile'!' atload'zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"' trapd00r/LS_COLORS

# Automatic insertion of closing brackets and quotes
# Must be AFTER calls to `compdef`.
zinit light-mode for hlissner/zsh-autopair

# Keybindings and auto-completion
# Must be AFTER all plugins that assign new keybindings.
source ~/.config/zsh/zle.zsh

# Command-line syntax highlighting
# Must be AFTER after all calls to `compdef`, `zle -N` or `zle -C`.
export ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
zinit light-mode for zsh-users/zsh-syntax-highlighting

# Automatic suggestions while you type, based on occurence frequency in history.
# Must be AFTER syntax highlighting.
source ~/.config/zsh/autosuggest.zsh
zinit light-mode for \
  pick'sqlite-history.zsh' atload'add-zsh-hook precmd histdb-update-outcome' larkery/zsh-histdb \
  atload'_zsh_autosuggest_start' zsh-users/zsh-autosuggestions

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
zinit light-mode for atload'source ~/.p10k.zsh' romkatv/powerlevel10k
