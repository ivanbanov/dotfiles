#!/bin/bash
# Status line mirroring ~/.config/starship.toml (directory, git_branch, time),
# plus model, reasoning effort, context usage (with ASCII bar), git dirty
# state, session cost, and output style appended.

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
style=$(echo "$input" | jq -r '.output_style.name // empty')

# directory: full path (truncate_to_repo=false, truncation_length=999), home -> 🏡
if [[ "$cwd" == "$HOME"* ]]; then
  dir_display="🏡${cwd#$HOME}"
else
  dir_display="$cwd"
fi

# git_branch: "[👻 $branch ]" — skip optional locks, only shown inside a repo.
# dirty: any uncommitted changes get a trailing marker.
branch=""
dirty=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
  if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
    dirty="*"
  fi
fi

# time: 12-hour clock, e.g. 03:45PM
time_display=$(date "+%I:%M%p")

# context bar: 10-cell ASCII bar, e.g. [###.......] 47%
ctx_bar=""
if [ -n "$used_pct" ]; then
  used_pct_int=$(printf '%.0f' "$used_pct")
  bar_len=10
  filled=$(( used_pct_int * bar_len / 100 ))
  [ "$filled" -gt "$bar_len" ] && filled="$bar_len"
  empty=$(( bar_len - filled ))
  bar="$(printf '%*s' "$filled" '' | tr ' ' '#')$(printf '%*s' "$empty" '' | tr ' ' '.')"
  ctx_bar="[${bar}] ${used_pct_int}%"
fi

# session cost: only shown when present and greater than zero
cost_display=""
if [ -n "$cost" ]; then
  nonzero=$(awk -v c="$cost" 'BEGIN { print (c + 0 > 0) ? 1 : 0 }')
  if [ "$nonzero" = "1" ]; then
    cost_display=$(awk -v c="$cost" 'BEGIN { printf "$%.2f", c }')
  fi
fi

RESET="\033[0m"
DIR_COLOR="\033[36m"
BRANCH_COLOR="\033[92m"
DIRTY_COLOR="\033[91m"
TIME_COLOR="\033[90m"
MODEL_COLOR="\033[35m"
EFFORT_COLOR="\033[33m"
CTX_COLOR="\033[34m"
COST_COLOR="\033[32m"
STYLE_COLOR="\033[37m"

# Line 1: non-Claude data — directory, git branch/dirty, time
line1="${DIR_COLOR}${dir_display}${RESET}"

if [ -n "$branch" ]; then
  branch_str="${BRANCH_COLOR}👻 ${branch}${RESET}"
  if [ -n "$dirty" ]; then
    branch_str="${branch_str} ${DIRTY_COLOR}${dirty}${RESET}"
  fi
  line1="${line1} ${branch_str}"
fi

line1="${line1} ${TIME_COLOR}${time_display}${RESET}"

# Line 2: Claude data — model, effort, context usage, cost, output style
line2=""

if [ -n "$model" ]; then
  line2="${line2}${MODEL_COLOR}${model}${RESET}"
fi

if [ -n "$effort" ]; then
  line2="${line2} ${EFFORT_COLOR}${effort} effort${RESET}"
fi

if [ -n "$ctx_bar" ]; then
  line2="${line2} ${CTX_COLOR}${ctx_bar}${RESET}"
fi

if [ -n "$cost_display" ]; then
  line2="${line2} ${COST_COLOR}${cost_display}${RESET}"
fi

if [ -n "$style" ]; then
  line2="${line2} ${STYLE_COLOR}${style}${RESET}"
fi

# strip a leading space in case model was empty
line2="${line2# }"

printf "%b\n%b" "$line1" "$line2"
