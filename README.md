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
  Linux. (Or you need to modify the `brew` target in the
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
1. [Fork this repo](/marlonrichert/.config/fork).
1. Edit the [.gitconfig](/marlonrichert/.config/blob/master/git/.gitconfig) file in your fork so it
   has **your** name and email address, not mine!
1. Open Terminal.app (or whatever terminal you like to use) and back up your existing `~/.config/`
   folder (if any):
   ```shell
   mv -iv ~/.config/ ~/.config\~
   ```
1. [Git clone your fork](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository)
   into your home folder. You will now have a new `~/.config/` folder.
1. Go into the new `~/.config` folder and run `make`:
   ```shell
   cd ~/.config/
   make
   ```
   This will…
    - back up your existing config files,
    - install new config files, and
    - use Homebrew (see [Requirements](#requirements)) to install dependencies.
1. Merge anything you'd like to keep from your old config files back into your new ones.
1. _(optional)_ In Terminal.app, go to Preferences and import the
   [Dark Mode theme](/marlonrichert/.config/terminal/Dark%20Mode.terminal) and set it as the
   default.
1. Restart your terminal.

## Author
© 2020 [Marlon Richert](/marlonrichert)

## License
This project is licensed under the MIT License - see the [LICENSE](/marlonrichert/.config/LICENSE)
file for details
