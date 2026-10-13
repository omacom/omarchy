#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

home="$test_tmp/home"
omarchy="$test_tmp/omarchy"
mock_bin="$test_tmp/bin"
set_log="$test_tmp/theme-set"
notify_log="$test_tmp/notify"

mkdir -p "$mock_bin" \
  "$home/.config/omarchy/themes" \
  "$home/.local/state/omarchy/current" \
  "$omarchy/themes"

cat >"$mock_bin/omarchy-theme-set" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_THEME_SET"
exit "${THEME_SET_EXIT:-0}"
SH

cat >"$mock_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$OMARCHY_TEST_NOTIFY"
SH

chmod +x "$mock_bin"/*

# Stock + user dirs, same union omarchy-theme-list walks. Slugs sort as
# catppuccin, gruvbox, tokyo-night → Catppuccin, Gruvbox, Tokyo Night.
mkdir -p "$omarchy/themes/catppuccin" "$omarchy/themes/tokyo-night" \
  "$home/.config/omarchy/themes/gruvbox"

# These entries are discoverable, but theme-set cannot apply them.
mkdir -p "$home/.config/omarchy/themes/.hidden" "$omarchy/themes/Bad Name"
ln -s "$test_tmp/missing" "$home/.config/omarchy/themes/h-broken"

run_cycle() {
  : >"$set_log"
  : >"$notify_log"
  HOME="$home" OMARCHY_PATH="$omarchy" PATH="$mock_bin:$ROOT/bin:$PATH" \
    OMARCHY_TEST_THEME_SET="$set_log" OMARCHY_TEST_NOTIFY="$notify_log" \
    bash "$ROOT/bin/$1"
}

printf 'gruvbox\n' >"$home/.local/state/omarchy/current/theme.name"
run_cycle omarchy-theme-next
grep -Fx 'tokyo-night' "$set_log" >/dev/null || fail "next from Gruvbox applies Tokyo Night" "$(cat "$set_log")"
grep -Fq 'Tokyo Night' "$notify_log" >/dev/null || fail "next notifies Tokyo Night" "$(cat "$notify_log")"

printf 'gruvbox\n' >"$home/.local/state/omarchy/current/theme.name"
run_cycle omarchy-theme-prev
grep -Fx 'catppuccin' "$set_log" >/dev/null || fail "prev from Gruvbox applies Catppuccin" "$(cat "$set_log")"
grep -Fq 'Catppuccin' "$notify_log" >/dev/null || fail "prev notifies Catppuccin" "$(cat "$notify_log")"

printf 'tokyo-night\n' >"$home/.local/state/omarchy/current/theme.name"
run_cycle omarchy-theme-next
grep -Fx 'catppuccin' "$set_log" >/dev/null || fail "next wraps last theme to first" "$(cat "$set_log")"

printf 'catppuccin\n' >"$home/.local/state/omarchy/current/theme.name"
run_cycle omarchy-theme-prev
grep -Fx 'tokyo-night' "$set_log" >/dev/null || fail "prev wraps first theme to last" "$(cat "$set_log")"

rm -rf "$omarchy/themes/tokyo-night" "$home/.config/omarchy/themes/gruvbox"
printf 'catppuccin\n' >"$home/.local/state/omarchy/current/theme.name"
run_cycle omarchy-theme-next
[[ ! -s $set_log ]] || fail "next with one theme does not re-apply" "$(cat "$set_log")"
grep -Fq 'Catppuccin' "$notify_log" >/dev/null || fail "next with one theme still names it" "$(cat "$notify_log")"

run_cycle omarchy-theme-prev
[[ ! -s $set_log ]] || fail "prev with one theme does not re-apply" "$(cat "$set_log")"

pass "theme next and prev wrap installed themes"

# A setter failure must not be followed by a success notification.
printf 'missing\n' >"$home/.local/state/omarchy/current/theme.name"
for command in omarchy-theme-next omarchy-theme-prev; do
  if THEME_SET_EXIT=7 run_cycle "$command"; then
    fail "$command must propagate a failed application"
  fi
  [[ ! -s $notify_log ]] || fail "$command must not notify success after failure"
done
pass "theme cycling propagates setter failures without success notifications"

# Confirm the real setter rejects these entries before reaching its mutation phase.
for invalid in .hidden h-broken 'Bad Name'; do
  if HOME="$home" OMARCHY_PATH="$omarchy" bash "$ROOT/bin/omarchy-theme-set" "$invalid" >"$test_tmp/rejected" 2>&1; then
    fail "real theme setter must reject the invalid cycling fixture"
  fi
done

rm -rf "$omarchy/themes/catppuccin"
for command in omarchy-theme-next omarchy-theme-prev; do
  run_cycle "$command"
  [[ ! -s $set_log && ! -s $notify_log ]] || fail "$command must ignore a catalog containing only invalid entries"
done
pass "theme cycling ignores dangling links, hidden and unaddressable names"

# Preserve the upstream instant image picker when adding sibling menu rows.
grep -F '"style.theme":' "$ROOT/default/omarchy/omarchy-menu.jsonc" | grep -Fq 'omarchy-shell shell summon omarchy.image-picker' ||
  fail "theme menu retains the upstream instant picker action"
pass "theme menu retains instant picker alongside cycling actions"
