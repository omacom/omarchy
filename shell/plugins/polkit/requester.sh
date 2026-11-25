#!/bin/bash

# Prints the mark of the coding agent a pkexec prompt comes from (claude,
# codex, ...), as the agents plugin names its icons, or nothing. polkit knows
# which process asked, but Quickshell doesn't pass that on, so this finds this
# user's pkexec that runs the command line the prompt shows, and walks up from
# it to the first agent. That names a process and proves nothing: any program
# can call itself claude.
#
# Usage: requester.sh "<the command line between the quotes in the prompt>"

proc_root=${OMARCHY_PROC_ROOT:-/proc}
shown=$1
uid=$(id -u)

# The names agents run under, and the mark each one has.
declare -A marks=(
  [claude]=claude
  [codex]=codex
  [grok]=grok
  [opencode]=opencode
  [cursor-agent]=cursor
  [copilot]=copilot
)

# pkexec's prompt shows the program by its full path, and the command line cut
# to its first 38 and last 37 bytes when it is longer than 80.
prompt_line() {
  local LC_ALL=C line=$1
  if (( ${#line} > 80 )); then
    line="${line:0:38} ... ${line: -37}"
  fi
  printf '%s' "$line"
}

# Whether a pkexec process runs the command line its prompt shows. The prompt
# names the program by the full path pkexec found it at, through the PATH and
# folder of whoever ran it, which this can't see when it was given by name:
# then only the end of the line can be compared, the program's own name and
# the arguments after it, as far as the last 37 bytes a long line keeps.
runs_shown() {
  local -a argv
  local i=1 program arg rest=""
  mapfile -d '' -t argv <"$proc_root/$1/cmdline" 2>/dev/null || return 1
  while (( i < ${#argv[@]} )); do
    case ${argv[i]} in
      --user | -u) (( i += 2 )) ;;
      --*) (( i += 1 )) ;;
      *) break ;;
    esac
  done
  (( i < ${#argv[@]} )) || return 1
  program=${argv[i]}
  for arg in "${argv[@]:i+1}"; do
    rest+=" $arg"
  done
  if [[ $program == /* ]]; then
    [[ $(prompt_line "$program$rest") == "$shown" ]]
  else
    ends_with "/${program#./}$rest"
  fi
}

ends_with() {
  local LC_ALL=C tail=$1
  (( ${#tail} > 37 )) && tail=${tail: -37}
  [[ $shown == *"$tail" ]]
}

real_uid() {
  local key real _
  while read -r key real _; do
    [[ $key == Uid: ]] && { printf '%s' "$real"; return 0; }
  done <"$proc_root/$1/status" 2>/dev/null
  return 1
}

parent() {
  local stat ppid _
  { IFS= read -r stat <"$proc_root/$1/stat"; } 2>/dev/null || return 1
  # The name in parentheses can hold spaces and parentheses of its own; the
  # state comes after it, then the parent.
  read -r _ ppid _ <<<"${stat##*) }"
  [[ $ppid =~ ^[0-9]+$ ]] && printf '%s' "$ppid"
}

# The first agent among the parents of a pkexec. An agent run by an
# interpreter goes by the interpreter's name, so the environment pkexec was
# started from is asked as well: Claude Code sets CLAUDECODE and AI_AGENT.
agent_of() {
  local pid=$1 first comm hops=0 name
  first=$(parent "$pid") || return 1
  pid=$first
  while (( pid > 1 && hops++ < 64 )); do
    { IFS= read -r comm <"$proc_root/$pid/comm"; } 2>/dev/null || break
    if [[ -n $comm && -n ${marks[$comm]-} ]]; then
      printf '%s' "${marks[$comm]}"
      return 0
    fi
    pid=$(parent "$pid") || break
  done
  while IFS= read -r -d '' name; do
    case $name in
      CLAUDECODE=1 | AI_AGENT=claude-code*)
        printf claude
        return 0
        ;;
    esac
  done <"$proc_root/$first/environ" 2>/dev/null
  return 1
}

shopt -s nullglob
comm_files=("$proc_root"/[0-9]*/comm)
(( ${#comm_files[@]} > 0 )) || exit 0

matching=()
while IFS= read -r file; do
  pid=${file#"$proc_root"/}
  pid=${pid%/comm}
  [[ $(real_uid "$pid") == "$uid" ]] || continue
  runs_shown "$pid" && matching+=("$pid")
done < <(grep -lx pkexec "${comm_files[@]}" 2>/dev/null)

# Two waiting with this command line can't be told apart, so an agent is only
# named when they come from the same one.
declare -A found=()
for pid in "${matching[@]}"; do
  found["$(agent_of "$pid")."]=1
done
if (( ${#found[@]} == 1 )); then
  mark=${!found[*]}
  mark=${mark%.}
  [[ -n $mark ]] && printf '%s\n' "$mark"
fi
exit 0
