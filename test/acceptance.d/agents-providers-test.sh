#!/bin/bash

# Snapshot and restore for the provider-switch acceptance run. Sourcing this
# file defines the cleanup and does not drive the session; executing it does.

# The lock stays beside usage/, not inside a captured or replaced tree.
# Gate acquisition errors are refusals. Do not delete or replace this inode.
agents_provider_gate_helper="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)/lib/omarchy_agent_usage_gate.py"

agents_provider_gate_acquire() {
  local dir="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/agents"
  local bound=${AGENTS_PROVIDER_COLLECTOR_WAIT:-90} reply
  if ! mkdir -p "$dir"; then
    return 1
  fi
  if ! exec {agents_provider_gate_fd}<>"$dir/.usage-restore.lock"; then
    return 1
  fi
  # A persistent actual lock owner makes blocked waiters observable in the
  # current PID namespace. Its stdin pipe controls lifetime, not a flag.
  coproc agents_provider_gate_owner {
    command python3 "$agents_provider_gate_helper" --hold "$agents_provider_gate_fd" "$bound"
  }
  agents_provider_gate_owner_pid=$agents_provider_gate_owner_PID
  agents_provider_gate_control=${agents_provider_gate_owner[1]}
  agents_provider_gate_reply=${agents_provider_gate_owner[0]}
  if ! read -r -t "$((bound + 1))" reply <&"$agents_provider_gate_reply" || [[ $reply != locked ]]; then
    agents_provider_gate_release || true
    printf 'leaving agent settings snapshots in place because collectors still running or gate acquisition failed\n' >&2
    return 1
  fi
  if ! agents_provider_gate_held; then
    agents_provider_gate_release || true
    return 1
  fi
}

agents_provider_gate_held() {
  if [[ -z ${agents_provider_gate_fd:-} ]] ||
    ! command python3 "$agents_provider_gate_helper" --held "$agents_provider_gate_fd"; then
    printf 'leaving agent settings snapshots in place because the exclusive gate could not be verified\n' >&2
    return 1
  fi
}

agents_provider_gate_release() {
  local status=0
  if [[ -n ${agents_provider_gate_control:-} ]]; then
    exec {agents_provider_gate_control}>&- || status=1
  fi
  if [[ -n ${agents_provider_gate_owner_pid:-} ]]; then
    wait "$agents_provider_gate_owner_pid" || status=1
  fi
  if [[ -n ${agents_provider_gate_reply:-} ]]; then
    exec {agents_provider_gate_reply}<&- || status=1
  fi
  if [[ -n ${agents_provider_gate_fd:-} ]]; then
    exec {agents_provider_gate_fd}>&- || status=1
  fi
  unset agents_provider_gate_fd agents_provider_gate_control agents_provider_gate_reply agents_provider_gate_owner_pid
  return "$status"
}

# Optional acceptance evidence is written under the real lease, outside all
# captured trees. It contains hashes and modes, never account names or bytes.
# Requested evidence failures retain the snapshot just like a restore failure.
agents_provider_manifest() {
  local phase=$1 backup=$2 shell=$3 usage=$4 cache=$5
  [[ -n ${OMARCHY_ACCEPTANCE_DIR:-} ]] || return 0
  if ! command python3 "$agents_provider_gate_helper" --manifest "$agents_provider_gate_fd" \
    "$OMARCHY_ACCEPTANCE_DIR" "$phase" "${backup##*/}" "$shell" "$usage" "$cache" \
    "$agents_provider_shell_json" "$agents_provider_usage_dir" "$agents_provider_cache_dir" "$backup"; then
    printf 'leaving agent settings snapshots in place because acceptance manifest evidence failed\n' >&2
    return 1
  fi
}

agents_provider_shell_json() {
  printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/shell.json"
}

agents_provider_usage_dir() {
  printf '%s\n' "${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/agents/usage"
}

agents_provider_cache_dir() {
  printf '%s\n' "${XDG_CACHE_HOME:-$HOME/.cache}/omarchy/agent-usage"
}

# The command itself is a collector. A later argument that merely mentions
# omarchy-agent-usage is not: that string shows up in the acceptance test and
# in ancestor shells that are not writing usage or cache files. Peer updaters
# stay untouched; kill -0 only probes. A zombie has already written what it will.
agents_provider_name_is_collector() {
  local name=$1
  [[ $name == omarchy-agent-usage || $name == omarchy-agent-usage-* ]]
}

# Find the script operand, not a later argument mentioning a collector. Python
# and shell options can precede it; -c, -m and stdin do not name a script.
agents_provider_argv_is_collector() {
  local -a tokens=("$@")
  local base family arg flags flag i=1 consume
  ((${#tokens[@]} > 0)) || return 1
  base=${tokens[0]##*/}
  if agents_provider_name_is_collector "$base"; then
    return 0
  fi
  case $base in
    bash | sh | dash) family=shell ;;
    python | python2 | python3 | python3.*) family=python ;;
    *) return 1 ;;
  esac
  while ((i < ${#tokens[@]})); do
    arg=${tokens[i]}
    if [[ $arg == -- ]]; then
      i=$((i + 1))
      break
    fi
    [[ $arg == - ]] && return 1
    consume=1
    if [[ $family == python ]]; then
      case $arg in
        --check-hash-based-pycs) consume=2 ;;
        --check-hash-based-pycs=*) ;;
        --*) return 1 ;;
        -?*)
          flags=${arg:1}
          while [[ -n $flags ]]; do
            flag=${flags:0:1}
            flags=${flags:1}
            case $flag in
              c | m | h | V) return 1 ;;
              W | X)
                [[ -n $flags ]] || consume=2
                break
                ;;
              b | B | d | E | i | I | O | P | q | R | s | S | u | v | x) ;;
              *) return 1 ;;
            esac
          done
          ;;
        *) break ;;
      esac
    else
      case $arg in
        --rcfile | --init-file) consume=2 ;;
        --rcfile=* | --init-file=* | --noprofile | --norc | --posix | --restricted | --verbose | --debugger | --login | --noediting) ;;
        --*) return 1 ;;
        -?* | +?*)
          flags=${arg:1}
          while [[ -n $flags ]]; do
            flag=${flags:0:1}
            flags=${flags:1}
            case $flag in
              c | s) return 1 ;;
              o | O)
                consume=$((consume + 1))
                ;;
              a | b | B | C | e | E | f | h | H | i | k | l | m | n | p | P | r | t | T | u | v | x) ;;
              *) return 1 ;;
            esac
          done
          ;;
        *) break ;;
      esac
    fi
    i=$((i + consume))
  done
  ((i < ${#tokens[@]})) || return 1
  agents_provider_name_is_collector "${tokens[i]##*/}"
}

# Read errors must be distinct from the NUL parser's normal EOF. Keep the bytes
# in a private temporary file because shell command substitution removes NULs.
agents_provider_read_cmdline() {
  cat "/proc/$1/cmdline"
}

# 0: this pid is a collector command. 1: it is not, or has disappeared.
# 2: its command line could not be read, which the caller treats as active.
agents_provider_pid_is_collector() {
  local pid=$1 snapshot
  local -a tokens=()
  [[ -d /proc/$pid ]] || return 1
  if ! snapshot=$(mktemp); then
    return 2
  fi
  if ! agents_provider_read_cmdline "$pid" >"$snapshot" 2>/dev/null; then
    rm -f "$snapshot" || return 2
    [[ -d /proc/$pid ]] && return 2
    return 1
  fi
  if ! mapfile -d '' -t tokens <"$snapshot"; then
    rm -f "$snapshot" || return 2
    return 2
  fi
  rm -f "$snapshot" || return 2
  agents_provider_argv_is_collector "${tokens[@]}"
}

agents_provider_pid_can_write() {
  local pid=$1 state
  if ! kill -0 "$pid" 2>/dev/null; then
    # A failed probe cannot prove a still-present pid has stopped writing.
    [[ -d /proc/$pid ]] && return 0
    return 1
  fi
  if [[ ! -r /proc/$pid/stat ]]; then
    return 0
  fi
  state=$(sed -n 's/.*) //p' "/proc/$pid/stat" | awk '{ print $1 }')
  if [[ -z $state || $state != Z ]]; then
    if [[ -n ${agents_provider_gate_fd:-} ]]; then
      # Only a kernel-proven READ waiter on this held exclusive gate cannot
      # write. Unknown reads/probes and every ungated live collector stay active.
      local blocked=0
      command python3 "$agents_provider_gate_helper" --blocked "$pid" "$agents_provider_gate_fd" || blocked=$?
      ((blocked == 0)) && return 1
    fi
    return 0
  fi
  return 1
}

# AGENTS_PROVIDER_COLLECTOR_PROBE, when it names an executable command, is the
# liveness seam. Exit 0 means a collector can still write. Exit 1 means the
# probe ran and no collector can. A missing command, or any other status, fails
# closed and counts as active. Unset, the process table is read. The probe is
# not a signal and it does not kill a peer.
# One checked acquisition per process-table scan avoids starting three commands
# for every pid. The record is pid, argument count, and NUL-delimited argv. A
# failed read of a pid that still exists aborts the entire observation.
agents_provider_read_cmdlines() {
  python3 - "$1" <<'PYTHON'
import os
import sys

try:
    output = sys.stdout.buffer
    for pid in sys.argv[1].split():
        if not pid.isdecimal():
            raise ValueError('invalid process id')
        try:
            with open('/proc/' + pid + '/cmdline', 'rb') as stream:
                data = stream.read()
        except OSError:
            if os.path.isdir('/proc/' + pid):
                raise
            continue
        tokens = data.split(b'\0') if data else []
        if tokens and not tokens[-1]:
            tokens.pop()
        output.write(pid.encode() + b'\0' + str(len(tokens)).encode() + b'\0')
        for token in tokens:
            output.write(token + b'\0')
    output.flush()
except (OSError, ValueError):
    sys.exit(2)
PYTHON
}

agents_provider_collectors_active() {
  local probe=${AGENTS_PROVIDER_COLLECTOR_PROBE:-} pid rc ps_out snapshot count i=0
  local -a records=() tokens=()
  if [[ -n $probe ]]; then
    if [[ ! -x $probe ]]; then
      return 0
    fi
    rc=0
    "$probe" || rc=$?
    ((rc == 1)) && return 1
    return 0
  fi
  if ! ps_out=$(ps -eo pid=); then
    return 0
  fi
  if ! snapshot=$(mktemp); then
    return 0
  fi
  if ! agents_provider_read_cmdlines "$ps_out" >"$snapshot" 2>/dev/null; then
    rm -f "$snapshot"
    return 0
  fi
  if ! mapfile -d '' -t records <"$snapshot"; then
    rm -f "$snapshot"
    return 0
  fi
  rm -f "$snapshot" || return 0
  while ((i < ${#records[@]})); do
    pid=${records[i]}
    i=$((i + 1))
    ((i < ${#records[@]})) || return 0
    count=${records[i]}
    i=$((i + 1))
    [[ $pid =~ ^[0-9]+$ && $count =~ ^[0-9]+$ ]] || return 0
    ((count <= ${#records[@]} - i)) || return 0
    tokens=("${records[@]:i:count}")
    i=$((i + count))
    if agents_provider_argv_is_collector "${tokens[@]}" && agents_provider_pid_can_write "$pid"; then
      return 0
    fi
  done
  return 1
}

# Two quiet polls, so a collector that exits between the probe and the copy
# cannot write the tree back after it was restored. Every live collector counts:
# a pid remembered after a copy has already started is still a writer. The bound
# is the whole wait, not a kill. Expiry before those two quiet polls is failure.
agents_provider_wait_for_collectors() {
  local bound=${AGENTS_PROVIDER_COLLECTOR_WAIT:-90}
  local deadline=$((SECONDS + bound))
  local quiet=0
  while ((SECONDS < deadline)); do
    if agents_provider_collectors_active; then
      quiet=0
    else
      quiet=$((quiet + 1))
      if ((quiet >= 2)); then
        return 0
      fi
    fi
    sleep 0.2
  done
  if agents_provider_collectors_active; then
    printf 'timed out after %ss with agent usage collectors still running\n' "$bound" >&2
  else
    printf 'timed out after %ss before agent usage collectors stayed quiet\n' "$bound" >&2
  fi
  return 1
}

agents_provider_capture_path() {
  local dest=$1 snapshot=$2 flag_name=$3
  printf -v "$flag_name" '%s' 0
  if [[ -e $dest || -L $dest ]]; then
    if ! cp -a "$dest" "$snapshot"; then
      printf 'failed to snapshot %s\n' "$dest" >&2
      return 1
    fi
    if [[ ! -e $snapshot && ! -L $snapshot ]]; then
      printf 'snapshot of %s is missing\n' "$dest" >&2
      return 1
    fi
    printf -v "$flag_name" '%s' 1
  fi
}

# A quiet wait is an observation of that interval, not permission for every
# later copy. A settings reload or another updater can start during staging
# or a move, so each boundary must observe again before discarding the backup.
agents_provider_restore_quiet() {
  agents_provider_gate_held || return 1
  if agents_provider_collectors_active; then
    printf 'leaving agent settings snapshots in place because collectors started during restore\n' >&2
    return 1
  fi
}

# Compare the captured existence, types, permissions and bytes. Directory
# entries and symlinks count too; an unreadable or changing path fails closed.
agents_provider_restore_path_matches() {
  python3 - "$1" "$2" "$3" <<'PYTHON'
import os
import stat
import sys

def same_path(snapshot, restored):
    original = os.lstat(snapshot)
    current = os.lstat(restored)
    if stat.S_IFMT(original.st_mode) != stat.S_IFMT(current.st_mode):
        return False
    if stat.S_IMODE(original.st_mode) != stat.S_IMODE(current.st_mode):
        return False
    if stat.S_ISLNK(original.st_mode):
        return os.readlink(snapshot) == os.readlink(restored)
    if stat.S_ISDIR(original.st_mode):
        names = sorted(os.listdir(snapshot))
        if names != sorted(os.listdir(restored)):
            return False
        return all(same_path(os.path.join(snapshot, name), os.path.join(restored, name)) for name in names)
    if stat.S_ISREG(original.st_mode):
        with open(snapshot, 'rb') as left, open(restored, 'rb') as right:
            while True:
                before = left.read(65536)
                after = right.read(65536)
                if before != after:
                    return False
                if not before:
                    return True
    return False

try:
    existed, snapshot, restored = sys.argv[1:]
    if existed == '1':
        matches = same_path(snapshot, restored)
    elif existed == '0':
        matches = not os.path.lexists(restored)
    else:
        matches = False
except (OSError, ValueError):
    matches = False
sys.exit(0 if matches else 1)
PYTHON
}

agents_provider_restored_paths_match() {
  if ! agents_provider_restore_path_matches "$agents_provider_shell_existed" "$1/shell.json" "$agents_provider_shell_json" ||
    ! agents_provider_restore_path_matches "$agents_provider_usage_existed" "$1/usage" "$agents_provider_usage_dir" ||
    ! agents_provider_restore_path_matches "$agents_provider_cache_existed" "$1/cache" "$agents_provider_cache_dir"; then
    printf 'leaving agent settings snapshots in place because restored existence, permissions or bytes differ\n' >&2
    return 1
  fi
}

# Record the same live paths on both sides of the final comparisons and
# process observations. A collector that finishes between checks may no
# longer have a pid, but its atomic record/cache writes change this evidence.
# The outer exclusive gate excludes cooperating writers for the transaction.
# These bounded observations still refuse unrelated or unreadable mutations.
agents_provider_restore_fingerprint() {
  python3 - --fingerprint "$agents_provider_shell_json" "$agents_provider_usage_dir" "$agents_provider_cache_dir" <<'PYTHON'
import hashlib
import json
import os
import stat
import sys

def version(info):
    return [info.st_dev, info.st_ino, info.st_mode, info.st_size, info.st_mtime_ns, info.st_ctime_ns]

def observe(path):
    try:
        before = os.lstat(path)
    except FileNotFoundError:
        return None
    evidence = {'version': version(before)}
    if stat.S_ISLNK(before.st_mode):
        evidence['target'] = os.readlink(path)
    elif stat.S_ISDIR(before.st_mode):
        names = sorted(os.listdir(path))
        evidence['entries'] = {name: observe(os.path.join(path, name)) for name in names}
        if names != sorted(os.listdir(path)):
            raise OSError('directory changed during observation')
    elif stat.S_ISREG(before.st_mode):
        digest = hashlib.sha256()
        with open(path, 'rb') as stream:
            while True:
                data = stream.read(65536)
                if not data:
                    break
                digest.update(data)
        evidence['sha256'] = digest.hexdigest()
    else:
        raise OSError('unsupported captured path type')
    if version(before) != version(os.lstat(path)):
        raise OSError('path changed during observation')
    return evidence

try:
    evidence = [observe(path) for path in sys.argv[2:]]
    payload = json.dumps(evidence, sort_keys=True, separators=(',', ':')).encode()
    print(hashlib.sha256(payload).hexdigest())
except (OSError, ValueError):
    sys.exit(1)
PYTHON
}

# Copy every snapshot into staging first. A failing copy leaves the live path
# and the backup where they are. Originals are removed only after every staged
# copy is present.
agents_provider_stage_restore() {
  local existed=$1 snapshot=$2 staged=$3 label=$4
  agents_provider_restore_quiet || return 1
  if ((existed)); then
    if [[ ! -e $snapshot && ! -L $snapshot ]]; then
      printf 'snapshot for %s is missing\n' "$label" >&2
      return 1
    fi
    if ! cp -a "$snapshot" "$staged"; then
      printf 'failed to stage restore of %s\n' "$label" >&2
      return 1
    fi
    if [[ ! -e $staged && ! -L $staged ]]; then
      printf 'staged restore of %s is missing\n' "$label" >&2
      return 1
    fi
    if ! agents_provider_restore_path_matches "$existed" "$snapshot" "$staged"; then
      printf 'staged restore of %s differs from its snapshot\n' "$label" >&2
      return 1
    fi
  fi
  agents_provider_restore_quiet
}

agents_provider_commit_restore() {
  local existed=$1 staged=$2 dest=$3
  agents_provider_restore_quiet || return 1
  if ((existed)); then
    if ! rm -rf "$dest"; then
      printf 'failed to remove %s before restore\n' "$dest" >&2
      return 1
    fi
    if ! mkdir -p "$(dirname "$dest")"; then
      printf 'failed to create the parent of %s\n' "$dest" >&2
      return 1
    fi
    agents_provider_restore_quiet || return 1
    if ! mv "$staged" "$dest"; then
      printf 'failed to move the staged restore into %s\n' "$dest" >&2
      return 1
    fi
  else
    if ! rm -rf "$dest"; then
      printf 'failed to remove %s\n' "$dest" >&2
      return 1
    fi
  fi
  agents_provider_restore_quiet
}

agents_provider_capture_settings() {
  agents_provider_shell_json=$(agents_provider_shell_json)
  agents_provider_usage_dir=$(agents_provider_usage_dir)
  agents_provider_cache_dir=$(agents_provider_cache_dir)
  # Snapshot only once current writers have been quiet. A copy taken while a
  # collector is in the middle of a write is not a state restore can put back.
  # Refusal leaves the fixture paths, the backup pointer, and the flags alone.
  if ! agents_provider_wait_for_collectors; then
    printf 'refusing to capture agent settings while usage collectors are still running\n' >&2
    return 1
  fi
  agents_provider_capture_complete=0
  if ! agents_provider_backup=$(mktemp -d); then
    printf 'failed to create an agent settings snapshot directory\n' >&2
    return 1
  fi
  if ! agents_provider_capture_path "$agents_provider_shell_json" "$agents_provider_backup/shell.json" agents_provider_shell_existed ||
    ! agents_provider_capture_path "$agents_provider_usage_dir" "$agents_provider_backup/usage" agents_provider_usage_existed ||
    ! agents_provider_capture_path "$agents_provider_cache_dir" "$agents_provider_backup/cache" agents_provider_cache_existed; then
    printf 'leaving the agent settings snapshot in place because capture failed\n' >&2
    return 1
  fi
  agents_provider_capture_complete=1
  agents_provider_gate_held || return 1
  agents_provider_manifest captured "$agents_provider_backup" "$agents_provider_backup/shell.json" \
    "$agents_provider_backup/usage" "$agents_provider_backup/cache"
}

agents_provider_restore_settings() {
  local backup=${agents_provider_backup:-} staged before after
  [[ -n $backup && -d $backup ]] || return 0

  # A partial capture must not delete a tree it failed to copy. The backup
  # stays so the failure can be seen and a later prepare can try again.
  if [[ ${agents_provider_capture_complete:-0} != 1 ]]; then
    printf 'leaving agent settings snapshots in place because the snapshot is incomplete\n' >&2
    return 1
  fi

  agents_provider_manifest captured "$backup" "$backup/shell.json" "$backup/usage" "$backup/cache" || return 1

  if command -v omarchy-shell >/dev/null 2>&1; then
    omarchy-shell shell hide omarchy.agents >/dev/null 2>&1 || true
  fi
  # Collectors that are still running keep the snapshot directory and the
  # existence flags. Restoring or deleting now races that writer, and clearing
  # the backup pointer would drop the only copy a later retry can use.
  if ! agents_provider_wait_for_collectors; then
    printf 'leaving agent settings snapshots in place because collectors are still running\n' >&2
    return 1
  fi

  if ! staged=$(mktemp -d); then
    printf 'failed to create restore staging\n' >&2
    return 1
  fi
  if ! agents_provider_stage_restore "$agents_provider_shell_existed" "$backup/shell.json" "$staged/shell.json" "$agents_provider_shell_json" ||
    ! agents_provider_stage_restore "$agents_provider_usage_existed" "$backup/usage" "$staged/usage" "$agents_provider_usage_dir" ||
    ! agents_provider_stage_restore "$agents_provider_cache_existed" "$backup/cache" "$staged/cache" "$agents_provider_cache_dir"; then
    rm -rf "$staged" || printf 'failed to remove restore staging %s\n' "$staged" >&2
    printf 'leaving agent settings snapshots in place because restore failed\n' >&2
    return 1
  fi

  # Settings can trigger a normal refresh. Put usage and cache back before
  # settings, then observe the reload interval and verify the captured state.
  if ! agents_provider_commit_restore "$agents_provider_usage_existed" "$staged/usage" "$agents_provider_usage_dir" ||
    ! agents_provider_commit_restore "$agents_provider_cache_existed" "$staged/cache" "$agents_provider_cache_dir" ||
    ! agents_provider_commit_restore "$agents_provider_shell_existed" "$staged/shell.json" "$agents_provider_shell_json"; then
    rm -rf "$staged" || printf 'failed to remove restore staging %s\n' "$staged" >&2
    printf 'leaving agent settings snapshots in place because restore failed\n' >&2
    return 1
  fi
  if ! rm -rf "$staged"; then
    printf 'failed to remove restore staging %s\n' "$staged" >&2
    return 1
  fi
  if ! agents_provider_wait_for_collectors; then
    printf 'leaving agent settings snapshots in place because collectors are still running after restore\n' >&2
    return 1
  fi
  if ! before=$(agents_provider_restore_fingerprint); then
    printf 'leaving agent settings snapshots in place because the initial restore observation failed\n' >&2
    return 1
  fi
  if ! agents_provider_restored_paths_match "$backup" || ! agents_provider_restore_quiet ||
    ! agents_provider_restored_paths_match "$backup" || ! agents_provider_restore_quiet; then
    return 1
  fi
  if ! after=$(agents_provider_restore_fingerprint) || [[ $before != "$after" ]]; then
    printf 'leaving agent settings snapshots in place because restored paths changed during final observations\n' >&2
    return 1
  fi
  agents_provider_gate_held || return 1
  agents_provider_manifest restored "$backup" "$agents_provider_shell_json" "$agents_provider_usage_dir" "$agents_provider_cache_dir" || return 1
  agents_provider_gate_held || return 1
  if ! rm -rf "$backup"; then
    printf 'failed to remove agent settings snapshot %s\n' "$backup" >&2
    return 1
  fi
  agents_provider_backup=""
}

# Holding exclusive excludes cooperating writers, including one that starts
# after the initial observation. Existing live ungated writers still refuse.
# The inner liveness checks recognize only actual gate-blocked kernel waiters;
# waiting for those processes to exit here would wait on our own lock forever.
prepare_agents_settings_restore() {
  local status=0
  agents_provider_gate_acquire || return 1
  agents_provider_capture_settings || status=$?
  agents_provider_gate_release || status=1
  return "$status"
}

restore_agents_settings() {
  local status=0 backup=${agents_provider_backup:-}
  [[ -n $backup && -d $backup ]] || return 0
  agents_provider_gate_acquire || return 1
  agents_provider_restore_settings || status=$?
  agents_provider_gate_release || status=1
  return "$status"
}

if [[ ${BASH_SOURCE[0]} != "$0" ]]; then
  return 0
fi

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Opens the agents panel and the provider switches, then puts back the shell
# settings, the usage directory, and the collector cache. Flipping a switch
# can start a real collector, so the same cleanup runs when a later step fails.
# This exercises the installed session; a checkout that has not been installed
# is not what the panel on screen is running.

prepare_agents_settings_restore
trap restore_agents_settings EXIT

omarchy-shell shell summon omarchy.agents >/dev/null
wait_until "agents panel opens" 15 layer_present "omarchy-keyboard-panel"
sleep 1
screenshot "success-agents-providers-open"

# One `s` opens the switches. If the panel opened straight onto them because
# every provider is off, that `s` leaves, and the second one comes back.
wtype s
sleep 1
if ! screen_contains "PROVIDERS"; then
  wtype s
  sleep 1
fi
wait_until "provider switches are visible" 15 screen_contains "PROVIDERS"
screenshot "success-agents-providers-switches"

# Space flips the highlighted switch. The trap puts the saved state back.
wtype -k space
sleep 1
screenshot "success-agents-providers-toggled"

wtype -k Escape
sleep 1
screenshot "success-agents-providers-escaped"
wtype -k Escape
wait_until "agents panel closes" 15 layer_absent "omarchy-keyboard-panel"

trap - EXIT
if ! restore_agents_settings; then
  exit 1
fi
