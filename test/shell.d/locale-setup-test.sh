#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

leaf="$ROOT/install/config/locale.sh"

[[ -f $leaf ]] || fail "the locale step ships"

grep -Fq 'config/locale.sh' "$ROOT/install/config/all.sh" ||
  fail "config phase sets a UTF-8 locale"
pass "config phase sets a UTF-8 locale"

# Root always writes the real locale files: the overrides below are for
# unprivileged runs, so as root the step would change this machine's locale.
if (( EUID == 0 )); then
  skip "running as root, where the locale step ignores its fixture; skipping"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
calls="$test_tmp/calls.log"
locale_conf="$test_tmp/etc/locale.conf"
locale_gen="$test_tmp/etc/locale.gen"
mkdir -p "$stub_bin" "$test_tmp/etc"

# GENERATED_LOCALES stands in for what the machine already has built.
cat >"$stub_bin/locale" <<'SH'
#!/bin/bash

[[ ${1:-} == "-a" ]] || exit 0
printf '%s\n' ${GENERATED_LOCALES:-C}
SH

cat >"$stub_bin/locale-gen" <<'SH'
#!/bin/bash

printf 'locale-gen\n' >>"$TEST_LOG"
SH

chmod +x "$stub_bin"/*

run_leaf() {
  : >"$calls"
  GENERATED_LOCALES="${1:-C}" TEST_LOG="$calls" PATH="$stub_bin:$PATH" \
    OMARCHY_LOCALE_CONF="$locale_conf" OMARCHY_LOCALE_GEN="$locale_gen" \
    bash -euo pipefail -c 'source "$1"' bash "$leaf" >/dev/null
}

# A root from a distribution tarball: LANG=C, nothing enabled in locale.gen.
printf 'LANG=C\n' >"$locale_conf"
printf '#en_US.UTF-8 UTF-8\n#de_DE.UTF-8 UTF-8\n' >"$locale_gen"
run_leaf C
/usr/bin/grep -qx 'LANG=en_US.UTF-8' "$locale_conf" || fail "a C locale is replaced with UTF-8" "$(cat "$locale_conf")"
/usr/bin/grep -qx 'en_US.UTF-8 UTF-8' "$locale_gen" || fail "en_US.UTF-8 is enabled in locale.gen" "$(cat "$locale_gen")"
/usr/bin/grep -qx '#de_DE.UTF-8 UTF-8' "$locale_gen" || fail "other locales are left commented" "$(cat "$locale_gen")"
/usr/bin/grep -qx 'locale-gen' "$calls" || fail "the locale is generated" "$(cat "$calls")"
pass "a stock LANG=C machine gets en_US.UTF-8"

# Only the stock state is repaired. Every named locale is somebody's choice --
# including C.UTF-8, and including one that is not UTF-8 at all.
for chosen in en_DK.UTF-8 C.UTF-8 en_US.ISO-8859-1; do
  printf 'LANG=%s\n' "$chosen" >"$locale_conf"
  run_leaf "C en_DK.utf8 C.utf8"
  /usr/bin/grep -qx "LANG=$chosen" "$locale_conf" || fail "a chosen locale is left alone" "$chosen -> $(cat "$locale_conf")"
  [[ ! -s $calls ]] || fail "a chosen locale is not regenerated" "$chosen: $(cat "$calls")"
done
pass "a machine with a chosen locale is left alone"

# POSIX is the same stock state under another name, and a missing file means
# the system never had one set.
printf 'LANG=POSIX\n' >"$locale_conf"
run_leaf C
/usr/bin/grep -qx 'LANG=en_US.UTF-8' "$locale_conf" || fail "a POSIX locale is repaired" "$(cat "$locale_conf")"

rm -f "$locale_conf"
run_leaf C
/usr/bin/grep -qx 'LANG=en_US.UTF-8' "$locale_conf" || fail "a machine with no locale.conf is repaired" "$(cat "$locale_conf" 2>&1)"
pass "POSIX and an absent locale.conf count as stock"

# Already generated, just not selected: set it without a rebuild.
printf 'LANG=C\n' >"$locale_conf"
run_leaf "C en_US.utf8"
/usr/bin/grep -qx 'LANG=en_US.UTF-8' "$locale_conf" || fail "an available locale is selected" "$(cat "$locale_conf")"
[[ ! -s $calls ]] || fail "a generated locale is not regenerated" "$(cat "$calls")"
pass "a generated locale is selected without rebuilding"

# Other locale variables somebody set stay as they are.
printf 'LANG=C\nLC_TIME=en_DK.UTF-8\nLC_PAPER=de_DE.UTF-8\n' >"$locale_conf"
run_leaf "C en_US.utf8"
[[ $(cat "$locale_conf") == $'LANG=en_US.UTF-8\nLC_TIME=en_DK.UTF-8\nLC_PAPER=de_DE.UTF-8' ]] ||
  fail "only LANG is repaired; LC_* settings stay" "$(cat "$locale_conf")"
printf 'LC_TIME=en_DK.UTF-8\n' >"$locale_conf"
run_leaf "C en_US.utf8"
[[ $(cat "$locale_conf") == $'LC_TIME=en_DK.UTF-8\nLANG=en_US.UTF-8' ]] ||
  fail "an unset LANG is added beside the LC_* settings" "$(cat "$locale_conf")"
pass "only LANG is repaired; LC_* settings stay"

printf 'LANG=C\n' >"$locale_conf"
run_leaf "C en_US.utf8"
# Second pass over a repaired machine changes nothing.
run_leaf "C en_US.utf8"
(( $(/usr/bin/grep -c . "$locale_conf") == 1 )) || fail "the locale step is idempotent" "$(cat "$locale_conf")"
pass "the locale step is idempotent"

# The x86 ISO writes the locale the owner picked before this runs, so there the
# step changes nothing.
printf 'LANG=en_US.UTF-8\n' >"$locale_conf"
printf '#en_US.UTF-8 UTF-8\n' >"$locale_gen"
: >"$calls"
output=$(GENERATED_LOCALES="C en_US.utf8" TEST_LOG="$calls" PATH="$stub_bin:$PATH" \
  OMARCHY_LOCALE_CONF="$locale_conf" OMARCHY_LOCALE_GEN="$locale_gen" \
  bash -euo pipefail -c 'source "$1"' bash "$leaf")
[[ $output == "Leaving the locale as en_US.UTF-8" && $(cat "$locale_conf") == "LANG=en_US.UTF-8" ]] ||
  fail "an ISO install's locale is left as the ISO wrote it" "$output"
[[ $(cat "$locale_gen") == "#en_US.UTF-8 UTF-8" && ! -s $calls ]] || fail "an ISO install's locale.gen is not touched"
pass "an ISO install's locale is left as the ISO wrote it"
