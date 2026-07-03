# dotfiles

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Setup

```sh
git clone https://github.com/ivanbanov/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

What `install.sh` does:

- 🍺 Installs Homebrew
- 📦 Install packages
- 🐚 Installs oh-my-zsh + plugins
- 🔗 Stows every package
- 🍎 Applies macOS defaults
- 🔁 Reloads zsh

## Apps

- 🚀 `raycast` — launcher (Option+Space)
- ✍️ `zed` — editor
- 🐙 `gh` — GitHub CLI
- 🔍 `fzf` — fuzzy finder
- 🤖 `claude` — Claude Code CLI
- 🍺 [more in the `Brewfile`](Brewfile)

## Stow

Each dir in this repo is a package that [`stow`](https://www.gnu.org/software/stow/manual/stow.html) symlinks into `$HOME`.

```
zsh/         -> ~/.zshrc
git/         -> ~/.gitconfig, ~/.gitignore_global
hammerspoon/ -> ~/.hammerspoon/init.lua
config/      -> ~/.config/{package}
```

### Commands

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

`home/` holds `.npmrc` and `.ssh/config` as empty templates, flagged
`git update-index --skip-worktree`: fill in real secrets locally and git ignores
the changes, so they can't be committed. `install.sh` re-applies the flag per
machine (it's local-only). To edit the template: `git update-index --no-skip-worktree <file>`.
