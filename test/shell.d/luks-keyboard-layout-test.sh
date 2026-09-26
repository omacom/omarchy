#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

helpers="$ROOT/install/helpers/keyboard-vconsole.sh"
script="$ROOT/bin/omarchy-provision-owner"
[[ -f $helpers ]] || fail "keyboard-vconsole helper exists"
grep -q 'install/helpers/keyboard-vconsole.sh' "$script" ||
  fail "apply_keyboard sources the keyboard-vconsole helper"
grep -q 'omarchy_ensure_vconsole_xkb' "$script" ||
  fail "apply_keyboard ensures XKBLAYOUT after firstboot"
grep -q 'omarchy_rebuild_boot_keyboard' "$script" ||
  fail "apply_keyboard rebuilds the UKI after persisting the layout"
grep -q 'keyboard-vconsole.sh' "$ROOT/install/config/all.sh" ||
  fail "install config runs keyboard-vconsole before the UKI build"
pass "keyboard persistence is wired through provision-owner and install config"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT

# Minimal kbd-model-map covering the cases this helper must resolve offline.
cat >"$scratch/kbd-model-map" <<'MAP'
# keymap		layout	model	variant	options
us			us	pc105	-	-
fr			fr	pc105	-	-
be-latin1		be	pc105	-	-
de			de	pc105	-	-
dvorak			us	pc105	dvorak	-
no			no	pc105	-	-
sr-latin		rs	pc105	latin	-
MAP

mkdir -p "$scratch/bin"
cat >"$scratch/bin/limine-mkinitcpio" <<'STUB'
#!/bin/bash
printf 'limine-mkinitcpio\n' >>"$CALL_LOG"
STUB
cat >"$scratch/bin/sudo" <<'STUB'
#!/bin/bash
exec "$@"
STUB
chmod +x "$scratch/bin/limine-mkinitcpio" "$scratch/bin/sudo"

run_helper() {
  local conf="$1" fn="$2"
  OMARCHY_VCONSOLE_CONF="$conf" OMARCHY_KBD_MODEL_MAP="$scratch/kbd-model-map" \
    CALL_LOG="$scratch/calls" PATH="$scratch/bin:$PATH" \
    bash -c "source \"$helpers\"; $fn"
}

assert_xkb() {
  local conf="$1" layout="$2" variant="${3:-}"
  grep -Fx "XKBLAYOUT=$layout" "$conf" >/dev/null ||
    fail "expected XKBLAYOUT=$layout in $conf" "$(cat "$conf")"
  if [[ -n $variant ]]; then
    grep -Fx "XKBVARIANT=$variant" "$conf" >/dev/null ||
      fail "expected XKBVARIANT=$variant in $conf" "$(cat "$conf")"
  fi
}

# French AZERTY: KEYMAP alone must gain XKBLAYOUT=fr so Plymouth matches loadkeys.
fr_conf="$scratch/fr.conf"
printf 'KEYMAP=fr\n' >"$fr_conf"
: >"$scratch/calls"
run_helper "$fr_conf" omarchy_ensure_vconsole_xkb
assert_xkb "$fr_conf" fr
pass "French KEYMAP gains XKBLAYOUT=fr"

# Belgian console keymap maps to XKB be.
be_conf="$scratch/be.conf"
printf 'KEYMAP=be-latin1\n' >"$be_conf"
run_helper "$be_conf" omarchy_ensure_vconsole_xkb
assert_xkb "$be_conf" be
pass "be-latin1 KEYMAP gains XKBLAYOUT=be"

# Colemak is an XKB variant of us, not a layout of its own.
colemak_conf="$scratch/colemak.conf"
printf 'KEYMAP=colemak\n' >"$colemak_conf"
run_helper "$colemak_conf" omarchy_ensure_vconsole_xkb
assert_xkb "$colemak_conf" us colemak
pass "colemak KEYMAP gains XKBLAYOUT=us XKBVARIANT=colemak"

# An admin-set XKBLAYOUT is left alone for ordinary keymaps.
keep_conf="$scratch/keep.conf"
printf 'KEYMAP=de\nXKBLAYOUT=de\nXKBVARIANT=nodeadkeys\n' >"$keep_conf"
run_helper "$keep_conf" omarchy_ensure_vconsole_xkb
grep -Fx 'XKBVARIANT=nodeadkeys' "$keep_conf" >/dev/null ||
  fail "existing XKBVARIANT must be preserved" "$(cat "$keep_conf")"
pass "existing XKBLAYOUT is not overwritten for ordinary keymaps"

# apply_keyboard rebuilds the UKI after persisting a Latin layout.
apply=$(sed -n '/^apply_keyboard() {/,/^}/p' "$script")
[[ -n $apply ]] || fail "apply_keyboard is defined"

cat >"$scratch/bin/tty" <<'STUB'
#!/bin/bash
echo /dev/pts/1
STUB
cat >"$scratch/bin/localectl" <<'STUB'
#!/bin/bash
[[ $* == "--no-pager list-keymaps" ]] && { printf '%s\n' us fr be-latin1 colemak; exit 0; }
exit 1
STUB
cat >"$scratch/bin/systemd-firstboot" <<'STUB'
#!/bin/bash
for arg in "$@"; do
  case "$arg" in
    --keymap=*) printf 'KEYMAP=%s\n' "${arg#--keymap=}" >"$OMARCHY_VCONSOLE_CONF" ;;
  esac
done
STUB
cat >"$scratch/bin/loadkeys" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$scratch/bin/"*

apply_conf="$scratch/apply.conf"
: >"$scratch/calls"
: >"$scratch/log"
OMARCHY_PATH="$ROOT" OMARCHY_VCONSOLE_CONF="$apply_conf" OMARCHY_KBD_MODEL_MAP="$scratch/kbd-model-map" \
  LOG_FILE="$scratch/log" CALL_LOG="$scratch/calls" PATH="$scratch/bin:$PATH" \
  bash -c "
    source '$helpers'
    log_step() { :; }
    $apply
    apply_keyboard fr
  "

grep -Fx 'KEYMAP=fr' "$apply_conf" >/dev/null || fail "apply_keyboard writes KEYMAP=fr" "$(cat "$apply_conf")"
assert_xkb "$apply_conf" fr
grep -Fx 'limine-mkinitcpio' "$scratch/calls" >/dev/null ||
  fail "apply_keyboard rebuilds the UKI after a Latin layout" "$(cat "$scratch/calls")"
pass "apply_keyboard persists French KEYMAP+XKBLAYOUT and rebuilds the UKI"

# Migration only rebuilds when it had to write XKBLAYOUT for a Latin layout.
migration="$ROOT/migrations/1790044019.sh"
[[ -f $migration ]] || fail "LUKS keyboard migration exists"

mig_conf="$scratch/mig.conf"
printf 'KEYMAP=fr\n' >"$mig_conf"
: >"$scratch/calls"
OMARCHY_PATH="$ROOT" OMARCHY_VCONSOLE_CONF="$mig_conf" OMARCHY_KBD_MODEL_MAP="$scratch/kbd-model-map" \
  CALL_LOG="$scratch/calls" PATH="$scratch/bin:$ROOT/bin:$PATH" \
  bash -euo pipefail "$migration" >/dev/null

assert_xkb "$mig_conf" fr
grep -Fx 'limine-mkinitcpio' "$scratch/calls" >/dev/null ||
  fail "migration rebuilds the UKI after filling XKBLAYOUT" "$(cat "$scratch/calls")"
pass "migration fills XKBLAYOUT and rebuilds for Latin keymaps"

# Already-complete vconsole must not force another rebuild.
printf 'KEYMAP=fr\nXKBLAYOUT=fr\n' >"$mig_conf"
: >"$scratch/calls"
OMARCHY_PATH="$ROOT" OMARCHY_VCONSOLE_CONF="$mig_conf" OMARCHY_KBD_MODEL_MAP="$scratch/kbd-model-map" \
  CALL_LOG="$scratch/calls" PATH="$scratch/bin:$ROOT/bin:$PATH" \
  bash -euo pipefail "$migration" >/dev/null

[[ ! -s $scratch/calls ]] ||
  fail "migration is a no-op when XKBLAYOUT is already set" "$(cat "$scratch/calls")"
pass "migration skips rebuild when XKBLAYOUT is already present"

# Offered keymaps missing from (or aliased in) kbd-model-map still persist.
no_conf="$scratch/no.conf"
printf 'KEYMAP=no-latin1\n' >"$no_conf"
run_helper "$no_conf" omarchy_ensure_vconsole_xkb
assert_xkb "$no_conf" no
pass "no-latin1 KEYMAP gains XKBLAYOUT=no"

ch_conf="$scratch/ch.conf"
printf 'KEYMAP=de_CH-latin1\n' >"$ch_conf"
run_helper "$ch_conf" omarchy_ensure_vconsole_xkb
assert_xkb "$ch_conf" ch de_nodeadkeys
pass "de_CH-latin1 KEYMAP gains XKBLAYOUT=ch XKBVARIANT=de_nodeadkeys"

sr_conf="$scratch/sr.conf"
printf 'KEYMAP=sr-latin\n' >"$sr_conf"
run_helper "$sr_conf" omarchy_ensure_vconsole_xkb
assert_xkb "$sr_conf" rs latin
# Latin variant of rs must still rebuild — it types Latin letters.
: >"$scratch/calls"
OMARCHY_PATH="$ROOT" OMARCHY_VCONSOLE_CONF="$sr_conf" OMARCHY_KBD_MODEL_MAP="$scratch/kbd-model-map" \
  CALL_LOG="$scratch/calls" PATH="$scratch/bin:$ROOT/bin:$PATH" \
  bash -c "source \"$helpers\"; omarchy_layout_is_non_latin rs latin; echo \$?" >"$scratch/non-latin.out"
[[ $(cat "$scratch/non-latin.out") == 1 ]] ||
  fail "rs/latin must not be treated as non-Latin" "$(cat "$scratch/non-latin.out")"
pass "sr-latin KEYMAP gains XKBLAYOUT=rs XKBVARIANT=latin and stays Latin"

# Protected vconsole.conf: setter elevates with sudo.
prot_dir="$scratch/prot"
mkdir -p "$prot_dir"
prot_conf="$prot_dir/vconsole.conf"
printf 'KEYMAP=fr\n' >"$prot_conf"
chmod a-w "$prot_conf" "$prot_dir"
: >"$scratch/sudo-calls"
cat >"$scratch/bin/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"${SUDO_LOG:?}"
# Drop the write bit only for the real file; allow the elevated tool to edit.
chmod u+w "$OMARCHY_VCONSOLE_CONF" "$(dirname "$OMARCHY_VCONSOLE_CONF")" 2>/dev/null || true
exec "$@"
STUB
chmod +x "$scratch/bin/sudo"
SUDO_LOG="$scratch/sudo-calls" OMARCHY_VCONSOLE_CONF="$prot_conf" \
  OMARCHY_KBD_MODEL_MAP="$scratch/kbd-model-map" PATH="$scratch/bin:$PATH" \
  bash -c "source \"$helpers\"; omarchy_ensure_vconsole_xkb"
chmod u+w "$prot_conf" "$prot_dir" 2>/dev/null || true
assert_xkb "$prot_conf" fr
grep -q '^sudo ' "$scratch/sudo-calls" ||
  fail "protected vconsole.conf write must use sudo" "$(cat "$scratch/sudo-calls")"
pass "omarchy_vconsole_set elevates writes to a protected vconsole.conf"
