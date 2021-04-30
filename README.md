# .config
Dotfiles for Zsh, Git, SSH, Terminal.app and Karabiner-Elements on macOS.

![screenshot](screenshot.png)

Table of Contents:
* [Requirements](#requirements)
* [Installation](#installation)
* [Updates](#updates)
* [Author](#author)
* [License](#license)

## Requirements
These dotfiles were written for **macOS**. With some minor modifications, they might be usable on
another Unix-based OS, but I have not tested them on anything else than macOS.

## Installation
1.  [Fork this repo](fork).
1.  ⚠️ Edit [`git/.gitconfig`](git/.gitconfig) in your fork (you can do this through GitHub's web
    UI) to use **your** name and email address, not mine!
1.  Open a terminal and do the following:
    ```shell
    % cd ~                    # Go to your home dir.
    % mv -iv .config .config~ # Back up your old .config dir (if any).
    ...
    % # Clone your fork, which will make a new .config dir:
    % git clone https://github.com/<YOUR USER NAME>/.config.git
    ...
    % cd .config              # Go to your new .config dir.
    % # 📝 Add anything you want to keep from your old dotfiles.
    % make clean install      # Run the installer to deploy your new dotfiles.
    ...
    % # Finally, once you're happy with the result:
    % git add .
    % git commit
    ...
    % # After running `make`, your clone will push to YOUR fork, not mine. 🙂
    % git push
    ...
    ```
1.  _(optional)_ In Terminal.app, go to Preferences, import
    [`terminal/Dark Mode.terminal`](terminal/Dark%20Mode.terminal) and set it as the default.
1.  Restart your terminal.

## Getting Updates
To get new updates to your fork from my repo, do the following:
```zsh
% cd ~/.config
% make          # Pull in updates, but don't install them yet.
...
# Review the incoming changes and make any adjustments you like.
% make install  # Run the installer to deploy your changes.
...
% # Finally, once you're happy with the result:
% git add .
% git commit
...
% # After running `make`, your clone will push to YOUR fork, not mine. 🙂
% git push
...
```

## Author
© 2020-2021 [Marlon Richert](https://github.com/marlonrichert)

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
