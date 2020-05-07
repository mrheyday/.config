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

# Bash/Readline compatibility
# zsh's default kills the whole line.
bindkey '^U' backward-kill-line

# Prezto/Emacs-undo-tree compatibility
# zsh does not have a default keybinding for this.
bindkey '^[_' redo

# Auto-completion
rm -f ~/.zcompdump
unsetopt AUTO_CD
source ~/.zinit/plugins/marlonrichert---zsh-autocomplete/zsh-autocomplete.plugin.zsh

# Enable alt-h help function.
export HELPDIR=$MANPATH
unalias run-help
autoload -Uz  run-help    run-help-git  run-help-ip   run-help-openssl \
              run-help-p4 run-help-sudo run-help-svk  run-help-svn

# Better `cd`
# Duplicates must be saved for this to work correctly.
unsetopt PUSHD_IGNORE_DUPS
zinit light-mode for id-as'zoxide/init' atclone'zoxide init zsh > zoxide-init.zsh' \
  atpull'!%atclone' run-atpull src'zoxide-init.zsh' zdharma/null
alias cd='z'

# Fuzzy find
# Requires `brew install fd` and `brew install fzf`.
export FZF_DEFAULT_COMMAND='fd -HI -E=".git"'
zinit light-mode for https://github.com/junegunn/fzf/blob/master/shell/completion.zsh \
                     https://github.com/junegunn/fzf/blob/master/shell/key-bindings.zsh
alias find='fzf'

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

# Command-line syntax highlighting
# Must be AFTER after all calls to `compdef`, `zle -N` or `zle -C`.
export ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
zinit light-mode for zsh-users/zsh-syntax-highlighting

# Colors for 'ls' and completions
# Requires `brew install coreutils`.
zinit light-mode for atclone'gdircolors -b LS_COLORS > clrs.zsh' atpull'%atclone' pick'clrs.zsh' \
  nocompile'!' atload'zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"' trapd00r/LS_COLORS

# Auto-suggest how to install missing commands.
zinit light-mode for is-snippet \
  https://github.com/Homebrew/homebrew-command-not-found/blob/master/handler.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
zinit light-mode for atload'source ~/.p10k.zsh' romkatv/powerlevel10k
