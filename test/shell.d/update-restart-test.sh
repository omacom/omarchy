#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
call_log="$test_tmp/calls.log"
home="$test_tmp/home"
state_dir="$home/.local/state/omarchy"
flag="$state_dir/reboot-required"
modules="$test_tmp/modules"
mkdir -p "$mock_bin" "$state_dir" "$modules/7.2.8-arch1-1"
touch "$modules/7.2.8-arch1-1/modules.builtin"

# The running kernel is the installed one, so only the flag can ask for a reboot.
cat >"$mock_bin/uname" <<'SH'
#!/bin/bash

echo 7.2.8-arch1-1
SH

cat >"$mock_bin/pacman" <<'SH'
#!/bin/bash

exit 0
SH

cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash

exit 1
SH

# gum records the prompt and declines it, so the script continues past it.
cat >"$mock_bin/gum" <<'SH'
#!/bin/bash

printf 'gum %s\n' "$*" >>"$CALL_LOG"
exit 1
SH

cat >"$mock_bin/omarchy-system" <<'SH'
#!/bin/bash

printf 'omarchy-system %s\n' "$*" >>"$CALL_LOG"
SH
chmod +x "$mock_bin"/*

run_update_restart() {
  : >"$call_log"
  HOME="$home" PATH="$mock_bin:$ROOT/bin:$PATH" CALL_LOG="$call_log" \
    OMARCHY_KERNEL_MODULES_PATH="$modules" OMARCHY_UPDATE_UNATTENDED=0 \
    "$ROOT/bin/omarchy-update-restart" --reboot-only >/dev/null
}

prompted_for_reboot() {
  grep -qF 'Updates require reboot. Ready?' "$call_log"
}

boot_time=$(awk '/^btime/ {print $2}' /proc/stat)

# A flag older than the current boot was already honored by a reboot that did
# not go through omarchy-system-reboot.
touch -d "@$((boot_time - 60))" "$flag"
run_update_restart

if prompted_for_reboot; then
  fail "reboot-required flag written before the current boot does not prompt"
fi
pass "reboot-required flag written before the current boot does not prompt"

if [[ -e $flag ]]; then
  fail "reboot-required flag written before the current boot is cleared"
fi
pass "reboot-required flag written before the current boot is cleared"

# A flag set since boot, e.g. by a migration in this very update, still prompts.
touch "$flag"
run_update_restart

if ! prompted_for_reboot; then
  fail "reboot-required flag written since boot prompts for a reboot" "$(cat "$call_log")"
fi
pass "reboot-required flag written since boot prompts for a reboot"

if [[ ! -e $flag ]]; then
  fail "declining the prompt keeps the reboot-required flag"
fi
pass "declining the prompt keeps the reboot-required flag"

# No flag, no prompt.
rm -f "$flag"
run_update_restart

if prompted_for_reboot; then
  fail "no reboot-required flag means no prompt"
fi
pass "no reboot-required flag means no prompt"
