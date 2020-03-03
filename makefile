install:
	brew install zsh
	brew install coreutils
	brew install fzf
	brew install exa
	brew install fd
	brew cask install font-fira-code
	brew tap homebrew/command-not-found
	ln -is .zshrc ~/.zshrc
	ln -is .gitconfig ~/.gitconfig
