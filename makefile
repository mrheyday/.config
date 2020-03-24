makefile-dir := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
atom-config := ~/.atom/config.cson
git-config := ~/.gitconfig
ssh-config := ~/.ssh/config
zsh-config := ~/.zshrc

install: brew-install backup symlink

brew-install:
	brew upgrade
	brew install bat
	brew install coreutils
	brew install exa
	brew install fd
	brew install fzf
	brew install multitail
	brew install pyenv
	brew install pipenv
	brew install trash
	brew tap homebrew/cask-fonts
	brew tap homebrew/command-not-found
	brew cask install atom
	brew cask install font-fira-code
	brew cask install karabiner-elements

backup:
	mv -iv $(atom-config) $(atom-config)\~
	mv -iv $(git-config) $(git-config)\~
	mv -iv $(ssh-config) $(ssh-config)\~
	mv -iv $(zsh-config) $(zsh-config)\~

symlink:
	ln -is $(makefile-dir)atom/config.cson $(atom-config)
	ln -is $(makefile-dir)git/.gitconfig $(git-config)
	ln -is $(makefile-dir)ssh/config $(ssh-config)
	ln -is $(makefile-dir)zsh/.zshrc $(zsh-config)

clean:
	trash $(atom-config)\~
	trash $(git-config)\~
	trash $(ssh-config)\~
	trash $(zsh-config)\~
