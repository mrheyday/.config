make-file := $(realpath $(lastword $(MAKEFILE_LIST)))
make-dir := $(dir $(make-file))

install: install-brew install-ln

install-brew:
	brew install bat
	brew install coreutils
	brew install exa
	brew install fd
	brew install fzf
	brew tap homebrew/cask-fonts
	brew tap homebrew/command-not-found
	brew cask install atom
	brew cask install font-fira-code
	brew cask install karabiner-elements

install-ln:
	ln -is $(make-dir)gitconfig ~/.gitconfig
	ln -is $(make-dir)ssh/config ~/.ssh/config
	ln -is $(make-dir)zshrc ~/.zshrc
