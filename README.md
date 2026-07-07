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
- 📦 Installs packages
- 🐚 Installs oh-my-zsh + plugins
- 🤖 Installs Claude Code
- 🔗 Stows every package
- 🍎 Applies macOS defaults
- 🎛️ Imports apps preferences
- 🔁 Reloads zsh

> Some keyboard/trackpad settings (three-finger drag, tap-to-click, key repeat)
> only take effect after a **logout/login**. To also empty the Dock on a fresh
> Mac, run `CLEAR_DOCK=1 ./install.sh`.

### Manual steps

A few settings can't be scripted and must be set once by hand:

- **Accessibility permissions** — Hammerspoon and Rectangle do nothing until
  approved under System Settings → Privacy & Security → Accessibility (Handy
  also needs Microphone). Each app prompts on first launch; TCC grants can't be
  scripted.
- **Control+scroll to zoom** — System Settings → Accessibility → Zoom → enable
  **"Use scroll gesture with modifier keys to zoom"** (modifier: Control). Not
  scriptable: its `com.apple.universalaccess` domain is TCC-protected and only
  writable by a process with Full Disk Access.
- **Spotlight hotkey** — the script tries to disable Spotlight's Cmd+Space, but
  the `com.apple.symbolichotkeys` write is flaky (needs a logout/login and
  `cfprefsd` can revert it). If Cmd+Space still opens Spotlight, turn it off by
  hand: System Settings → Keyboard → Keyboard Shortcuts → Spotlight.
- **Raycast hotkey** — set to Cmd+Space in Raycast → Settings (after Spotlight's
  is freed).

## Apps

- 🚀 `raycast` — launcher (Option+Space)
- ✍️ `zed` — editor
- 🐙 `gh` — GitHub CLI
- 🔍 `fzf` — fuzzy finder
- 🤖 `claude` — Claude Code CLI
- 🍺 [more in the `Brewfile`](Brewfile)

## Stow

Each dir in this repo except `appdefaults/` (imported by `appdefaults.sh`, not stowed) is a package that [`stow`](https://www.gnu.org/software/stow/manual/stow.html) symlinks into `$HOME`. A package's inner layout mirrors `$HOME`, so its contents show where the links land (e.g. `config/.config/…` → `~/.config/…`).

### Commands

```sh
stow zsh [...package]                 # link packages
stow -R zsh                           # restow (re-link after changes)
stow -D zsh                           # unstow (remove links)
stow -n -v zsh                        # dry run, verbose (preview, no changes)
```

If Stow reports a conflict, an existing real file is in the way. Back it up and
remove it, then re-run. `stow --adopt <pkg>` pulls the existing file into the
repo instead (review with `git diff` afterwards).

## Secrets

`home/` holds `.npmrc` and `.ssh/config` as empty templates, flagged
`git update-index --skip-worktree`: fill in real secrets locally and git ignores
the changes, so they can't be committed. `install.sh` re-applies the flag per
machine (it's local-only). To edit the template: `git update-index --no-skip-worktree <file>`.
