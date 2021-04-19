.PHONY: *
install: link zsh homebrew

makefile-dir := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
code-dir := ~/Library/Application\ Support/Code/User/
git-dir := ~/Git
gradle-dir := ~/.gradle/
ssh-dir := ~/.ssh/

ln := ln -fs
mkdir := mkdir -pm 0700
brew-install := brew install --quiet
homebrew-no-update := HOMEBREW_NO_AUTO_UPDATE=1

code := $(code-dir)settings.json
git := ~/.gitconfig
gradle := $(gradle-dir)gradle.properties
ssh := $(ssh-dir)config
zsh := ~/.zshenv

dotfiles := $(code) $(git) $(gradle) $(ssh) $(zsh)

update:
	$(homebrew-no-update) $(brew-install) git
	git config remote.pushdefault origin
	git config push.default current
	@git remote add upstream https://github.com/marlonrichert/.config.git 2>/dev/null; true;
	git fetch -q upstream
	git branch -q --set-upstream-to upstream/master
	git pull -q --autostash upstream

clean: update
	$(foreach c, $(dotfiles),\
		$(if $(wildcard $(c)~ ),\
			rm -f $(c)~;,\
			) )
backup: clean
	$(foreach d, $(dotfiles),\
		$(if $(wildcard $(d) ),\
			mv -f $(d) $(d)~;,\
			) )

zsh-datadir := ~/.local/share/zsh/
zsh-oldhist := ~/.zsh_history
zsh-newhist := $(zsh-datadir)history
zsh-oldcdr := ~/.chpwd-recent-dirs
zsh-newcdr := $(zsh-datadir).chpwd-recent-dirs
link: backup
	$(mkdir) $(zsh-datadir)
	$(if $(wildcard $(zsh-oldhist)), \
		$(if $(wildcard $(zsh-newhist)),\
			,\
			mv -f $(zsh-oldhist) $(zsh-newhist) ),\
		)
	$(if $(wildcard $(zsh-oldcdr)), \
		$(if $(wildcard $(zsh-newcdr)),\
			,\
			mv -f $(zsh-oldcdr) $(zsh-newcdr) ),\
		)
	$(mkdir) $(code-dir)
	$(ln) $(makefile-dir)visual-studio-code/settings.json $(code)
	$(ln) $(makefile-dir)git/.gitconfig $(git)
	$(mkdir) $(gradle-dir)
	$(ln) $(makefile-dir)gradle/gradle.properties $(gradle)
	$(mkdir) $(ssh-dir)
	$(ln) $(makefile-dir)ssh/config $(ssh)
	$(ln) $(makefile-dir)zsh/.zshenv $(zsh)

znap:
	$(homebrew-no-update) $(brew-install) --HEAD --fetch-HEAD zsh
	$(mkdir) $(git-dir)
	$(if $(wildcard $(git-dir)/zsh-snap), ,\
		git -C $(git-dir) clone -q --depth=1 git@github.com:marlonrichert/zsh-snap.git)
	$(shell zsh $(makefile-dir)zsh/znap-clone.zsh)

taps := homebrew/core homebrew/services homebrew/cask homebrew/cask-fonts homebrew/cask-versions
formulas := asciinema bat coreutils gradle less nano node pyenv tomcat@8
casks := karabiner-elements rectangle visual-studio-code
homebrew: update
	$(homebrew-no-update)
	brew upgrade --quiet
	$(foreach t, $(taps), brew tap --quiet $(t);)
	$(brew-install) --formula $(formulas)
	$(brew-install) --cask $(casks) 2>/dev/null
	brew autoremove
