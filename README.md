# .config

Fast & powerful configs (dotfiles) for Zsh, Git, SSH, Terminal.app and Karabiner-Elements on macOS


### Features

For [Karabiner-Elements](https://pqrs.org/osx/karabiner/):
* [Ergoemacs mode level 1 and 2](http://ergoemacs.github.io/gradual-adoption.html) for faster and more ergonomic text editing (developed by yours truly.)

For SSH connections:
* Automatic loading of keys from [Keychain](https://support.apple.com/guide/keychain-access/welcome/mac) into SSH agent. No need to enter your password anymore for every SSH connection.

For [Git](https://git-scm.com):
* Colored output
* Use FileMerge for diffs and merges.
* Use Atom for editing commit messages.
* Automatically rebase when you pull.

For [Terminal.app](https://support.apple.com/guide/terminal/welcome/mac):
* Proper settings for getting the most out of the Z Shell (see below).
* A nice, hand-crafted theme with pleasant colors and transparency (designed by yours truly)
* [Programing ligatures and Powerline symbols](/tonsky/FiraCode)

For the [Z Shell](http://zsh.sourceforge.net):
* Starts up **fast** (thanks to [Zinit](/zdharma/zinit) and [Pure](sindresorhus/pure)).
* Uses **sensible defaults** (based on [Prezto](/sorin-ionescu/prezto) and [Zimfw](/zimfw)).
* Activates the **built-in help function**, so you can press ⌥H on any command for online help.
* **[Colored output](/trapd00r/LS_COLORS)** and **[syntax highlighting](/zsh-users/zsh-syntax-highlighting)**
* Enhanced **tab completions** (thanks to Prezto and [zsh-syntax-highlighting](/zsh-users/zsh-syntax-highlighting))
* [Automatic **completion suggestions** while you type](/zsh-users/zsh-autosuggestions), [based on your command history](/zsh-users/zsh-autosuggestions)
* [Automatic **insertion of closing brackets and quotes**](/hlissner/zsh-autopair)
* **Improved functionality** for [`cd`](/b4b4r07/enhancd), [`ls`](/ogham/exa), [`find`, and `tree`](/sharkdp/fd)
* **[Fuzzy search](/junegunn/fzf)**
* Better **[history search](zsh-users/zsh-history-substring-search)** when you press the ↑ key
* [Automatic **Pipenv shell**](MichaelAquilina/zsh-autoswitch-virtualenv)
* [Automatic **Homebrew installation suggestions** for missing commands](/Homebrew/homebrew-command-not-found)


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
   mv -iv .zshrc .zshrc.bak
   mv -iv .gitconfig .gitconfig.bak
   mv -iv .config/ .config.bak
   ```
1. [Git clone your fork](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository) into your home folder. You will now have a new `~/.config` folder.
1. Go into the new `.config` folder and run `make`:
   ```
   cd .config/
   make
   ```
   You will now have new `~/.zshrc` and `~/.gitconfig` files.
1. Merge back anything you'd like to keep from your old config files into your new ones.
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
