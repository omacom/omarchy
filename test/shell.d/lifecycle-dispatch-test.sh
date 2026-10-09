#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

dispatch="$ROOT/bin/omarchy-lifecycle-dispatch"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

operations=(provision-prepare provision-commit provision-verify reset-prepare reset-verify reset-commit reset-rollback update-verify update-takeover luks-slots setup-boot)
apple_optional=()

for platform in aarch64-apple aarch64 x86; do
  fake_platform "$tmp/$platform" "$platform"
done
mkdir -p "$tmp/contradiction/proc/device-tree"
printf '%s\0' apple,j416c qcom,x1e80100 >"$tmp/contradiction/proc/device-tree/compatible"
cp -r "$tmp/aarch64-apple/bin" "$tmp/contradiction/bin"

# A root-owned directory of entrypoints stands in for the boot package; in a
# fixture root the caller's own files count as root's.
implementation=usr/lib/omarchy/mac-boot
install_implementation() {
  local root=$1 operation
  rm -rf "$root"
  mkdir -p "$root/$implementation"
  for operation in "${operations[@]}"; do
    cat >"$root/$implementation/$operation" <<SH
#!/bin/bash
{ printf '%s' "$operation"; printf ' %q' "\$@"; echo; } >>"$tmp/ran"
env >"$tmp/env"
[[ ! -e $tmp/fail-with ]] || exit "\$(cat "$tmp/fail-with")"
SH
    chmod 755 "$root/$implementation/$operation"
  done
  chmod -R go-w "$root"
}

# Runs the dispatcher on a platform fixture: $1 platform, $2 lifecycle root.
on() {
  local platform=$1 root=$2
  shift 2
  OMARCHY_PROC_ROOT="$tmp/$platform/proc" OMARCHY_LIFECYCLE_ROOT="$root" PATH="$tmp/$platform/bin:$PATH" \
    "$dispatch" "$@"
}

# -p in the shebang is what keeps a root caller's exported functions and
# BASH_ENV out, so an ordinary Bash launch with a decoy -p argument is refused
# before it resolves anything.
status=0
output=$(/usr/bin/bash "$dispatch" -p 2>&1) || status=$?
(( status == 126 )) && [[ $output == "Refusing an unsafe Bash startup." ]] ||
  fail "an ordinary Bash launch with a decoy -p is refused" "status $status: $output"
pass "an ordinary Bash launch with a decoy -p is refused"

require_platform_fixtures "lifecycle dispatch on platform fixtures"

full=$tmp/full
install_implementation "$full"
empty=$tmp/empty
mkdir -p "$empty"

# x86 and plain aarch64 register no boot package: every operation
# is a no-op there, even with Mac entrypoints on disk that would fail.
echo 9 >"$tmp/fail-with"
for platform in x86 aarch64; do
  for operation in "${operations[@]}"; do
    rm -f "$tmp/ran"
    output=$(on "$platform" "$full" "$operation" --flag 2>&1) || fail "$platform: $operation is a no-op" "$output"
    [[ -z $output && ! -e $tmp/ran ]] || fail "$platform: $operation runs nothing and says nothing" "$output"
    output=$(on "$platform" "$full" --resolve "$operation" 2>&1) || fail "$platform: $operation resolves" "$output"
    [[ -z $output ]] || fail "$platform: $operation resolves to nothing" "$output"
  done
  pass "$platform: every operation is a no-op and no Mac entrypoint runs"
done
rm -f "$tmp/fail-with"

# Apple with omarchy-mac-boot: each operation runs its entrypoint with the
# caller's arguments, a cleared environment and a fixed PATH.
export CALLER_SECRET=leak
for operation in "${operations[@]}"; do
  rm -f "$tmp/ran"
  on aarch64-apple "$full" "$operation" first "second arg" || fail "apple: $operation runs its entrypoint"
  [[ $(cat "$tmp/ran") == "$operation first second\\ arg" ]] || fail "apple: $operation passes its arguments" "$(cat "$tmp/ran")"
  ! grep -q CALLER_SECRET "$tmp/env" || fail "apple: $operation does not pass the caller's environment" "$(cat "$tmp/env")"
  grep -qx 'PATH=/usr/local/sbin:/usr/local/bin:/usr/bin' "$tmp/env" || fail "apple: $operation runs with a fixed PATH" "$(cat "$tmp/env")"
  resolved=$(on aarch64-apple "$full" --resolve "$operation") || fail "apple: $operation resolves"
  [[ $resolved == "$full/$implementation/$operation" ]] || fail "apple: $operation resolves to its entrypoint" "$resolved"
done
unset CALLER_SECRET
echo 7 >"$tmp/fail-with"
status=0
on aarch64-apple "$full" provision-commit || status=$?
(( status == 7 )) || fail "apple: the entrypoint's exit status is the dispatcher's" "status: $status"
rm -f "$tmp/fail-with"
pass "apple: each operation runs the boot package's entrypoint with its arguments and status"

# Apple without omarchy-mac-boot: required operations fail naming the package
# and entrypoint; optional ones are no-ops.
for operation in "${operations[@]}"; do
  status=0
  output=$(on aarch64-apple "$empty" "$operation" 2>&1) || status=$?
  if [[ " ${apple_optional[*]} " == *" $operation "* ]]; then
    (( status == 0 )) && [[ -z $output ]] || fail "apple: optional $operation is a no-op without the boot package" "$output"
    output=$(on aarch64-apple "$empty" --resolve "$operation" 2>&1) && [[ -z $output ]] ||
      fail "apple: optional $operation resolves to nothing without the boot package" "$output"
  else
    (( status == 3 )) || fail "apple: required $operation fails with status 3 without the boot package" "status: $status"
    [[ $output == "Error: $operation on aarch64-apple needs omarchy-mac-boot, which provides /usr/lib/omarchy/mac-boot/$operation; it is not installed" ]] ||
      fail "apple: required $operation names the missing package and entrypoint" "$output"
    status=0
    on aarch64-apple "$empty" --resolve "$operation" >/dev/null 2>&1 || status=$?
    (( status == 3 )) || fail "apple: required $operation does not resolve without the boot package" "status: $status"
  fi
done
pass "apple: without omarchy-mac-boot required operations fail with a clear message and optional ones are no-ops"

# An installed omarchy-mac-boot that predates an operation is named with its
# version, as an update away rather than missing.
older=$tmp/older
mkdir -p "$older/usr/lib/omarchy/mac-boot" "$older/var/lib/pacman/local/omarchy-mac-boot-20260921-10"
for operation in "${operations[@]}"; do
  [[ " ${apple_optional[*]} " == *" $operation "* ]] && continue
  status=0
  output=$(on aarch64-apple "$older" "$operation" 2>&1) || status=$?
  (( status == 1 )) && [[ $output == "Error: $operation on aarch64-apple needs /usr/lib/omarchy/mac-boot/$operation, which omarchy-mac-boot 20260921-10 does not provide; update omarchy-mac-boot" ]] ||
    fail "apple: an omarchy-mac-boot without $operation is named with its version" "status $status: $output"
done
pass "apple: an installed omarchy-mac-boot that lacks a required operation fails asking for its update"

# An entrypoint anyone but root could have changed never runs, optional or not.
untrusted() {
  local description=$1 operation=$2
  rm -f "$tmp/ran"
  if output=$(on aarch64-apple "$full" "$operation" 2>&1); then
    fail "apple: $description is refused"
  fi
  [[ ! -e $tmp/ran ]] || fail "apple: $description never runs"
  [[ $output == *"refusing /usr/lib/omarchy/mac-boot/$operation"* ]] || fail "apple: $description is named" "$output"
  if on aarch64-apple "$full" --resolve "$operation" >/dev/null 2>&1; then
    fail "apple: $description does not resolve"
  fi
}

install_implementation "$full"
chmod g+w "$full/$implementation/reset-commit"
untrusted "a group-writable entrypoint" reset-commit

install_implementation "$full"
chmod o+w "$full/$implementation/provision-commit"
untrusted "a world-writable entrypoint" provision-commit

install_implementation "$full"
chmod o+w "$full/usr/lib/omarchy"
untrusted "an entrypoint in a world-writable directory" provision-verify

install_implementation "$full"
mv "$full/$implementation/provision-prepare" "$tmp/elsewhere"
ln -s "$tmp/elsewhere" "$full/$implementation/provision-prepare"
untrusted "a symlinked entrypoint" provision-prepare

install_implementation "$full"
chmod 644 "$full/$implementation/update-verify"
untrusted "a non-executable entrypoint" update-verify

install_implementation "$full"
rm "$full/$implementation/reset-verify"
mkdir "$full/$implementation/reset-verify"
chmod 755 "$full/$implementation/reset-verify"
untrusted "a directory in place of an entrypoint" reset-verify
pass "apple: an entrypoint that is not a root-owned file in root-owned directories never runs"

install_implementation "$full"
for arguments in "" "unknown-operation" "--resolve" "--resolve unknown-operation"; do
  rm -f "$tmp/ran"
  status=0
  output=$(on aarch64-apple "$full" $arguments 2>&1) || status=$?
  (( status == 2 )) && [[ $output == Usage:* ]] || fail "'$arguments' is a usage error" "status $status: $output"
  [[ ! -e $tmp/ran ]] || fail "'$arguments' runs nothing"
done
status=0
output=$(on aarch64-apple "$full" "provision-prepare provision-commit" 2>&1) || status=$?
(( status == 2 )) && [[ ! -e $tmp/ran ]] || fail "two operation names in one argument are a usage error" "status $status: $output"
pass "an operation outside the fixed set is a usage error"

rm -f "$tmp/ran"
if output=$(on contradiction "$full" provision-commit 2>&1); then
  fail "a platform the detector cannot settle fails the operation"
fi
[[ ! -e $tmp/ran && $output == *"cannot determine the hardware platform for provision-commit"* ]] ||
  fail "an undetermined platform runs nothing and says why" "$output"
pass "an undetermined platform fails closed"

rm -f "$tmp/ran"
if output=$(cd "$tmp" && on aarch64-apple full provision-commit 2>&1); then
  fail "a relative fixture root is refused"
fi
[[ ! -e $tmp/ran && $output == "Error: OMARCHY_LIFECYCLE_ROOT must be an absolute path" ]] ||
  fail "a relative fixture root runs nothing and says why" "$output"
pass "a relative fixture root is refused"

# Root resolves only the fixed /usr/lib path, whatever fixture root its
# environment names. A copy beside a detector that always answers Apple keeps
# the live platform out of the way.
if unshare --user --map-root-user true 2>/dev/null; then
  mkdir -p "$tmp/rootbin"
  cp "$dispatch" "$tmp/rootbin/"
  printf '#!/bin/bash\necho aarch64-apple\n' >"$tmp/rootbin/omarchy-hw-platform"
  chmod +x "$tmp/rootbin/omarchy-hw-platform"
  rm -f "$tmp/ran"
  status=0
  output=$(OMARCHY_LIFECYCLE_ROOT="$full" unshare --user --map-root-user "$tmp/rootbin/omarchy-lifecycle-dispatch" reset-prepare 2>&1) ||
    status=$?
  (( status != 0 )) && [[ ! -e $tmp/ran && $output != *"$tmp"* && $output == *" /usr/lib/omarchy/mac-boot/reset-prepare"* ]] ||
    fail "root ignores a fixture root in its environment" "status $status: $output"
  pass "root ignores fixture roots when resolving an operation"

  printf 'touch %q\n' "$tmp/bash-env-ran" >"$tmp/bash-env"
  dirname() { touch "$tmp/function-ran"; echo /nonexistent; }
  export -f dirname
  BASH_ENV="$tmp/bash-env" unshare --user --map-root-user "$dispatch" --resolve provision-commit >/dev/null 2>&1 || true
  unset -f dirname
  [[ ! -e $tmp/bash-env-ran && ! -e $tmp/function-ran ]] || fail "root runs no code from BASH_ENV or exported functions"
  pass "root runs no code from BASH_ENV or exported functions"
else
  skip "no unprivileged user namespace; skipping the root override probe"
fi

# ── setup and app-install operations ─────────────────────────────────────────

# System and user setup and the app-install hooks resolve in omarchy-mac's
# directory on a Mac, never in omarchy-mac-boot's, and are optional everywhere.
setup_operations=(setup-system setup-user post-install pre-remove)
user_operations=(setup-user post-install pre-remove)
setup_implementation=usr/lib/omarchy/mac
install_setup() {
  local root=$1 dir=$2 operation
  mkdir -p "$root/$dir"
  for operation in "${setup_operations[@]}"; do
    cat >"$root/$dir/$operation" <<SH
#!/bin/bash
{ printf '%s' "$operation"; (( \$# == 0 )) || printf ' %q' "\$@"; echo; } >>"$tmp/ran"
env >"$tmp/env"
[[ ! -e $tmp/fail-with ]] || exit "\$(cat "$tmp/fail-with")"
SH
    chmod 755 "$root/$dir/$operation"
  done
  chmod -R go-w "$root"
}

with_mac=$tmp/with-mac
rm -rf "$with_mac"
install_setup "$with_mac" "$setup_implementation"
boot_only=$tmp/boot-only
rm -rf "$boot_only"
install_setup "$boot_only" "$implementation"

echo 9 >"$tmp/fail-with"
for platform in x86 aarch64; do
  for operation in "${setup_operations[@]}"; do
    rm -f "$tmp/ran"
    output=$(on "$platform" "$with_mac" "$operation" 2>&1) && [[ -z $output && ! -e $tmp/ran ]] ||
      fail "$platform: $operation is a no-op" "$output"
    output=$(on "$platform" "$with_mac" --resolve "$operation" 2>&1) && [[ -z $output ]] ||
      fail "$platform: $operation resolves to nothing" "$output"
  done
done
rm -f "$tmp/fail-with"
pass "x86 and plain aarch64: setup and app-install operations are no-ops, even with Mac entrypoints on disk"

for operation in "${setup_operations[@]}"; do
  rm -f "$tmp/ran"
  resolved=$(on aarch64-apple "$with_mac" --resolve "$operation") && [[ $resolved == "$with_mac/$setup_implementation/$operation" ]] ||
    fail "apple: $operation resolves to omarchy-mac's entrypoint" "$resolved"
  output=$(on aarch64-apple "$empty" "$operation" 2>&1) && [[ -z $output ]] ||
    fail "apple: $operation is a no-op without omarchy-mac" "$output"
  output=$(on aarch64-apple "$boot_only" "$operation" 2>&1) && [[ -z $output && ! -e $tmp/ran ]] ||
    fail "apple: $operation never runs from omarchy-mac-boot's directory" "$output"
done
pass "apple: setup and the app-install hooks resolve in omarchy-mac's directory, and are no-ops without omarchy-mac"

session=(CALLER_SECRET=leak HOME=/home/owner USER=owner XDG_RUNTIME_DIR=/run/user/1000 XDG_CONFIG_HOME=/home/owner/.cfg
  XDG_STATE_HOME=/home/owner/.st XDG_DATA_HOME=/home/owner/.data DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus OMARCHY_PATH=/usr/share/omarchy)
rm -f "$tmp/ran"
env -u WAYLAND_DISPLAY "${session[@]}" OMARCHY_PROC_ROOT="$tmp/aarch64-apple/proc" OMARCHY_LIFECYCLE_ROOT="$with_mac" \
  PATH="$tmp/aarch64-apple/bin:$PATH" "$dispatch" setup-system image-first-boot || fail "apple: setup-system runs"
[[ $(cat "$tmp/ran") == "setup-system image-first-boot" ]] || fail "apple: setup-system gets its argument" "$(cat "$tmp/ran")"
[[ $(grep -Ev '^(_|PWD|OLDPWD|SHLVL)=' "$tmp/env" | sort) == "PATH=/usr/local/sbin:/usr/local/bin:/usr/bin" ]] ||
  fail "apple: setup-system gets PATH alone" "$(cat "$tmp/env")"
expected=$(printf '%s\n' DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus HOME=/home/owner OMARCHY_PATH=/usr/share/omarchy \
  PATH=/usr/local/sbin:/usr/local/bin:/usr/bin USER=owner XDG_CONFIG_HOME=/home/owner/.cfg XDG_RUNTIME_DIR=/run/user/1000 XDG_STATE_HOME=/home/owner/.st)
for invocation in "setup-user" "post-install steam" "pre-remove steam"; do
  rm -f "$tmp/ran"
  env -u WAYLAND_DISPLAY "${session[@]}" OMARCHY_PROC_ROOT="$tmp/aarch64-apple/proc" OMARCHY_LIFECYCLE_ROOT="$with_mac" \
    PATH="$tmp/aarch64-apple/bin:$PATH" "$dispatch" $invocation || fail "apple: $invocation runs"
  [[ $(cat "$tmp/ran") == "$invocation" ]] || fail "apple: $invocation runs its entrypoint with its argument" "$(cat "$tmp/ran")"
  [[ $(grep -Ev '^(_|PWD|OLDPWD|SHLVL)=' "$tmp/env" | sort) == "$expected" ]] ||
    fail "apple: $invocation gets the user's home and session, and nothing else" "$(cat "$tmp/env")"
done
echo 3 >"$tmp/fail-with"
status=0
on aarch64-apple "$with_mac" setup-user || status=$?
(( status == 3 )) || fail "apple: a setup entrypoint's own status 3 passes through" "status $status"
rm -f "$tmp/fail-with"
pass "apple: setup-system gets PATH alone and the user operations the user's home and session, with the entrypoint's status"

chmod o+w "$with_mac/$setup_implementation/setup-user"
rm -f "$tmp/ran"
if output=$(on aarch64-apple "$with_mac" setup-user 2>&1); then
  fail "apple: a world-writable setup entrypoint is refused"
fi
[[ ! -e $tmp/ran && $output == *"refusing /usr/lib/omarchy/mac/setup-user"* ]] ||
  fail "apple: a world-writable setup entrypoint never runs" "$output"
chmod o-w "$with_mac/$setup_implementation/setup-user"
pass "apple: a setup entrypoint that fails the trust rules never runs"

# Root is refused a user operation only where the platform registers it, so an
# installer run with sudo still finishes elsewhere. As root the dispatcher runs
# the detector beside it, so each platform gets a copy beside a stub.
if unshare --user --map-root-user true 2>/dev/null; then
  for platform in aarch64-apple x86 aarch64; do
    mkdir -p "$tmp/root-$platform"
    cp "$dispatch" "$tmp/root-$platform/"
    printf '#!/bin/bash\necho %s\n' "$platform" >"$tmp/root-$platform/omarchy-hw-platform"
    chmod +x "$tmp/root-$platform/omarchy-hw-platform"
    for operation in "${user_operations[@]}"; do
      for arguments in "$operation" "--resolve $operation" "$operation steam"; do
        rm -f "$tmp/ran"
        status=0
        output=$(OMARCHY_LIFECYCLE_ROOT="$with_mac" unshare --user --map-root-user \
          "$tmp/root-$platform/omarchy-lifecycle-dispatch" $arguments 2>&1) || status=$?
        [[ ! -e $tmp/ran ]] || fail "$platform: root never runs '$arguments'"
        if [[ $platform == "aarch64-apple" ]]; then
          (( status == 1 )) && [[ $output == "Error: $operation runs as the user, never as root" ]] ||
            fail "apple: root is refused '$arguments'" "status $status: $output"
        else
          (( status == 0 )) && [[ -z $output ]] || fail "$platform: '$arguments' is a no-op for root" "status $status: $output"
        fi
      done
    done
  done
  pass "setup-user, post-install and pre-remove refuse root on Apple Silicon, and are no-ops for root elsewhere"
else
  skip "no unprivileged user namespace; skipping the root refusal of the user operations"
fi
