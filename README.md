# .config
Properly managed, easy-to-grok dotfiles for macOS and Ubuntu.

> Enjoy using this software? [Become a sponsor!](https://github.com/sponsors/marlonrichert)

![screenshot](screenshot.png)

## Installation
0.  Open a terminal, do one of the folowing, and wait for the installation to complete:
    * macOS:
      ```shell
      xcode-select --install
      ```
    * Ubuntu:
      ```shell
      sudo apt install zsh
      ```
1.  [Fork this repo](fork).
1.  ⚠️ In your fork, edit [`git/.gitconfig`](git/.gitconfig) (you can do this through GitHub's web
    UI) to make Git use _your_ name and email address, not mine! 🙂
1.  Open a terminal and do the following:
    ```shell
    % cd ~
    % mv .config .config~   # Back up your old .config dir (if any).
    % # Clone your fork, which will make a new .config dir:
    % git clone https://github.com/<YOUR USER NAME>/.config.git
    ...
    % cd .config            # Go to your new .config dir.
    📝 Add anything you want to keep from your old dotfiles.
    % make -j install       # Run the installer to deploy your new dotfiles.
    ...
    % # Finally, update your fork with your changes:
    % git add -f <file> ... # All files have to be staged explicitly.
    % git commit
    % git push
    ...
    %
    ```
1.  Restart your terminal.

## Getting Updates
To get new updates to your fork from my repo, do the following:
```zsh
% cd ~/.config
% make -jr              # Pull in updates from upstream (my repo), but don't install them yet.
...
📝 Review the incoming changes and make any adjustments you like.
% make -jr install      # Run the installer to deploy your changes.
...
% # Finally, update your fork with your changes:
% git add -f <file>...  # Choose which files you actually want to track in Git.
% git commit
% git push
...
%
```

## Author
© 2020-2021 [Marlon Richert](https://github.com/marlonrichert)

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
