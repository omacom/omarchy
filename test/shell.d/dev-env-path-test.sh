#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

unset "${!MISE_@}" XDG_DATA_HOME

run_bootstrap() {
  local shell_bin="$1"
  local bootstrap="$2"
  local home="$3"
  local path_value="$4"

  shell_bin=$(command -v "$shell_bin")
  HOME="$home" PATH="$path_value" "$shell_bin" -c '
    . "$1"
    printf "%s\n%s\n" "$OMARCHY_PATH" "$PATH"
  ' sh "$bootstrap"
}

assert_path_first() {
  local path_value="$1"
  local entry="$2"
  local description="$3"

  [[ ${path_value%%:*} == "$entry" ]] || fail "$description" "expected first PATH entry: $entry\nactual PATH: $path_value"
  pass "$description"
}

assert_path_present() {
  local path_value="$1"
  local entry="$2"
  local description="$3"

  case ":$path_value:" in
    *":$entry:"*) pass "$description" ;;
    *) fail "$description" "PATH does not contain $entry in $path_value" ;;
  esac
}

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
mkdir -p "$tmpdir/active/bin" "$tmpdir/unrelated/bin"

# Test against a copy so the test controls /etc/omarchy.conf without mutating the host.
bootstrap="$tmpdir/env-bootstrap"
sed "s#/etc/omarchy.conf#$tmpdir/omarchy.conf#g" "$ROOT/default/bash/env-bootstrap" >"$bootstrap"

printf 'export OMARCHY_PATH="/usr/share/omarchy"\n' >"$tmpdir/omarchy.conf"
mapfile -t default_result < <(run_bootstrap bash "$bootstrap" "$home" "$tmpdir/unrelated/bin:/usr/bin")
default_path=${default_result[1]}

[[ ${default_result[0]} == /usr/share/omarchy ]] || fail "env-bootstrap resolves default OMARCHY_PATH" "actual: ${default_result[0]}"
pass "env-bootstrap resolves default OMARCHY_PATH"
assert_path_present "$default_path" "$tmpdir/unrelated/bin" "env-bootstrap preserves PATH entries in default mode"
[[ :$default_path: == *":$tmpdir/unrelated/bin:$home/.local/share/mise/shims:/usr/bin:"* ]] ||
  fail "env-bootstrap puts mise shims just ahead of system binaries" "actual PATH: $default_path"
pass "env-bootstrap puts mise shims just ahead of system binaries, behind what the parent put first"
assert_path_present "$default_path" "$home/.local/bin" "env-bootstrap appends ~/.local/bin"
assert_path_first "$default_path" "$home/.local/share/omarchy/agent-accounts/bin" "env-bootstrap puts the account dispatchers ahead of inherited tool binaries"

printf 'export OMARCHY_PATH="%s"\n' "$tmpdir/active" >"$tmpdir/omarchy.conf"
mapfile -t linked_result < <(run_bootstrap bash "$bootstrap" "$home" "$tmpdir/unrelated/bin:/usr/bin")
linked_path=${linked_result[1]}

[[ ${linked_result[0]} == "$tmpdir/active" ]] || fail "env-bootstrap resolves linked OMARCHY_PATH" "actual: ${linked_result[0]}"
pass "env-bootstrap resolves linked OMARCHY_PATH"
assert_path_first "$linked_path" "$home/.local/share/omarchy/agent-accounts/bin" "env-bootstrap keeps account dispatchers first in linked mode"
assert_path_present "$linked_path" "$tmpdir/active/bin" "env-bootstrap includes the active checkout bin in linked mode"
assert_path_present "$linked_path" "$tmpdir/unrelated/bin" "env-bootstrap preserves unrelated PATH entries in linked mode"

mapfile -t linked_duplicate_result < <(run_bootstrap bash "$bootstrap" "$home" "$tmpdir/active/bin:/usr/bin:$home/.local/share/mise/shims:$home/.local/bin")
linked_duplicate_path=${linked_duplicate_result[1]}
[[ $linked_duplicate_path == "$home/.local/share/omarchy/agent-accounts/bin:$tmpdir/active/bin:$home/.local/share/mise/shims:/usr/bin:$home/.local/bin" ]] || fail "env-bootstrap does not duplicate PATH entries" "actual PATH: $linked_duplicate_path"
pass "env-bootstrap does not duplicate PATH entries"

# An empty PATH must not produce empty entries (a bare ":" means the cwd)
mapfile -t empty_path_result < <(run_bootstrap bash "$bootstrap" "$home" "")
empty_path=${empty_path_result[1]}
[[ $empty_path == "$home/.local/share/omarchy/agent-accounts/bin:$tmpdir/active/bin:$home/.local/share/mise/shims:$home/.local/bin" ]] || fail "env-bootstrap builds a clean PATH from an empty one" "actual PATH: $empty_path"
pass "env-bootstrap builds a clean PATH from an empty one"

if command -v zsh >/dev/null 2>&1; then
  mapfile -t zsh_result < <(run_bootstrap zsh "$bootstrap" "$home" "$tmpdir/unrelated/bin:/usr/bin")
  zsh_path=${zsh_result[1]}
  assert_path_first "$zsh_path" "$home/.local/share/omarchy/agent-accounts/bin" "env-bootstrap works when sourced by zsh"
  assert_path_present "$zsh_path" "$tmpdir/unrelated/bin" "env-bootstrap zsh mode preserves unrelated PATH entries"
  [[ :$zsh_path: == *":$home/.local/share/mise/shims:/usr/bin:"* ]] || fail "env-bootstrap puts mise shims ahead of system binaries under zsh" "actual PATH: $zsh_path"
fi

mapfile -t repeated_result < <(run_bootstrap bash "$bootstrap" "$home" "$linked_duplicate_path")
[[ ${repeated_result[1]} == "$linked_duplicate_path" ]] || fail "repeated bootstrap leaves the dispatcher path unchanged"
pass "repeated bootstrap leaves the dispatcher path unchanged"

# mise's command wrappers did the dispatch once; a session from then still has
# their directory on PATH, and it goes.
mapfile -t retired_result < <(run_bootstrap bash "$bootstrap" "$home" "$home/.local/share/mise/command-wrappers/bin:/usr/bin")
[[ :${retired_result[1]}: != *":$home/.local/share/mise/command-wrappers/bin:"* ]] ||
  fail "env-bootstrap drops mise's old command wrappers" "${retired_result[1]}"
pass "env-bootstrap drops mise's old command wrappers"

# A parent agent or mise activation may have put real tool bins before the
# dispatcher directory when it was already present. Move the existing entry rather than skip it.
inherited_path="$tmpdir/managed/bin:$home/.local/share/omarchy/agent-accounts/bin:/usr/bin"
mapfile -t reordered_result < <(run_bootstrap bash "$bootstrap" "$home" "$inherited_path")
[[ ${reordered_result[1]} == "$home/.local/share/omarchy/agent-accounts/bin:$tmpdir/active/bin:$tmpdir/managed/bin:$home/.local/share/mise/shims:/usr/bin:$home/.local/bin" ]] ||
  fail "bootstrap moves existing dispatchers ahead of inherited managed tool paths without duplication" "${reordered_result[1]}"
pass "bootstrap moves existing dispatchers ahead of inherited managed tool paths without duplication"

# Interactive shell startup caches static starship/zoxide init output keyed by
# binary fingerprint (invalidating on both newer and older-timestamp replacements)
# and lazy-loads bash_completion on first completion request.
init_bin="$tmpdir/init-bin"
init_cache="$tmpdir/init-cache"
init_calls="$tmpdir/init-calls"
mkdir -p "$init_bin"
cat >"$init_bin/starship" <<'SH'
#!/bin/bash
echo "starship $*" >>"$OMARCHY_TEST_INIT_CALLS"
if [[ $1 == "prompt" && $2 == "--continuation" ]]; then
  printf '%s' "${OMARCHY_TEST_PS2:-.. }"
  exit 0
fi
if [[ $1 == "time" ]]; then
  echo 1234567890000
  exit 0
fi
cat <<EOF
OMARCHY_TEST_STARSHIP=v1
starship_preexec() { STARSHIP_START_TIME=\$($0 time); }
starship_precmd() { STARSHIP_END_TIME=\$($0 time); }
if [[ "\${PS0-}" != *"starship_preexec_ps0"* ]]; then
    PS0='\${STARSHIP_START_TIME:\$((STARSHIP_START_TIME="\$(starship_preexec_ps0)",STARSHIP_PREEXEC_READY=0,0)):0}'"\${PS0-}"
fi
STARSHIP_START_TIME=\$($0 time)
PS2="\$($0 prompt --continuation)"
EOF
SH
cat >"$init_bin/zoxide" <<'SH'
#!/bin/bash
echo "zoxide $*" >>"$OMARCHY_TEST_INIT_CALLS"
echo 'OMARCHY_TEST_ZOXIDE=v1'
SH
cat >"$init_bin/mise" <<'SH'
#!/bin/bash
echo "mise $*" >>"$OMARCHY_TEST_INIT_CALLS"
if [[ $1 == "activate" ]]; then
  printf "export __MISE_ORIG_PATH='%s'\n" "$PATH"
  printf "export PATH='%s:%s'\n" "$OMARCHY_TEST_MISE_TOOL_BIN" "$PATH"
  cat <<'EOF'
_mise_hook() {
  eval "$(mise hook-env -s bash "$@")"
}
_mise_hook --force
EOF
elif [[ $1 == "hook-env" ]]; then
  printf "export PATH='%s:%s'\n" "$OMARCHY_TEST_MISE_TOOL_BIN" "$PATH"
  if [[ -n ${OMARCHY_TEST_MISE_STARSHIP_CONFIG:-} ]]; then
    printf "export STARSHIP_CONFIG='%s'\n" "$OMARCHY_TEST_MISE_STARSHIP_CONFIG"
  fi
fi
SH
chmod +x "$init_bin/starship" "$init_bin/zoxide" "$init_bin/mise"
mkdir -p "$tmpdir/mise-tool/bin"
starship_cfg="$tmpdir/starship.toml"
printf 'add_newline = true\n' >"$starship_cfg"

run_init() {
  HOME="$home" TERM=xterm-256color XDG_CACHE_HOME="$init_cache" OMARCHY_PATH="$ROOT" \
    STARSHIP_CONFIG="$starship_cfg" OMARCHY_TEST_MISE_TOOL_BIN="$tmpdir/mise-tool/bin" \
    OMARCHY_TEST_INIT_CALLS="$init_calls" PATH="$home/.local/share/omarchy/agent-accounts/bin:$init_bin:/usr/bin" \
    bash --norc -ic 'source "$OMARCHY_PATH/default/bash/init"; printf "%s:%s:%s:%s\n" "${OMARCHY_TEST_STARSHIP:-}" "${OMARCHY_TEST_ZOXIDE:-}" "$PS2" "${PATH%%:*}"' 2>/dev/null
}

mkdir -p "$home"
cd "$home"

[[ $(run_init) == "v1:v1:.. :$home/.local/share/omarchy/agent-accounts/bin" ]] ||
  fail "first interactive shell populates starship and zoxide init caches and preserves agent-accounts precedence" "$(run_init)"
: >"$init_calls"
[[ $(run_init) == "v1:v1:.. :$home/.local/share/omarchy/agent-accounts/bin" ]] ||
  fail "subsequent interactive shell loads cached init scripts with baked PS2 and agent-accounts first on PATH"
! grep -q '^starship ' "$init_calls" || fail "cached starship init avoids re-executing starship (including time and continuation)" "$(<"$init_calls")"
! grep -q '^zoxide ' "$init_calls" || fail "cached zoxide init avoids re-executing zoxide" "$(<"$init_calls")"

# Verify PS0/preexec/precmd timing uses EPOCHREALTIME (dot or comma decimal) without calling starship time
: >"$init_calls"
time_check=$(HOME="$home" TERM=xterm-256color XDG_CACHE_HOME="$init_cache" OMARCHY_PATH="$ROOT" \
  STARSHIP_CONFIG="$starship_cfg" OMARCHY_TEST_MISE_TOOL_BIN="$tmpdir/mise-tool/bin" \
  OMARCHY_TEST_INIT_CALLS="$init_calls" PATH="$home/.local/share/omarchy/agent-accounts/bin:$init_bin:/usr/bin" \
  bash --norc -ic 'source "$OMARCHY_PATH/default/bash/init"; : "${PS0@P}"; ps0_t="$STARSHIP_START_TIME"; starship_preexec; starship_precmd; printf "%s:%s:%s\n" "$ps0_t" "$STARSHIP_START_TIME" "$STARSHIP_END_TIME"' 2>/dev/null)
[[ $time_check =~ ^[0-9]{13}:[0-9]{13}:[0-9]{13}$ ]] || fail "rewritten starship time produces 13-digit epoch milliseconds" "$time_check"
! grep -q '^starship time' "$init_calls" || fail "starship preexec/precmd do not fork starship time" "$(<"$init_calls")"

# Updating starship.toml invalidates cached PS2, including same-size edits within the same second
printf 'continuation_prompt = ">> "\n' >"$starship_cfg"
touch -d '@1795600000.100' "$starship_cfg"
out_after_cfg=$(OMARCHY_TEST_PS2=">> " run_init)
[[ $out_after_cfg == "v1:v1:>> :$home/.local/share/omarchy/agent-accounts/bin" ]] ||
  fail "editing STARSHIP_CONFIG invalidates cached starship PS2" "$out_after_cfg"

printf 'continuation_prompt = "!! "\n' >"$starship_cfg"
touch -d '@1795600000.900' "$starship_cfg"
out_same_sec=$(OMARCHY_TEST_PS2="!! " run_init)
[[ $out_same_sec == "v1:v1:!! :$home/.local/share/omarchy/agent-accounts/bin" ]] ||
  fail "same-size edit to STARSHIP_CONFIG within the same second invalidates cached PS2" "$out_same_sec"

# Project STARSHIP_CONFIG set during mise activation invalidates cached PS2
starship_proj_cfg="$tmpdir/starship-project.toml"
printf 'continuation_prompt = "## "\n' >"$starship_proj_cfg"
out_mise_cfg=$(OMARCHY_TEST_MISE_STARSHIP_CONFIG="$starship_proj_cfg" OMARCHY_TEST_PS2="## " run_init)
[[ $out_mise_cfg == "v1:v1:## :$home/.local/share/omarchy/agent-accounts/bin" ]] ||
  fail "STARSHIP_CONFIG exported by mise activation invalidates cached starship PS2" "$out_mise_cfg"

# Static continuation_prompt containing the letter 'r' still bakes PS2 into cache
printf 'continuation_prompt = "more> "\n' >"$starship_cfg"
: >"$init_calls"
out_more=$(OMARCHY_TEST_PS2="more> " run_init)
[[ $out_more == "v1:v1:more> :$home/.local/share/omarchy/agent-accounts/bin" ]] ||
  fail "static continuation_prompt containing 'r' bakes PS2" "$out_more"
: >"$init_calls"
[[ $(run_init) == "v1:v1:more> :$home/.local/share/omarchy/agent-accounts/bin" ]] &&
  ! grep -q '^starship ' "$init_calls" ||
  fail "cached static continuation_prompt containing 'r' avoids re-running starship" "$(<"$init_calls")"

# Dynamic continuation_prompt (bare or quoted TOML key) is evaluated per shell rather than baked
for dyn_line in 'continuation_prompt = "$directory> "' '"continuation_prompt" = "$directory> "'; do
  starship_dyn_cfg="$tmpdir/starship-dynamic.toml"
  printf '%s\n' "$dyn_line" >"$starship_dyn_cfg"
  out_dyn_a=$(STARSHIP_CONFIG="$starship_dyn_cfg" OMARCHY_TEST_PS2="dirA> " \
    HOME="$home" TERM=xterm-256color XDG_CACHE_HOME="$init_cache" OMARCHY_PATH="$ROOT" \
    OMARCHY_TEST_MISE_TOOL_BIN="$tmpdir/mise-tool/bin" OMARCHY_TEST_INIT_CALLS="$init_calls" \
    PATH="$home/.local/share/omarchy/agent-accounts/bin:$init_bin:/usr/bin" \
    bash --norc -ic 'source "$OMARCHY_PATH/default/bash/init"; printf "%s" "$PS2"' 2>/dev/null)
  out_dyn_b=$(STARSHIP_CONFIG="$starship_dyn_cfg" OMARCHY_TEST_PS2="dirB> " \
    HOME="$home" TERM=xterm-256color XDG_CACHE_HOME="$init_cache" OMARCHY_PATH="$ROOT" \
    OMARCHY_TEST_MISE_TOOL_BIN="$tmpdir/mise-tool/bin" OMARCHY_TEST_INIT_CALLS="$init_calls" \
    PATH="$home/.local/share/omarchy/agent-accounts/bin:$init_bin:/usr/bin" \
    bash --norc -ic 'source "$OMARCHY_PATH/default/bash/init"; printf "%s" "$PS2"' 2>/dev/null)
  [[ $out_dyn_a == "dirA> " && $out_dyn_b == "dirB> " ]] ||
    fail "dynamic continuation_prompt ($dyn_line) is evaluated live per shell" "$out_dyn_a | $out_dyn_b"
done

# Non-interactive shell with set -e completes init cleanly
errexit_out=$(HOME="$home" XDG_CACHE_HOME="$init_cache" OMARCHY_PATH="$ROOT" \
  OMARCHY_TEST_MISE_TOOL_BIN="$tmpdir/mise-tool/bin" OMARCHY_TEST_INIT_CALLS="$init_calls" \
  PATH="$home/.local/share/omarchy/agent-accounts/bin:$init_bin:/usr/bin" \
  bash -ec 'source "$OMARCHY_PATH/default/bash/init"; echo reached' 2>/dev/null)
[[ $errexit_out == "reached" ]] || fail "init succeeds under set -e in non-interactive shells" "$errexit_out"

cat >"$init_bin/starship" <<'SH'
#!/bin/bash
echo "starship $*" >>"$OMARCHY_TEST_INIT_CALLS"
echo 'OMARCHY_TEST_STARSHIP=v2'
SH
chmod +x "$init_bin/starship"
touch -d "2020-01-01 00:00:00" "$init_bin/starship"
[[ $(run_init) == "v2:v1:"* ]] || fail "replacement starship binary with older timestamp invalidates its cached init script" "$(run_init)"
pass "starship (zero-fork time + PS2) and zoxide init scripts cache across shells, invalidate on changes, and mise keeps agent-accounts first on PATH"

if [[ -f /usr/share/bash-completion/bash_completion ]]; then
  TERM=xterm-256color OMARCHY_PATH="$ROOT" bash --norc -ic '
    source "$OMARCHY_PATH/default/bash/shell"
    [[ ! -v BASH_COMPLETION_VERSINFO ]] || exit 1
    _omarchy_lazy_bash_completion git || rc=$?
    [[ ${rc:-0} == 124 && -v BASH_COMPLETION_VERSINFO ]]
  ' 2>/dev/null || fail "bash_completion lazy-loads on first completion request"
  pass "bash_completion lazy-loads on first completion request"
fi
