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
assert_equal "$(vconsole_value XKBLAYOUT "$file")" "be" "a present XKB layout is replaced in place"

printf 'XKBVARIANT=old\n' >>"$file"
omarchy_write_xkb_layout "$file" "us" "colemak"
assert_equal "$(vconsole_value XKBVARIANT "$file")" "colemak" "a present variant is replaced in place"
assert_equal "$(vconsole_value XKBLAYOUT "$file")" "us" "the layout rides along with a variant write"

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
