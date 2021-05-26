#!/usr/bin/make -f

SHELL = /bin/zsh
prefix = /usr/local
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin
datarootdir = $(prefix)/share
datadir = $(datarootdir)

makedir = $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
OSASCRIPT = /usr/bin/osascript

BREW = $(bindir)/brew
BREWFLAGS = --quiet
HOMEBREW_PREFIX = $(exec_prefix)
HOMEBREW_REPOSITORY = $(HOMEBREW_PREFIX)/Homebrew
HOMEBREW_CELLAR = $(HOMEBREW_PREFIX)/Cellar

BASH = /bin/bash
CURL = /usr/bin/curl

GIT = /usr/bin/git
GITFLAGS = --quiet
upstream = https://github.com/marlonrichert/.config.git
gitconfig = ~/.gitconfig

ZSH = /bin/zsh
zshenv = ~/.zshenv
ZNAP = ~/Git/zsh-snap

taps := cask cask-fonts cask-versions core services
taps := $(taps:%=$(HOMEBREW_REPOSITORY)/Library/Taps/homebrew/homebrew-%)

formulas := asciinema bash bat chkrootkit coreutils elasticsearch ffmpeg gawk gnu-sed gource \
		gradle graphviz libatomic_ops mariadb@10.3 nano ncurses tomcat@9 wget xmlstarlet yarn
formulas := $(formulas:%=$(HOMEBREW_CELLAR)/%)

casks = adoptopenjdk8 karabiner-elements rectangle visual-studio-code \
		font-material-icons font-montserrat font-open-sans font-roboto font-ubuntu

sshconfig = ~/.ssh/config
vscodesettings = ~/Library/ApplicationSupport/Code/User/settings.json
vscodekeybindings = ~/Library/ApplicationSupport/Code/User/keybindings.json
gradleproperties = ~/.gradle/gradle.properties

dotfiles = $(gitconfig) $(zshenv) $(sshconfig) \
	$(vscodesettings) $(vscodekeybindings) $(gradleproperties)

backups := $(wildcard $(dotfiles:%=%~))
find = ) (
replace = ), (
backups := $(subst $(find),$(replace),$(foreach f,$(backups),(POSIX file "$(f)")))

XDG_DATA_HOME = ~/.local/share
zsh-datadir = $(XDG_DATA_HOME)/zsh/
zsh-hist = $(zsh-datadir)history
zsh-hist-old = ~/.zsh_history
zsh-cdr = $(zsh-datadir).chpwd-recent-dirs
zsh-cdr-old = ~/.chpwd-recent-dirs

.NOTPARALLEL:
.ONESHELL:
.PHONY: all install installdirs clean
.SUFFIXES:

all:
	@$(GIT) config remote.pushdefault origin
	@$(GIT) config push.default current
ifneq ($(upstream),$(shell $(GIT) remote get-url upstream 2>/dev/null))
	@-$(GIT) remote add upstream $(upstream) 2>/dev/null
	@$(GIT) remote set-url upstream $(upstream)
endif
	$(GIT) fetch $(GITFLAGS) upstream
	@$(GIT) branch $(GITFLAGS) --set-upstream-to upstream/master
	$(GIT) pull $(GITFLAGS) --autostash upstream

clean:
ifneq (,$(backups))
	-$(OSASCRIPT) -e 'tell application "Finder" to delete every item of {$(backups)}' >/dev/null
endif

installdirs:
	mkdir -pm 0700 $(TERMINFO) $(zsh-datadir) $(dir $(ZNAP)) $(dir $(dotfiles))

repos: zsh/znap-repos.zsh $(ZSH) $(gitdir) $(ZNAP)
	$(ZSH) $<

$(taps):
	-$(if $(wildcard $@),,$(BREW) tap $(BREWFLAGS) $(subst -,/,$(notdir $@)) )

$(formulas):
	-$(if $(wildcard $@),,$(BREW) install $(BREWFLAGS) --formula $(notdir $@))

casks: $(BREW)
	@-$(BREW_INSTALL) --cask $(casks) 2>/dev/null

$(BREW):
	$(BASH) -c "$$($(CURL) -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

$(GIT): $(BREW)
	$(BREW_INSTALL) git

$(ZSH): $(BREW)
	-$(BREW_INSTALL) --fetch-HEAD --HEAD zsh
ifneq (UserShell: /bin/zsh,$(shell dscl . -read $(HOME)/ UserShell))
	chsh -s /bin/zsh
endif

$(ZNAP):
	@mkdir -pm 0700 $(dir $@)
	$(GIT) -C $(dir $@) clone $(GITFLAGS) --depth=1 git@github.com:marlonrichert/zsh-snap.git

install: clean all installdirs $(BREW) $(taps) $(formulas) $(ZNAP)
	$(PRE_INSTALL) # Pre-install:
	-$(BREW) install $(BREWFLAGS) --cask $(casks) 2>/dev/null
	@source $(ZNAP)/znap.zsh; znap clone
	$(NORMAL_INSTALL) # Install:
	$(foreach f,$(wildcard $(dotfiles)),mv $(f) $(f)~;)
	ln -s $(makedir)git/.gitconfig $(gitconfig)
	ln -s $(makedir)zsh/.zshenv $(zshenv)
	ln -s $(makedir)ssh/config $(sshconfig)
	ln -s $(makedir)vscode/settings.json $(vscodesettings)
	ln -s $(makedir)vscode/keybindings.json $(vscodekeybindings)
	ln -s $(makedir)gradle/gradle.properties $(gradleproperties)
ifeq (,$(wildcard $(zsh-hist)))
ifneq (,$(wildcard $(zsh-hist-old)))
	mv $(zsh-hist-old) $(zsh-hist)
endif
endif
ifeq (,$(wildcard $(zsh-cdr)))
ifneq (,$(wildcard $(zsh-cdr-old)))
	mv $(zsh-cdr-old) $(zsh-cdr)
endif
endif
