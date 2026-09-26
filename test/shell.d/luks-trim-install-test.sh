#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/config/luks-trim.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"

export PATH="$scratch/bin:$PATH"
export CALL_LOG="$scratch/calls"
export OMARCHY_PATH="$ROOT"
export OMARCHY_LUKS_TRIM_LIMINE_CONF="$scratch/limine"
trim_options="allow-discards,no-read-workqueue,no-write-workqueue"

cat > "$scratch/bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo %s\n' "$*" >> "$CALL_LOG"
exec "$@"
SH
chmod +x "$scratch/bin/sudo"

# omarchy-apply-system sources each install leaf in its own shell, the way
# run_logged does.
run_leaf() {
  bash -eE -c 'source "$1"' bash "$leaf" < /dev/null > "$scratch/output" 2>&1
}

reset_fixture() {
  : > "$CALL_LOG"
  cat > "$OMARCHY_LUKS_TRIM_LIMINE_CONF" <<'CONF'
KERNEL_CMDLINE[default]+=" root=UUID=keep-me rw cryptdevice=UUID=keep-me:omarchy_root rootflags=subvol=@"
BOOT_ORDER="linux-omarchy, *, *fallback, Snapshots"
CONF
  cp "$OMARCHY_LUKS_TRIM_LIMINE_CONF" "$scratch/original-limine"
}

grep -Fq 'config/luks-trim.sh' "$ROOT/install/config/all.sh" ||
  fail "the install path runs the leaf"
pass "the target setup runs the leaf during every install"

reset_fixture
run_leaf
grep -Fq "cryptdevice=UUID=keep-me:omarchy_root:$trim_options" "$OMARCHY_LUKS_TRIM_LIMINE_CONF" ||
  fail "a fresh encrypted install gets the options before the UKI is built" "$(<"$OMARCHY_LUKS_TRIM_LIMINE_CONF")"
[[ $(grep -o 'allow-discards' "$OMARCHY_LUKS_TRIM_LIMINE_CONF" | wc -l) == 1 ]] ||
  fail "allow-discards is added exactly once" "$(<"$OMARCHY_LUKS_TRIM_LIMINE_CONF")"
grep -Fq 'root=UUID=keep-me rw' "$OMARCHY_LUKS_TRIM_LIMINE_CONF" || fail "the root parameters survive"
grep -Fq 'rootflags=subvol=@' "$OMARCHY_LUKS_TRIM_LIMINE_CONF" || fail "the btrfs subvolume survives"
grep -Fq 'BOOT_ORDER="linux-omarchy, *, *fallback, Snapshots"' "$OMARCHY_LUKS_TRIM_LIMINE_CONF" || fail "unrelated boot settings survive"
pass "the install writes the options into the parameter the first boot entry is built from"

cp "$OMARCHY_LUKS_TRIM_LIMINE_CONF" "$scratch/installed-limine"
: > "$CALL_LOG"
run_leaf
cmp -s "$OMARCHY_LUKS_TRIM_LIMINE_CONF" "$scratch/installed-limine" ||
  fail "a second run changes nothing" "$(<"$OMARCHY_LUKS_TRIM_LIMINE_CONF")"
[[ ! -s $CALL_LOG ]] || fail "a configured install does no work" "$(<"$CALL_LOG")"
pass "a second run changes nothing"

reset_fixture
sed -i 's# cryptdevice=UUID=keep-me:omarchy_root##' "$OMARCHY_LUKS_TRIM_LIMINE_CONF"
cp "$OMARCHY_LUKS_TRIM_LIMINE_CONF" "$scratch/original-limine"
run_leaf
cmp -s "$OMARCHY_LUKS_TRIM_LIMINE_CONF" "$scratch/original-limine" ||
  fail "an unencrypted install keeps its boot settings byte for byte" "$(<"$OMARCHY_LUKS_TRIM_LIMINE_CONF")"
[[ ! -s $CALL_LOG ]] || fail "an unencrypted install changes nothing" "$(<"$CALL_LOG")"
pass "an unencrypted install is left byte for byte unchanged"

reset_fixture
sed -i 's#:omarchy_root#:omarchy_root:allow-discards#' "$OMARCHY_LUKS_TRIM_LIMINE_CONF"
run_leaf
grep -Fq "cryptdevice=UUID=keep-me:omarchy_root:$trim_options" "$OMARCHY_LUKS_TRIM_LIMINE_CONF" ||
  fail "an existing option list is extended with the missing options" "$(<"$OMARCHY_LUKS_TRIM_LIMINE_CONF")"
[[ $(grep -o 'allow-discards' "$OMARCHY_LUKS_TRIM_LIMINE_CONF" | wc -l) == 1 ]] ||
  fail "an option that is already there is not repeated" "$(<"$OMARCHY_LUKS_TRIM_LIMINE_CONF")"
pass "a parameter that already carries an option gains only the missing ones"

reset_fixture
rm "$OMARCHY_LUKS_TRIM_LIMINE_CONF"
run_leaf
[[ ! -e $OMARCHY_LUKS_TRIM_LIMINE_CONF ]] || fail "a machine without a boot cmdline file is left alone"
pass "a machine with no boot cmdline file is left alone"
