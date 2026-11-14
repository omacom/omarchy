#!/bin/bash
#
# omarchy-thunderbolt-boot-rebuild rebuilds the boot image when Bolt's store
# changes, so the Thunderbolt devices the omarchy-thunderbolt hook authorizes
# at the disk unlock prompt follow Bolt's current decisions.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

command="$ROOT/bin/omarchy-thunderbolt-boot-rebuild"
stubs="$test_tmp/bin"
calls="$test_tmp/calls"

export OMARCHY_BOLT_STORE="$test_tmp/boltd"
export OMARCHY_PACMAN_LOCK="$test_tmp/db.lck"
export CALLS=$calls

mkdir -p "$stubs"

# limine-mkinitcpio is present unless NO_LIMINE is set.
cat >"$stubs/omarchy-cmd-present" <<'EOF'
#!/bin/bash
[[ $1 == "limine-mkinitcpio" && -n ${NO_LIMINE:-} ]] && exit 1
exit 0
EOF

# Each builder records its call. LIMINE_OUTPUT is what it prints, CHANGE_STORE
# stores a device during the first build, and FAIL_BUILD makes it exit 1.
cat >"$stubs/limine-mkinitcpio" <<'EOF'
#!/bin/bash
echo limine-mkinitcpio "$@" >>"$CALLS"
[[ -n ${LIMINE_OUTPUT:-} ]] && echo "$LIMINE_OUTPUT"
if [[ -n ${CHANGE_STORE:-} && ! -e $OMARCHY_BOLT_STORE/devices/new ]]; then
  printf '[user]\npolicy=auto\n' >"$OMARCHY_BOLT_STORE/devices/new"
fi
[[ -z ${FAIL_BUILD:-} ]]
EOF

cat >"$stubs/mkinitcpio" <<'EOF'
#!/bin/bash
echo mkinitcpio "$@" >>"$CALLS"
EOF

chmod +x "$stubs"/*

new_run() {
  rm -rf "$OMARCHY_BOLT_STORE" "$calls" "$OMARCHY_PACMAN_LOCK"
  mkdir -p "$OMARCHY_BOLT_STORE/devices"
  printf '[user]\npolicy=iommu\n' >"$OMARCHY_BOLT_STORE/devices/c2010000-0072-741e-8393-1fe15e244809"
  : >"$calls"
}

run_command() {
  PATH="$stubs:$PATH" "$command" >/dev/null 2>"$test_tmp/stderr"
}

assert_calls() {
  local description=$1 expected=$2 actual
  actual=$(<"$calls")
  [[ $actual == $expected ]] || fail "$description" "expected:"$'\n'"$expected"$'\n'"actual:"$'\n'"$actual"
  pass "$description"
}

new_run
run_command || fail "a store change rebuilds the images once" "$(<"$test_tmp/stderr")"
assert_calls "a store change rebuilds the images once" "limine-mkinitcpio"

new_run
NO_LIMINE=1 run_command || fail "without limine-mkinitcpio it rebuilds with mkinitcpio -P" "$(<"$test_tmp/stderr")"
assert_calls "without limine-mkinitcpio it rebuilds with mkinitcpio -P" "mkinitcpio -P"

new_run
CHANGE_STORE=1 run_command || fail "a store change during a build builds again" "$(<"$test_tmp/stderr")"
assert_calls "a store change during a build builds again" "limine-mkinitcpio"$'\n'"limine-mkinitcpio"

new_run
if FAIL_BUILD=1 run_command; then
  fail "a failed build fails the rebuild"
fi
pass "a failed build fails the rebuild"

new_run
if LIMINE_OUTPUT="==> mkinitcpio failed for kernel: linux" run_command; then
  fail "a kernel limine-mkinitcpio could not rebuild fails the rebuild"
fi
pass "a kernel limine-mkinitcpio could not rebuild fails the rebuild"

new_run
: >"$OMARCHY_PACMAN_LOCK"
(
  sleep 1
  echo "pacman done" >>"$calls"
  rm -f "$OMARCHY_PACMAN_LOCK"
) &
run_command || fail "it builds after a running pacman transaction" "$(<"$test_tmp/stderr")"
wait
assert_calls "it builds after a running pacman transaction" "pacman done"$'\n'"limine-mkinitcpio"
