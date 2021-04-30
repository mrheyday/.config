#!/bin/zsh
zmodload zsh/zutil
zstyle ':znap:*' auto-compile no
source ~/Git/zsh-snap/znap.zsh
znap clone 2>/dev/null
znap pull
