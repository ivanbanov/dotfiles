export EDITOR=nvim

# brew
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/opt/homebrew/bin:$PATH"

# zsh
export ZSH="/Users/ivanbanov/.oh-my-zsh"
export TERM="xterm-256color"

plugins=(
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#727072"

# starship
eval "$(starship init zsh)"

# fzf
source <(fzf --zsh)
export FZF_DEFAULT_OPTS="
--color=fg:#e0e0e0,bg:#2d2a2e,hl:#61afef
--color=fg+:#ffffff,bg+:#3a3a3e,hl+:#61afef,hl+:bold
--color=marker:#ffd866
--marker='★'
--pointer='▶'
--prompt='❯ '
--layout=reverse
--preview-window=up:90%
--height 10
"

# nvm (brew keeps nvm.sh in its prefix — ~/.nvm is only nvm's working dir)
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && . "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# Claude
export CLAUDE_CODE_EXECUTABLE="$(which claude)"

# pnpm
export PNPM_HOME="/Users/ivanbanov/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "/Users/ivanbanov/.bun/_bun" ] && source "/Users/ivanbanov/.bun/_bun"

# aliases
alias back='cd "$OLDPWD"'

alias z="zed"
alias "z?"="fzf -m --height 100% --preview 'bat --style=numbers --color=always {}' --bind='enter:execute-silent(zed {+})+abort'"

alias zshrc="z ~/.zshrc"
alias gitconfig="z ~/.gitconfig"

alias dnk="cd ~/dev/dunky"
alias mds="cd ~/dev/miro/design-system"
alias mcl="cd ~/dev/miro/client"
alias mcl-e2e="cd ~/dev/miro/client/e2e-tests/client"
alias .mds="open https://github.com/miroapp-dev/design-system"
alias .mcl="open https://github.com/miroapp-dev/client"
alias e2e-test="yarn spectator test -b chromium -m headful --timeout 9999999" # -s path/to/test | -a ALLURE-ID
alias e2e-switch-local="yarn spectator switch -n local-release -i" # IP
alias e2e-switch-autotest="yarn spectator switch -n autotests-9 -c" # BUILD-ID
alias e2e-update="node scripts/design-system/e2e-tests/e2e-screenshots.js --buildId" # BUILD-ID

alias glog="git log --pretty=format:'%C(magenta)%h %C(yellow)%ad %C(cyan)%an%n%C(white)%s%n' --date=format:'%d/%m/%y %H:%M'"
alias gfreshmaster="git checkout -b freshmaster && git branch -D master && git checkout -t origin/master"
alias gch="git checkout"
alias gcm="git commit"
alias gbr="git branch"
alias gad="git add"
alias gft="git fetch"
alias gpl="git pull"
alias gps="git push"
alias gst="git status"
alias gdf="git diff"
alias grs="git reset"
alias groot='while [ "$PWD" != / ] && [ ! -d .git ]; do cd ..; done'
alias gstash="git stash clear && git add . && git stash"
alias gwip="git add . && git commit -m 'WIP' --no-verify"
alias greset1="git reset HEAD~1"
alias gempty="git commit -m 'empty' --allow-empty --no-verify"
alias gdebug="git commit -m 'debug'"
alias gamend="git commit --amend --no-verify -C HEAD"
alias gcurrent="git branch --show-current"
alias glockfile="git add pnpm-lock.yaml yarn.lock package-lock.json 2>/dev/null; git commit -m 'Update lockfile' --no-verify"
alias gbackup='branch=$(git branch --show-current); git branch -D "$branch-bkp" 2>/dev/null; git checkout -b "$branch-bkp" && git checkout $branch'
alias gfind='branch=$(git branch -a | sed "s#^[* ]*##" | fzf); git switch ${branch#remotes/*/}'
alias gti=git
alias got=git

fn_gsync() { git pull origin "${1:-$(git branch --show-current)}" }
alias gsync=fn_gsync

fn_grestore() { git checkout "origin/$1" -- "$2" }
alias grestore=fn_grestore

fn_pkgrun() {
if [[ -f "yarn.lock" ]]; then
    PKG_MANAGER="yarn"
  elif [[ -f "pnpm-lock.yaml" ]]; then
    PKG_MANAGER="pnpm"
  elif [[ -f "package-lock.json" ]]; then
    PKG_MANAGER="npm"
  else
    echo "No lockfile found. Defaulting to npm."
    PKG_MANAGER="npm"
  fi

  SCRIPT=$(jq -r '.scripts | to_entries[] | "\(.key): \(.value)"' package.json 2>/dev/null | fzf | cut -d: -f1)

  if [[ -n "$SCRIPT" ]]; then
    echo "Running '$SCRIPT' with $PKG_MANAGER..."
    $PKG_MANAGER run "$SCRIPT"
  fi
}
alias pkgrun=fn_pkgrun

# cleanup $PATH
typeset -U PATH

# start session
fastfetch
