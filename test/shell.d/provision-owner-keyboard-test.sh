#!/bin/bash
#
# First-boot keyboard step: whatever layout the owner picked to type their
# password with must still be the layout the login screen resolves. The
# session and the SDDM greeter both read XKBLAYOUT/XKBVARIANT out of
# /etc/vconsole.conf, so the step has to guarantee those variables even for
# the console keymaps systemd's kbd-model-map has no conversion row for.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# The gap table and its lookup live in the shared setup form, so the installer
# and this test read the same mapping.
source "$ROOT/install/provisioning/setup-form.sh"

# The keyboard step's functions, extracted the way the provisioning tests run
# single pieces of omarchy-provision-owner.
eval "$(sed -n '/^omarchy_write_xkb_layout() {/,/^}/p' "$ROOT/bin/omarchy-provision-owner")"
eval "$(sed -n '/^omarchy_expose_xkb_layout() {/,/^}/p' "$ROOT/bin/omarchy-provision-owner")"
eval "$(sed -n '/^apply_keyboard() {/,/^}/p' "$ROOT/bin/omarchy-provision-owner")"

LOG_FILE="$TMPDIR/log"
log_step() { printf '%s\n' "$1" >>"$LOG_FILE"; }

assert_equal() {
  local actual="$1" expected="$2" description="$3"

  [[ $actual == "$expected" ]] ||
    fail "$description" "expected: $expected"$'\n'"actual:   $actual"
  pass "$description"
}

vconsole_value() {
  awk -F= -v key="$1" '
    $1 == key {
      value = $2
      sub(/^[[:space:]]*/, "", value)
      sub(/[[:space:]]*$/, "", value)
      print value
      exit
    }
  ' "$2"
}

# ── omarchy_keyboard_xkb ─────────────────────────────────────────────────────

assert_equal "$(omarchy_keyboard_xkb azerty)" "fr " "the azerty gap maps to the layout typed at install time"
assert_equal "$(omarchy_keyboard_xkb colemak)" "us colemak" "the colemak gap keeps the ISO's layout and variant"
assert_equal "$(omarchy_keyboard_xkb pl)" "pl " "the polish gap maps to the polish layout"
assert_equal "$(omarchy_keyboard_xkb ua)" "ua " "the ukrainian gap maps to the ukrainian layout"
assert_equal "$(omarchy_keyboard_xkb fr)" "" "a keymap systemd converts is not a gap"
assert_equal "$(omarchy_keyboard_xkb nosuchkeymap)" "" "an unknown keymap is not a gap"

# Every layout the form offers must resolve somewhere: either systemd's own
# conversion table knows the keymap, or the gap table does. A new row in the
# picker with neither would silently log the machine into a "us" login screen.
if [[ -f /usr/share/systemd/kbd-model-map ]]; then
  while IFS='|' read -r _ keymap; do
    [[ -n $keymap ]] || continue
    if cut -f1 /usr/share/systemd/kbd-model-map | grep -qix "$keymap"; then
      continue
    fi
    [[ -n $(omarchy_keyboard_xkb "$keymap") ]] ||
      fail "offered keymap $keymap resolves to an XKB layout" "neither kbd-model-map nor OMARCHY_KEYBOARD_XKB_GAPS knows $keymap"
  done < <(printf '%s\n' "$OMARCHY_KEYBOARD_LAYOUTS")
  pass "every offered keymap resolves to an XKB layout"
else
  pass "no kbd-model-map on this machine; skipping the conversion-table cross-check"
fi

# ── omarchy_write_xkb_layout ─────────────────────────────────────────────────

file="$TMPDIR/vconsole-upsert"
printf '# Written by systemd-localed(8)\nKEYMAP=pl\nFONT=default8x16\n' >"$file"
omarchy_write_xkb_layout "$file" "pl" ""
assert_equal "$(vconsole_value XKBLAYOUT "$file")" "pl" "an absent XKB layout is appended"
[[ $(grep -c '^XKBVARIANT=' "$file") == 0 ]] || fail "an empty variant writes no XKBVARIANT"
assert_equal "$(vconsole_value KEYMAP "$file")" "pl" "the upsert leaves the keymap alone"
assert_equal "$(vconsole_value FONT "$file")" "default8x16" "the upsert leaves the font alone"
head -1 "$file" | grep -q '^# Written' || fail "the upsert leaves comments alone"
pass "the upsert preserves the rest of vconsole.conf"

omarchy_write_xkb_layout "$file" "be" ""
assert_equal "$(vconsole_value XKBLAYOUT "$file")" "be" "a present XKB layout is replaced"
[[ $(grep -c 'XKBLAYOUT=' "$file") == 1 ]] || fail "a replaced layout is not duplicated" "$(cat "$file")"

printf 'XKBVARIANT=old\n' >>"$file"
omarchy_write_xkb_layout "$file" "us" "colemak"
assert_equal "$(vconsole_value XKBVARIANT "$file")" "colemak" "a present variant is replaced"
assert_equal "$(vconsole_value XKBLAYOUT "$file")" "us" "the layout rides along with a variant write"

# A keymap without a variant must clear the previous keymap's one: kept
# beside a layout that has none, it would silently reshape the new keys.
printf 'KEYMAP=pl\nXKBVARIANT=dvorak\n' >"$file"
omarchy_write_xkb_layout "$file" "pl" ""
grep -q '^XKBVARIANT=' "$file" && fail "a stale variant is cleared when the keymap has none" "$(cat "$file")"
assert_equal "$(vconsole_value XKBLAYOUT "$file")" "pl" "the layout lands beside the cleared variant"

# The Lua readers accept leading whitespace on an assignment, so an indented
# one is replaced instead of left behind a new one.
file="$TMPDIR/vconsole-indented"
printf 'KEYMAP=pl\n  XKBLAYOUT=fr\n    XKBVARIANT=dvorak\n' >"$file"
omarchy_write_xkb_layout "$file" "us" "colemak"
[[ $(grep -c 'XKBLAYOUT=' "$file") == 1 && $(grep -c 'XKBVARIANT=' "$file") == 1 ]] ||
  fail "an indented assignment is replaced, not duplicated" "$(cat "$file")"
assert_equal "$(omarchy_vconsole_value XKBLAYOUT "$file")" "us" "an indented layout is replaced"
assert_equal "$(omarchy_vconsole_value XKBVARIANT "$file")" "colemak" "an indented variant is replaced"

# A failed write must reach the caller, which reports it.
file="$TMPDIR/vconsole-unwritable"
printf 'KEYMAP=pl\n' >"$file"
if (sed() { return 1; }; omarchy_write_xkb_layout "$file" "pl" ""); then
  fail "a failed write is reported"
fi
grep -q 'XKBLAYOUT=' "$file" && fail "a failed delete appends nothing" "$(cat "$file")"
pass "a failed write is reported"

# ── omarchy_expose_xkb_layout ────────────────────────────────────────────────

file="$TMPDIR/vconsole-gap"
printf 'KEYMAP=pl\nFONT=default8x16\n' >"$file"
omarchy_expose_xkb_layout "$file" "pl"
assert_equal "$(vconsole_value XKBLAYOUT "$file")" "pl" "a keymap-only vconsole.conf gains its layout"
grep -q '^XKBVARIANT=' "$file" && fail "a variantless keymap gains no variant line"
pass "a variantless keymap gains no variant line"

file="$TMPDIR/vconsole-variant-gap"
printf 'KEYMAP=colemak\n' >"$file"
omarchy_expose_xkb_layout "$file" "colemak"
assert_equal "$(vconsole_value XKBLAYOUT "$file")" "us" "the colemak gap exposes its layout"
assert_equal "$(vconsole_value XKBVARIANT "$file")" "colemak" "the colemak gap exposes its variant"

file="$TMPDIR/vconsole-already"
printf 'KEYMAP=de\nXKBLAYOUT=de\n' >"$file"
omarchy_expose_xkb_layout "$file" "pl"
assert_equal "$(vconsole_value XKBLAYOUT "$file")" "de" "a vconsole.conf that already carries a layout is untouched"

# The guard reads like the Lua readers do: an indented assignment counts, so
# a second exposure attempt must not append a duplicate after it.
file="$TMPDIR/vconsole-indented-layout"
printf 'KEYMAP=de\n  XKBLAYOUT=fr\n' >"$file"
omarchy_expose_xkb_layout "$file" "pl"
[[ $(grep -c 'XKBLAYOUT=' "$file") == 1 ]] || fail "an indented layout satisfies the exposure guard" "$(cat "$file")"
grep -q '^  XKBLAYOUT=fr$' "$file" || fail "the guard leaves the indented layout alone" "$(cat "$file")"
pass "an indented layout satisfies the exposure guard"

# A stale variant must not survive an exposure for a keymap without one.
file="$TMPDIR/vconsole-stale-variant"
printf 'KEYMAP=pl\nXKBVARIANT=dvorak\n' >"$file"
omarchy_expose_xkb_layout "$file" "pl"
grep -q '^XKBVARIANT=' "$file" && fail "an exposure clears the stale variant" "$(cat "$file")"
assert_equal "$(vconsole_value XKBLAYOUT "$file")" "pl" "an exposure lands beside the cleared variant"

file="$TMPDIR/vconsole-nongap"
printf 'KEYMAP=fr\n' >"$file"
omarchy_expose_xkb_layout "$file" "fr"
grep -q '^XKBLAYOUT=' "$file" && fail "a converted keymap is left to systemd"
pass "a converted keymap is left to systemd"

grep -q 'no XKB conversion' "$LOG_FILE" || fail "the gap fill is logged"
pass "the gap fill is logged"

# ── apply_keyboard wiring ────────────────────────────────────────────────────
#
# The real functions are replaced with a recorder, so the collaborators can be
# driven without root and without touching this machine's /etc/vconsole.conf.

STUB_BIN="$TMPDIR/bin"
mkdir -p "$STUB_BIN"
cat >"$STUB_BIN/systemd-firstboot" <<'STUB'
#!/bin/bash
[[ ${STUB_FIRSTBOOT:-ok} == ok ]]
STUB
cat >"$STUB_BIN/localectl" <<'STUB'
#!/bin/bash
if [[ $1 == "--no-pager" ]]; then
  printf '%s\n' ${STUB_KEYMAPS:-}
  exit 0
fi
[[ ${STUB_LOCALECTL:-} == ok ]]
STUB
cat >"$STUB_BIN/loadkeys" <<'STUB'
#!/bin/bash
touch "$STUB_LOADKEYS_MARKER"
STUB
chmod +x "$STUB_BIN/systemd-firstboot" "$STUB_BIN/localectl" "$STUB_BIN/loadkeys"
export PATH="$STUB_BIN:$PATH"
export STUB_LOADKEYS_MARKER="$TMPDIR/loadkeys-called"

exposed_args=""
omarchy_expose_xkb_layout() { exposed_args="$*"; }

run_apply() {
  exposed_args=""
  rm -f "$STUB_LOADKEYS_MARKER"
  apply_keyboard "$1"
}

STUB_KEYMAPS=pl run_apply pl
assert_equal "$exposed_args" "/etc/vconsole.conf pl" "a persisted keymap has its XKB layout exposed"

STUB_KEYMAPS=pl run_apply pl
[[ -e $STUB_LOADKEYS_MARKER ]] && fail "loadkeys is skipped off the console"
pass "loadkeys is skipped off the console"

STUB_KEYMAPS=pl STUB_FIRSTBOOT=fail STUB_LOCALECTL=ok run_apply pl
assert_equal "$exposed_args" "/etc/vconsole.conf pl" "the localectl fallback exposes the layout too"

STUB_KEYMAPS=pl STUB_FIRSTBOOT=fail STUB_LOCALECTL=fail run_apply pl
assert_equal "$exposed_args" "" "a keymap nothing persisted exposes nothing"

STUB_KEYMAPS=de STUB_FIRSTBOOT=fail STUB_LOCALECTL=fail run_apply pl
assert_equal "$exposed_args" "" "a keymap localectl does not know exposes nothing"

omarchy_expose_xkb_layout() { return 1; }
STUB_KEYMAPS=pl run_apply pl
grep -q 'could not expose the XKB layout' "$LOG_FILE" || fail "a failed exposure is logged, not fatal"
pass "a failed exposure is logged, not fatal"
