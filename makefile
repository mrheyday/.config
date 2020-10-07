.PHONY: *
install: clean backup link zsh homebrew

no-update := HOMEBREW_NO_AUTO_UPDATE=1

code := ~/Library/ApplicationSupport/Code/User/settings.json
git := ~/.gitconfig
gradle := ~/.gradle/gradle.properties
ssh := ~/.ssh/config
zsh := ~/.zshrc
dotfiles := $(code) $(git) $(gradle) $(ssh) $(zsh)

clean:
	$(no-update) brew install trash 2> /dev/null
	trash -F $(foreach c, $(dotfiles), $(wildcard $(c)~))

backup:
	$(foreach d, $(dotfiles), $(if $(wildcard $(d)), mv -iv $(d) $(d)~;, ))

makefile-dir := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
ln := ln -isv
link:
	$(ln) $(makefile-dir)visual-studio-code/settings.json $(code)
	$(ln) $(makefile-dir)git/.gitconfig $(git)
	$(ln) $(makefile-dir)gradle/gradle.properties $(gradle)
	$(ln) $(makefile-dir)ssh/config $(ssh)
	$(ln) $(makefile-dir)zsh/.zshrc $(zsh)

plugins-dir := ~/.zsh
znap:
	$(no-update) brew install git 2> /dev/null
	mkdir -p $(plugins-dir)
	$(if $(wildcard $(plugins-dir)/zsh-snap), , \
			git -C $(plugins-dir) clone --depth=1 git@github.com:marlonrichert/zsh-snap.git;)

zsh: znap
	$(no-update) brew install zsh 2> /dev/null
	$(shell zsh zsh/znap-clone.zsh )

taps := homebrew/core homebrew/services homebrew/cask homebrew/cask-fonts homebrew/cask-versions
formulas := asciinema bat coreutils nano ncurses pyenv pipenv svn zsh
casks := font-fira-code karabiner-elements rectangle visual-studio-code
homebrew:
	brew upgrade
	$(foreach t, $(taps), $(no-update) brew tap $(t); )
	$(foreach f, $(formulas), $(no-update) brew install $(f) 2> /dev/null; )
	$(foreach c, $(casks), $(no-update) brew cask install $(c) 2> /dev/null; )
