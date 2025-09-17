# ===============================
# Fish-like Bash Prompt
# ===============================

# --- Colors ---
RESET="\[\e[0m\]"
BOLD="\[\e[1m\]"
CYAN="\[\e[36m\]"
GREEN="\[\e[32m\]"
YELLOW="\[\e[33m\]"
BLUE="\[\e[34m\]"
MAGENTA="\[\e[35m\]"
RED="\[\e[31m\]"

# --- Git branch function ---
# Shows the current Git branch:
# - Magenta if clean
# - Red if there are uncommitted changes
parse_git_branch() {
  branch=$(git branch --show-current 2>/dev/null)
  if [ -n "$branch" ]; then
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
      echo " ${RED}${branch}${RESET}"
    else
      echo " ${MAGENTA}${branch}${RESET}"
    fi
  fi
}

# --- Timer ---
# Records the start time of a command
timer_start() {
  export CMD_START=$SECONDS
}

# --- Prompt builder ---
# Builds PS1 dynamically:
# - Colors username, host, directory
# - Appends git branch
# - Shows command duration if >1s
# - Arrow is yellow on success, red on failure
set_prompt() {
  local EXIT="$?"

  # --- Compute duration ---
  local DURATION=""
  if [ -n "$CMD_START" ]; then
    local ELAPSED=$((SECONDS - CMD_START))
    if [ $ELAPSED -gt 1 ]; then
      # Pretty format: convert to m/s
      if [ $ELAPSED -ge 60 ]; then
        local MIN=$((ELAPSED / 60))
        local SEC=$((ELAPSED % 60))
        DURATION=" (${MIN}m ${SEC}s)"
      else
        DURATION=" (${ELAPSED}s)"
      fi
    fi
  fi

  # --- Arrow color based on exit code ---
  if [ $EXIT -eq 0 ]; then
    local ARROW="${YELLOW}❯${RESET}"
  else
    local ARROW="${RED}❯${RESET}"
  fi

  # --- Final prompt ---
  PS1="${GREEN}\u${RESET}@${CYAN}\h ${BOLD}${BLUE}\w${RESET}\$(parse_git_branch)${DURATION}\n${ARROW} "
}

# --- Hooks ---
# Run timer before each command
trap 'timer_start' DEBUG
# Build prompt before showing it
PROMPT_COMMAND=set_prompt

# ===============================
# Optional: Command syntax highlighting
# ===============================
# Clone this once:
#   git clone https://github.com/jackharrisonsherlock/common.git ~/.bash-syntax-highlighting
# Then enable:
if [ -f ~/.bash-syntax-highlighting/syntax-highlighting.sh ]; then
  source ~/.bash-syntax-highlighting/syntax-highlighting.sh
fi

# ===============================
# Enable colored output in core utils
# ===============================
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
