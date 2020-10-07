#!/bin/zsh
zmodload zsh/zutil
zstyle ':znap:*' auto-compile no
source ~/.zsh/zsh-snap/znap.zsh
znap clone 2>/dev/null
