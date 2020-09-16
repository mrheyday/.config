.PHONY: *
install: clean backup link zsh homebrew

no-update := HOMEBREW_NO_AUTO_UPDATE=1

code := ~/Library/ApplicationSupport/Code/User/settings.json
git := ~/.gitconfig
p10k := ~/.p10k.zsh
ssh := ~/.ssh/config
zsh := ~/.zshrc
dotfiles := $(code) $(git) $(p10k) $(ssh) $(zsh)

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
	$(ln) $(makefile-dir)ssh/config $(ssh)
	$(ln) $(makefile-dir)zsh/.p10k.zsh $(p10k)
	$(ln) $(makefile-dir)zsh/.zshrc $(zsh)

plugins := marlonrichert/zsh-autocomplete marlonrichert/zsh-hist marlonrichert/zsh-snap \
	ekalinin/github-markdown-toc MichaelAquilina/zsh-autoswitch-virtualenv romkatv/powerlevel10k \
	trapd00r/LS_COLORS zdharma/fast-syntax-highlighting \
	zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting
plugins-dir := ~/.zsh-plugins
zsh:
	mkdir -p $(plugins-dir)
	$(no-update) brew install git 2> /dev/null
	$(foreach p, $(plugins), $(if $(wildcard $(plugins-dir)/$(notdir $(p))), , \
			git -C $(plugins-dir) clone --depth=1 git@github.com:$(p).git;))

taps := homebrew/cask homebrew/cask-fonts homebrew/cask-versions homebrew/core homebrew/services
formulas := asciinema bat coreutils exa ncurses pyenv pipenv svn zsh
casks := font-fira-code karabiner-elements rectangle visual-studio-code
homebrew:
	brew upgrade
	$(foreach t, $(taps), $(no-update) brew tap $(t); )
	$(foreach f, $(formulas), $(no-update) brew install $(f) 2> /dev/null; )
	$(foreach c, $(casks), $(no-update) brew cask install $(c) 2> /dev/null; )
