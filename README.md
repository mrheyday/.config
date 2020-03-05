# .config

Clean, simple, fast & powerful configuration (dotfiles) for SSH, Git, Zsh and Karabiner on macOS


### Requirements

* These dotfiles were written for **macOS**. If you are using some other (Unix-based) OS, they will need some editing before you can use them.
* You need to have **[Homebrew](https://brew.sh)** installed.
* You need to be running `zsh` as your shell. Here's the best way how to do that:
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
     (Or if the first line above does not exist, just add the second line above to the end of the file.)
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
