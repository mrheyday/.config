make-file := $(realpath $(lastword $(MAKEFILE_LIST)))
make-dir := $(dir $(make-file))

install: install-brew install-ln

install-brew:
	brew install coreutils
	brew install bat
	brew install exa
	brew install fd
	brew install fzf
	brew tap homebrew/command-not-found
	brew tap homebrew/cask-fonts
	brew cask install font-fira-code
	brew cask install karabiner-elements

install-ln:
	ln -is $(make-dir)zshrc ~/.zshrc
	ln -is $(make-dir)gitconfig ~/.gitconfig
	ln -is $(make-dir)ssh/config ~/.ssh/config
