#!/bin/bash

# Check which skill folders each coding agent actually reads.
#
# Plants one canary skill in every candidate folder at once, each named after
# its folder, then asks every installed agent which canaries it can see. A
# reported canary maps back to exactly one folder. The canaries, and any folder
# made to hold one, are removed on exit; the agents' answers are kept as logs.
#
# Each agent runs from an empty temporary directory, so project-level skills
# don't count, and makes one model call on the account it is signed in with.

set -euo pipefail

usage() {
  cat <<USAGE
Usage: scripts/agent-skill-paths.sh [--dry-run] [--trace] [--timeout <seconds>] [agent...]

  --dry-run    plant and remove the canaries without running any agent
  --trace      also watch the folders with inotify while each agent starts, and
               report the canaries it opened; works for agents that are not
               signed in, since they scan their skill folders before asking
  --timeout    seconds to wait for each agent (default 240)
  --model      model to ask, for an agent whose default needs a plan the
               account lacks; honoured by pi, kilo and codex
  agent...     only check these agents, named as in omarchy default agent
USAGE
}

dry_run=0
trace=0
timeout_seconds=240
model=""
only=()

while (( $# > 0 )); do
  case $1 in
    --dry-run) dry_run=1 ;;
    --trace) trace=1 ;;
    --timeout) timeout_seconds=$2; shift ;;
    --model) model=$2; shift ;;
    -h | --help) usage; exit 0 ;;
    -*) usage >&2; exit 1 ;;
    *) only+=("$1") ;;
  esac
  shift
done

config_home=${XDG_CONFIG_HOME:-$HOME/.config}

# Every folder some agent is said to read, from the npx skills agent list, the
# agents' own docs, and a few guesses for agents with no documented folder.
# The slug before "=" names the canary planted there.
folders=(
  "agents=$HOME/.agents/skills"
  "config-agents=$config_home/agents/skills"
  "claude=${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"
  "codex=${CODEX_HOME:-$HOME/.codex}/skills"
  "pi=${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}/skills"
  "omp=$HOME/.omp/agent/skills"
  "hermes=${HERMES_HOME:-$HOME/.hermes}/skills"
  "gemini-config=$HOME/.gemini/config/skills"
  "gemini-agy-cli=$HOME/.gemini/antigravity-cli/skills"
  "gemini-antigravity=$HOME/.gemini/antigravity/skills"
  "gemini=$HOME/.gemini/skills"
  "grok=${GROK_HOME:-$HOME/.grok}/skills"
  "copilot=$HOME/.copilot/skills"
  "cursor=$HOME/.cursor/skills"
  "opencode=$config_home/opencode/skills"
  "crush=$config_home/crush/skills"
  "kilo=$HOME/.kilo/skills"
  "qwen=$HOME/.qwen/skills"
  "minimax=$HOME/.minimax/skills"
  "kiro=$HOME/.kiro/skills"
  "devin=$config_home/devin/skills"
  "commandcode=$HOME/.commandcode/skills"
  "openclaw=$HOME/.openclaw/skills"
  "kimi=$HOME/.kimi/skills"
  "kimi-code=$HOME/.kimi-code/skills"
  "muse=$HOME/.muse/skills"
  "ori=$HOME/.ori/skills"
  "freebuff=$HOME/.freebuff/skills"
)

# The agents omarchy-default-agent offers; each name is also its command.
agents=(
  pi omp opencode ori claude codex crush grok openclaw agy hermes copilot
  muse cursor-agent kimi qwen dsh mcode kiro-cli freebuff kilo devin amp
  commandcode
)

prompt='Do not run any tools or commands. Look only at the skills available to you right now. Print the name of every skill whose name starts with "canary-", one per line, and nothing else. If there are none, print NONE.'

# How to ask each agent one question without opening a session. Agents that
# can list their loaded skills are asked that way, since it needs no model
# call or login. Every line here has been run; an agent that is not signed in
# stops with its own login message, which still shows the line is right.
ask() {
  local agent=$1

  case $agent in
    # These list their loaded skills without a model call or a login.
    hermes | muse | commandcode | devin | amp) "$agent" skills list ;;
    copilot | omp) "$agent" skill list ;;
    codex) codex exec --skip-git-repo-check --sandbox read-only --ephemeral ${model:+-m "$model"} "$prompt" ;;
    pi) pi ${model:+--model "$model"} -p "$prompt" ;;
    kilo) kilo run ${model:+-m "$model"} "$prompt" ;;
    opencode | crush) "$agent" run "$prompt" ;;
    kiro-cli) kiro-cli chat --no-interactive "$prompt" ;;
    # Refuses to run non-interactively in a directory not marked trusted;
    # the directory is an empty temporary one.
    cursor-agent) cursor-agent --trust -p "$prompt" ;;
    openclaw) openclaw agent --message "$prompt" ;;
    # No one-off mode: started under a pseudo-terminal so --trace can watch
    # what its interactive session opens; it never prints an answer.
    freebuff) script -qec freebuff /dev/null ;;
    *) "$agent" -p "$prompt" ;;
  esac
}

# mise puts a shim on the path for every agent Omarchy offers, installed or
# not, and omarchy-mise-install a wrapper that installs the tool on first
# run, so neither counts until mise can resolve the tool: running the wrapper
# here would install agents the user never asked for. Same rule as
# omarchy-agent-skills-link.
agent_installed() {
  local path

  path=$(type -P -- "$1") || return 1
  if [[ $(readlink -f -- "$path") == */mise ]] || grep -qaE 'mise (use|x) ' < <(head -c 4096 -- "$path" 2>/dev/null); then
    mise which "$1" >/dev/null 2>&1
  else
    return 0
  fi
}

pretty() {
  printf '%s\n' "${1/#$HOME/\~}"
}

planted=()
created_dirs=()

cleanup() {
  local skill i

  for skill in "${planted[@]}"; do
    if [[ -f $skill/.omarchy-canary ]]; then
      rm -rf -- "$skill"
    fi
  done

  for (( i = ${#created_dirs[@]} - 1; i >= 0; i-- )); do
    rmdir -- "${created_dirs[i]}" 2>/dev/null || true
  done
}

trap cleanup EXIT

# Creates a folder and remembers each level that did not exist, so cleanup
# removes exactly those.
make_dir() {
  local dir=$1 missing=()

  while [[ ! -d $dir ]]; do
    missing=("$dir" "${missing[@]}")
    dir=$(dirname "$dir")
  done

  for dir in "${missing[@]}"; do
    mkdir -- "$dir"
    created_dirs+=("$dir")
  done
}

declare -A folder_of=() first_slug_for=()
slugs=()

for entry in "${folders[@]}"; do
  slug=${entry%%=*}
  dir=${entry#*=}
  folder_of[$slug]=$dir

  # A folder that is a link to another one, like ~/.claude/skills pointing at
  # ~/.agents/skills, is the same folder: plant once and say so.
  if [[ -d $dir ]]; then
    real=$(readlink -f "$dir")
    if [[ -n ${first_slug_for[$real]:-} ]]; then
      echo "$(pretty "$dir") is the same folder as $(pretty "${folder_of[${first_slug_for[$real]}]}"); not planted twice"
      continue
    fi
    first_slug_for[$real]=$slug
  fi

  skill="$dir/canary-$slug"
  if [[ -e $skill ]]; then
    echo "Error: $(pretty "$skill") already exists; remove it and rerun." >&2
    exit 1
  fi

  make_dir "$dir"
  mkdir -- "$skill"
  planted+=("$skill")
  touch "$skill/.omarchy-canary"
  cat >"$skill/SKILL.md" <<SKILL
---
name: canary-$slug
description: Test skill planted by Omarchy's skill-path check in $(pretty "$dir"). It does nothing; never use it.
---

This skill exists only to show which folders an agent reads.
SKILL
  slugs+=("$slug")
done

echo "Planted ${#slugs[@]} canaries, created ${#created_dirs[@]} folders to hold them."

if (( dry_run )); then
  for slug in "${slugs[@]}"; do
    echo "  canary-$slug in $(pretty "${folder_of[$slug]}")"
  done
  exit 0
fi

if (( ${#only[@]} > 0 )); then
  agents=("${only[@]}")
fi

workdir=$(mktemp -d)
logdir=$(mktemp -d "${TMPDIR:-/tmp}/agent-skill-paths.XXXXXX")
export prompt model
export -f ask

# Runs one agent with stdin closed, from an empty directory, so project skills
# don't count. CLAUDECODE is unset so the check also works from inside a Claude
# Code session. Leaves the exit status in $status.
run_agent() {
  status=0
  (cd "$workdir" && env -u CLAUDECODE timeout "$timeout_seconds" bash -c 'ask "$1"' _ "$1") \
    >"$log" 2>&1 </dev/null || status=$?
}

# Canary names found in a file, one per line. Whole names only: canary-gemini
# must not count as seen inside canary-gemini-config.
canaries_in() {
  grep -oE 'canary-[a-z0-9-]+' "$1" | sort -u || true
}

# Watches every planted folder while one agent runs (or, with no agent, for a
# few seconds of background noise) and leaves the canaries that were opened in
# $opened. Not called in a subshell, so $status from run_agent survives too.
# inotify reports opens, not stats, so a hit means the folder was really read.
trace_opens() {
  local agent=$1 events=$2 pid i

  inotifywait -m -r -e open --format '%w%f' "${watch_dirs[@]}" >"$events" 2>"$events.err" &
  pid=$!
  for (( i = 0; i < 100; i++ )); do
    grep -q "Watches established" "$events.err" 2>/dev/null && break
    sleep 0.1
  done

  if [[ -n $agent ]]; then
    run_agent "$agent"
  else
    sleep 4
  fi
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
  opened=$(canaries_in "$events")
}

folders_for() {
  local slug found
  for slug in "${slugs[@]}"; do
    if grep -qx -- "canary-$slug" <<<"$1"; then
      found=$(pretty "${folder_of[$slug]}")
      if [[ -n ${2:-} ]] && grep -qx -- "canary-$slug" <<<"$2"; then
        found+=" (also opened with no agent running)"
      fi
      printf '%s, ' "$found"
    fi
  done
}

noise=""
if (( trace )); then
  if ! command -v inotifywait >/dev/null; then
    echo "Error: --trace needs inotifywait (package inotify-tools)." >&2
    exit 1
  fi
  watch_dirs=()
  for slug in "${slugs[@]}"; do
    watch_dirs+=("${folder_of[$slug]}")
  done
  trace_opens "" "$logdir/background.events"
  noise=$opened
  joined=$(folders_for "$noise")
  joined=${joined%, }
  echo "With no agent running, something else opened: ${joined:-nothing}"
fi

echo
for agent in "${agents[@]}"; do
  if ! agent_installed "$agent"; then
    printf '%-14s not installed\n' "$agent"
    continue
  fi

  log="$logdir/$agent.log"
  if (( trace )); then
    trace_opens "$agent" "$logdir/$agent.events"
  else
    run_agent "$agent"
  fi
  answered=$(folders_for "$(canaries_in "$log")")

  if (( trace )); then
    found=$(folders_for "$opened" "$noise")
    if [[ -n $found ]]; then
      printf '%-14s opened %s' "$agent" "${found%, }"
      [[ -n $answered ]] && printf '; answered %s' "${answered%, }"
      echo
    else
      printf '%-14s opened nothing before it stopped (exit %d), see %s\n' "$agent" "$status" "$log"
    fi
  elif [[ -n $answered ]]; then
    printf '%-14s reads %s\n' "$agent" "${answered%, }"
  elif (( status != 0 )); then
    printf '%-14s error (exit %d), see %s\n' "$agent" "$status" "$log"
  else
    printf '%-14s reported no canaries, see %s\n' "$agent" "$log"
  fi
done

echo
echo "Answers kept in $logdir"
# Some agents leave session files behind (Crush writes .crush/), so not rmdir.
rm -rf -- "$workdir"
