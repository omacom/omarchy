#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

acpi_path="$test_tmp/acpi"
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# The bus answer is the whole UPower contract this helper depends on, so the
# stub stands in for that one property rather than the daemon.
write_upower() {
  cat >"$stub_bin/busctl" <<SH
#!/bin/bash
printf '%s\n' "$1"
SH
  chmod +x "$stub_bin/busctl"
}

write_acpi() {
  rm -rf "$acpi_path"
  mkdir -p "$acpi_path/LID0"
  printf 'state:      %s\n' "$1" >"$acpi_path/LID0/state"
}

clear_acpi() {
  rm -rf "$acpi_path"
  mkdir -p "$acpi_path"
}

lid_closed() {
  OMARCHY_ACPI_LID_PATH="$acpi_path" PATH="$stub_bin:$PATH" \
    "$ROOT/bin/omarchy-hw-laptop-closed"
}

write_acpi closed
write_upower "b false"
lid_closed || fail "a closed ACPI lid reports closed"
pass "a closed ACPI lid reports closed"

# ACPI is the cheaper source and the one x86 has always used, so it decides
# even when UPower is reachable and disagrees.
write_acpi open
write_upower "b true"
if lid_closed; then
  fail "an open ACPI lid outranks UPower"
fi
pass "an open ACPI lid outranks UPower"

# Apple Silicon has no /proc/acpi at all. Reporting the lid open by default
# here is the bug this covers: it silently disabled every caller's guard.
clear_acpi
write_upower "b true"
lid_closed || fail "a closed lid reports closed with no ACPI tree"
pass "a closed lid reports closed with no ACPI tree"

clear_acpi
write_upower "b false"
if lid_closed; then
  fail "an open lid reports open with no ACPI tree"
fi
pass "an open lid reports open with no ACPI tree"

# A machine with neither source must not claim the lid is closed, and must not
# spray bus errors into a PAM stack that runs this on every sudo.
clear_acpi
cat >"$stub_bin/busctl" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$stub_bin/busctl"

set +e
unreadable_error=$(lid_closed 2>&1 >/dev/null)
unreadable_status=$?
set -e

(( unreadable_status != 0 )) || fail "an unreadable lid source does not report closed"
[[ -z $unreadable_error ]] || fail "an unreadable lid source stays quiet" "$unreadable_error"
pass "an unreadable lid source does not report closed"
