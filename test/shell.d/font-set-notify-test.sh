#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

test_home="$tmpdir/home"
busctl_dir="$tmpdir/busctl-calls"
mkdir -p "$test_home" "$busctl_dir"

cat >"$tmpdir/fc-list" <<'SH'
#!/bin/bash
printf '%s\n' 'Test Font'
SH

cat >"$tmpdir/pgrep" <<'SH'
#!/bin/bash
case "$*" in
  "-x ghostty") printf '%s\n' 1111 ;;
  "-x foot") printf '%s\n' 2222 ;;
  *) exit 1 ;;
esac
SH

cat >"$tmpdir/busctl" <<'SH'
#!/bin/bash
count=0
[[ -f $OMARCHY_TEST_BUSCTL_COUNT ]] && read -r count <"$OMARCHY_TEST_BUSCTL_COUNT"
count=$((count + 1))
printf '%s\n' "$count" >"$OMARCHY_TEST_BUSCTL_COUNT"
printf '%s\n' "$@" >"$OMARCHY_TEST_BUSCTL_DIR/call-$count"
echo "u 42"
SH

cat >"$tmpdir/notify-send" <<'SH'
#!/bin/bash
echo "notify-send was invoked" >"$OMARCHY_TEST_NOTIFY_TRIPWIRE"
exit 3
SH

for command in omarchy-restart-shell omarchy-hook; do
  printf '#!/bin/bash\nexit 0\n' >"$tmpdir/$command"
done
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/omarchy-cmd-present"
chmod +x "$tmpdir/"*

tripwire="$tmpdir/notify-send-was-used"
output=$(
  env \
    HOME="$test_home" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_TEST_BUSCTL_COUNT="$tmpdir/busctl-count" \
    OMARCHY_TEST_BUSCTL_DIR="$busctl_dir" \
    OMARCHY_TEST_NOTIFY_TRIPWIRE="$tripwire" \
    PATH="$tmpdir:$ROOT/bin:$PATH" \
    omarchy-font-set "Test Font"
)

[[ $output != *"1111"* && $output != *"2222"* ]] || fail "font set hides terminal process ids" "$output"
pass "font set hides terminal process ids"

[[ $(<"$tmpdir/busctl-count") == "2" ]] || fail "font set sends restart notifications for running Ghostty and Foot"
pass "font set sends restart notifications for running Ghostty and Foot"

declare -a ghostty_args foot_args
mapfile -t ghostty_args <"$busctl_dir/call-1"
mapfile -t foot_args <"$busctl_dir/call-2"

[[ ${ghostty_args[11]} == "Restart your terminal" ]] || fail "Ghostty restart notification has the expected summary" "${ghostty_args[11]}"
[[ ${ghostty_args[12]} == "You must restart Ghostty to see the font change" ]] || fail "Ghostty restart notification has the expected body" "${ghostty_args[12]}"
pass "Ghostty restart notification has a summary and body"

[[ ${foot_args[11]} == "Restart your terminal" ]] || fail "Foot restart notification has the expected summary" "${foot_args[11]}"
[[ ${foot_args[12]} == "You must restart Foot to see the font change" ]] || fail "Foot restart notification has the expected body" "${foot_args[12]}"
pass "Foot restart notification has a summary and body"

[[ ! -e $tripwire ]] || fail "font set notifications must never invoke notify-send"
pass "font set notifications use the D-Bus wrapper"
