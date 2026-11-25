#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The login notifier runs on every machine, including Limine ones with no boot
# store: there it has nothing to say and exits cleanly instead of failing the
# user unit.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin"
for cmd in systemctl omarchy-notification-wait omarchy-notification-send; do
  printf '#!/bin/bash\necho "%s $*" >>"%s/calls"\n' "$cmd" "$test_tmp" >"$test_tmp/bin/$cmd"
done
printf '#!/bin/bash\necho "$*"\n' >"$test_tmp/bin/omarchy-i18n"
chmod +x "$test_tmp/bin/"*

notify() {
  env PATH="$test_tmp/bin:$PATH" OMARCHY_BOOT_STORE="$test_tmp/store" XDG_STATE_HOME="$test_tmp/state" \
    bash "$ROOT/bin/omarchy-boot-notify"
}

notify || fail "the notifier exits cleanly without a boot store"
! grep -q notification-send "$test_tmp/calls" 2>/dev/null || fail "nothing is shown without a boot store"
pass "a machine without a boot store gets no notice and no failure"

mkdir -p "$test_tmp/store"
printf 'notice_id=7\nnotice_key=restored\nnotice_arg=8\n' >"$test_tmp/store/state"
notify || fail "the notifier shows a notice"
grep -q 'notification-send' "$test_tmp/calls" || fail "a waiting notice is shown" "$(cat "$test_tmp/calls")"
: >"$test_tmp/calls"
notify || fail "the notifier runs again"
! grep -q notification-send "$test_tmp/calls" || fail "a notice is shown only once"
pass "a waiting notice is shown once"
