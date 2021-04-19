# .config

Dotfiles for Zsh, Git, SSH, Terminal.app, Karabiner-Elements and my web browser on macOS

![screenshot](screenshot.png)

Table of Contents:
* [Requirements](#requirements)
* [Installation](#installation)
* [Updates](#updates)
* [Author](#author)
* [License](#license)

## Requirements
* These dotfiles were written for **macOS**. If you are using some other (Unix-based) OS, they
  will likely need some editing before you can use them. I have not tested them on anything else
  than macOS.
* You need to have **[Homebrew](https://brew.sh)** installed, which is available for both macOS and
  Linux. (Or you need to modify the `homebrew` target in the [makefile](makefile) to use another
  package manager of  your choosing.)
* To benefit from the Zsh config included, you obviously need to be running `zsh` as your shell
  —which I highly recommend anyway. Here's the best way to install the latest version:
  1.  Open a terminal (I use macOS's Terminal.app) and use Homebrew (see above) to install the
      latest version of the Z Shell:
      ```shell
      brew install zsh
      ```
  1.  Change your shell to `zsh`:
      ```shell
      chsh -s /usr/local/bin/zsh
      ```
  1.  Restart your terminal.

## Installation
1.  [Fork this repo](fork).
1.  Edit [`git/.gitconfig`](git/.gitconfig) in your fork so it has **your** name and email address,
    not mine!
1.  Open a terminal and do the following:
  ```shell
  # Go to your home dir:
  % cd ~

  # Back up your old .config dir (if any):
  % mv -iv .config .config~

  # Clone your fork, which will make a new .config dir:
  % git clone https://github.com/<your user name>/.config.git

  # Go to your new .config dir:
  % cd .config

  # Run the installer:
  % make
  # Your old dotfiles will be backed up by appending `~` to their filenames.

  # Merge anything you'd like to keep from your old dotfiles back into your new ones.

  # Finally, once you're happy with the result:
  % git add .
  % git commit
  % git push  # After running `make`, this will automatically push to _your_ fork, not mine.
  ```
1.  _(optional)_ In Terminal.app, go to Preferences, import
    [`terminal/Dark Mode.terminal`](terminal/Dark%20Mode.terminal) and set it as the default.
1.  Restart your terminal.

## Getting Updates
Simply do
```zsh
% cd ~/.config
% make
```

## Author
© 2020 [Marlon Richert](https://github.com/marlonrichert)

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
