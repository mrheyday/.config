.PHONY: *
install: clean backup link zsh homebrew

no-update := HOMEBREW_NO_AUTO_UPDATE=1

code-dir := ~/Library/Application\ Support/Code/User/
code := $(code-dir)settings.json

git := ~/.gitconfig

gradle-dir := ~/.gradle/
gradle := $(gradle-dir)gradle.properties

ssh-dir := ~/.ssh/
ssh := $(ssh-dir)config

zsh := ~/.zshrc

dotfiles := $(code) $(git) $(gradle) $(ssh) $(zsh)

clean:
	$(no-update) brew install trash 2> /dev/null
	trash -F $(foreach c, $(dotfiles), $(wildcard $(c)~))

backup:
	$(foreach d, $(dotfiles), $(if $(wildcard $(d)), mv -iv $(d) $(d)~; , ))

makefile-dir := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
ln := ln -fsv
link:
	mkdir -p $(code-dir)
	$(ln) $(makefile-dir)visual-studio-code/settings.json $(code)
	$(ln) $(makefile-dir)git/.gitconfig $(git)
	mkdir -p $(gradle-dir)
	$(ln) $(makefile-dir)gradle/gradle.properties $(gradle)
	mkdir -p $(ssh-dir)
	$(ln) $(makefile-dir)ssh/config $(ssh)
	$(ln) $(makefile-dir)zsh/.zshrc $(zsh)

plugins-dir := ~/.zsh
znap:
	$(no-update) brew install git 2> /dev/null
	mkdir -p $(plugins-dir)
	$(if $(wildcard $(plugins-dir)/zsh-snap), , \
			git -C $(plugins-dir) clone --depth=1 git@github.com:marlonrichert/zsh-snap.git )

zsh: znap
	$(no-update) brew install zsh 2> /dev/null
	$(shell zsh zsh/znap-clone.zsh )

taps := homebrew/core homebrew/services homebrew/cask homebrew/cask-fonts homebrew/cask-versions
formulas := asciinema bat coreutils nano ncurses pyenv pipenv svn zsh
casks := karabiner-elements rectangle visual-studio-code
homebrew:
	brew upgrade
	$(foreach t, $(taps),\
		$(no-update) brew tap $(t);)
	$(no-update) brew install $(formulas) 2> /dev/null
	$(no-update) brew cask install $(casks) 2> /dev/null
