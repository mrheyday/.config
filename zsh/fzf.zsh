export FZF_COMPLETION_TRIGGER=''
export FZF_CTRL_R_OPTS="--height=40% --layout=default --no-multi"
export fzf_default_completion='complete-word'
export FZF_DEFAULT_COMMAND='fd -HI -E=".git"'
export FZF_TMUX_HEIGHT=$(( ${LINES} - 2 ))
export FZF_DEFAULT_OPTS="--height=$FZF_TMUX_HEIGHT -i --bind=ctrl-space:abort,ctrl-k:kill-line \
  --exact --info=inline --layout=reverse --multi --tiebreak=length,begin,end"
