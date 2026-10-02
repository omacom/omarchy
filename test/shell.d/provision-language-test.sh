#!/bin/bash
#
# First-boot provisioning applies the owner's language with localectl, because
# that is the call that generates the locale; systemd-firstboot only writes
# /etc/locale.conf, so it may only stand in when localectl cannot be reached.
# With firstboot first, every language but the image's own came out named in
# locale.conf and generated nowhere.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

calls="$TMPDIR/calls"
mkdir -p "$TMPDIR/bin"

# Each stub records how it was called; STUB_FAIL names the ones that fail.
for command in localectl systemd-firstboot; do
  cat >"$TMPDIR/bin/$command" <<STUB
#!/bin/bash
echo "$command \$*" >>"$calls"
[[ " \${STUB_FAIL:-} " != *" $command "* ]]
STUB
done
printf '#!/bin/bash\nprintf "sl_SI.UTF-8\\tSlovenian\\tSlovenia\\tSlovenian (Slovenia)\\n"\n' \
  >"$TMPDIR/bin/omarchy-locale-list"
chmod +x "$TMPDIR/bin/"*
export PATH="$TMPDIR/bin:$PATH"

log_step() { echo "log: $*" >>"$calls"; }

# Load the real configure_language() from the provisioning command.
eval "$(sed -n '/^configure_language() {/,/^}/p' "$ROOT/bin/omarchy-provision-owner")"

run() {
  : >"$calls"
  language=$1 configure_language >/dev/null
}

run sl_SI.UTF-8
[[ $(cat "$calls") == "localectl set-locale LANG=sl_SI.UTF-8" ]] ||
  fail "a known locale is applied with localectl alone" "$(cat "$calls")"
pass "a known locale is applied with localectl, which generates it"

STUB_FAIL=localectl run sl_SI.UTF-8
grep -qx "systemd-firstboot --locale=sl_SI.UTF-8 --force" "$calls" ||
  fail "systemd-firstboot stands in when localectl fails" "$(cat "$calls")"
grep -q "without generating it" "$calls" ||
  fail "the fallback says the locale was not generated" "$(cat "$calls")"
pass "systemd-firstboot stands in for localectl, and says it did not generate"

STUB_FAIL="localectl systemd-firstboot" run sl_SI.UTF-8
grep -q "could not persist locale sl_SI.UTF-8" "$calls" ||
  fail "both failing is logged, not fatal" "$(cat "$calls")"
pass "a locale neither can persist is logged rather than failing setup"

run xx_XX.UTF-8
[[ $(cat "$calls") == "log: locale xx_XX.UTF-8 unknown to glibc; keeping the default" ]] ||
  fail "a locale glibc does not list is left alone" "$(cat "$calls")"
pass "a locale glibc does not list is never handed to localectl"

run ""
[[ ! -s $calls ]] || fail "no language chosen changes nothing" "$(cat "$calls")"
pass "no language chosen changes nothing"
