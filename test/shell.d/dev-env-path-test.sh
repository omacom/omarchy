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
assert_path_first "$default_path" "$home/.local/share/mise/command-wrappers/bin" "env-bootstrap puts command wrappers ahead of inherited tool binaries"

printf 'export OMARCHY_PATH="%s"\n' "$tmpdir/active" >"$tmpdir/omarchy.conf"
mapfile -t linked_result < <(run_bootstrap bash "$bootstrap" "$home" "$tmpdir/unrelated/bin:/usr/bin")
linked_path=${linked_result[1]}

[[ ${linked_result[0]} == "$tmpdir/active" ]] || fail "env-bootstrap resolves linked OMARCHY_PATH" "actual: ${linked_result[0]}"
pass "env-bootstrap resolves linked OMARCHY_PATH"
assert_path_first "$linked_path" "$home/.local/share/mise/command-wrappers/bin" "env-bootstrap keeps command wrappers first in linked mode"
assert_path_present "$linked_path" "$tmpdir/active/bin" "env-bootstrap includes the active checkout bin in linked mode"
assert_path_present "$linked_path" "$tmpdir/unrelated/bin" "env-bootstrap preserves unrelated PATH entries in linked mode"

mapfile -t linked_duplicate_result < <(run_bootstrap bash "$bootstrap" "$home" "$tmpdir/active/bin:/usr/bin:$home/.local/share/mise/shims:$home/.local/bin")
linked_duplicate_path=${linked_duplicate_result[1]}
[[ $linked_duplicate_path == "$home/.local/share/mise/command-wrappers/bin:$tmpdir/active/bin:/usr/bin:$home/.local/share/mise/shims:$home/.local/bin" ]] || fail "env-bootstrap does not duplicate PATH entries" "actual PATH: $linked_duplicate_path"
pass "env-bootstrap does not duplicate PATH entries"

# An empty PATH must not produce empty entries (a bare ":" means the cwd)
mapfile -t empty_path_result < <(run_bootstrap bash "$bootstrap" "$home" "")
empty_path=${empty_path_result[1]}
[[ $empty_path == "$home/.local/share/mise/command-wrappers/bin:$tmpdir/active/bin:$home/.local/share/mise/shims:$home/.local/bin" ]] || fail "env-bootstrap builds a clean PATH from an empty one" "actual PATH: $empty_path"
pass "env-bootstrap builds a clean PATH from an empty one"

if command -v zsh >/dev/null 2>&1; then
  mapfile -t zsh_result < <(run_bootstrap zsh "$bootstrap" "$home" "$tmpdir/unrelated/bin:/usr/bin")
  zsh_path=${zsh_result[1]}
  assert_path_first "$zsh_path" "$home/.local/share/mise/command-wrappers/bin" "env-bootstrap works when sourced by zsh"
  assert_path_present "$zsh_path" "$tmpdir/unrelated/bin" "env-bootstrap zsh mode preserves unrelated PATH entries"
fi

mapfile -t repeated_result < <(run_bootstrap bash "$bootstrap" "$home" "$linked_duplicate_path")
[[ ${repeated_result[1]} == "$linked_duplicate_path" ]] || fail "repeated bootstrap leaves the command wrapper path unchanged"
pass "repeated bootstrap leaves the command wrapper path unchanged"

mapfile -t custom_data_result < <(MISE_DATA_DIR="$tmpdir/custom-mise" run_bootstrap bash "$bootstrap" "$home" "/usr/bin")
assert_path_first "${custom_data_result[1]}" "$tmpdir/custom-mise/command-wrappers/bin" "env-bootstrap honors a custom mise data directory"

# A parent agent or mise activation may have put real tool bins before a wrapper
# directory that was already present. Move the existing entry rather than skip it.
inherited_path="$tmpdir/managed/bin:$home/.local/share/mise/command-wrappers/bin:/usr/bin"
mapfile -t reordered_result < <(run_bootstrap bash "$bootstrap" "$home" "$inherited_path")
[[ ${reordered_result[1]} == "$home/.local/share/mise/command-wrappers/bin:$tmpdir/active/bin:$tmpdir/managed/bin:/usr/bin:$home/.local/share/mise/shims:$home/.local/bin" ]] ||
  fail "bootstrap moves existing wrappers ahead of inherited managed tool paths without duplication" "${reordered_result[1]}"
pass "bootstrap moves existing wrappers ahead of inherited managed tool paths without duplication"
