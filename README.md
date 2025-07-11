# dotfiles

My dotfiles for Linux (Debian).

## Bootstrap

bootstrap.sh is an all-in-one script to download some initial tools (brew, age, chezmoi) and initialize chezmoi with this repository.

```
sudo apt upate && sudo apt install curl -y
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Useekaw/dotfiles/HEAD/bootstrap.sh)"
```

## Sources

<https://github.com/Allaman/dots/> Lots of configs of mine are based on the ones found in this repository.
