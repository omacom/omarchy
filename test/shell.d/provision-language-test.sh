#!/bin/bash
#
# First-boot provisioning applies the owner's language with systemd-firstboot,
# which refuses a locale that has not been generated yet, and falls back to
# localectl, which generates it. That refusal is the whole mechanism for every
# language but the image's own, so it is pinned here: an ungenerated locale
# must reach localectl. (Measured in a booted Arch container: firstboot exits
# with "Locale de_DE.UTF-8 is not installed." and localectl then generates it.)

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

calls="$TMPDIR/calls"
mkdir -p "$TMPDIR/bin"

# Each stub records how it was called; STUB_FAIL names the ones that fail.
# A failing systemd-firstboot stands for its refusal of an ungenerated locale.
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
[[ $(cat "$calls") == "systemd-firstboot --locale=sl_SI.UTF-8 --force" ]] ||
  fail "an already generated locale is applied by systemd-firstboot alone" "$(cat "$calls")"
pass "an already generated locale is applied by systemd-firstboot alone"

STUB_FAIL=systemd-firstboot run sl_SI.UTF-8
[[ $(sed -n 2p "$calls") == "localectl set-locale LANG=sl_SI.UTF-8" ]] ||
  fail "an ungenerated locale, refused by systemd-firstboot, reaches localectl" "$(cat "$calls")"
grep -q "^log:" "$calls" && fail "a successful localectl fallback logs nothing" "$(cat "$calls")"
pass "an ungenerated locale, refused by systemd-firstboot, reaches localectl to be generated"

STUB_FAIL="systemd-firstboot localectl" run sl_SI.UTF-8
grep -q "could not persist locale sl_SI.UTF-8" "$calls" ||
  fail "both failing is logged, not fatal" "$(cat "$calls")"
pass "a locale neither can persist is logged rather than failing setup"

run xx_XX.UTF-8
[[ $(cat "$calls") == "log: locale xx_XX.UTF-8 unknown to glibc; keeping the default" ]] ||
  fail "a locale glibc does not list is left alone" "$(cat "$calls")"
pass "a locale glibc does not list is never handed to either"

run ""
[[ ! -s $calls ]] || fail "no language chosen changes nothing" "$(cat "$calls")"
pass "no language chosen changes nothing"
