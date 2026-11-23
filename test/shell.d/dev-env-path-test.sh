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
# Production code always opens /etc/passwd. Root runs with no real foreign
# account home point a private copy of env-bootstrap at a fixture file.
active_bootstrap=$bootstrap

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
  ' sh "$active_bootstrap"
}

# Rewrite /etc/passwd in a dedicated copy. env-bootstrap has no test hook.
use_synthetic_passwd() {
  local passwd_file="$1"

  sed "s#/etc/passwd#${passwd_file}#g" "$bootstrap" >"$tmpdir/env-bootstrap-synthetic"
  active_bootstrap=$tmpdir/env-bootstrap-synthetic
}

reset_bootstrap() {
  active_bootstrap=$bootstrap
}

# Homes of accounts this process does not own. The directory's owner uid must
# be the passwd entry whose home is that directory. "/" is not a home root.
foreign_account_homes() {
  local passwd_file="${1:-/etc/passwd}"
  local uid home owner seen

  seen=":"
  [[ -r $passwd_file ]] || return 0
  while IFS=: read -r _ _ uid _ _ home _; do
    [[ $uid =~ ^[0-9]+$ ]] || continue
    home=${home%/}
    [[ -n $home && $home != / && -d $home && ! -O $home ]] || continue
    owner=$(stat -c '%u' "$home" 2>/dev/null || stat -f '%u' "$home" 2>/dev/null) || continue
    [[ $owner == "$uid" ]] || continue
    case $seen in
      *":$home:"*) continue ;;
    esac
    seen="$seen$home:"
    printf '%s\n' "$home"
  done <"$passwd_file"
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

same_account_functions=$(env -i HOME="$home" PATH=/usr/bin bash -c '
  stat() { :; }
  getent() { :; }
  . "$1"
  type -t stat
  type -t getent
' sh "$bootstrap")
[[ $same_account_functions == $'function\nfunction' ]] ||
  fail "a fresh shell preserves existing stat and getent functions" "$same_account_functions"
pass "a fresh shell preserves existing stat and getent functions"

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

foreign=
foreign_ready=0
# Another account's real home. A symlink to an unowned non-home such as
# /usr is an override: the prefix is not that owner's passwd home.
mapfile -t discovered_homes < <(foreign_account_homes)
if (( ${#discovered_homes[@]} > 0 )); then
  foreign=${discovered_homes[0]}
  foreign_ready=1
elif (( EUID == 0 )); then
  foreign=$tmpdir/foreign
  mkdir -p "$foreign/.local/state"
  if chown 65534:65534 "$foreign" "$foreign/.local" "$foreign/.local/state" 2>/dev/null; then
    printf 'omarchy-foreign:x:65534:65534::%s:/bin/sh\n' "$foreign" >"$tmpdir/foreign.passwd"
    use_synthetic_passwd "$tmpdir/foreign.passwd"
    foreign_ready=1
  fi
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

  mapfile -t bare_state_result < <(source_bootstrap_env bash \
    -u OMARCHY_XDG_HOME \
    HOME="$target" \
    PATH="/usr/bin" \
    XDG_STATE_HOME="$foreign/.local/state")
  [[ ${bare_state_result[4]} == "UNSET" ]] ||
    fail "a bare foreign state home is dropped with PATH=/usr/bin and no mise variables" \
      "state=${bare_state_result[4]}"
  [[ ${bare_state_result[8]} == "UNSET" && ${bare_state_result[11]} == "UNSET" ]] ||
    fail "a bare foreign state home does not invent a mise session" \
      "shell=${bare_state_result[8]} session=${bare_state_result[11]}"
  pass "a bare foreign state home is dropped with PATH=/usr/bin and no mise variables"
  reset_bootstrap
else
  skip "no unowned directory fixture available for foreign XDG fallback test"
fi

# Private (0700) previous home without OMARCHY_XDG_HOME: the target user cannot
# traverse into $prev_home/.local/state, so `-d` on the XDG leaf fails with
# EACCES; ownership must fall back to the enclosing foreign home directory.
private_foreign="$tmpdir/private-foreign"
private_ready=0
for candidate in /root /var/root /etc/ssl/private /var/db/sudo; do
  [[ -d $candidate && ! -O $candidate && ! -x $candidate ]] || continue
  while IFS= read -r home; do
    [[ $home == "$candidate" ]] || continue
    ln -s "$candidate" "$private_foreign"
    private_ready=1
    break
  done < <(foreign_account_homes)
  (( private_ready )) && break
done
if (( ! private_ready && EUID == 0 )); then
  mkdir -p "$private_foreign"
  chmod 700 "$private_foreign"
  if chown 65534:65534 "$private_foreign" 2>/dev/null; then
    printf 'omarchy-private:x:65534:65534::%s:/bin/sh\n' "$private_foreign" >"$tmpdir/private.passwd"
    use_synthetic_passwd "$tmpdir/private.passwd"
    private_ready=1
  fi
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
  reset_bootstrap
else
  skip "no non-searchable unowned directory available for private-home XDG fallback test"
fi

# Fresh session, no recorded owner. The cache lives under a writable directory
# this account does not own, and that directory is not the owner's passwd home.
shared_cache_root=
if (( EUID == 0 )); then
  shared_cache_root=$tmpdir/pr-18952-shared
  mkdir -p "$shared_cache_root"
  chown 65534:65534 "$shared_cache_root" 2>/dev/null || shared_cache_root=
else
  for candidate in /tmp /private/tmp /var/tmp /private/var/tmp; do
    [[ -d $candidate && ! -O $candidate && -w $candidate ]] || continue
    [[ -d $candidate/.cache && -O $candidate/.cache ]] && continue
    shared_is_home=0
    while IFS= read -r home; do
      [[ $home == "$candidate" ]] && shared_is_home=1
    done < <(foreign_account_homes)
    (( shared_is_home )) && continue
    shared_cache_root=$candidate
    break
  done
fi
if [[ -n $shared_cache_root ]]; then
  fresh_path="/usr/bin:$shared_cache_root/bin"
  mapfile -t fresh_result < <(source_bootstrap_env bash \
    -u OMARCHY_XDG_HOME \
    HOME="$target" \
    PATH="$fresh_path" \
    XDG_CACHE_HOME="$shared_cache_root/.cache" \
    MISE_SHELL=bash \
    __MISE_SESSION=keep-session)
  [[ ${fresh_result[2]} == "$shared_cache_root/.cache" ]] ||
    fail "a fresh session keeps a cache override whose parent is not an account home" \
      "cache=${fresh_result[2]}"
  [[ ${fresh_result[8]} == "bash" && ${fresh_result[11]} == "keep-session" ]] ||
    fail "a fresh session keeps its mise session when the cache parent is not an account home" \
      "shell=${fresh_result[8]} session=${fresh_result[11]}"
  [[ ${fresh_result[12]} == "$target/.local/share/mise/command-wrappers/bin:$fresh_path:$target/.local/share/mise/shims:$target/.local/bin" ]] ||
    fail "a fresh session keeps PATH entries under a non-home cache parent" \
      "actual PATH: ${fresh_result[12]}"
  pass "a fresh session keeps a cache override whose parent is not an account home"
else
  skip "no writable foreign non-home directory available for shared cache override test"
fi

mapfile -t account_homes < <(foreign_account_homes)
inherited_home=${account_homes[0]:-}
if [[ -z $inherited_home ]] && (( EUID == 0 )); then
  inherited_home=$tmpdir/inherited-home
  mkdir -p "$inherited_home"
  if chown 65534:65534 "$inherited_home" 2>/dev/null; then
    printf 'omarchy-inherited:x:65534:65534::%s:/bin/sh\n' "$inherited_home" >"$tmpdir/inherited.passwd"
    use_synthetic_passwd "$tmpdir/inherited.passwd"
  else
    inherited_home=
  fi
fi

if [[ -n $shared_cache_root && -n $inherited_home ]]; then
  mapfile -t mixed_result < <(source_bootstrap_env bash \
    -u OMARCHY_XDG_HOME \
    HOME="$target" \
    PATH="/usr/bin:$inherited_home/.local/share/mise/shims:$inherited_home/.local/bin" \
    XDG_CONFIG_HOME="$shared_cache_root/.config" \
    XDG_STATE_HOME="$inherited_home/.local/state" \
    MISE_SHELL=bash \
    __MISE_ORIG_PATH="$inherited_home/.local/share/mise/shims" \
    __MISE_DIFF=inherited \
    __MISE_SESSION=inherited \
    __MISE_EXE="$inherited_home/.local/bin/mise")
  [[ ${mixed_result[1]} == "$shared_cache_root/.config" ]] ||
    fail "a shared config override stays when inherited state is cleaned" \
      "config=${mixed_result[1]}"
  [[ ${mixed_result[4]} == "UNSET" ]] ||
    fail "inherited state is cleaned when a shared config override is also set" \
      "state=${mixed_result[4]}"
  [[ ${mixed_result[8]} == "UNSET" && ${mixed_result[9]} == "UNSET" && ${mixed_result[10]} == "UNSET" && ${mixed_result[11]} == "UNSET" ]] ||
    fail "inherited mise session is cleaned when a shared config override is also set" \
      "shell=${mixed_result[8]} orig=${mixed_result[9]} diff=${mixed_result[10]} session=${mixed_result[11]}"
  [[ ${mixed_result[12]} == "$target/.local/share/mise/command-wrappers/bin:/usr/bin:$target/.local/share/mise/shims:$target/.local/bin" ]] ||
    fail "inherited home is removed from PATH when a shared config override is also set" \
      "actual PATH: ${mixed_result[12]}"
  pass "a shared config override stays while the previous account's state, PATH, and mise session are cleaned"

  mapfile -t bare_mixed_result < <(source_bootstrap_env bash \
    -u OMARCHY_XDG_HOME \
    HOME="$target" \
    PATH="/usr/bin" \
    XDG_CONFIG_HOME="$shared_cache_root/.config" \
    XDG_STATE_HOME="$inherited_home/.local/state")
  [[ ${bare_mixed_result[1]} == "$shared_cache_root/.config" ]] ||
    fail "a shared config override stays when foreign state is dropped with no PATH or mise corroboration" \
      "config=${bare_mixed_result[1]}"
  [[ ${bare_mixed_result[4]} == "UNSET" ]] ||
    fail "foreign state is dropped when a shared config override is set and PATH is only /usr/bin" \
      "state=${bare_mixed_result[4]}"
  [[ ${bare_mixed_result[12]} == "$target/.local/share/mise/command-wrappers/bin:/usr/bin:$target/.local/share/mise/shims:$target/.local/bin" ]] ||
    fail "PATH stays free of the foreign home when state is dropped without mise corroboration" \
      "actual PATH: ${bare_mixed_result[12]}"
  pass "a shared config override stays while foreign state is dropped with PATH=/usr/bin and no mise variables"
  reset_bootstrap
else
  skip "no shared directory and foreign account home available for mixed XDG fallback test"
fi

override_home=${account_homes[1]:-}
if [[ -z $override_home ]] && (( EUID == 0 )); then
  two_inherited=$tmpdir/alice-home
  override_home=$tmpdir/carol-home
  mkdir -p "$two_inherited" "$override_home"
  if chown 65534:65534 "$two_inherited" 2>/dev/null && chown 65533:65533 "$override_home" 2>/dev/null; then
    printf '%s\n' \
      "alice:x:65534:65534::${two_inherited}:/bin/sh" \
      "carol:x:65533:65533::${override_home}:/bin/sh" \
      >"$tmpdir/two-homes.passwd"
    use_synthetic_passwd "$tmpdir/two-homes.passwd"
    inherited_home=$two_inherited
  else
    override_home=
  fi
fi
if [[ -n $inherited_home && -n $override_home && $inherited_home != "$override_home" ]]; then
  mapfile -t conflict_result < <(source_bootstrap_env bash \
    -u OMARCHY_XDG_HOME \
    HOME="$target" \
    PATH="/usr/bin:$inherited_home/.local/bin" \
    XDG_CONFIG_HOME="$override_home/.config" \
    XDG_STATE_HOME="$inherited_home/.local/state" \
    MISE_SHELL=bash \
    __MISE_ORIG_PATH="$inherited_home/.local/share/mise/shims" \
    __MISE_DIFF=inherited \
    __MISE_SESSION=inherited \
    __MISE_EXE="$inherited_home/.local/bin/mise")
  [[ ${conflict_result[1]} == "$override_home/.config" ]] ||
    fail "a config override in another account home stays while inherited state is cleaned" \
      "config=${conflict_result[1]}"
  [[ ${conflict_result[4]} == "UNSET" ]] ||
    fail "inherited state is cleaned when another account home is only a config override" \
      "state=${conflict_result[4]}"
  [[ ${conflict_result[8]} == "UNSET" && ${conflict_result[9]} == "UNSET" && ${conflict_result[10]} == "UNSET" && ${conflict_result[11]} == "UNSET" ]] ||
    fail "inherited mise session is cleaned when another account home is only a config override" \
      "shell=${conflict_result[8]} orig=${conflict_result[9]} diff=${conflict_result[10]} session=${conflict_result[11]}"
  [[ ${conflict_result[12]} == "$target/.local/share/mise/command-wrappers/bin:/usr/bin:$target/.local/share/mise/shims:$target/.local/bin" ]] ||
    fail "the previous account is removed from PATH when another account home is only a config override" \
      "actual PATH: ${conflict_result[12]}"
  pass "another account's config override stays while the previous account's state, PATH, and mise session are cleaned"

  mapfile -t two_account_result < <(source_bootstrap_env bash \
    -u OMARCHY_XDG_HOME \
    HOME="$target" \
    PATH="/usr/bin" \
    XDG_CONFIG_HOME="$override_home/.config" \
    XDG_STATE_HOME="$inherited_home/.local/state")
  [[ ${two_account_result[1]} == "$override_home/.config" ]] ||
    fail "another account's lone config override stays when foreign state is dropped with no PATH or mise corroboration" \
      "config=${two_account_result[1]}"
  [[ ${two_account_result[4]} == "UNSET" ]] ||
    fail "foreign state is dropped when another account home is only a config override and PATH is /usr/bin" \
      "state=${two_account_result[4]}"
  [[ ${two_account_result[12]} == "$target/.local/share/mise/command-wrappers/bin:/usr/bin:$target/.local/share/mise/shims:$target/.local/bin" ]] ||
    fail "neither account home is added to PATH when only foreign state is inherited" \
      "actual PATH: ${two_account_result[12]}"
  pass "another account's lone config override stays while foreign state is dropped with PATH=/usr/bin and no mise variables"

  two_qualified_path="/usr/bin:$inherited_home/.local/bin:$override_home/.local/bin"
  mapfile -t two_qualified_result < <(source_bootstrap_env bash \
    -u OMARCHY_XDG_HOME \
    HOME="$target" \
    PATH="$two_qualified_path" \
    XDG_CONFIG_HOME="$override_home/.config" \
    XDG_CACHE_HOME="$override_home/.cache" \
    XDG_STATE_HOME="$inherited_home/.local/state" \
    MISE_SHELL=bash \
    __MISE_SESSION=inherited)
  [[ ${two_qualified_result[1]} == "UNSET" && ${two_qualified_result[2]} == "UNSET" && ${two_qualified_result[4]} == "UNSET" ]] ||
    fail "two qualified foreign account homes both drop their XDG defaults" \
      "config=${two_qualified_result[1]} cache=${two_qualified_result[2]} state=${two_qualified_result[4]}"
  [[ ${two_qualified_result[8]} == "UNSET" && ${two_qualified_result[11]} == "UNSET" ]] ||
    fail "two qualified foreign account homes clear the mise session" \
      "shell=${two_qualified_result[8]} session=${two_qualified_result[11]}"
  [[ ${two_qualified_result[12]} == "$target/.local/share/mise/command-wrappers/bin:/usr/bin:$target/.local/share/mise/shims:$target/.local/bin" ]] ||
    fail "two qualified foreign account homes are both removed from PATH" \
      "actual PATH: ${two_qualified_result[12]}"
  pass "two qualified foreign account homes are both cleaned, including PATH entries and the mise session"
else
  skip "two foreign account homes are not available for the conflicting-root fallback test"
fi
reset_bootstrap

lone_home=${account_homes[0]:-}
if [[ -z $lone_home && -n $inherited_home && -f $tmpdir/inherited.passwd ]]; then
  use_synthetic_passwd "$tmpdir/inherited.passwd"
  lone_home=$(foreign_account_homes "$tmpdir/inherited.passwd")
fi
if [[ -n $lone_home ]]; then
  mapfile -t lone_result < <(source_bootstrap_env bash \
    -u OMARCHY_XDG_HOME \
    HOME="$target" \
    PATH="/usr/bin" \
    XDG_CONFIG_HOME="$lone_home/.config" \
    MISE_SHELL=bash \
    __MISE_SESSION=keep-session)
  [[ ${lone_result[1]} == "$lone_home/.config" ]] ||
    fail "a single foreign account config override is kept when the session did not come from that home" \
      "config=${lone_result[1]}"
  [[ ${lone_result[8]} == "bash" && ${lone_result[11]} == "keep-session" ]] ||
    fail "a single foreign account config override keeps the current mise session" \
      "shell=${lone_result[8]} session=${lone_result[11]}"
  pass "a single foreign account config override is kept when the session did not come from that home"

  mapfile -t quad_result < <(source_bootstrap_env bash \
    -u OMARCHY_XDG_HOME \
    HOME="$target" \
    PATH="/usr/bin" \
    XDG_CONFIG_HOME="$lone_home/.config" \
    XDG_CACHE_HOME="$lone_home/.cache" \
    XDG_DATA_HOME="$lone_home/.local/share" \
    XDG_STATE_HOME="$lone_home/.local/state" \
    MISE_SHELL=bash \
    __MISE_SESSION=inherited)
  [[ ${quad_result[1]} == "UNSET" && ${quad_result[2]} == "UNSET" && ${quad_result[3]} == "UNSET" && ${quad_result[4]} == "UNSET" ]] ||
    fail "four XDG defaults under one foreign home are dropped even without a PATH entry" \
      "config=${quad_result[1]} cache=${quad_result[2]} data=${quad_result[3]} state=${quad_result[4]}"
  [[ ${quad_result[11]} == "UNSET" ]] ||
    fail "four inherited XDG defaults clear the previous mise session" \
      "session=${quad_result[11]}"
  pass "four XDG defaults under one foreign home are dropped even without a PATH entry"

  hostile_home=$lone_home
  hostile_bin=$tmpdir/hostile-bin
  hostile_log=$tmpdir/hostile-shim.log
  mkdir -p "$hostile_bin"
  cat >"$hostile_bin/stat" <<'EOF'
#!/bin/sh
printf '%s\n' stat >>"$OMARCHY_SHIM_LOG"
printf '%s\n' '59999 0:1'
EOF
  cat >"$hostile_bin/getent" <<'EOF'
#!/bin/sh
printf '%s\n' getent >>"$OMARCHY_SHIM_LOG"
printf '%s\n' 'fake:x:59999:59999::/tmp/not-a-home:/bin/sh'
EOF
  chmod +x "$hostile_bin/stat" "$hostile_bin/getent"
  hostile_shell=$(command -v bash)
  hostile_import=$(env 'BASH_FUNC_command%%=() { echo imported-command; }' "$hostile_shell" -c 'type command')
  [[ $hostile_import == *function* ]] ||
    fail "bash imports BASH_FUNC_command so the hostile-function check is real" "$hostile_import"
  mapfile -t hostile_result < <(source_bootstrap_env bash \
    -u OMARCHY_XDG_HOME \
    HOME="$target" \
    PATH="$hostile_bin:/usr/bin" \
    OMARCHY_SHIM_LOG="$hostile_log" \
    XDG_STATE_HOME="$hostile_home/.local/state" \
    'BASH_FUNC_command%%=() { printf "%s\n" command-func >>"$OMARCHY_SHIM_LOG"; builtin command "$@"; }' \
    'BASH_FUNC_builtin%%=() { printf "%s\n" builtin-func >>"$OMARCHY_SHIM_LOG"; }' \
    'BASH_FUNC_unset%%=() { printf "%s\n" unset-func >>"$OMARCHY_SHIM_LOG"; }' \
    'BASH_FUNC_stat%%=() { printf "%s\n" stat-func >>"$OMARCHY_SHIM_LOG"; printf "%s\n" "59999 0:1"; }' \
    'BASH_FUNC_getent%%=() { printf "%s\n" getent-func >>"$OMARCHY_SHIM_LOG"; printf "%s\n" "fake:x:59999:59999::/tmp/not-a-home:/bin/sh"; }')
  [[ ${hostile_result[4]} == "UNSET" ]] ||
    fail "command -p stat and getent ignore a PATH shim and imported functions" \
      "state=${hostile_result[4]}"
  [[ ! -e $hostile_log ]] ||
    fail "a PATH shim or imported command/builtin/unset/stat/getent function ran during env-bootstrap" \
      "$(<"$hostile_log")"
  hostile_shellopts=$(env -i \
    HOME="$target" \
    PATH="$hostile_bin:/usr/bin" \
    XDG_STATE_HOME="$hostile_home/.local/state" \
    'BASH_FUNC_shopt%%=() { printf "%s\n" shopt-func >>"$OMARCHY_SHIM_LOG"; }' \
    OMARCHY_SHIM_LOG="$hostile_log" \
    "$hostile_shell" -c '. "$1"; set -e; result=$(false; printf recovered); printf "%s|%s|%s\n" "${SHELLOPTS:-}" "${BASHOPTS:-}" "$result"' sh "$active_bootstrap" || true)
  [[ ! -e $hostile_log ]] ||
    fail "imported shopt function ran during env-bootstrap" "$(<"$hostile_log")"
  [[ $hostile_shellopts == *\|recovered ]] ||
    fail "env-bootstrap broke set -e command substitution recovery" "$hostile_shellopts"
  [[ :${hostile_shellopts%%|*}: != *:posix:* ]] ||
    fail "env-bootstrap restores non-posix mode after scrubbing imported functions" "$hostile_shellopts"
  hostile_bashopts=${hostile_shellopts#*|}
  hostile_bashopts=${hostile_bashopts%|*}
  [[ :$hostile_bashopts: != *:inherit_errexit:* ]] ||
    fail "env-bootstrap left inherit_errexit enabled after scrubbing imported functions" "$hostile_shellopts"
  pre_inherit_bashopts=$(env -i \
    HOME="$target" \
    PATH="$hostile_bin:/usr/bin" \
    XDG_STATE_HOME="$hostile_home/.local/state" \
    "$hostile_shell" -O inherit_errexit -c '. "$1"; printf "%s\n" "${BASHOPTS:-}"' sh "$active_bootstrap")
  [[ :$pre_inherit_bashopts: == *:inherit_errexit:* ]] ||
    fail "env-bootstrap preserves inherit_errexit when already enabled" "$pre_inherit_bashopts"
  posix_shellopts=$(env -i \
    HOME="$target" \
    PATH="$hostile_bin:/usr/bin" \
    XDG_STATE_HOME="$hostile_home/.local/state" \
    "$hostile_shell" --posix -c '. "$1"; printf "%s\n" "${SHELLOPTS:-}"' sh "$active_bootstrap")
  [[ :$posix_shellopts: == *:posix:* ]] ||
    fail "env-bootstrap preserves posix mode when bash started in posix mode" "$posix_shellopts"
  pass "a hostile PATH shim and imported command/builtin/unset/shopt/stat/getent functions do not run or alter shell options"
fi
reset_bootstrap

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
