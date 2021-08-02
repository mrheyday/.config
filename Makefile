#!/usr/bin/make -f

upstream = https://github.com/marlonrichert/.config.git
SHELL = /bin/zsh

# Include only the software that we want on all machines.
executables = aureliojargas/clitest ekalinin/github-markdown-toc
formulas := asciinema bat less nano pyenv
taps := services
ifeq (linux-gnu,$(shell print $$OSTYPE))
formulas += git grep
endif
ifeq (darwin,$(findstring darwin,$(shell print $$OSTYPE)))
taps += autoupdate cask cask-fonts cask-versions
formulas += bash coreutils
casks = karabiner-elements rectangle visual-studio-code
endif

zshenv = ~/.zshenv
sshconfig = ~/.ssh/config
dotfiles := $(zshenv) $(sshconfig)
ifeq (darwin,$(findstring darwin,$(shell print $$OSTYPE)))
vscode-settings = ~/Library/ApplicationSupport/Code/User/settings.json
vscode-keybindings = ~/Library/ApplicationSupport/Code/User/keybindings.json
dotfiles += $(vscode-settings) $(vscode-keybindings)
endif

XDG_DATA_HOME = ~/.local/share
zsh-datadir = $(XDG_DATA_HOME)/zsh/
zsh-hist = $(zsh-datadir)history
zsh-hist-old = ~/.zsh_history
zsh-cdr = $(zsh-datadir).chpwd-recent-dirs
zsh-cdr-old = ~/.chpwd-recent-dirs

prefix = /usr/local
ifeq (linux-gnu,$(shell print $$OSTYPE))
exec_prefix = /home/linuxbrew/.linuxbrew
else
exec_prefix = $(prefix)
endif
bindir = $(exec_prefix)/bin
datarootdir = $(prefix)/share
datadir = $(datarootdir)

BASH = /bin/bash
CURL = /usr/bin/curl
OSASCRIPT = /usr/bin/osascript
DSCL = /usr/bin/dscl
APT = /usr/bin/apt
DCONF = /usr/bin/dconf
GETENT = /usr/bin/getent
GIO = /usr/bin/gio

ifeq (linux-gnu,$(shell print $$OSTYPE))
GIT = $(bindir)/git
else
GIT = /usr/bin/git
endif
GITFLAGS = -q

ZSH = /bin/zsh
ZNAP = ~/Git/zsh-snap/znap.zsh

BREW = $(bindir)/brew
BREWFLAGS = -q
HOMEBREW_PREFIX = $(exec_prefix)
HOMEBREW_CELLAR = $(HOMEBREW_PREFIX)/Cellar
HOMEBREW_REPOSITORY = $(HOMEBREW_PREFIX)/Homebrew
tapsdir = $(HOMEBREW_REPOSITORY)/Library/Taps/homebrew
taps := $(taps:%=$(tapsdir)/homebrew-%)
formulas := $(formulas:%=$(HOMEBREW_CELLAR)/%)

PYENV_ROOT = ~/.pyenv
PYENV = $(bindir)/pyenv
PYENV_VERSION = 3.7.10
PYENVFLAGS =
PIP = $(PYENV_ROOT)/shims/pip
PIPFLAGS = -q
PIPX = ~/.local/bin/pipx
PIPXFLAGS =
PIPENV = ~/.local/bin/pipenv
ifeq (linux-gnu,$(shell print $$OSTYPE))
python-dependencies = bzip2 sqlite3 zlib1g-dev
endif

all: ibus terminal git

ibus: FORCE
ifneq (,$(wildcard $(DCONF)))
	$(DCONF) dump /desktop/ibus/ > $(CURDIR)/ibus/dconf.txt
endif

terminal: FORCE
ifneq (,$(wildcard $(DCONF)))
	$(DCONF) dump /org/gnome/terminal/ > $(CURDIR)/terminal/dconf.txt
endif

git: git-config git-remote git-branch
	$(GIT) fetch $(GITFLAGS) -t upstream
	$(GIT) branch $(GITFLAGS) -u upstream/main main
	$(GIT) pull $(GITFLAGS) --autostash upstream > /dev/null
	$(GIT) remote set-head upstream -a > /dev/null

git-config: FORCE
	$(GIT) config remote.pushdefault origin
	$(GIT) config push.default current

git-remote: FORCE
ifneq ($(upstream),$(shell $(GIT) remote get-url upstream 2> /dev/null))
	-$(GIT) remote add upstream $(upstream)
	$(GIT) remote set-url upstream $(upstream)
endif

git-branch: FORCE
ifeq (,$(shell $(GIT) branch -l main))
	-$(GIT) branch $(GITFLAGS) -m master main
endif

backups := $(wildcard $(dotfiles:%=%~))
ifneq (,$(wildcard $(OSASCRIPT)))
find = ) (
replace = ), (
backups := $(subst $(find),$(replace),$(foreach f,$(backups),(POSIX file "$(f)")))
endif

clean: FORCE
ifneq (,$(backups))
ifneq (,$(wildcard $(OSASCRIPT)))
	$(OSASCRIPT) -e 'tell application "Finder" to delete every item of {$(backups)}' &> /dev/null || :
else ifneq (,$(wildcard $(GIO)))
	$(GIO) trash $(backups)
endif
endif

install: all installdirs install-brew install-shell install-python $(dotfiles:%=%~)
ifneq (,$(wildcard $(DCONF)))
	$(DCONF) load /desktop/ibus/ < $(CURDIR)/ibus/dconf.txt
	$(DCONF) load /org/gnome/terminal/ < $(CURDIR)/terminal/dconf.txt
	$(foreach p,\
		$(filter-out list,$(shell $(DCONF) list /org/gnome/terminal/legacy/profiles:/)),\
		$(DCONF) write /org/gnome/terminal/legacy/profiles:/$(p)login-shell true;)
	$(foreach p,$(filter-out list,\
		$(shell $(DCONF) list /com/gexperts/Tilix/profiles/)),\
		$(DCONF) write /com/gexperts/Tilix/profiles:/$(p)login-shell true;)
endif
	ln -s $(CURDIR)/zsh/.zshenv $(zshenv)
ifeq (darwin,$(findstring darwin,$(shell print $$OSTYPE)))
	ln -s $(CURDIR)/ssh/config $(sshconfig)
	ln -s $(CURDIR)/vscode/settings.json $(vscode-settings)
	ln -s $(CURDIR)/vscode/keybindings.json $(vscode-keybindings)
endif
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

installdirs: FORCE
ifeq (darwin,$(findstring darwin,$(shell print $$OSTYPE)))
ifneq (,$(wildcard $(HOME)/Library/ApplicationSupport))
	$(OSASCRIPT) -e 'tell application "Finder" to delete every item of {(POSIX file "$(HOME)/Library/ApplicationSupport")}' &> /dev/null || :
endif
	ln -fns "$(HOME)/Library/Application Support" ~/Library/ApplicationSupport
endif
	mkdir -pm 0700 $(sort $(zsh-datadir) $(dir $(dotfiles)))

install-brew: $(formulas) $(casks) install-brew-autoupdate
	HOMEBREW_NO_AUTO_UPDATE=1 $(BREW) autoremove $(BREWFLAGS)
	HOMEBREW_NO_AUTO_UPDATE=1 $(BREW) cleanup $(BREWFLAGS)

$(formulas): install-brew-upgrade
	HOMEBREW_NO_AUTO_UPDATE=1 $(BREW) install $(BREWFLAGS) --formula $(notdir $@)

$(casks): $(tapsdir)/homebrew-cask
ifeq (darwin,$(findstring darwin,$(shell print $$OSTYPE)))
	HOMEBREW_NO_AUTO_UPDATE=1 $(BREW) install $(BREWFLAGS) --cask $@ 2> /dev/null
endif

install-brew-autoupdate: $(tapsdir)/homebrew-autoupdate
ifeq (darwin,$(findstring darwin,$(shell print $$OSTYPE)))
	-HOMEBREW_NO_AUTO_UPDATE=1 $(BREW) autoupdate stop $(BREWFLAGS) > /dev/null
	HOMEBREW_NO_AUTO_UPDATE=1 $(BREW) autoupdate start $(BREWFLAGS) --cleanup --upgrade > /dev/null
endif

$(taps): install-brew-upgrade
	HOMEBREW_NO_AUTO_UPDATE=1 $(BREW) tap $(BREWFLAGS) $(subst homebrew-,homebrew/,$(notdir $@))

install-brew-upgrade: $(BREW)
	$(BREW) update
	HOMEBREW_NO_AUTO_UPDATE=1 $(BREW) upgrade $(BREWFLAGS)

$(BREW):
	$(BASH) -c "$$( $(CURL) -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh )"

install-shell: install-shell-executables install-shell-change

install-shell-executables: $(ZNAP)
	source $(ZNAP) && znap install $(executables) > /dev/null

install-shell-change: FORCE
ifneq (,$(wildcard $(DSCL)))
ifneq (UserShell: $(SHELL),$(shell $(DSCL) . -read ~/ UserShell))
	chsh -s $(SHELL)
endif
else ifneq (,$(wildcard $(GETENT)))
ifneq ($(SHELL),$(findstring $(SHELL),$(shell $(GETENT) passwd $$LOGNAME)))
	chsh -s $(SHELL)
endif
endif

$(ZNAP):
	mkdir -pm 0700 $(abspath $(dir $@)..)
	$(GIT) -C $(abspath $(dir $@)..) clone $(GITFLAGS) --depth=1 https://github.com/marlonrichert/zsh-snap.git

install-python: install-python-pipenv

install-python-pipenv: install-python-pipenv-brew install-python-pipenv-pipx

install-python-pipenv-brew: FORCE
ifneq (,$(wildcard $(HOMEBREW_CELLAR)/pipenv))
	-HOMEBREW_NO_AUTO_UPDATE=1 $(BREW) uninstall $(BREWFLAGS) --formula pipenv
endif

install-python-pipenv-pipx: install-python-pipx
	$(PIPX) upgrade pipenv &> /dev/null || $(PIPX) install $(PIPXFLAGS) pipenv > /dev/null

install-python-pipx: install-python-pipx-brew install-python-pipx-pip

install-python-pipx-brew: FORCE
ifneq (,$(wildcard $(HOMEBREW_CELLAR)/pipx))
	-HOMEBREW_NO_AUTO_UPDATE=1 $(BREW) uninstall $(BREWFLAGS) --formula pipx
endif

install-python-pipx-pip: install-python-pip
	$(PIP) install $(PIPFLAGS) -U --user pipx

install-python-pip: install-python-pyenv
	$(PIP) install $(PIPFLAGS) -U pip

install-python-pyenv: $(HOMEBREW_CELLAR)/pyenv $(python-dependencies)
ifeq (,$(findstring $(PYENV_VERSION),$(shell $(PYENV) versions --bare)))
	@print '\e[5;31;40mCompiling Python $(PYENV_VERSION). This might take a while! Please stand by...\e[0m' && :
	PYENV_ROOT=$(PYENV_ROOT) $(PYENV) install $(PYENVFLAGS) -s $(PYENV_VERSION)
endif
	PYENV_ROOT=$(PYENV_ROOT) $(PYENV) global $(PYENV_VERSION)

$(python-dependencies): FORCE
ifeq (linux-gnu,$(shell print $$OSTYPE))
	$(APT) show $@ &> /dev/null || sudo $(APT) install $@
endif

$(dotfiles:%=%~): clean
	$(if $(wildcard $(@:%~=%)), mv $(@:%~=%) $@,)

.SUFFIXES:
FORCE:
