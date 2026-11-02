#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
home="$tmpdir/home"
mkdir -p "$mock_bin" "$home/.config/ghostty" "$home/.config/foot"
printf 'font-family = "Old Font"\n' >"$home/.config/ghostty/config"
printf 'font=Old Font:size=9\n' >"$home/.config/foot/foot.ini"

cat >"$mock_bin/fc-list" <<'SH'
#!/bin/bash
printf 'Fira Mono:style=Regular\n'
SH

cat >"$mock_bin/pgrep" <<'SH'
#!/bin/bash
# procps-ng 4 pgrep has no -q short option. It always prints matching PIDs;
# callers quiet it with >/dev/null.
[[ -n ${OMARCHY_TEST_NO_TERMINALS:-} ]] && exit 1
printf '15887\n'
exit 0
SH

cat >"$mock_bin/pkill" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$mock_bin/omarchy-restart-shell" <<'SH'
#!/bin/bash
exit 0
SH

cat >"$mock_bin/omarchy-hook" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"${OMARCHY_TEST_HOOK_LOG:?}"
SH

# Stub only the D-Bus transport, so the real omarchy-notification-send parses
# the arguments. One NUL-delimited file per Notify call.
cat >"$mock_bin/busctl" <<'SH'
#!/bin/bash
calls=("${OMARCHY_TEST_BUSCTL_DIR:?}"/call-*)
[[ -e ${calls[0]} ]] || calls=()
printf '%s\0' "$@" >"$OMARCHY_TEST_BUSCTL_DIR/call-$((${#calls[@]} + 1))"
echo "u 42"
SH

cat >"$mock_bin/notify-send" <<'SH'
#!/bin/bash
echo "notify-send was invoked" >"${OMARCHY_TEST_NOTIFY_TRIPWIRE:?}"
exit 3
SH

chmod +x "$mock_bin"/*

hook_log="$tmpdir/hook.log"
busctl_dir="$tmpdir/busctl-calls"
tripwire="$tmpdir/notify-send-was-used"
: >"$hook_log"
mkdir -p "$busctl_dir"

output=$(
  HOME="$home" OMARCHY_PATH="$ROOT" OMARCHY_TEST_HOOK_LOG="$hook_log" OMARCHY_TEST_BUSCTL_DIR="$busctl_dir" \
    OMARCHY_TEST_NOTIFY_TRIPWIRE="$tripwire" PATH="$mock_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-font-set" "Fira Mono" 2>&1
) || fail "font set accepts a font name that contains a space" "$output"

[[ $output != *15887* ]] || fail "font set does not print pgrep PIDs" "$output"
[[ $output != *Usage:* ]] || fail "font set does not dump notification-send usage" "$output"
pass "font set stays quiet for a multi-word font name"

# busctl argv: --user -- call <dest> <path> <iface> Notify <sig> app_name
# replaces_id icon summary body actions hint_count hints... timeout
notification() {
  local -a args
  mapfile -d '' args <"$busctl_dir/call-$1"
  [[ ${args[11]} == "$2" ]] || fail "font set notification $1 has the headline \"$2\"" "$(printf '%q ' "${args[@]}")"
  [[ ${args[14]} == 2 && ${args[18]} == omarchy-glyph && ${args[20]} == $'\xee\x99\x99' ]] ||
    fail "font set notification $1 carries the font glyph" "$(printf '%q ' "${args[@]}")"
}

[[ -e $busctl_dir/call-2 && ! -e $busctl_dir/call-3 ]] || fail "font set sends one notification each for running Ghostty and Foot" "$(ls "$busctl_dir")"
notification 1 "You must restart Ghostty to see font change"
notification 2 "You must restart Foot to see font change"
[[ ! -e $tripwire ]] || fail "font set notifies through omarchy-notification-send, never notify-send"
pass "font set notification keeps the restart headline"

mapfile -d '' hook_args <"$hook_log"
[[ ${#hook_args[@]} == 2 && ${hook_args[0]} == "font-set" && ${hook_args[1]} == "Fira Mono" ]] ||
  fail "font set passes the full font name as one hook argument" "$(printf '%q ' "${hook_args[@]}")"
pass "font set passes the full font name as one hook argument"

rm -f "$busctl_dir"/call-*
output=$(
  HOME="$home" OMARCHY_PATH="$ROOT" OMARCHY_TEST_HOOK_LOG="$hook_log" OMARCHY_TEST_BUSCTL_DIR="$busctl_dir" \
    OMARCHY_TEST_NOTIFY_TRIPWIRE="$tripwire" OMARCHY_TEST_NO_TERMINALS=1 PATH="$mock_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-font-set" "Fira Mono" 2>&1
) || fail "font set succeeds with no terminal running" "$output"
[[ -z $output && ! -e $busctl_dir/call-1 ]] || fail "font set sends no restart notification when no terminal is running" "$output"
pass "font set sends no restart notification when no terminal is running"
