##
# Completion config
#

# Real-time auto-completion
znap source marlonrichert/zsh-autocomplete

# Auto-installed by Brew, but far worse than the one supplied by Zsh
rm -f $HOMEBREW_PREFIX/share/zsh/site-functions/_git{,.zwc}


# Set up lazy loading for Python-related completions:

znap function _pyenv pyenv              'eval "$( pyenv init - --no-rehash )"'
compctl -K    _pyenv pyenv

znap function _pip_completion pip       'eval "$( pip completion --zsh )"'
compctl -K    _pip_completion pip

znap function _python_argcomplete pipx  'eval "$( register-python-argcomplete pipx  )"'
complete -o nospace -o default -o bashdefault \
           -F _python_argcomplete pipx

znap function _pipenv pipenv            'eval "$( pipenv --completion )"'
compdef       _pipenv pipenv
