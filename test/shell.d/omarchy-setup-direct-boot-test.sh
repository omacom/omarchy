#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

command="$ROOT/bin/omarchy-setup-direct-boot"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"

export PATH="$scratch/bin:$PATH"
export OMARCHY_DIRECT_BOOT_ROOT="$scratch/root"
export EFI_STATE="$scratch/efi"
export CALL_LOG="$scratch/calls"

# A small NVRAM model: one "num|label|loader" line per entry, plus the boot order.
cat > "$scratch/bin/efibootmgr" <<'SH'
#!/bin/bash
entries="$EFI_STATE/entries"
order="$EFI_STATE/order"

if (( $# == 0 )); then
  printf 'BootCurrent: 0000\n'
  [[ -s $order ]] && printf 'BootOrder: %s\n' "$(cat "$order")"
  while IFS='|' read -r num label loader; do
    printf 'Boot%s* %s\tHD(1,GPT,0000,0x800,0x400000)/%s\n' "$num" "$label" "$loader"
  done < "$entries"
  exit 0
fi

printf 'efibootmgr %s\n' "$*" >> "$CALL_LOG"
case "$1" in
  --create)
    label="" loader=""
    while (( $# )); do
      case "$1" in
        --label) label="$2"; shift ;;
        --loader) loader="$2"; shift ;;
      esac
      shift
    done
    last=$(cut -d'|' -f1 "$entries" | sort | tail -1)
    num=$(printf '%04X' $(( 16#${last:-0} + 1 )))
    printf '%s|%s|%s\n' "$num" "$label" "$loader" >> "$entries"
    if [[ -s $order ]]; then
      printf '%s,%s\n' "$num" "$(cat "$order")" > "$order"
    else
      printf '%s\n' "$num" > "$order"
    fi
    ;;
  --bootnum)
    [[ $3 == "--delete-bootnum" ]] || exit 99
    grep -v "^$2|" "$entries" > "$entries.new" || true
    mv "$entries.new" "$entries"
    sed -E "s/(^|,)$2(,|$)/\1\2/; s/,,/,/; s/^,//; s/,$//" "$order" > "$order.new"
    mv "$order.new" "$order"
    ;;
  --bootorder) printf '%s\n' "$2" > "$order" ;;
  *) exit 99 ;;
esac
SH

cat > "$scratch/bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH

cat > "$scratch/bin/findmnt" <<'SH'
#!/bin/bash
printf '/dev/nvme0n1p1\n'
SH

cat > "$scratch/bin/omarchy-state" <<'SH'
#!/bin/bash
printf 'state %s\n' "$*" >> "$CALL_LOG"
SH

cat > "$scratch/bin/gum" <<'SH'
#!/bin/bash
[[ $1 == "confirm" ]]
SH
chmod +x "$scratch/bin/"*

# Reset to a UEFI system with both kernels' UKIs and Omarchy's default boot order.
reset_system() {
  rm -rf "$OMARCHY_DIRECT_BOOT_ROOT" "$EFI_STATE" "$CALL_LOG"
  mkdir -p "$OMARCHY_DIRECT_BOOT_ROOT/sys/firmware/efi" "$OMARCHY_DIRECT_BOOT_ROOT/boot/EFI/Linux" \
    "$OMARCHY_DIRECT_BOOT_ROOT/etc/limine-entry-tool.d" "$OMARCHY_DIRECT_BOOT_ROOT/etc/default" "$EFI_STATE"
  touch "$OMARCHY_DIRECT_BOOT_ROOT/boot/EFI/Linux/omarchy_linux.efi" \
    "$OMARCHY_DIRECT_BOOT_ROOT/boot/EFI/Linux/omarchy_linux-omarchy.efi" "$CALL_LOG"
  printf '%s\n' 'BOOT_ORDER="linux-t2, linux-omarchy, linux-omarchy-*, *, *fallback, Snapshots"' \
    > "$OMARCHY_DIRECT_BOOT_ROOT/etc/limine-entry-tool.d/omarchy-defaults.conf"
  printf '%s\n' '0000|UiApp|FvFile(462caa21)' '0003|Limine|\EFI\limine\limine_x64.efi' > "$EFI_STATE/entries"
  printf '0000\n' > "$EFI_STATE/order"
}

loader_of_omarchy_entry() {
  "$scratch/bin/efibootmgr" | sed -n 's/^Boot[0-9A-F]*\* Omarchy\t.*\/\(.*\)$/\1/p'
}

reset_system
"$command" >/dev/null
[[ $(loader_of_omarchy_entry) == '\EFI\Linux\omarchy_linux-omarchy.efi' ]] || fail "setup points at the kernel BOOT_ORDER prefers" "$(loader_of_omarchy_entry)"
pass "setup points at the kernel BOOT_ORDER prefers"

reset_system
printf '%s\n' 'BOOT_ORDER="linux, *"' > "$OMARCHY_DIRECT_BOOT_ROOT/etc/default/limine"
"$command" >/dev/null
[[ $(loader_of_omarchy_entry) == '\EFI\Linux\omarchy_linux.efi' ]] || fail "/etc/default/limine overrides the drop-in boot order"
pass "/etc/default/limine overrides the drop-in boot order"

reset_system
rm "$OMARCHY_DIRECT_BOOT_ROOT/boot/EFI/Linux/omarchy_linux-omarchy.efi"
printf '0004|Omarchy|\\EFI\\Linux\\omarchy_linux.efi\n' >> "$EFI_STATE/entries"
"$command" --refresh
[[ ! -s $CALL_LOG ]] || fail "refresh leaves an entry that already boots the only kernel" "$(cat "$CALL_LOG")"
pass "refresh leaves an entry that already boots the only kernel"

reset_system
printf '0004|Omarchy|\\EFI\\LINUX\\OMARCHY_LINUX.EFI\n' >> "$EFI_STATE/entries"
printf '0003,0004,0000\n' > "$EFI_STATE/order"
output=$("$command" --refresh)
[[ $(loader_of_omarchy_entry) == '\EFI\Linux\omarchy_linux-omarchy.efi' ]] || fail "refresh repoints an upper-case firmware path at the preferred kernel" "$output"
[[ $("$scratch/bin/efibootmgr" | grep -c ' Omarchy') == "1" ]] || fail "refresh replaces the old entry instead of adding a second one"
[[ $(cat "$EFI_STATE/order") == "0003,0005,0000" ]] || fail "refresh keeps the entry's place in the boot order" "$(cat "$EFI_STATE/order")"
grep -Fxq 'state set reboot-required' "$CALL_LOG" || fail "refresh requests a reboot"
pass "refresh repoints the entry in place and requests a reboot"

cp "$CALL_LOG" "$scratch/first-refresh"
"$command" --refresh
cmp -s "$CALL_LOG" "$scratch/first-refresh" || fail "a second refresh is a no-op"
pass "a second refresh is a no-op"

reset_system
printf '0004|Omarchy|\\EFI\\custom\\grubx64.efi\n' >> "$EFI_STATE/entries"
"$command" --refresh
[[ ! -s $CALL_LOG ]] || fail "refresh leaves entries pointing outside the Omarchy UKIs"
pass "refresh leaves entries pointing outside the Omarchy UKIs"

reset_system
"$command" --refresh
[[ ! -s $CALL_LOG ]] || fail "refresh does nothing without direct boot"
rm -r "$OMARCHY_DIRECT_BOOT_ROOT/sys/firmware/efi"
"$command" --refresh || fail "refresh succeeds on systems without UEFI"
pass "refresh does nothing without direct boot or UEFI"
