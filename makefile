install: brew clean backup symlink

repos := homebrew/cask-fonts homebrew/command-not-found
formulas := bat coreutils exa fd fzf multitail pyenv pipenv trash
casks := atom font-fira-code karabiner-elements
no-update := HOMEBREW_NO_AUTO_UPDATE=1
brew:
	brew upgrade
	$(foreach r, $(repos), $(no-update) brew tap $(r); )
	$(foreach f, $(formulas), $(no-update) brew install $(f) 2> /dev/null; )
	$(foreach c, $(casks), $(no-update) brew cask install $(c) 2> /dev/null; )

atom-config := ~/.atom/config.cson
git-config := ~/.gitconfig
ssh-config := ~/.ssh/config
zsh-config := ~/.zshrc
configs := $(atom-config) $(git-config) $(ssh-config) $(zsh-config)

clean:
	trash -F $(foreach c, $(configs), $(wildcard $(c)~))

backup:
	$(foreach c, $(configs), mv -iv $(c) $(c)~; )

makefile-dir := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
symlink:
	ln -isv $(makefile-dir)atom/config.cson $(atom-config)
	ln -isv $(makefile-dir)git/.gitconfig $(git-config)
	ln -isv $(makefile-dir)ssh/config $(ssh-config)
	ln -isv $(makefile-dir)zsh/.zshrc $(zsh-config)
