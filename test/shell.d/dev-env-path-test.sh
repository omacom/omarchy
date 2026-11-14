#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

unset MISE_DATA_DIR MISE_STATE_DIR MISE_CONFIG_DIR MISE_CACHE_DIR MISE_SHELL
unset OMARCHY_XDG_HOME __MISE_ORIG_PATH __MISE_DIFF __MISE_SESSION __MISE_EXE XDG_DATA_HOME

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

# Lines: OMARCHY_XDG_HOME, four XDG bases, XDG_RUNTIME_DIR, MISE_DATA_DIR,
# MISE_STATE_DIR, MISE_SHELL, __MISE_ORIG_PATH, __MISE_DIFF, __MISE_SESSION, PATH.
source_bootstrap_env() {
  local shell_bin="$1"

  shell_bin=$(command -v "$shell_bin")
  shift
  env "$@" "$shell_bin" -c '
    . "$1"
    . "$1"
    printf "%s\n" \
      "${OMARCHY_XDG_HOME-}" \
      "${XDG_CONFIG_HOME-UNSET}" \
      "${XDG_CACHE_HOME-UNSET}" \
      "${XDG_DATA_HOME-UNSET}" \
      "${XDG_STATE_HOME-UNSET}" \
      "${XDG_RUNTIME_DIR-UNSET}" \
      "${MISE_DATA_DIR-UNSET}" \
      "${MISE_STATE_DIR-UNSET}" \
      "${MISE_SHELL-UNSET}" \
      "${__MISE_ORIG_PATH-UNSET}" \
      "${__MISE_DIFF-UNSET}" \
      "${__MISE_SESSION-UNSET}" \
      "$PATH"
  ' sh "$bootstrap"
}

printf 'export OMARCHY_PATH="/usr/share/omarchy"\n' >"$tmpdir/omarchy.conf"

original="$tmpdir/original-user"
target="$tmpdir/test-user"
mkdir -p "$original/.local/state/mise" "$original/.config" "$original/.cache" "$original/.local/share/mise"
chmod 777 "$original" "$original/.local" "$original/.local/state" "$original/.local/state/mise"

# /opt/extra/bin was added after mise activation, so it is absent from
# __MISE_ORIG_PATH. It must survive; only the previous account's own entries go.
inherited_path="/opt/extra/bin:$original/.local/share/mise/installs/node/20/bin:$original/.local/share/mise/command-wrappers/bin:/opt/tools/bin:$original/.local/share/mise/shims:$original/.local/bin"
mise_orig_path="$original/.local/share/mise/command-wrappers/bin:/opt/tools/bin:$original/.local/share/mise/shims:$original/.local/bin"
switched_path="$target/.local/share/mise/command-wrappers/bin:/opt/extra/bin:/opt/tools/bin:$target/.local/share/mise/shims:$target/.local/bin"

mapfile -t switch_result < <(source_bootstrap_env bash \
  HOME="$target" \
  PATH="$inherited_path" \
  OMARCHY_XDG_HOME="$original" \
  XDG_CONFIG_HOME="$original/.config" \
  XDG_CACHE_HOME="$original/.cache" \
  XDG_DATA_HOME="$original/.local/share" \
  XDG_STATE_HOME="$original/.local/state" \
  XDG_RUNTIME_DIR="/run/user/1000" \
  MISE_DATA_DIR="$original/.local/share/mise" \
  MISE_STATE_DIR="$original/.local/state/mise" \
  MISE_SHELL=bash \
  __MISE_ORIG_PATH="$mise_orig_path" \
  __MISE_DIFF=inherited \
  __MISE_SESSION=inherited \
  __MISE_EXE="$original/.local/bin/mise")

[[ ${switch_result[0]} == "$target" ]] || fail "plain su records the target account as the XDG owner" "actual: ${switch_result[0]}"
[[ ${switch_result[1]} == "UNSET" && ${switch_result[2]} == "UNSET" && ${switch_result[3]} == "UNSET" && ${switch_result[4]} == "UNSET" ]] ||
  fail "plain su drops XDG defaults inherited from the previous account" \
    "config=${switch_result[1]} cache=${switch_result[2]} data=${switch_result[3]} state=${switch_result[4]}"
[[ ${switch_result[5]} == "/run/user/1000" ]] || fail "plain su leaves XDG_RUNTIME_DIR alone" "actual: ${switch_result[5]}"
[[ ${switch_result[6]} == "UNSET" && ${switch_result[7]} == "UNSET" ]] ||
  fail "plain su drops mise dirs that are the previous account's defaults" "data=${switch_result[6]} state=${switch_result[7]}"
[[ ${switch_result[8]} == "UNSET" && ${switch_result[9]} == "UNSET" && ${switch_result[10]} == "UNSET" && ${switch_result[11]} == "UNSET" ]] ||
  fail "plain su drops the previous account's mise shell session" \
    "shell=${switch_result[8]} orig=${switch_result[9]} diff=${switch_result[10]} session=${switch_result[11]}"
[[ ${switch_result[12]} == "$switched_path" ]] ||
  fail "plain su rebuilds PATH for the target account before mise activation" "actual PATH: ${switch_result[12]}"
pass "plain su drops inherited XDG defaults and mise state even when those directories are writable"

mapfile -t override_result < <(source_bootstrap_env bash \
  HOME="$target" \
  PATH="/opt/tools/bin:$original/.local/bin" \
  OMARCHY_XDG_HOME="$original" \
  XDG_CONFIG_HOME="$tmpdir/elsewhere" \
  XDG_CACHE_HOME="$original/.cache" \
  XDG_DATA_HOME="$tmpdir/custom-data" \
  XDG_STATE_HOME="$original/.local/state" \
  XDG_RUNTIME_DIR="/run/user/1000" \
  MISE_DATA_DIR="$tmpdir/custom-mise" \
  MISE_STATE_DIR="$original/custom-state")
[[ ${override_result[1]} == "$tmpdir/elsewhere" && ${override_result[3]} == "$tmpdir/custom-data" && ${override_result[6]} == "$tmpdir/custom-mise" ]] ||
  fail "plain su keeps intentional XDG and mise directory overrides" \
    "config=${override_result[1]} data=${override_result[3]} mise=${override_result[6]}"
[[ ${override_result[2]} == "UNSET" && ${override_result[4]} == "UNSET" && ${override_result[7]} == "UNSET" ]] ||
  fail "plain su still drops previous-home paths when other directories are overridden" \
    "cache=${override_result[2]} state=${override_result[4]} mise_state=${override_result[7]}"
[[ ${override_result[12]} == "$tmpdir/custom-mise/command-wrappers/bin:/opt/tools/bin:$target/.local/share/mise/shims:$target/.local/bin" ]] ||
  fail "plain su keeps an overridden mise data dir on PATH" "actual PATH: ${override_result[12]}"
pass "plain su keeps intentional directory overrides"

same_path="$home/.local/share/mise/installs/node/bin:/opt/tools/bin"
mapfile -t same_result < <(source_bootstrap_env bash \
  -u OMARCHY_XDG_HOME -u MISE_DATA_DIR -u MISE_STATE_DIR \
  HOME="$home" \
  PATH="$same_path" \
  XDG_CONFIG_HOME="$home/.config" \
  XDG_CACHE_HOME="$home/.cache" \
  XDG_DATA_HOME="$home/.local/share" \
  XDG_STATE_HOME="$home/.local/state" \
  XDG_RUNTIME_DIR="/run/user/1000" \
  MISE_SHELL=bash \
  __MISE_ORIG_PATH=/opt/tools/bin \
  __MISE_DIFF=keep-diff \
  __MISE_SESSION=keep-session)
[[ ${same_result[0]} == "$home" ]] || fail "the account that owns the session keeps that XDG owner" "actual: ${same_result[0]}"
[[ ${same_result[1]} == "$home/.config" && ${same_result[4]} == "$home/.local/state" && ${same_result[3]} == "$home/.local/share" ]] ||
  fail "a session keeps its own explicit XDG defaults" "config=${same_result[1]} data=${same_result[3]} state=${same_result[4]}"
[[ ${same_result[8]} == "bash" && ${same_result[9]} == "/opt/tools/bin" && ${same_result[10]} == "keep-diff" && ${same_result[11]} == "keep-session" ]] ||
  fail "a session keeps its own mise activation" \
    "shell=${same_result[8]} orig=${same_result[9]} diff=${same_result[10]} session=${same_result[11]}"
[[ ${same_result[12]} == "$home/.local/share/mise/command-wrappers/bin:$same_path:$home/.local/share/mise/shims:$home/.local/bin" ]] ||
  fail "a session keeps tool paths mise already added" "actual PATH: ${same_result[12]}"
pass "the same account keeps explicit XDG defaults and its mise session"

# No recorded owner. A directory this user created only looks like another
# home's default; it is an override and stays. A standard default this user
# does not own was inherited and is dropped.
mapfile -t owned_result < <(source_bootstrap_env bash \
  -u OMARCHY_XDG_HOME \
  HOME="$target" \
  PATH="/usr/bin" \
  XDG_STATE_HOME="$original/.local/state")
[[ ${owned_result[4]} == "$original/.local/state" ]] ||
  fail "an owned XDG default is kept when no previous account was recorded" "actual: ${owned_result[4]}"
pass "an owned XDG default is kept when no previous account was recorded"

foreign="$tmpdir/foreign"
foreign_ready=0
if (( EUID == 0 )); then
  mkdir -p "$foreign/.local/state"
  if chown 65534:65534 "$foreign" "$foreign/.local" "$foreign/.local/state" 2>/dev/null; then
    foreign_ready=1
  fi
else
  mkdir -p "$foreign/.local"
  ln -s /usr "$foreign/.local/state"
  [[ -d $foreign/.local/state && ! -O $foreign/.local/state ]] && foreign_ready=1
fi
if (( foreign_ready )); then
  mapfile -t foreign_result < <(source_bootstrap_env bash \
    -u OMARCHY_XDG_HOME \
    HOME="$target" \
    PATH="/usr/bin:$foreign/.local/bin" \
    XDG_STATE_HOME="$foreign/.local/state")
  [[ ${foreign_result[0]} == "$target" && ${foreign_result[4]} == "UNSET" ]] ||
    fail "an unowned inherited XDG default is dropped when no owner was recorded" \
      "owner=${foreign_result[0]} state=${foreign_result[4]}"
  [[ ${foreign_result[12]} == "$target/.local/share/mise/command-wrappers/bin:/usr/bin:$target/.local/share/mise/shims:$target/.local/bin" ]] ||
    fail "an unowned inherited home is removed from PATH" "actual PATH: ${foreign_result[12]}"
  pass "an unowned inherited XDG default is dropped when no owner was recorded"

  # Owned subdirectory inside an unowned parent (e.g. shared root-owned prefix)
  # is an intentional override and must not be mistaken for a foreign home.
  shared_root="$tmpdir/shared-parent"
  if (( EUID == 0 )); then
    mkdir -p "$shared_root/.local/state"
    chown 65534:65534 "$shared_root" "$shared_root/.local"
  else
    mkdir -p "$shared_root/.local/state"
  fi
  mapfile -t shared_owned_result < <(source_bootstrap_env bash \
    -u OMARCHY_XDG_HOME \
    HOME="$target" \
    PATH="/usr/bin" \
    XDG_STATE_HOME="$shared_root/.local/state")
  [[ ${shared_owned_result[4]} == "$shared_root/.local/state" ]] ||
    fail "an owned XDG directory under another parent is kept" "actual: ${shared_owned_result[4]}"
  pass "an owned XDG directory under another parent is kept"
else
  skip "no unowned directory fixture available for foreign XDG fallback test"
fi

# Private (0700) previous home without OMARCHY_XDG_HOME: the target user cannot
# traverse into $prev_home/.local/state, so `-d` on the XDG leaf fails with
# EACCES; ownership must fall back to the enclosing foreign home directory.
private_foreign="$tmpdir/private-foreign"
private_ready=0
if (( EUID == 0 )); then
  mkdir -p "$private_foreign"
  chmod 700 "$private_foreign"
  if chown 65534:65534 "$private_foreign" 2>/dev/null; then
    private_ready=1
  fi
else
  for candidate in /root /var/root /etc/ssl/private /var/db/sudo; do
    if [[ -d $candidate && ! -O $candidate && ! -x $candidate ]]; then
      ln -s "$candidate" "$private_foreign"
      private_ready=1
      break
    fi
  done
fi
if (( private_ready )); then
  mapfile -t private_result < <(source_bootstrap_env bash \
    -u OMARCHY_XDG_HOME \
    HOME="$target" \
    PATH="/usr/bin:$private_foreign/.local/bin" \
    XDG_CONFIG_HOME="$private_foreign/.config" \
    XDG_STATE_HOME="$private_foreign/.local/state")
  [[ ${private_result[0]} == "$target" && ${private_result[1]} == "UNSET" && ${private_result[4]} == "UNSET" ]] ||
    fail "a private (0700) unowned home is dropped when XDG leaf directories cannot be traversed" \
      "owner=${private_result[0]} config=${private_result[1]} state=${private_result[4]}"
  [[ ${private_result[12]} == "$target/.local/share/mise/command-wrappers/bin:/usr/bin:$target/.local/share/mise/shims:$target/.local/bin" ]] ||
    fail "a private (0700) unowned home is removed from PATH" "actual PATH: ${private_result[12]}"
  pass "a private (0700) unowned home is dropped when XDG leaf directories cannot be traversed"
else
  skip "no non-searchable unowned directory available for private-home XDG fallback test"
fi

if command -v zsh >/dev/null 2>&1; then
  mapfile -t zsh_switch_result < <(source_bootstrap_env zsh \
    HOME="$target" \
    PATH="$inherited_path" \
    OMARCHY_XDG_HOME="$original" \
    XDG_CONFIG_HOME="$original/.config" \
    XDG_DATA_HOME="$original/.local/share" \
    XDG_STATE_HOME="$original/.local/state" \
    XDG_CACHE_HOME="$original/.cache" \
    MISE_SHELL=bash \
    __MISE_ORIG_PATH="$mise_orig_path" \
    __MISE_DIFF=inherited \
    __MISE_SESSION=inherited)
  [[ ${zsh_switch_result[4]} == "UNSET" && ${zsh_switch_result[12]} == "$switched_path" ]] ||
    fail "plain su drops inherited XDG state when env-bootstrap is sourced by zsh" \
      "state=${zsh_switch_result[4]} PATH=${zsh_switch_result[12]}"
  pass "plain su drops inherited XDG state when env-bootstrap is sourced by zsh"
fi
