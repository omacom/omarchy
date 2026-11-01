#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
log_file="$test_tmp/dev.log"
conf_file="$test_tmp/omarchy.conf"
sudoers_file="$test_tmp/omarchy-dev-path"
mkdir -p "$stub_bin" "$test_tmp/home"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$OMARCHY_DEV_TEST_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$OMARCHY_DEV_TEST_LOG"
done
printf '\n' >>"$OMARCHY_DEV_TEST_LOG"

case "$1" in
  tee)
    cat >"$OMARCHY_DEV_TEST_CONF"
    ;;
  install)
    # The staged file is the second-to-last argument.
    cp "${@: -2:1}" "$OMARCHY_DEV_TEST_SUDOERS"
    ;;
esac
SH
chmod +x "$stub_bin/sudo"

cat >"$stub_bin/gum" <<'SH'
#!/bin/bash

printf 'gum' >>"$OMARCHY_DEV_TEST_LOG"
for arg in "$@"; do
  printf '\t%s' "$arg" >>"$OMARCHY_DEV_TEST_LOG"
done
printf '\n' >>"$OMARCHY_DEV_TEST_LOG"
SH
chmod +x "$stub_bin/gum"

cat >"$stub_bin/omarchy-system" <<'SH'
#!/bin/bash
[[ $1 == "reboot" ]] || exit 2

printf 'reboot\n' >>"$OMARCHY_DEV_TEST_LOG"
SH
chmod +x "$stub_bin/omarchy-system"

run_dev() {
  local command="$1"
  shift

  HOME="$test_tmp/home" \
    OMARCHY_DEV_TEST_LOG="$log_file" \
    OMARCHY_DEV_TEST_CONF="$conf_file" \
    OMARCHY_DEV_TEST_SUDOERS="$sudoers_file" \
    PATH="$stub_bin:$PATH" \
    "$ROOT/bin/omarchy-dev-$command" "$@"
}

make_checkout() {
  local checkout="$test_tmp/$1"

  mkdir -p "$checkout/bin" "$checkout/default" "$checkout/shell"
  printf '%s' "$checkout"
}

checkout=$(make_checkout checkout)

: >"$log_file"
: >"$sudoers_file"
run_dev link "$checkout" --no-reboot >"$test_tmp/link.out"

[[ $(<"$conf_file") == "export OMARCHY_PATH=\"$checkout\"" ]] ||
  fail "dev link points OMARCHY_PATH at the checkout" "$(<"$conf_file")"
pass "dev link points OMARCHY_PATH at the checkout"

# sudo reads secure_path, not the caller's PATH, so the checkout has to come
# first there too or `sudo omarchy-*` runs the packaged copy.
[[ $(<"$sudoers_file") == "Defaults secure_path=\"$checkout/bin:/usr/local/sbin:/usr/local/bin:/usr/bin\"" ]] ||
  fail "dev link prepends the checkout to sudo's secure_path" "$(<"$sudoers_file")"
pass "dev link prepends the checkout to sudo's secure_path"

grep -Eq $'^sudo\tinstall\t-Dm440\t-o\troot\t-g\troot\t[^\t]+\t/etc/sudoers\\.d/omarchy-dev-path$' "$log_file" ||
  fail "dev link installs the drop-in root-owned and read-only" "$(cat "$log_file")"
pass "dev link installs the drop-in root-owned and read-only"

visudo -cf "$sudoers_file" >/dev/null ||
  fail "dev link writes a sudoers drop-in sudo can parse" "$(<"$sudoers_file")"
pass "dev link writes a sudoers drop-in sudo can parse"

grep -F "sudo now resolves omarchy-* from $checkout/bin" "$test_tmp/link.out" >/dev/null ||
  fail "dev link reports the sudo change" "$(cat "$test_tmp/link.out")"
pass "dev link reports the sudo change"

if grep -Eq '^(gum|reboot)' "$log_file"; then
  fail "dev link --no-reboot skips the reboot prompt" "$(cat "$log_file")"
fi
pass "dev link --no-reboot skips the reboot prompt"

# A path sudoers would have to escape, not one the shell alone handles.
quoted_checkout=$(make_checkout 'check "out"')

: >"$log_file"
: >"$sudoers_file"
run_dev link "$quoted_checkout" --no-reboot >/dev/null

visudo -cf "$sudoers_file" >/dev/null ||
  fail "dev link escapes a checkout path for sudoers" "$(<"$sudoers_file")"
pass "dev link escapes a checkout path for sudoers"

: >"$log_file"
if run_dev link "$test_tmp/missing" --no-reboot >/dev/null 2>"$test_tmp/missing.err"; then
  fail "dev link rejects a path that does not exist"
fi
grep -F "Error: path does not exist: $test_tmp/missing" "$test_tmp/missing.err" >/dev/null ||
  fail "dev link explains a path that does not exist" "$(cat "$test_tmp/missing.err")"
if grep -q 'sudo' "$log_file"; then
  fail "dev link touches nothing when the path does not exist" "$(cat "$log_file")"
fi
pass "dev link rejects a path that does not exist"

: >"$log_file"
run_dev unlink --no-reboot

grep -Fx $'sudo\ttee\t/etc/omarchy.conf' "$log_file" >/dev/null ||
  fail "dev unlink writes the package path without rebooting" "$(cat "$log_file")"
[[ $(<"$conf_file") == 'export OMARCHY_PATH="/usr/share/omarchy"' ]] ||
  fail "dev unlink writes the package path guard" "$(<"$conf_file")"

# Left behind, it keeps sudo running a checkout nothing else points at.
grep -Fx $'sudo\trm\t-f\t/etc/sudoers.d/omarchy-dev-path' "$log_file" >/dev/null ||
  fail "dev unlink drops the sudo secure_path drop-in" "$(cat "$log_file")"
pass "dev unlink drops the sudo secure_path drop-in"

if grep -Eq '^(gum|reboot)' "$log_file"; then
  fail "dev unlink --no-reboot skips the reboot prompt" "$(cat "$log_file")"
fi
pass "dev unlink --no-reboot skips the reboot prompt"

: >"$log_file"
run_dev unlink

grep -Fx $'gum\tconfirm\tReboot now to activate?' "$log_file" >/dev/null ||
  fail "interactive dev unlink still prompts for reboot" "$(cat "$log_file")"
grep -Fx 'reboot' "$log_file" >/dev/null ||
  fail "interactive dev unlink still reboots after confirmation" "$(cat "$log_file")"
pass "interactive dev unlink keeps its reboot prompt"

if run_dev unlink --invalid >"$test_tmp/invalid.out" 2>"$test_tmp/invalid.err"; then
  fail "dev unlink rejects unknown arguments"
fi
grep -F 'Usage: omarchy dev unlink [--no-reboot]' "$test_tmp/invalid.err" >/dev/null ||
  fail "dev unlink explains valid arguments" "$(cat "$test_tmp/invalid.err")"
pass "dev unlink rejects unknown arguments"
