# .config

Fast & powerful configs (dotfiles) for Zsh, Git, SSH, Terminal.app and Karabiner-Elements on macOS


### Features

For SSH connections:
* Automatic loading of keys from
[Keychain](https://support.apple.com/guide/keychain-access/welcome/mac) into SSH agent. No need to
enter your password anymore for every SSH connection.

For [Karabiner-Elements](https://pqrs.org/osx/karabiner/):
* Enables [Ergoemacs mode](http://ergoemacs.github.io/gradual-adoption.html), so you can edit text faster
and more ergonomically.
* Makes ⌘Z and ⌘⇧Z shortcuts for undo and redo work in terminal apps.

For [Terminal.app](https://support.apple.com/guide/terminal/welcome/mac):
* Custom, translucent dark mode theme that uses colors from macOS's own palette
* Proper settings for using the Z Shell (see below)
* [Programing ligatures and Powerline symbols](/tonsky/FiraCode)

For [Git](https://git-scm.com):
* Colored output
* Automatic rebase when you pull
* Use [Xcode](https://apps.apple.com/fi/app/xcode/id497799835?mt=12)'s FileMerge for diffs and
merges.
* Use [Atom](https://atom.io) for editing commit messages.

For the [Z Shell](http://zsh.sourceforge.net):
* **[Starts up fast](https://github.com/zdharma/zinit)**
* [**Asynchronously updating** prompt](https://github.com/sindresorhus/pure)
* Comes with **[sensible](https://github.com/sorin-ionescu/prezto) [defaults](https://github.com/zimfw)**.
* Activates the **built-in help function**, so you can press ⌥H on any command for online help.
* **[Colored output](https://github.com/trapd00r/LS_COLORS)** and **[syntax](https://github.com/zsh-users/zsh-syntax-highlighting) [highlighting](https://github.com/sharkdp/bat)**
* Enhanced **[tab completions](https://github.com/zsh-users/zsh-completions)**.
* [Automatic **completion suggestions** while you type](https://github.com/zsh-users/zsh-autosuggestions), [based on your command history](https://github.com/zsh-users/zsh-autosuggestions)
* [Automatic **matching of brackets and quotes**](https://github.com/hlissner/zsh-autopair)
* **Upgraded commands** for [`cd`](https://github.com/b4b4r07/enhancd), [`ls`](https://github.com/ogham/exa), [`find`, `tree`](https://github.com/sharkdp/fd) and [`tail`](https://github.com/flok99/multitail)
* **[Fuzzy search](https://github.com/junegunn/fzf)**
* Better **[history search](https://github.com/zsh-users/zsh-history-substring-search)** when you press the ↑ key
* [Automatic **Pipenv shell**](https://github.com/MichaelAquilina/zsh-autoswitch-virtualenv)
* [Automatic **Homebrew installation suggestions** for missing commands](https://github.com/Homebrew/homebrew-command-not-found)


### Requirements

* These dotfiles were written for **macOS**. If you are using some other (Unix-based) OS, they might need some editing before you can use them. I have not tested them on anything else than macOS.
* You need to have **[Homebrew](https://brew.sh)** installed, which is available for both macOS and Linux. (Or you need to modify the `install-brew` target in the [makefile](makefile) to use another package manager of your choosing.)
* To benefit from the Z Shell part, you obviously need to be running `zsh` as your shell, which I highly recommend. Here's the best way to install the latest version:
  1. Open Terminal.app (or whatever terminal you like to use).
  1. Use **Homebrew** (see above) to install the latest version of `zsh`:
     ```
     brew install zsh
     ```
  1. Edit the file `/etc/shells` and change the line that says
     ```
     /bin/zsh
     ```
     to
     ```
     /usr/local/bin/zsh
     ```
     (Or if the file doesn't contain the first line above, just add the second line above to the end of the file.)
  1. Change your shell to `zsh`:
     ```
     chsh -s /usr/local/bin/zsh
     ```
  1. Restart your terminal.


## Installation

1. [Fork this repo](./fork).
1. Edit the [gitconfig](./blob/master/gitconfig) file in your fork so it has **your** name and email address, not mine!
1. Open Terminal.app (or whatever terminal you like to use).
1. Go to your home folder:
   ```
   cd ~
   ```
1. Back up your existing config files (if any):
   ```
   mv -iv .config/ .config.bak
   mv -iv .gitconfig .gitconfig.bak
   mv -iv .ssh/config .ssh/config.bak
   mv -iv .zshrc .zshrc.bak
   ```
1. [Git clone your fork](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository) into your home folder. You will now have a new `~/.config/` folder.
1. Go into the new `.config` folder and run `make`:
   ```
   cd .config/
   make
   ```
   You will now have new `~/.gitconfig`, `~/.ssh/config` and `~/.zshrc` files.
1. Merge anything you'd like to keep from your old config files back into your new ones.
1. Import the theme `~/.config/zsh.terminal` into Terminal.app
1. Restart your terminal.


### Installing

A step by step series of examples that tell you how to get a development env running

Say what the step will be

```
Give the example
```

And repeat

```
until finished
```

End with an example of getting some data out of the system or using it for a little demo


## Author
© 2020 [Marlon Richert](https://github.com/marlonrichert)


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
