export FZF_COMPLETION_TRIGGER=''
export FZF_TMUX_HEIGHT=40%
export FZF_DEFAULT_OPTS="-i
                         --bind=ctrl-space:abort
                         --exact
                         --height $FZF_TMUX_HEIGHT
                         --info=inline
                         --layout=reverse
                         --multi
                         --prompt='❯ '
                         --pointer='❯'
                         --marker='❯ '
                         --tiebreak=length,begin,end"
export FZF_CTRL_R_OPTS="--layout=default --no-extended --no-multi"
