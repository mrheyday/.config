upstream = https://github.com/marlonrichert/.config.git

SHELL = /bin/sh
prefix = /usr/local
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin
datarootdir = $(prefix)/share
datadir = $(datarootdir)

makedir = $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
LN = ln -fs
MKDIR = @mkdir -pm 0700
MV = mv -f

brew-no-update = HOMEBREW_NO_AUTO_UPDATE=1
BREW = $(bindir)/brew
BREW_INSTALL = $(brew-no-update) $(BREW) install --quiet

BASH = /bin/bash
CURL = /usr/bin/curl
GIT = $(bindir)/git
ZSH = $(bindir)/zsh

gitdir = $(HOME)/Git
ZNAP = $(gitdir)/zsh-snap

taps := core services cask cask-fonts cask-versions
taps := $(taps:%=$(prefix)/Homebrew/Library/Taps/homebrew/homebrew-%)

formulas := asciinema bash bat chkrootkit coreutils elasticsearch ffmpeg gawk gnu-sed gource \
		gradle graphviz less libatomic_ops mariadb nano pyenv subversion tomcat@8 wget xmlstarlet \
		yarn
formulas := $(formulas:%=$(exec_prefix)/Cellar/%)

casks = adoptopenjdk8 font-material-icons font-montserrat font-open-sans font-roboto font-ubuntu \
		karabiner-elements rectangle visual-studio-code

gitconfig = $(HOME)/.gitconfig
zshconfig = $(HOME)/.zshenv
sshconfig = $(HOME)/.ssh/config
codeconfig = $(HOME)/Library/ApplicationSupport/Code/User/settings.json
gradleconfig = $(HOME)/.gradle/gradle.properties

dotfiles = $(gitconfig) $(zshconfig) $(sshconfig) $(codeconfig) $(gradleconfig)

backups = $(foreach file,$(dotfiles),$(file)~)

zsh-datadir = $(HOME)/.local/share/zsh/
zsh-hist = $(zsh-datadir)history
zsh-hist-old = $(HOME)/.zsh_history
zsh-cdr = $(zsh-datadir).chpwd-recent-dirs
zsh-cdr-old = $(HOME)/.chpwd-recent-dirs

.SUFFIXES:
.NOTPARALLEL:
.PHONY: all clean install casks repos

all: $(BREW) $(GIT)
	$(BREW) update
	$(BREW) upgrade --quiet --fetch-HEAD
	@rm -f $(datadir)/zsh/site-functions/{_git{,.zwc},git-completion.bash}
	@$(GIT) config remote.pushdefault origin
	@$(GIT) config push.default current
ifneq ($(upstream),$(shell $(GIT) remote get-url upstream 2>/dev/null))
	@-$(GIT) remote add upstream https://github.com/marlonrichert/.config.git 2>/dev/null
	@$(GIT) remote set-url upstream https://github.com/marlonrichert/.config.git
endif
	$(GIT) fetch --quiet upstream
	@$(GIT) branch --quiet --set-upstream-to upstream/master
	$(GIT) pull --quiet --autostash upstream

find = ) (
replace = ), (
osabackups = $(subst $(find),$(replace),$(foreach f,$(wildcard $(backups)),(POSIX file "$(f)")))
clean:
	$(BREW) autoremove
	$(BREW) cleanup
ifneq (,$(osabackups))
	-osascript -e 'tell application "Finder" to delete every item of {$(osabackups)}' >/dev/null
endif

install: all $(taps) $(formulas) casks repos $(backups) $(dotfiles) $(zsh-hist) $(zsh-cdr)

repos: zsh/znap-repos.zsh $(ZSH) $(gitdir) $(ZNAP)
	$(ZSH) $<

$(taps): $(BREW)
	-$(if $(wildcard $@),,$(brew-no-update) $(BREW) tap --quiet homebrew/$(notdir $@))

$(formulas): $(BREW)
	-$(if $(wildcard $@),,$(BREW_INSTALL) --formula $(notdir $@))

casks: $(BREW)
	@-$(BREW_INSTALL) --cask $(casks) 2>/dev/null

$(BREW): $(BASH) $(CURL)
	$(BASH) -c "$$($(CURL) -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

$(GIT): $(BREW)
	$(BREW_INSTALL) git

$(ZSH): $(BREW)
	-$(BREW_INSTALL) --fetch-HEAD --HEAD zsh
ifneq (UserShell: /bin/zsh,$(shell dscl . -read $(HOME)/ UserShell))
	chsh -s /bin/zsh
endif

$(ZNAP): $(GIT) $(gitdir)
ifeq (,$(wildcard $(ZNAP)))
	$(MKDIR) $(gitdir)
	$(GIT) -C $(gitdir) clone --quiet --depth=1 git@github.com:marlonrichert/zsh-snap.git
endif

$(backups):
	-$(MV) $(patsubst %~,%,$@) $@

$(gitconfig): git/.gitconfig
	$(LN) $(makedir)$< $@

$(zshconfig): zsh/.zshenv
	$(LN) $(makedir)$< $@

$(sshconfig): ssh/config
	$(MKDIR) $(dir $@)
	$(LN) $(makedir)$< $@

$(codeconfig): visual-studio-code/settings.json
	$(MKDIR) $(dir $@)
	$(LN) $(makedir)$< $@

$(gradleconfig): gradle/gradle.properties
	$(MKDIR) $(dir $@)
	$(LN) $(makedir)$< $@

ifneq (,$(wildcard $(zsh-hist-old)))
$(zsh-hist): $(zsh-hist-old)
	$(MKDIR) $(dir $@)
	$(MV) $< $@
endif

ifneq (,$(wildcard $(zsh-cdr-old)))
$(zsh-cdr): $(zsh-cdr-old)
	$(MKDIR) $(dir $@)
	$(MV) $< $@
endif
