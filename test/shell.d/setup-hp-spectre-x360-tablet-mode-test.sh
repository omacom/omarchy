#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

command="$ROOT/bin/omarchy-setup-hp-spectre-x360-tablet-mode"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

# The setup writes to an absolute system path no unprivileged suite can touch.
# Retarget a scratch copy instead of the real command, asserting the path is
# named exactly once so this seam cannot quietly stop standing for the file
# the shipped command actually writes.
occurrences=$(grep -Fxc 'BLACKLIST_FILE="/etc/modprobe.d/blacklist-intel-hid.conf"' "$command") || occurrences=0
(( occurrences == 1 )) ||
  fail "the setup names its blacklist path exactly once" "found $occurrences occurrences"

blacklist_file="$tmp_dir/blacklist-intel-hid.conf"
command_copy="$tmp_dir/setup.sh"
sed "s|^BLACKLIST_FILE=\"/etc/modprobe.d/blacklist-intel-hid.conf\"\$|BLACKLIST_FILE=\"$blacklist_file\"|" \
  "$command" >"$command_copy"
pass "setup names its blacklist path once, and the test drives a retargeted copy"

stub_bin="$tmp_dir/bin"
sudo_log="$tmp_dir/sudo.log"
mkdir -p "$stub_bin"

# Stands in for the real hardware detector so the model match is controllable
# from a variable rather than the machine this suite happens to run on.
cat >"$stub_bin/omarchy-hw-hp-spectre-x360-2019" <<'STUB'
#!/bin/bash
[[ ${STUB_HW_MATCH:-1} == 1 ]]
STUB

# Stands in for the live sensor probe with a canned verdict. The probe's own
# logic (proc discovery, EVIOCGSW decode, stuck/OK classification) is covered
# directly in hw-hp-spectre-x360-tablet-mode-probe-test.sh; here we only need
# the setup command's branch on each verdict it can return. Like the real evdev
# node, it is unreadable unless sudo ran it.
cat >"$stub_bin/omarchy-hw-hp-spectre-x360-tablet-mode-probe" <<'STUB'
#!/bin/bash
if [[ ${STUB_AS_ROOT:-} == 1 ]]; then
  printf '%s\n' "${STUB_VERDICT:-OK}"
else
  printf 'NO_PERMISSION\n'
fi
STUB

cat >"$stub_bin/gum" <<'STUB'
#!/bin/bash
[[ $1 == confirm ]] || { printf 'unexpected gum invocation: %s\n' "$*" >&2; exit 99; }
[[ ${STUB_GUM_CONFIRM_YES:-1} == 1 ]]
STUB

# Only the whitelisted calls the real command is expected to make are honored;
# anything else fails loudly instead of silently no-oping.
cat >"$stub_bin/sudo" <<STUB
#!/bin/bash
printf '%s\n' "\$*" >>"$sudo_log"
case "\$1" in
  true) ;;
  omarchy-hw-hp-spectre-x360-tablet-mode-probe) STUB_AS_ROOT=1 "\$@" ;;
  tee) cat >"$blacklist_file" ;;
  mkinitcpio) ;;
  *)
    printf 'unexpected sudo invocation: %s\n' "\$*" >&2
    exit 98
    ;;
esac
STUB

chmod +x "$stub_bin"/*

run() { # STUB_HW_MATCH STUB_VERDICT STUB_GUM_CONFIRM_YES
  env PATH="$stub_bin:$PATH" \
    STUB_HW_MATCH="${1:-1}" STUB_VERDICT="${2:-OK}" STUB_GUM_CONFIRM_YES="${3:-1}" \
    bash "$command_copy" >/dev/null 2>&1
}

assert_no_sudo_calls() {
  local description="$1"

  [[ ! -s $sudo_log ]] || fail "$description" "$(cat "$sudo_log")"
}

# Reading the switch needs sudo too, so the branches that stop short of the fix
# still call it; what they must not do is write or rebuild anything.
assert_no_changes() {
  local description="$1"

  ! grep -qE '^(tee|mkinitcpio) ' "$sudo_log" 2>/dev/null || fail "$description" "$(cat "$sudo_log")"
  [[ ! -e $blacklist_file ]] || fail "$description" "the blacklist file was written"
}

rm -f "$sudo_log" "$blacklist_file"
if run 0; then
  fail "a machine that isn't a 2019 Spectre x360 exits 0"
fi
assert_no_sudo_calls "an unmatched model does not call sudo"
pass "a non-2019-Spectre model is rejected without touching sudo"

rm -f "$sudo_log"
printf 'blacklist intel_hid\n' >"$blacklist_file"
if ! run 1; then
  fail "an already-blacklisted system exits non-zero"
fi
assert_no_sudo_calls "an already-applied blacklist does not call sudo"
pass "an already-blacklisted system is treated as a no-op"

rm -f "$sudo_log" "$blacklist_file"
if run 1 OK; then
  fail "a sensor that isn't stuck exits 0"
fi
assert_no_changes "an unstuck sensor changes nothing"
grep -Fxq 'omarchy-hw-hp-spectre-x360-tablet-mode-probe' "$sudo_log" ||
  fail "the setup did not read the switch through sudo" "$(cat "$sudo_log" 2>/dev/null)"
pass "a sensor that toggles as the lid moves is read through sudo and left alone"

rm -f "$sudo_log" "$blacklist_file"
if run 1 NOT_FOUND; then
  fail "a missing switch device exits 0"
fi
assert_no_changes "a missing switch device changes nothing"
pass "a missing switch device is reported without changing anything"

rm -f "$sudo_log" "$blacklist_file"
if run 1 NO_PERMISSION; then
  fail "unreadable switch device exits 0"
fi
assert_no_changes "unreadable switch device changes nothing"
pass "an unreadable switch device is reported without changing anything"

rm -f "$sudo_log" "$blacklist_file"
if ! run 1 STUCK 0; then
  fail "declining the fix on a stuck sensor exits non-zero"
fi
assert_no_changes "declining the fix changes nothing"
pass "a stuck sensor with a declined prompt makes no changes"

rm -f "$sudo_log" "$blacklist_file"
if ! run 1 STUCK 1; then
  fail "confirming the fix on a stuck sensor exits non-zero"
fi
grep -Fxq 'blacklist intel_hid' "$blacklist_file" ||
  fail "confirming the fix did not blacklist intel_hid" "$(cat "$blacklist_file" 2>/dev/null)"
grep -Fxq "tee $blacklist_file" "$sudo_log" ||
  fail "the fix did not write the blacklist file via sudo tee" "$(cat "$sudo_log")"
grep -Fxq 'mkinitcpio -P' "$sudo_log" ||
  fail "the fix did not rebuild the initramfs via sudo mkinitcpio -P" "$(cat "$sudo_log")"
pass "a stuck sensor with a confirmed prompt blacklists intel_hid and rebuilds the initramfs"
