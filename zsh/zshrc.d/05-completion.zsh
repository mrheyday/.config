##
# Completion config
#

# Real-time auto-completion
znap source marlonrichert/zsh-autocomplete

# Auto-installed by Brew, but far worse than the one supplied by Zsh
rm -f $HOMEBREW_PREFIX/share/zsh/site-functions/_git{,.zwc}

# Include absolute path for `znap eval` cache invalidation.
znap eval pyenv-init ${${:-=pyenv}:P}' init - --no-rehash'

# Include Python version as comment, for `znap eval` cache invalidation.
znap eval    pip-completion "pip completion --zsh             # $PYENV_VERSION"
znap eval   pipx-completion "register-python-argcomplete pipx # $PYENV_VERSION"
znap eval pipenv-completion "pipenv --completion              # $PYENV_VERSION"
