#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

unset MISE_DATA_DIR XDG_DATA_HOME

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
assert_path_present "$default_path" "$home/.local/share/mise/shims" "env-bootstrap appends mise shims"
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
[[ $linked_duplicate_path == "$home/.local/share/omarchy/agent-accounts/bin:$tmpdir/active/bin:/usr/bin:$home/.local/share/mise/shims:$home/.local/bin" ]] || fail "env-bootstrap does not duplicate PATH entries" "actual PATH: $linked_duplicate_path"
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
[[ ${reordered_result[1]} == "$home/.local/share/omarchy/agent-accounts/bin:$tmpdir/active/bin:$tmpdir/managed/bin:/usr/bin:$home/.local/share/mise/shims:$home/.local/bin" ]] ||
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
echo starship >>"$OMARCHY_TEST_INIT_CALLS"
echo 'OMARCHY_TEST_STARSHIP=v1'
SH
cat >"$init_bin/zoxide" <<'SH'
#!/bin/bash
echo zoxide >>"$OMARCHY_TEST_INIT_CALLS"
echo 'OMARCHY_TEST_ZOXIDE=v1'
SH
chmod +x "$init_bin/starship" "$init_bin/zoxide"

run_init() {
  TERM=xterm-256color XDG_CACHE_HOME="$init_cache" OMARCHY_PATH="$ROOT" \
    OMARCHY_TEST_INIT_CALLS="$init_calls" PATH="$init_bin:/usr/bin" \
    bash --norc -ic 'source "$OMARCHY_PATH/default/bash/init"; printf "%s:%s\n" "${OMARCHY_TEST_STARSHIP:-}" "${OMARCHY_TEST_ZOXIDE:-}"' 2>/dev/null
}

[[ $(run_init) == "v1:v1" ]] || fail "first interactive shell populates starship and zoxide init caches"
: >"$init_calls"
[[ $(run_init) == "v1:v1" ]] || fail "subsequent interactive shell loads cached starship and zoxide init"
[[ ! -s $init_calls ]] || fail "cached starship and zoxide init avoids re-executing the binaries" "$(<"$init_calls")"

cat >"$init_bin/starship" <<'SH'
#!/bin/bash
echo starship >>"$OMARCHY_TEST_INIT_CALLS"
echo 'OMARCHY_TEST_STARSHIP=v2'
SH
chmod +x "$init_bin/starship"
touch -d "2020-01-01 00:00:00" "$init_bin/starship"
[[ $(run_init) == "v2:v1" ]] || fail "replacement starship binary with older timestamp invalidates its cached init script"
pass "starship and zoxide init scripts cache across shells and invalidate on replacement"

if [[ -f /usr/share/bash-completion/bash_completion ]]; then
  TERM=xterm-256color OMARCHY_PATH="$ROOT" bash --norc -ic '
    source "$OMARCHY_PATH/default/bash/shell"
    [[ ! -v BASH_COMPLETION_VERSINFO ]] || exit 1
    _omarchy_lazy_bash_completion git || rc=$?
    [[ ${rc:-0} == 124 && -v BASH_COMPLETION_VERSINFO ]]
  ' 2>/dev/null || fail "bash_completion lazy-loads on first completion request"
  pass "bash_completion lazy-loads on first completion request"
fi
