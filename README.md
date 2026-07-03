# dotfiles

Personal macOS dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## New machine setup

```sh
git clone <this-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

`install.sh` installs Homebrew, runs `brew bundle` (see `Brewfile`), installs
oh-my-zsh + plugins + tmux's TPM, scaffolds `~/.config/secrets.env`, and stows
every package. It is idempotent — safe to re-run.

Then:

1. Fill in `~/.config/secrets.env` with your real tokens (see `secrets/.config/secrets.env.example`).
2. Set the WakaTime API key in `~/.config/zed/settings.json` (`waka_REPLACE_ME`).
3. `exec zsh` to reload.

## How Stow works here

Each top-level directory is a **package**. Its inner layout mirrors `$HOME`.
`stow <package>` creates symlinks from `$HOME` into this repo.

```
zsh/         -> ~/.zshrc
git/         -> ~/.gitconfig, ~/.gitignore_global
tmux/        -> ~/.tmux.conf, ~/.config/tmux/tmux.conf
hammerspoon/ -> ~/.hammerspoon/init.lua
config/      -> ~/.config/{nvim,ghostty,kitty,bat,htop,fastfetch,zed,starship.toml}
secrets/     -> template only (real secrets.env is git-ignored, never stowed)
```

### Common commands

```sh
stow zsh            # link one package
stow */             # link all packages
stow -R zsh         # restow (re-link after changes)
stow -D zsh         # unstow (remove links)
stow -n -v zsh      # dry run, verbose (preview, no changes)
```

If Stow reports a conflict, an existing real file is in the way. Back it up and
remove it, then re-run. `stow --adopt <pkg>` pulls the existing file into the
repo instead (review with `git diff` afterwards).

## Secrets

No live secrets are committed. `~/.config/secrets.env` (git-ignored) is sourced
by `.zshrc` and holds `GITHUB_TOKEN`, `SLACK_TOKEN`, etc. `.npmrc` and `~/.ssh`
are **not** in this repo — restore those manually or from a secure backup, and
rotate any token that was ever committed anywhere.

## Updating the Brewfile

```sh
brew bundle dump --file=~/dotfiles/Brewfile --force --describe
```
