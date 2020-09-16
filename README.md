# .config

Dotfiles for Zsh, Git, SSH, Terminal.app, Karabiner-Elements and my web browser on macOS

![screenshot](screenshot.png)

Table of Contents:
* [Requirements](#requirements)
* [Installation](#installation)
* [Author](#author)
* [License](#license)

## Requirements
* These dotfiles were written for **macOS**. If you are using some other (Unix-based) OS, they
  might need some editing before you can use them. I have not tested them on anything else than
  macOS.
* You need to have **[Homebrew](https://brew.sh)** installed, which is available for both macOS and
  Linux. (Or you need to modify the `homebrew` target in the
  [makefile](/marlonrichert/.config/blob/master/git/makefile) to use another package manager of
  your choosing.)
* To benefit from the Z Shell part, you obviously need to be running `zsh` as your shell —which I
  highly recommend. Here's the best way to install the latest version:
  1. Open Terminal.app (or whatever terminal you like to use) and use Homebrew (see above) to
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
1. [Fork this repo](fork).
1. Edit [`git/.gitconfig`](git/.gitconfig) in your fork so it has **your** name and email address,
   not mine!
1. Open Terminal.app (or whatever terminal you like to use) and back up your existing `~/.config/`
   folder (if any):
   ```shell
   mv -iv ~/.config/ ~/.config.old
   ```
1. [`git clone` your
   fork](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository)
   into your home folder. You will now have a new `~/.config/` folder.
1. Go into the new `~/.config` folder and run `make`:
   ```shell
   cd ~/.config/
   make
   ```
   This will…
    - back up your existing dotfiles (by appending `~` to their file names),
    - install new dotfiles, and
    - use Homebrew (see [Requirements](#requirements)) to install dependencies.
1. Merge anything you'd like to keep from your old dotfiles and `~/.config/` folder back into your
   new one.
1. _(optional)_ In Terminal.app, go to Preferences, import
   [`terminal/Dark Mode.terminal`](terminal/Dark%20Mode.terminal) and set it as the default.
1. Restart your terminal.

Finally, to get code ligatures in Safari, go to **Preferences > Advanced > Style sheet** and select
[browser/user.css](browser/user.css).

## Updating

To pull in new commits from my repo (a.k.a _upstream_) into yours, [follow this
guide](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/merging-an-upstream-repository-into-your-fork).

## Author
© 2020 [Marlon Richert](/marlonrichert)

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE)
file for details
