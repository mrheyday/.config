# .config

Fast, powerful & friendly configs ("dotfiles") for Zsh, Git, SSH, Terminal.app, Karabiner-Element and your web browser on macOS

![screenshot](screenshot.png)


## Features

SSH config:
* Automatically load SSH keys from macOS login keychain into SSH agent, so you don't have to type any passwords for SSH connections.

User style sheet:
* Style all code in your web browser with the [Fira Code](https://github.com/tonsky/FiraCode) font.

[Terminal.app](https://support.apple.com/guide/terminal/welcome/mac) theme:
* Translucent dark mode with macOS system colors and Fira Code font

[Karabiner-Elements](https://karabiner-elements.pqrs.org) config:
* [Ergoemacs mode](https://ke-complex-modifications.pqrs.org/?q=ergoemacs#ergoemacs_mode)
* [Navigation in terminal apps](https://ke-complex-modifications.pqrs.org/?q=terminal#terminal_navi)
* [Undo and Redo in terminal apps](https://ke-complex-modifications.pqrs.org/?q=terminal#terminal_undo_redo)

Git config:
* Colored output
* Automatic rebase when you pull
* Use Xcode's FileMerge for diffs and
merges.
* Use Atom for editing commit messages.

Atom config:
* Format code on save.
* Use Fira Code as the font.
* Set line length to 99 characters.
* Configure [ide-python](https://atom.io/packages/ide-python) to work with
  [`pipenv`](https://pipenv.pypa.io/en/latest/), [`flake8`](https://flake8.pycqa.org/en/latest/),
  [`pycodestyle`](https://pycodestyle.pycqa.org/en/latest/) and [`pylint`](https://www.pylint.org).

[Z Shell](http://zsh.sourceforge.net) config:
* Fast start-up thanks to [asynchronous plugin loading](https://github.com/zdharma/zinit)
* [Sensible defaults](https://github.com/sorin-ionescu/prezto)
* Activates Zsh's built-in help function, so you can press ⌥H on any command for online help.
* [Pure](https://github.com/sindresorhus/pure) prompt
* Upgraded commands for
  * [`cd`](https://github.com/b4b4r07/enhancd),
  * [`ls`](https://github.com/ogham/exa),
  * [`find` and `tree`](https://github.com/sharkdp/fd), and
  * [`tail`](https://github.com/flok99/multitail)
* [Command-line syntax highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
* [Code syntax highlighting](https://github.com/sharkdp/bat) in `less`
* [Colored output](https://github.com/trapd00r/LS_COLORS) in `ls`, `grep` and command-line
  completion
* [Fuzzy history search and file completion](https://github.com/junegunn/fzf)
* [Homebrew "command not found" suggestions](https://github.com/Tireg/zsh-macos-command-not-found)
* [Additional command-line completions](https://github.com/zsh-users/zsh-completions)
* [Automatic closing brackets and quotes](https://github.com/hlissner/zsh-autopair)
* [Automatic suggestions while you type](https://github.com/zsh-users/zsh-autosuggestions),
  [based on your command history](https://github.com/larkery/zsh-histdb)
* Automatic [Pyenv init](https://github.com/davidparsson/zsh-pyenv-lazy) and
  [Pipenv shell](https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv)


## Requirements

* These dotfiles were written for **macOS**. If you are using some other (Unix-based) OS, they might need some editing before you can use them. I have not tested them on anything else than macOS.
* You need to have **[Homebrew](https://brew.sh)** installed, which is available for both macOS and Linux. (Or you need to modify the `brew` target in the [makefile](/marlonrichert/.config/blob/master/git/makefile) to use another package manager of your choosing.)
* To benefit from the Z Shell part, you obviously need to be running `zsh` as your shell —which I highly recommend. Here's the best way to install the latest version:
  1. Open Terminal.app (or whatever terminal you like to use) and use **Homebrew** (see above) to
     install the latest version of `zsh`:
     ```shell
     brew install zsh
     ```
  1. Edit your `/etc/shells` file and change the line that says
     ```shell
     /bin/zsh
     ```
     to
     ```shell
     /usr/local/bin/zsh
     ```
     (Or if the first line isn't there, just add the second line to the end of the file.)
  1. Change your shell to `zsh`:
     ```shell
     chsh -s /usr/local/bin/zsh
     ```
  1. Restart your terminal.


## Installation

1. [Fork this repo](/marlonrichert/.config/fork).
1. Edit the [.gitconfig](/marlonrichert/.config/blob/master/git/.gitconfig) file in your fork so it has **your** name and email address, not mine!
1. Open Terminal.app (or whatever terminal you like to use) and back up your existing `~/.config/` folder (if any):
   ```shell
   mv -iv ~/.config/ ~/.config\~
   ```
1. [Git clone your fork](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository) into your home folder. You will now have a new `~/.config/` folder.
1. Go into the new `~/.config` folder and run `make`:
   ```shell
   cd ~/.config/
   make
   ```
   This will…
    - back up your existing config files,
    - use Homebrew (see [Requirements](#requirements)) to install dependencies, and
    - install new config files.
1. Merge anything you'd like to keep from your old config files back into your new ones.
1. _(optional)_ In Terminal.app, go to Preferences and import the [Dark Mode theme](/marlonrichert/.config/terminal/Dark%20Mode.terminal) and set it as the default.
1. Restart your terminal.


## Author
© 2020 [Marlon Richert](/marlonrichert)


## License

This project is licensed under the MIT License - see the [LICENSE](/marlonrichert/.config/LICENSE) file for details
