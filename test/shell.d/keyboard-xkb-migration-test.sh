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
[[ ${SUDO_FAIL:-0} == 1 ]] && exit 1
exec "$@"
STUB
cat >"$stub_bin/limine-mkinitcpio" <<'STUB'
#!/bin/bash
[[ ${LIMINE_FAIL:-0} == 1 ]] && exit 1
touch "$LIMINE_REBUILD_MARKER"
STUB
chmod +x "$stub_bin/sudo" "$stub_bin/limine-mkinitcpio"
LIMINE_REBUILD_MARKER="$TMPDIR/rebuild-called"
export LIMINE_REBUILD_MARKER

# omarchy-migrate runs each migration with `bash -euo pipefail` and stops the
# whole chain on a non-zero exit, so match that invocation exactly. The hooks
# conf defaults to an absent fixture: cases that don't exercise the initramfs
# repair must not depend on the machine's real one.
run_migration() {
  local vconsole="$1" hooks="${2:-$TMPDIR/absent-hooks.conf}"
  PATH="$stub_bin:$PATH" OMARCHY_PATH="$ROOT" OMARCHY_VCONSOLE_CONF="$vconsole" \
    OMARCHY_HOOKS_CONF="$hooks" \
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

  # kbd-model-map pads its columns with a variable number of tabs; is-latin1's
  # row carries one tab fewer, which would hand the model (pc105) back as the
  # layout under a fixed-position read.
  vconsole="$TMPDIR/icelandic.conf"
  printf 'KEYMAP=is-latin1\n' >"$vconsole"
  run_migration "$vconsole"
  [[ $(value XKBLAYOUT "$vconsole") == "is" ]] ||
    fail "migration parses padded rows by logical column" "$(cat "$vconsole")"
  grep -q '^XKBVARIANT=' "$vconsole" && fail "migration writes no variant for is-latin1"
  pass "migration writes no variant for is-latin1"

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

# Gap-table variants: a blank variant would select XKB's default (BDS for
# Bulgarian, QWERTZ for Czech) and silently move the keys a setup-typed
# password depends on.
vconsole="$TMPDIR/bulgarian.conf"
printf 'KEYMAP=bg-cp1251\n' >"$vconsole"
run_migration "$vconsole"
[[ $(value XKBLAYOUT "$vconsole") == "bg" && $(value XKBVARIANT "$vconsole") == "phonetic" ]] ||
  fail "migration exposes the phonetic Bulgarian variant" "$(cat "$vconsole")"
pass "migration exposes the phonetic Bulgarian variant"

vconsole="$TMPDIR/czech.conf"
printf 'KEYMAP=cz\n' >"$vconsole"
run_migration "$vconsole"
[[ $(value XKBLAYOUT "$vconsole") == "cz" && $(value XKBVARIANT "$vconsole") == "qwerty" ]] ||
  fail "migration exposes the qwerty Czech variant" "$(cat "$vconsole")"
pass "migration exposes the qwerty Czech variant"

# The non-Latin initramfs repair: 1784476564.sh no-oped for installs whose
# vconsole.conf carried no XKBLAYOUT, so its bundling may still be pending.
# Exposing bg here must remove it and rebuild, or the next UKI rebuild locks
# the LUKS passphrase behind a Cyrillic console map.
hooks="$TMPDIR/omarchy_hooks.conf"
vconsole="$TMPDIR/bulgarian-stale-hooks.conf"
printf 'KEYMAP=bg-cp1251\n' >"$vconsole"
printf 'HOOKS=(base udev plymouth keyboard)\nFILES+=(/etc/vconsole.conf)\n' >"$hooks"
rm -f "$LIMINE_REBUILD_MARKER"
PATH="$stub_bin:$PATH" SUDO_FAIL=1 OMARCHY_PATH="$ROOT" OMARCHY_VCONSOLE_CONF="$vconsole" \
  OMARCHY_HOOKS_CONF="$hooks" bash -euo pipefail "$migration" >/dev/null 2>&1 &&
  fail "migration fails when the privileged write fails"
grep -q 'FILES+=(/etc/vconsole.conf)' "$hooks" || fail "a failed write leaves the hooks file untouched"
grep -q '^XKBLAYOUT=' "$vconsole" && fail "a failed write leaves the vconsole untouched"
pass "a failed write leaves the migration pending with nothing applied"

run_migration "$vconsole" "$hooks"
grep -q 'FILES+=(/etc/vconsole.conf)' "$hooks" && fail "migration removes the stale initramfs bundling" "$(cat "$hooks")"
pass "migration removes the stale initramfs bundling"
[[ -e $LIMINE_REBUILD_MARKER ]] || fail "migration rebuilds the initramfs after removing the bundling"
pass "migration rebuilds the initramfs after removing the bundling"
[[ $(value XKBLAYOUT "$vconsole") == "bg" && $(value XKBVARIANT "$vconsole") == "phonetic" ]] ||
  fail "migration still exposes the layout after the repair" "$(cat "$vconsole")"
pass "migration still exposes the layout after the repair"
grep -q '^HOOKS=(base udev plymouth keyboard)' "$hooks" || fail "migration keeps the rest of the hooks file" "$(cat "$hooks")"
pass "migration keeps the rest of the hooks file"

# A failed initramfs rebuild must keep the repair pending: the bundling is
# disabled in place, so the retry still matches the guard and rebuilds
# instead of completing while the old UKI bundles the unsafe vconsole.conf.
hooks="$TMPDIR/omarchy_hooks-retry.conf"
vconsole="$TMPDIR/bulgarian-retry.conf"
printf 'KEYMAP=bg-cp1251\n' >"$vconsole"
printf 'HOOKS=(base udev plymouth keyboard)\nFILES+=(/etc/vconsole.conf)\n' >"$hooks"
rm -f "$LIMINE_REBUILD_MARKER"
PATH="$stub_bin:$PATH" LIMINE_FAIL=1 OMARCHY_PATH="$ROOT" OMARCHY_VCONSOLE_CONF="$vconsole" \
  OMARCHY_HOOKS_CONF="$hooks" bash -euo pipefail "$migration" >/dev/null 2>&1 &&
  fail "migration fails when the initramfs rebuild fails"
grep -q '^#FILES+=(/etc/vconsole.conf)$' "$hooks" || fail "a failed rebuild leaves the bundling disabled" "$(cat "$hooks")"
grep -qx 'FILES+=(/etc/vconsole.conf)' "$hooks" && fail "a failed rebuild leaves no active bundling" "$(cat "$hooks")"
grep -q '^XKBLAYOUT=' "$vconsole" && fail "a failed rebuild leaves the vconsole untouched"
pass "a failed rebuild disables the bundling and stays pending"

run_migration "$vconsole" "$hooks"
[[ -e $LIMINE_REBUILD_MARKER ]] || fail "the retry rebuilds the initramfs after a failed rebuild"
pass "the retry rebuilds the initramfs after a failed rebuild"
grep -q 'FILES+=(/etc/vconsole.conf)' "$hooks" && fail "the retry drops the disabled bundling" "$(cat "$hooks")"
pass "the retry drops the disabled bundling"
[[ $(value XKBLAYOUT "$vconsole") == "bg" && $(value XKBVARIANT "$vconsole") == "phonetic" ]] ||
  fail "the retry exposes the layout" "$(cat "$vconsole")"
pass "the retry exposes the layout"

# An already-repaired (or never-stale) hooks file is left alone.
hooks="$TMPDIR/omarchy_hooks-conditional.conf"
vconsole="$TMPDIR/ukrainian-conditional.conf"
printf 'KEYMAP=ua\n' >"$vconsole"
printf 'HOOKS=(base)\n    *) FILES+=(/etc/vconsole.conf) ;;\n' >"$hooks"
rm -f "$LIMINE_REBUILD_MARKER"
run_migration "$vconsole" "$hooks"
[[ $(value XKBLAYOUT "$vconsole") == "ua" ]] || fail "migration exposes the ukrainian layout" "$(cat "$vconsole")"
grep -q 'FILES+=(/etc/vconsole.conf)' "$hooks" || fail "migration leaves a conditional hooks file alone"
[[ -e $LIMINE_REBUILD_MARKER ]] && fail "migration rebuilds nothing when the hooks file is fine"
pass "migration leaves a conditional hooks file alone"

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
