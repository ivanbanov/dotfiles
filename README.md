```
      _       _    __ _ _
   __| | ___ | |_ / _(_) | ___  ___
  / _` |/ _ \| __| |_| | |/ _ \/ __|
 | (_| | (_) | |_|  _| | |  __/\__ \
  \__,_|\___/ \__|_| |_|_|\___||___/
```

macOS dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Setup

**1. Command Line Tools** (provides `git` — required before the clone).
Recommended: download **"Command Line Tools for Xcode"** from
<https://developer.apple.com/download> and run the `.dmg`. This is the most
reliable on a fresh Mac. (The shortcut `xcode-select --install` also works but
its dialog is flaky.) Verify with `git --version` before continuing.

If `git` stalls on the license agreement, accept it once:

```sh
sudo xcodebuild -license accept
```

**2. Clone and run.**

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

Each dir in this repo is a package that [`stow`](https://www.gnu.org/software/stow/manual/stow.html) symlinks into `$HOME`. A package's inner layout mirrors `$HOME`, so its contents show where the links land (e.g. `config/.config/…` → `~/.config/…`).

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
