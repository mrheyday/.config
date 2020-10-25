# #!/bin/zsh

# Make history a bit bigger than macOS default.
SAVEHIST=2000
HISTSIZE=$(( 1.2 * SAVEHIST))  # Zsh recommended value

# zmodload zsh/zprof

# Znap! The lightweight plugin manager that's easy to grok.
# Get it from https://github.com/marlonrichert/zsh-snap
source ~/.zsh/zsh-snap/znap.zsh

# Znap makes your prompt appear instantly & you can start typing right away.
znap prompt pure
# PS4='+%N:%I> '

add-zsh-hook -d precmd update_terminal_cwd
unfunction update_terminal_cwd

# Options
setopt autocd autopushd cdsilent chaselinks pushdignoredups pushdsilent
setopt NO_caseglob extendedglob globdots globstarshort nullglob numericglobsort
setopt histfcntllock histignorealldups histsavenodups sharehistory
setopt NO_flowcontrol interactivecomments rcquotes

# Environment variables
export LANG='en_US.UTF-8'
export EDITOR='code'
export VISUAL='code'
export CLICOLOR=1
export CLICOLOR_FORCE=1
export JAVA_HOME=$(/usr/libexec/java_home -v 1.8)
znap eval brew-shellenv 'brew shellenv'
rm -f $HOMEBREW_PREFIX/share/zsh/site-functions/_git

# Syntax highlighting in `less` and `man`
export PAGER='less'
export LESS='-giR'
export READNULLCMD='bat'
export MANPAGER="sh -c 'col -bpx | bat -l man -p'"
export BAT_PAGER="less $LESS"

# Real-time auto-completion
# Get it from https://github.com/marlonrichert/zsh-autocomplete
znap source zsh-autocomplete

# In-line suggestions
znap source zsh-autosuggestions
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=( "${ZSH_AUTOSUGGEST_ACCEPT_WIDGETS[@]:#*forward-char}" )
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=( forward-char vi-forward-char )

# Add external commands
znap eval pyenv-init 'pyenv init -'
znap eval pipenv-completion 'pipenv --completion'
typeset -gU PATH path=(
  $(znap path github-markdown-toc)
  ~/Applications/apache-tomcat-8.5.55/bin
  /usr/local/opt/ncurses/bin
  $path
  .
)

# Better line editing tools
# Get them from https://github.com/marlonrichert/zsh-edit
znap source zsh-edit
WORDCHARS='*?\'

# History editing tools
# Get them from https://github.com/marlonrichert/zsh-hist
znap source zsh-hist
bindkey '^[q' push-line-or-edit

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

# Color `grep`
alias grep='grep --color=always'

# Colors for 'ls' and completions
znap eval dircolors 'gdircolors -b'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
alias ls='ls -AFH'

# Command-line syntax highlighting
export ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
znap source zsh-syntax-highlighting
# znap source fast-syntax-highlighting

# zprof
