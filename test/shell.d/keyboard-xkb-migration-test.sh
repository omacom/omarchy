#!/bin/bash
#
# The XKB-exposure migration repairs installs whose /etc/vconsole.conf carries
# only KEYMAP — the shape systemd-firstboot leaves behind for console keymaps
# its kbd-model-map has no conversion row for. Without XKBLAYOUT/XKBVARIANT
# the session and the SDDM greeter resolve "us" and a password typed under the
# chosen layout during setup no longer works.

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

migration=$(grep -rl 'Expose the XKB keyboard layout' "$ROOT/migrations" | head -n 1 || true)
[[ -n $migration ]] || fail "XKB exposure migration exists"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# The migration edits /etc/vconsole.conf through sudo. Stub sudo so the write
# lands on the fixture, and point $OMARCHY_PATH at the checkout so the gap
# table resolves.
stub_bin="$TMPDIR/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
exec "$@"
STUB
chmod +x "$stub_bin/sudo"

# omarchy-migrate runs each migration with `bash -euo pipefail` and stops the
# whole chain on a non-zero exit, so match that invocation exactly.
run_migration() {
  local vconsole="$1"
  PATH="$stub_bin:$PATH" OMARCHY_PATH="$ROOT" OMARCHY_VCONSOLE_CONF="$vconsole" \
    bash -euo pipefail "$migration" >/dev/null ||
    fail "migration exits clean for $(basename "$vconsole")"
}

value() {
  awk -F= -v key="$1" '$1 == key { sub(/^[[:space:]]*/,"",$2); sub(/[[:space:]]*$/,"",$2); print $2; exit }' "$2"
}

# A gap-table keymap: systemd-firstboot wrote KEYMAP only.
vconsole="$TMPDIR/polish.conf"
printf 'KEYMAP=pl\nFONT=default8x16\n' >"$vconsole"
run_migration "$vconsole"
[[ $(value XKBLAYOUT "$vconsole") == "pl" ]] || fail "migration exposes the polish layout" "$(cat "$vconsole")"
grep -q '^XKBVARIANT=' "$vconsole" && fail "migration writes no variant for a variantless keymap"
pass "migration writes no variant for a variantless keymap"
[[ $(value KEYMAP "$vconsole") == "pl" ]] || fail "migration keeps the keymap"
pass "migration keeps the keymap"

# A gap-table keymap with a variant.
vconsole="$TMPDIR/colemak.conf"
printf 'KEYMAP=colemak\n' >"$vconsole"
run_migration "$vconsole"
[[ $(value XKBLAYOUT "$vconsole") == "us" && $(value XKBVARIANT "$vconsole") == "colemak" ]] ||
  fail "migration exposes the colemak layout and variant" "$(cat "$vconsole")"
pass "migration exposes the colemak layout and variant"

# A keymap systemd's own table converts: layout and variant come from there.
if [[ -f /usr/share/systemd/kbd-model-map ]]; then
  vconsole="$TMPDIR/dvorak.conf"
  printf 'KEYMAP=dvorak\n' >"$vconsole"
  run_migration "$vconsole"
  [[ $(value XKBLAYOUT "$vconsole") == "us" && $(value XKBVARIANT "$vconsole") == "dvorak" ]] ||
    fail "migration derives the layout from kbd-model-map" "$(cat "$vconsole")"
  pass "migration derives the layout from kbd-model-map"

  # A comma-separated conversion keeps only its first entry: the session and
  # greeter prepend "us" to non-Latin layouts themselves.
  vconsole="$TMPDIR/russian.conf"
  printf 'KEYMAP=ru\n' >"$vconsole"
  run_migration "$vconsole"
  [[ $(value XKBLAYOUT "$vconsole") == "ru" ]] ||
    fail "migration keeps the first entry of a converted list" "$(cat "$vconsole")"
  pass "migration keeps the first entry of a converted list"
else
  pass "no kbd-model-map on this machine; skipping the conversion-table cases"
fi

# A layout already present (ISO-written, or another user's earlier run) must
# leave the file byte-identical, and rerunning a fixed file stays clean.
vconsole="$TMPDIR/already.conf"
printf 'KEYMAP=de\nXKBLAYOUT=de\nFONT=default8x16\n' >"$vconsole"
cp "$vconsole" "$TMPDIR/already.orig"
run_migration "$vconsole"
run_migration "$vconsole"
cmp -s "$vconsole" "$TMPDIR/already.orig" || fail "migration leaves an exposed layout alone" "$(cat "$vconsole")"
pass "migration leaves an exposed layout alone"

# No keymap to derive a layout from: leave the file alone.
vconsole="$TMPDIR/nokeymap.conf"
printf 'FONT=default8x16\n' >"$vconsole"
run_migration "$vconsole"
grep -q '^XKBLAYOUT=' "$vconsole" && fail "migration skips a keymap-less vconsole.conf"
pass "migration skips a keymap-less vconsole.conf"

# Missing file entirely: clean exit, nothing created.
vconsole="$TMPDIR/absent.conf"
run_migration "$vconsole"
[[ -e $vconsole ]] && fail "migration no-ops without vconsole.conf"
pass "migration no-ops without vconsole.conf"
