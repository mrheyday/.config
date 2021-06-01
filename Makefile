#!/usr/bin/make -f

SHELL = /bin/zsh
prefix = /usr/local
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin
datarootdir = $(prefix)/share
datadir = $(datarootdir)

makedir = $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

BASH = /bin/bash
CURL = /usr/bin/curl
OSASCRIPT = /usr/bin/osascript

GIT = /usr/bin/git
GITFLAGS = --quiet
upstream = https://github.com/marlonrichert/.config.git
gitconfig = ~/.gitconfig
gitignore = ~/.gitignore_global

ZSH = /bin/zsh
zshenv = ~/.zshenv
ZNAP = ~/Git/zsh-snap/znap.zsh

BREW = $(bindir)/brew
BREWFLAGS = --quiet
HOMEBREW_PREFIX = $(exec_prefix)
HOMEBREW_CELLAR = $(HOMEBREW_PREFIX)/Cellar
HOMEBREW_REPOSITORY = $(HOMEBREW_PREFIX)/Homebrew

taps := cask cask-fonts cask-versions core services
taps := $(taps:%=$(HOMEBREW_REPOSITORY)/Library/Taps/homebrew/homebrew-%)

formulas := asciinema bash bat chkrootkit coreutils elasticsearch ffmpeg gawk gnu-sed gource \
	gradle graphviz libatomic_ops mariadb@10.3 nano ncurses pyenv tomcat@9 wget xmlstarlet yarn
formulas := $(formulas:%=$(HOMEBREW_CELLAR)/%)

casks = adoptopenjdk8 karabiner-elements rectangle visual-studio-code \
	font-material-icons font-montserrat font-open-sans font-roboto font-ubuntu

PYENV_ROOT = ~/.pyenv
PYENV = PYENV_ROOT=$(PYENV_ROOT) $(bindir)/pyenv
PYENV_VERSION = 3.7.10
PIP = $(PYENV_ROOT)/shims/pip
PIPFLAGS = --quiet
PIPX = ~/.local/bin/pipx
PIPENV = ~/.local/bin/pipenv

gradleproperties = ~/.gradle/gradle.properties
sshconfig = ~/.ssh/config
vscodesettings = ~/Library/ApplicationSupport/Code/User/settings.json
vscodekeybindings = ~/Library/ApplicationSupport/Code/User/keybindings.json

dotfiles = $(gitconfig) $(gitignore) $(gradleproperties) $(sshconfig) $(zshenv) \
	$(vscodesettings) $(vscodekeybindings)

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
.PHONY: all clean installdirs install
.SUFFIXES:

all:
	# all
ifeq (,$(wildcard /Library/Developer/CommandLineTools))
	xcode-select --install 2>/dev/null
endif
	@$(GIT) config remote.pushdefault origin
	@$(GIT) config push.default current
ifneq ($(upstream),$(shell $(GIT) remote get-url upstream 2>/dev/null))
	@-$(GIT) remote add upstream $(upstream) 2>/dev/null
	@$(GIT) remote set-url upstream $(upstream)
endif
ifeq (,$(shell git branch -l main))
	@-git branch -m master main 2>/dev/null
endif
	$(GIT) fetch $(GITFLAGS) upstream
	@$(GIT) branch $(GITFLAGS) -u upstream/main main
	$(GIT) pull $(GITFLAGS) --autostash upstream
	@$(GIT) remote set-head upstream -a

clean:
	# clean
ifneq (,$(backups))
	-$(OSASCRIPT) -e 'tell application "Finder" to delete every item of {$(backups)}' >/dev/null
endif

installdirs:
	# install dirs
	mkdir -pm 0700 $(zsh-datadir) $(dir $(dotfiles))

install: all clean installdirs $(BREW) $(taps) $(formulas) $(ZNAP) $(PIPX) $(PIPENV)
	$(PRE_INSTALL) # pre-install
	-$(BREW) install $(BREWFLAGS) --cask $(casks) 2>/dev/null
ifneq ($(PYENV_VERSION),$(shell $(PYENV) global))
	$(PYENV) install -s $(PYENV_VERSION)
	$(PYENV) global $(PYENV_VERSION)
endif
	$(NORMAL_INSTALL) # install
	$(foreach f,$(wildcard $(dotfiles)),mv $(f) $(f)~;)
	ln -s $(makedir)git/gitconfig $(gitconfig)
	ln -s $(makedir)git/gitignore_global $(gitignore)
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
	$(POST_INSTALL) # post-install
ifneq (UserShell: /bin/zsh,$(shell dscl . -read ~/ UserShell))
	chsh -s /bin/zsh
endif

$(BREW):
	# brew
	$(BASH) -c "$$($(CURL) -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

$(taps):
	# tap
	-$(if $(wildcard $@),,$(BREW) tap $(BREWFLAGS) $(subst -,/,$(notdir $@)) )

$(formulas):
	# formula
	-$(if $(wildcard $@),,$(BREW) install $(BREWFLAGS) --formula $(notdir $@))

$(ZNAP):
	# znap
	@mkdir -pm 0700 $(dir $(dir $@))
	$(GIT) -C $(dir $(dir $@)) clone $(GITFLAGS) --depth=1 \
		git@github.com:marlonrichert/zsh-snap.git

$(PIPX):
	# pipx
	$(PIP) install $(PIPFLAGS) --user pipx

$(PIPENV):
	# pipenv
	$(PIPX) install pipenv
