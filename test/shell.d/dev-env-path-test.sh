#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

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

assert_path_before() {
  local path_value="$1"
  local earlier="$2"
  local later="$3"
  local description="$4"
  local IFS=':'
  local -a parts
  local i earlier_i=-1 later_i=-1

  read -ra parts <<<"$path_value"
  for i in "${!parts[@]}"; do
    [[ ${parts[i]} == "$earlier" ]] && earlier_i=$i
    [[ ${parts[i]} == "$later" ]] && later_i=$i
  done

  (( earlier_i >= 0 && later_i >= 0 && earlier_i < later_i )) ||
    fail "$description" "expected $earlier before $later in $path_value"
  pass "$description"
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
assert_path_present "$default_path" "$home/.local/share/mise/shims" "env-bootstrap prepends mise shims"
assert_path_present "$default_path" "$home/.local/bin" "env-bootstrap prepends ~/.local/bin"
assert_path_first "$default_path" "$home/.local/share/mise/shims" "env-bootstrap puts mise shims first in default mode"
assert_path_before "$default_path" "$home/.local/share/mise/shims" "$home/.local/bin" "env-bootstrap puts mise shims before ~/.local/bin"
assert_path_before "$default_path" "$home/.local/bin" "/usr/bin" "env-bootstrap puts ~/.local/bin before /usr/bin"

printf 'export OMARCHY_PATH="%s"\n' "$tmpdir/active" >"$tmpdir/omarchy.conf"
mapfile -t linked_result < <(run_bootstrap bash "$bootstrap" "$home" "$tmpdir/unrelated/bin:/usr/bin")
linked_path=${linked_result[1]}

[[ ${linked_result[0]} == "$tmpdir/active" ]] || fail "env-bootstrap resolves linked OMARCHY_PATH" "actual: ${linked_result[0]}"
pass "env-bootstrap resolves linked OMARCHY_PATH"
assert_path_first "$linked_path" "$tmpdir/active/bin" "env-bootstrap prepends active checkout bin in linked mode"
assert_path_before "$linked_path" "$tmpdir/active/bin" "$home/.local/share/mise/shims" "env-bootstrap puts checkout bin before mise shims in linked mode"
assert_path_present "$linked_path" "$tmpdir/unrelated/bin" "env-bootstrap preserves unrelated PATH entries in linked mode"

# User dirs already at the end (the old PAM order) must move to the front.
mapfile -t reorder_result < <(run_bootstrap bash "$bootstrap" "$home" "$tmpdir/unrelated/bin:/usr/bin:$home/.local/share/mise/shims:$home/.local/bin")
reorder_path=${reorder_result[1]}
[[ $reorder_path == "$tmpdir/active/bin:$home/.local/share/mise/shims:$home/.local/bin:$tmpdir/unrelated/bin:/usr/bin" ]] ||
  fail "env-bootstrap moves existing user-level paths to the front" "actual PATH: $reorder_path"
pass "env-bootstrap moves existing user-level paths to the front"

mapfile -t linked_duplicate_result < <(run_bootstrap bash "$bootstrap" "$home" "$tmpdir/active/bin:/usr/bin:$home/.local/share/mise/shims:$home/.local/bin")
linked_duplicate_path=${linked_duplicate_result[1]}
[[ $linked_duplicate_path == "$tmpdir/active/bin:$home/.local/share/mise/shims:$home/.local/bin:/usr/bin" ]] ||
  fail "env-bootstrap does not duplicate PATH entries" "actual PATH: $linked_duplicate_path"
pass "env-bootstrap does not duplicate PATH entries"

# An empty PATH must not produce empty entries (a bare ":" means the cwd)
mapfile -t empty_path_result < <(run_bootstrap bash "$bootstrap" "$home" "")
empty_path=${empty_path_result[1]}
[[ $empty_path == "$tmpdir/active/bin:$home/.local/share/mise/shims:$home/.local/bin" ]] || fail "env-bootstrap builds a clean PATH from an empty one" "actual PATH: $empty_path"
pass "env-bootstrap builds a clean PATH from an empty one"

if command -v zsh >/dev/null 2>&1; then
  mapfile -t zsh_result < <(run_bootstrap zsh "$bootstrap" "$home" "$tmpdir/unrelated/bin:/usr/bin")
  zsh_path=${zsh_result[1]}
  assert_path_first "$zsh_path" "$tmpdir/active/bin" "env-bootstrap works when sourced by zsh"
  assert_path_present "$zsh_path" "$tmpdir/unrelated/bin" "env-bootstrap zsh mode preserves unrelated PATH entries"
  assert_path_before "$zsh_path" "$home/.local/bin" "/usr/bin" "env-bootstrap zsh mode puts ~/.local/bin before /usr/bin"
fi
