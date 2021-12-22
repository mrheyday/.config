#!/usr/bin/make -f

upstream = https://github.com/marlonrichert/.config.git
SHELL = /bin/zsh
VENDOR = $(shell print $$VENDOR)
OSTYPE = $(shell print $$OSTYPE)

# Include only the software that we want on all machines.
shell-commands = \
	aureliojargas/clitest \
	pyenv/pyenv \
	zsh-users/zsh-completions
vscode-extensions = \
	bmalehorn.shell-syntax \
	davidhewitt.shebang-language-associator \
	DotJoshJohnson.xml \
	GitHub.copilot \
	GitHub.vscode-pull-request-github \
	jeff-hykin.better-shellscript-syntax \
	jock.svg \
	kaiwood.center-editor-window \
	marvhen.reflow-markdown \
	ms-python.python \
	ms-python.vscode-pylance \
	ms-vscode.cpptools \
	ms-vsliveshare.vsliveshare \
	stylelint.vscode-stylelint
brew-taps := services
brew-formulas := bat diffutils git less nano
ifeq (apple,$(VENDOR))
brew-taps += autoupdate cask cask-fonts cask-versions
brew-formulas += bash coreutils
brew-casks = karabiner-elements rectangle visual-studio-code
else ifeq (linux-gnu,$(OSTYPE))
brew-formulas += grep
packages = konsole
endif

XDG_DATA_HOME = $(HOME)/.local/share
zshenv = $(HOME)/.zshenv
sshconfig = $(HOME)/.ssh/config
dotfiles := $(zshenv) $(sshconfig)
ifeq (apple,$(VENDOR))
vscode-settings = $(HOME)/Library/ApplicationSupport/Code/User/settings.json
vscode-keybindings = $(HOME)/Library/ApplicationSupport/Code/User/keybindings.json
dotfiles += $(vscode-settings) $(vscode-keybindings)
else ifeq (linux-gnu,$(OSTYPE))
konsole = $(XDG_DATA_HOME)/konsole
kxmlgui5 = $(XDG_DATA_HOME)/kxmlgui5
dotfiles += $(konsole) $(kxmlgui5)
endif
zsh-datadir = $(XDG_DATA_HOME)/zsh/
zsh-hist = $(zsh-datadir)history
zsh-hist-old = $(HOME)/.zsh_history
zsh-cdr = $(zsh-datadir).chpwd-recent-dirs
zsh-cdr-old = $(HOME)/.chpwd-recent-dirs

prefix = /usr/local
ifeq (linux-gnu,$(OSTYPE))
exec_prefix = /home/linuxbrew/.linuxbrew
else
exec_prefix = $(prefix)
endif
bindir = $(exec_prefix)/bin
datarootdir = $(prefix)/share
datadir = $(datarootdir)

BASH = /bin/bash
ifeq (apple,$(VENDOR))
CODE = $(bindir)/code
else
CODE = /usr/bin/code
endif
CURL = /usr/bin/curl
OSASCRIPT = /usr/bin/osascript
PLUTIL = /usr/bin/plutil
DSCL = /usr/bin/dscl
APT = /usr/bin/apt
DCONF = /usr/bin/dconf
GETENT = /usr/bin/getent
GIO = /usr/bin/gio
SNAP = /usr/bin/snap
WGET = /usr/bin/wget

GIT := $(bindir)/git
ifeq (,$(wildcard $(GIT)))
GIT := /usr/bin/git
endif
GITFLAGS = -q
gitdir = $(HOME)/Git

ZSH = /bin/zsh
ZNAP = $(gitdir)/zsh-snap/znap.zsh

BREW = $(bindir)/brew
BREWFLAGS = -q
HOMEBREW_PREFIX = $(exec_prefix)
HOMEBREW_CELLAR = $(HOMEBREW_PREFIX)/Cellar
HOMEBREW_REPOSITORY = $(HOMEBREW_PREFIX)/Homebrew

PIPX_BIN_DIR = $(HOME)/.local/bin
PIPX = $(PIPX_BIN_DIR)/pipx
PIPXFLAGS =
PIPENV = $(PIPX_BIN_DIR)/pipenv
PYENV_ROOT = $(gitdir)/pyenv
PYENV = $(PIPX_BIN_DIR)/pyenv
PYENV_VERSION = 3.7.10
PYENVFLAGS =
PYTHON = $(PYENV_ROOT)/versions/$(PYENV_VERSION)/bin/python
ifeq (linux-gnu,$(OSTYPE))
python-build = \
	build-essential \
	curl \
	libbz2-dev \
	libffi-dev \
	liblzma-dev \
	libncursesw5-dev \
	libreadline-dev \
	libsqlite3-dev \
	libssl-dev \
	libxml2-dev \
	libxmlsec1-dev \
	llvm \
	make \
	tk-dev \
	wget \
	xz-utils \
	zlib1g-dev
endif
PIP = $(PYENV_ROOT)/shims/pip
PIPFLAGS = -q

phony :=

ifeq (apple,$(VENDOR))
terminal = $(CURDIR)/terminal-apple/Dark\ Mode.terminal
else ifneq (,$(wildcard $(DCONF)))
terminal = $(CURDIR)/terminal-gnome/dconf.txt
ibus = $(CURDIR)/ibus/dconf.txt
endif

phony += all
all : | $(ibus) $(terminal)
	$(GIT) config remote.pushdefault origin
	$(GIT) config push.default current
ifneq ($(upstream),$(shell $(GIT) remote get-url upstream 2> /dev/null))
	-$(GIT) remote add upstream $(upstream)
	$(GIT) remote set-url upstream $(upstream)
endif
ifeq (,$(shell $(GIT) branch -l main))
	-$(GIT) branch $(GITFLAGS) -m master main
endif
	$(GIT) fetch $(GITFLAGS) -t upstream
	$(GIT) branch $(GITFLAGS) -u upstream/main main
	$(GIT) pull $(GITFLAGS) --autostash upstream > /dev/null
	$(GIT) remote set-head upstream -a > /dev/null

phony += $(terminal)
ifeq (apple,$(VENDOR))
$(terminal) :
	-$(PLUTIL) -extract 'Window Settings.Dark Mode' xml1 \
		-o '$@' $(HOME)/Library/Preferences/com.apple.Terminal.plist
else ifneq (,$(wildcard $(DCONF)))
$(terminal) :
	$(DCONF) dump /org/gnome/terminal/ > $@
endif

ifneq (,$(wildcard $(DCONF)))
phony += $(ibus)
$(ibus) :
	$(DCONF) dump /desktop/ibus/ > $@
endif

backups := $(wildcard $(dotfiles:%=%~))
ifneq (,$(wildcard $(OSASCRIPT)))
find = ) (
replace = ), (
backups := $(subst $(find),$(replace),$(foreach f,$(backups),(POSIX file "$(f)")))
endif

phony += clean
clean :
ifneq (,$(backups))
ifneq (,$(wildcard $(OSASCRIPT)))
	-$(OSASCRIPT) -e 'tell app "Finder" to delete every item of {$(backups)}' &> /dev/null
else ifneq (,$(wildcard $(GIO)))
	$(GIO) trash $(backups)
endif
endif

# Calls to `defaults` fail when they're not in a top-level target.
phony += install
install : | installdirs installconfig installapt installbrew installzsh installpython installcode
ifeq (apple,$(VENDOR))
	-$(OSASCRIPT) -e 'tell app "Terminal" to set current settings of windows to settings set "Basic"'
	-$(OSASCRIPT) -e 'tell app "Terminal" to delete settings set "Dark Mode"'
	$(OSASCRIPT) -e 'tell app "Terminal" to open POSIX file "$(CURDIR)/terminal-apple/Dark Mode.terminal"' > /dev/null
	$(OSASCRIPT) -e 'tell app "Terminal" to set current settings of windows to settings set "Dark Mode"'
	$(OSASCRIPT) -e 'tell app "Terminal" to set default settings to settings set "Dark Mode"'
	$(OSASCRIPT) -e 'tell app "Terminal" to set startup settings to settings set "Dark Mode"'
	$(OSASCRIPT) -e $$'tell app "Terminal" to do script "\C-C\C-D" in window 1' > /dev/null
	sleep 1
	$(OSASCRIPT) -e 'tell app "Terminal" to close window 1'
else ifneq (,$(wildcard $(DCONF)))
	$(DCONF) load /desktop/ibus/ < $(CURDIR)/ibus/dconf.txt
	$(DCONF) load /org/gnome/terminal/ < $(CURDIR)/terminal-gnome/dconf.txt
endif

phony += installconfig
installconfig : | $(dotfiles:%=%~)
	ln -fns $(CURDIR)/zsh/env $(zshenv)
ifeq (apple,$(VENDOR))
	ln -fns $(CURDIR)/ssh/config $(sshconfig)
	ln -fns $(CURDIR)/vscode/settings.json $(vscode-settings)
	ln -fns $(CURDIR)/vscode/keybindings.json $(vscode-keybindings)
	ln -fns /usr/local/share/nano $(CURDIR)/nano/syntax-highlighting
else ifeq (linux-gnu,$(OSTYPE))
	ln -fns $(CURDIR)/konsole $(konsole)
	ln -fns $(CURDIR)/kxmlgui5 $(kxmlgui5)
	ln -fns /usr/share/nano $(CURDIR)/nano/syntax-highlighting
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

phony += $(dotfiles:%=%~)
$(dotfiles:%=%~) : | clean
	$(if $(wildcard $(@:%~=%)), mv $(@:%~=%) $@,)

dirs = $(sort $(zsh-datadir) $(dir $(dotfiles)))
$(dirs) :
	mkdir -pm 0700 $@

ifeq (apple,$(VENDOR))
$(HOME)/Library/ApplicationSupport :
	ln -fns "$(HOME)/Library/Application Support" $@

installdirs : | $(dirs) $(HOME)/Library/ApplicationSupport
else
installdirs : | $(dirs)
endif
phony += installdirs

tapsdir = $(HOMEBREW_REPOSITORY)/Library/Taps/homebrew
brew-taps := $(brew-taps:%=$(tapsdir)/homebrew-%)
brew-formulas := $(brew-formulas:%=$(HOMEBREW_CELLAR)/%)

phony += installbrew
installbrew : | $(brew-taps) $(brew-formulas) $(brew-casks)

phony += brewupdate
brewupdate : | $(tapsdir)/homebrew-autoupdate
	$(BREW) autoremove $(BREWFLAGS)
ifeq (apple,$(VENDOR))
	-$(BREW) autoupdate stop $(BREWFLAGS) &> /dev/null
	$(BREW) autoupdate start $(BREWFLAGS) --cleanup --upgrade > /dev/null
else ifeq (linux-gnu,$(OSTYPE))
	$(BREW) update $(BREWFLAGS)
	$(BREW) upgrade $(BREWFLAGS)
endif

$(brew-formulas) : | brewupdate $(brew-taps)
	$(BREW) install $(BREWFLAGS) --formula $(notdir $@)

ifeq (apple,$(VENDOR))
phony += $(brew-casks)
$(brew-casks) : | $(tapsdir)/homebrew-cask
	$(if $(findstring $@,$(shell $(BREW) list --cask)),,\
	$(BREW) install $(BREWFLAGS) --cask $@ 2> /dev/null )
endif

$(brew-taps) : | $(BREW)
	$(BREW) tap $(BREWFLAGS) $(subst homebrew-,homebrew/,$(notdir $@))

$(BREW) :
	$(BASH) -c "$$( $(CURL) -fsSL \
		https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh )"

phony += installzsh
installzsh : | $(ZNAP)
	source $(ZNAP) && znap install $(shell-commands)
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
	$(GIT) -C $(abspath $(dir $@)..) clone $(GITFLAGS) --depth=1 -- \
		https://github.com/marlonrichert/zsh-snap.git

phony += installpython
installpython : | $(PIPENV)

phony += $(PIPENV)
$(PIPENV) : | $(PIPX)
	-$(BREW) uninstall $(BREWFLAGS) --formula pipx 2> /dev/null
	-$(PIPX) uninstall $(PIPXFLAGS) pipenv 2> /dev/null
	$(PIPX) install $(PIPXFLAGS) pipenv > /dev/null

phony += $(PIPX)
$(PIPX) : | $(PYTHON)
	-$(BREW) uninstall $(BREWFLAGS) --formula pipenv 2> /dev/null
	-$(PIP) uninstall $(PIPFLAGS) --user pipx 2> /dev/null
	$(PIP) install $(PIPFLAGS) --user pipx

phony += $(PYTHON)
$(PYTHON) : | $(PYENV)
	PYENV_ROOT=$(PYENV_ROOT) $(PYENV) install $(PYENVFLAGS) -s $(PYENV_VERSION)
	PYENV_ROOT=$(PYENV_ROOT) $(PYENV) global $(PYENV_VERSION)
	$(PIP) install $(PIPFLAGS) -U pip

phony += $(PYENV)
$(PYENV) : | $(python-build) installzsh

phony += installapt
installapt: $(packages)

ifeq (linux-gnu,$(OSTYPE))
phony += $(packages) $(python-build)
$(packages) $(python-build) :
	$(if $(findstring $@,$(shell $(APT) list --installed $@ 2> /dev/null)),,\
	sudo $(APT) install -y $@\
	)
endif

phony += installcode
installcode: $(vscode-extensions)

phony += $(vscode-extensions)
$(vscode-extensions) : | $(CODE)
	$(if $(findstring $@,$(shell $(CODE) --list-extensions)),,\
	$(CODE) --install-extension $@)

ifeq (apple,$(VENDOR))
$(CODE) : | visual-studio-code

else ifeq (linux-gnu,$(OSTYPE))
phony += $(CODE)
$(CODE) :
ifneq (,$(shell $(SNAP) list code 2> /dev/null))
	$(SNAP) remove code
endif
	$(if $(wildcard $(CODE)),,\
	( TMPSUFFIX=.deb; sudo $(APT) install -y =( $(WGET) -ncv --show-progress -O - \
		'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' ))\
	)
endif

.NOTPARALLEL :
.PHONY : $(phony)
.SUFFIXES :
