make-file := $(abspath $(lastword $(MAKEFILE_LIST)))
make-dir := $(notdir $(patsubst %/,%,$(dir $(make-file))))

install: install-brew install-ln

install-brew:
	brew install zsh
	brew install coreutils
	brew install fzf
	brew install exa
	brew install fd
	brew tap homebrew/command-not-found
	brew tap homebrew/cask-fonts
	brew cask install font-fira-code

install-ln:
	ln -is $(make-dir)/zshrc ~/.zshrc
	ln -is $(make-dir)/gitconfig ~/.gitconfig
