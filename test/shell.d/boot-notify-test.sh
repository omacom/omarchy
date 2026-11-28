#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The login notifier runs on every machine, including Limine ones with no boot
# store: there it has nothing to say and exits cleanly instead of failing the
# user unit.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mkdir -p "$test_tmp/bin"
for cmd in omarchy-notification-wait omarchy-notification-send; do
  printf '#!/bin/bash\necho "%s $*" >>"%s/calls"\n' "$cmd" "$test_tmp" >"$test_tmp/bin/$cmd"
done
printf '#!/bin/bash\necho "$*"\n' >"$test_tmp/bin/omarchy-i18n"
# omarchy-boot-confirm: queued for as many checks as $test_tmp/queued holds,
# then it writes its notice and is done.
cat >"$test_tmp/bin/systemctl" <<SH
#!/bin/bash
[[ \$1 == list-jobs ]] || exit 0
left=\$(cat "$test_tmp/queued" 2>/dev/null || echo 0)
if ((left > 0)); then
  echo \$((left - 1)) >"$test_tmp/queued"
  echo "42 omarchy-boot-confirm.service start waiting"
elif [[ -f $test_tmp/next-notice ]]; then
  mv "$test_tmp/next-notice" "$test_tmp/store/state"
fi
SH
chmod +x "$test_tmp/bin/"*
echo 'BOOT_IMAGE=/vmlinuz root=UUID=1 rootflags=subvol=@ rw' >"$test_tmp/cmdline"

notify() {
  env PATH="$test_tmp/bin:$PATH" OMARCHY_BOOT_STORE="$test_tmp/store" XDG_STATE_HOME="$test_tmp/state" \
    OMARCHY_PROC_CMDLINE="$test_tmp/cmdline" bash "$ROOT/bin/omarchy-boot-notify"
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

# A login that beats omarchy-boot-confirm, still queued behind
# graphical.target, waits for the notice it writes.
printf 'notice_id=8\nnotice_key=switched\nnotice_arg=\n' >"$test_tmp/next-notice"
echo 1 >"$test_tmp/queued"
: >"$test_tmp/calls"
notify || fail "the notifier waits for a queued confirm"
grep -q 'notification-send.*boot.notice.switched' "$test_tmp/calls" || fail "the notice confirm writes after the login is shown" "$(cat "$test_tmp/calls")"
pass "a login before omarchy-boot-confirm ran still gets this boot's notice"
