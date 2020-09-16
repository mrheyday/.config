# Environment variables
PS4='+%N:%I> '
export LANG='en_US.UTF-8'
export WORDCHARS='~&|;!#$%^'
export EDITOR='code'
export VISUAL='code'

# Options
setopt autocd autopushd cdsilent chaselinks pushdignoredups pushdsilent
setopt NO_caseglob extendedglob globdots globstarshort nullglob numericglobsort
setopt histfcntllock histignorealldups histreduceblanks histsavenodups sharehistory
setopt NO_flowcontrol interactivecomments
setopt NO_shortloops

# Znap! The lightweight plugin manager that's easy to grok.
# Get it from https://github.com/marlonrichert/zsh-snap
source ~/.zsh-plugins/zsh-snap/znap.plugin.zsh

# Advanced auto-completion
znap source zsh-autocomplete
# znap source zsh-autosuggestions

# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# History editing tools
bindkey '^[Q' push-line-or-edit
znap source zsh-hist

# Bash/Readline compatibility
# Zsh's default kills the whole line.
bindkey '^U' backward-kill-line

# Prezto/Emacs-undo-tree compatibility
# Zsh does not have a default keybinding for this.
bindkey '^[_' redo

# Enable alt-h help function.
unalias run-help
autoload -Uz  run-help    run-help-git  run-help-ip   run-help-openssl \
              run-help-p4 run-help-sudo run-help-svk  run-help-svn

# Pattern matching support for `cp`, `ln` and `mv`
# See http://zsh.sourceforge.net/Doc/Release/User-Contributions.html#index-zmv
autoload -Uz zmv
alias zcp='zmv -Civ'
alias zln='zmv -Liv'
alias zmv='zmv -Miv'

# Safer alternative to `rm`
alias trash='trash -F'

# Better `ls`
alias ls='exa -aFghmu -I .git -s extension --git --color=always --color-scale --group-directories-first --time-style=long-iso'
alias tree='ls -T'

# Some more commands
typeset -gU PATH path=(
  $(znap path github-markdown-toc)
  ~/Applications/apache-tomcat-8.5.55/bin
  /usr/local/opt/ncurses/bin
  $path
  .
)

# Command-line syntax highlighting
export ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
znap source zsh-syntax-highlighting
# znap source fast-syntax-highlighting

# Syntax highlighting in `less` and `man`
export PAGER='bat'
export MANPAGER="sh -c 'col -bx | $PAGER -l man'"
export READNULLCMD='bat'
export LESS='-giR'
export BAT_PAGER="less $LESS"

# Colors for 'ls' and completions
znap eval LS_COLORS 'gdircolors -b LS_COLORS'
zstyle ":completion:*" list-colors "${(s.:.)LS_COLORS}"

# Color `grep`
alias grep='grep --color=always'

znap eval brew-shellenv 'brew shellenv'
znap eval pyenv-init `pyenv init -`
znap eval pipenv-completion 'pipenv --completion'

# Automatic `pipenv shell`
# Must come AFTER initializing the prompt.
znap source zsh-autoswitch-virtualenv

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
znap source powerlevel10k
source ~/.p10k.zsh
