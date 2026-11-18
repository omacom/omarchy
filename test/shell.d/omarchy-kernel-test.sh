#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

command="$ROOT/bin/omarchy-kernel"
# The root half is the packaged copy wherever one is installed, else this one.
root_half=/usr/bin/omarchy-kernel
[[ -x $root_half ]] || root_half=$command
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin" "$scratch/root-bin" "$scratch/drop-ins" "$scratch/modules"

export PATH="$scratch/bin:$PATH"
export CALL_LOG="$scratch/calls"
export OMARCHY_PATH="$ROOT"
export OMARCHY_KERNEL_LIMINE_CONF="$scratch/limine"
export OMARCHY_KERNEL_LIMINE_DROP_INS="$scratch/drop-ins"
export OMARCHY_KERNEL_MODULES_DIR="$scratch/modules"
export OMARCHY_KERNEL_ROOT_PATH="$scratch/root-bin:/usr/bin:/bin"
export OMARCHY_KERNEL_LOCK="$scratch/lock"

install_kernels() {
  local kernel
  rm -rf "$scratch/modules/"*
  for kernel in "$@"; do
    mkdir -p "$scratch/modules/$kernel-version"
    printf '%s\n' "$kernel" > "$scratch/modules/$kernel-version/pkgbase"
  done
}

# Unprivileged side: escalation records what it would run instead of running it.
for tool in pkexec sudo omarchy-state omarchy-notification-send; do
  cat > "$scratch/bin/$tool" <<SH
#!/bin/bash
printf '$tool %s\n' "\$*" >> "\$CALL_LOG"
[[ \${ESCALATION_FAIL:-0} == "0" || $tool != "pkexec" ]]
SH
done

# efibootmgr answers both halves, so root sees Direct Boot too.
for dir in bin root-bin; do
  cat > "$scratch/$dir/efibootmgr" <<'SH'
#!/bin/bash
printf 'BootCurrent: 0000\nBoot0000* Limine\tHD(1,GPT)/\\EFI\\limine\\limine_x64.efi\n'
[[ ${DIRECT_BOOT:-0} == "0" ]] || printf 'Boot0001* Omarchy\tHD(1,GPT)/\\EFI\\Linux\\omarchy_linux-omarchy.efi\n'
SH
done

# Root side: the boot menu lives in a file. A rebuild moves its kernel to the
# front, as limine-entry-tool's BOOT_ORDER sort does when that kernel leads the
# order, unless the build is skipped; it can also fail afterwards, as a post
# hook can, and can be slowed to overlap with another switch.
export MENU_FILE="$scratch/menu"
cat > "$scratch/root-bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
printf 'limine-mkinitcpio %s\n' "$*" >> "$CALL_LOG"
[[ $1 != "${SLOW_REBUILD:-}" ]] || sleep 1
if [[ $1 != "${SKIP_REORDER:-}" ]]; then
  { printf '%s\n' "$1"; grep -Fxv -- "$1" "$MENU_FILE"; } > "$MENU_FILE.new"
  mv "$MENU_FILE.new" "$MENU_FILE"
fi
[[ $1 != "${FAIL_REBUILD:-}" ]]
SH
cat > "$scratch/root-bin/limine-entry-tool" <<'SH'
#!/bin/bash
[[ $* == "--tree" ]] || exit 99
printf '%s\n' 'Omarchy'
sed 's/^/├─ /' "$MENU_FILE"
printf '%s\n' '└─ Snapshots' '   └─ 52 │ 2026-10-19 20:33:31'
SH
# An in-place edit that changes the config and then fails stands in for a disk
# that fills mid-write.
cat > "$scratch/root-bin/sed" <<'SH'
#!/bin/bash
/usr/bin/sed "$@" || exit
[[ ${FAIL_WRITE:-0} == "0" || $1 != "-i" ]]
SH
chmod +x "$scratch/bin/"* "$scratch/root-bin/"*

reset_fixture() {
  : > "$CALL_LOG"
  rm -f "$scratch/drop-ins/"*
  install_kernels linux linux-omarchy linux-omarchy-bore-o3-exp
  cat > "$OMARCHY_KERNEL_LIMINE_CONF" <<'CONF'
KERNEL_CMDLINE[default]+="root=/dev/mapper/root rw"
BOOT_ORDER="linux-omarchy-bore-o3-exp, linux-omarchy, linux-omarchy-*, *, *fallback, Snapshots"
CONF
  cp "$OMARCHY_KERNEL_LIMINE_CONF" "$scratch/original-limine"
  printf '%s\n' linux-omarchy-bore-o3-exp linux-omarchy linux > "$MENU_FILE"
}

as_root() {
  if (( EUID == 0 )); then
    "$@"
  else
    unshare --user --map-root-user "$@"
  fi
}

reset_fixture
[[ $("$command" list) == $'linux\nlinux-omarchy\nlinux-omarchy-bore-o3-exp' ]] || fail "list prints each installed kernel once"
[[ $("$command" get) == "linux-omarchy-bore-o3-exp" ]] || fail "get reads the central boot order"
[[ $("$command") == "linux-omarchy-bore-o3-exp" ]] || fail "get is the default verb"
printf '%s\n' 'BOOT_ORDER="linux, *" # stock kernel for now' >> "$OMARCHY_KERNEL_LIMINE_CONF"
[[ $("$command" get) == "linux" ]] || fail "an assignment with a trailing comment still counts"
pass "list and get read installed kernels and the boot order"

reset_fixture
sed -i '/^BOOT_ORDER=/d' "$OMARCHY_KERNEL_LIMINE_CONF"
printf '%s\n' 'BOOT_ORDER="linux-t2, linux-omarchy, linux-omarchy-*, *, *fallback, Snapshots"' > "$scratch/drop-ins/omarchy-defaults.conf"
[[ $("$command" get) == "linux-omarchy" ]] || fail "a drop-in order applies when the central config has none"
printf '%s\n' "BOOT_ORDER='linux, *'" > "$scratch/drop-ins/zz-local.conf"
[[ $("$command" get) == "linux" ]] || fail "the last drop-in read wins"
printf '%s\n' 'BOOT_ORDER="linux-omarchy, *"' >> "$OMARCHY_KERNEL_LIMINE_CONF"
[[ $("$command" get) == "linux-omarchy" ]] || fail "the central config wins over drop-ins"
pass "get resolves the effective order the way limine-entry-tool reads it"

reset_fixture
printf '%s\n' 'BOOT_ORDER="linux-omarchy-*, linux, *"' >> "$OMARCHY_KERNEL_LIMINE_CONF"
[[ -z $("$command" get) ]] || fail "a wildcard first match names no kernel, so no menu row is checked"
pass "get does not guess when a wildcard decides"

reset_fixture
if "$command" set linux-lts 2> "$scratch/output"; then
  fail "a kernel that is not installed is refused"
fi
grep -Fq "linux-lts is not an installed kernel" "$scratch/output" || fail "the refusal names the kernel" "$(<"$scratch/output")"
[[ ! -s $CALL_LOG ]] || fail "a refused kernel never escalates" "$(<"$CALL_LOG")"
pass "set only accepts installed kernels"

reset_fixture
"$command" set linux-omarchy < /dev/null
[[ $(grep -c '^pkexec ' "$CALL_LOG") == "1" ]] || fail "the menu path escalates through pkexec once" "$(<"$CALL_LOG")"
grep -Fxq "pkexec $root_half set linux-omarchy" "$CALL_LOG" || fail "pkexec runs this command's root half" "$(<"$CALL_LOG")"
! grep -q '^sudo ' "$CALL_LOG" || fail "the menu path has no terminal for sudo"
grep -Fxq 'omarchy-state set reboot-required' "$CALL_LOG" || fail "a switch asks for a reboot"
[[ $(grep -c '^omarchy-notification-send ' "$CALL_LOG") == "1" ]] || fail "only the finished switch is announced" "$(<"$CALL_LOG")"
grep -Fxq 'omarchy-notification-send -g  -t 30000 Now using linux-omarchy Reboot to use new default kernel --exec omarchy-system reboot' "$CALL_LOG" || fail "the notification names the kernel and reboots when clicked" "$(<"$CALL_LOG")"
pass "picked from the menu, set authenticates once with pkexec and asks for a reboot"

reset_fixture
if DIRECT_BOOT=1 "$command" set linux-omarchy < /dev/null 2> "$scratch/output"; then
  fail "a switch is refused while Direct Boot bypasses the boot menu"
fi
! grep -Eq '^(pkexec|sudo|omarchy-state) ' "$CALL_LOG" || fail "Direct Boot refuses before any prompt or reboot request" "$(<"$CALL_LOG")"
grep -Fq "Setup > Direct Boot" "$scratch/output" || fail "the refusal says how to turn Direct Boot off"
grep -q '^omarchy-notification-send .*-u critical' "$CALL_LOG" || fail "picked from the menu, the refusal is a notification"
pass "Direct Boot systems are told to turn it off instead of getting a switch that does nothing"

reset_fixture
if ESCALATION_FAIL=1 "$command" set linux-omarchy < /dev/null; then
  fail "a cancelled prompt fails the switch"
fi
! grep -q '^omarchy-state ' "$CALL_LOG" || fail "a cancelled switch does not ask for a reboot"
grep -Fxq "omarchy-notification-send -g  -u critical -t 30000 Couldn't switch to linux-omarchy Retry in a terminal --exec omarchy-launch-floating-terminal-with-presentation omarchy-kernel set linux-omarchy" "$CALL_LOG" ||
  fail "a failed switch says so like a success does, and retries in a terminal when clicked" "$(<"$CALL_LOG")"
pass "a cancelled or failed pkexec leaves no reboot request"

if (( EUID != 0 )) && ! unshare --user --map-root-user true 2>/dev/null; then
  skip "root half needs a user namespace"
  exit 0
fi

reset_fixture
as_root "$command" set linux
[[ $(grep -c '^BOOT_ORDER=' "$OMARCHY_KERNEL_LIMINE_CONF") == "1" ]] || fail "one boot order remains"
grep -Fxq 'BOOT_ORDER="linux, linux-omarchy-bore-o3-exp, linux-omarchy, linux-omarchy-*, *, *fallback, Snapshots"' "$OMARCHY_KERNEL_LIMINE_CONF" ||
  fail "the kernel goes first and the rest of the order follows" "$(<"$OMARCHY_KERNEL_LIMINE_CONF")"
grep -Fxq 'KERNEL_CMDLINE[default]+="root=/dev/mapper/root rw"' "$OMARCHY_KERNEL_LIMINE_CONF" || fail "the kernel cmdline is preserved"
[[ $(<"$CALL_LOG") == "limine-mkinitcpio linux" ]] || fail "only the chosen kernel is rebuilt" "$(<"$CALL_LOG")"
[[ $("$command" get) == "linux" ]] || fail "get reports the new default"
pass "the root half puts the kernel first, keeps other settings, and rebuilds one kernel"

reset_fixture
as_root "$command" set linux-omarchy
as_root "$command" set linux-omarchy
grep -Fxq 'BOOT_ORDER="linux-omarchy, linux-omarchy-bore-o3-exp, linux-omarchy-*, *, *fallback, Snapshots"' "$OMARCHY_KERNEL_LIMINE_CONF" ||
  fail "setting the same kernel twice does not repeat it" "$(<"$OMARCHY_KERNEL_LIMINE_CONF")"
! grep -q '^$' "$OMARCHY_KERNEL_LIMINE_CONF" || fail "repeated switches do not pile up blank lines"
pass "switching is idempotent"

reset_fixture
if SKIP_REORDER=linux as_root "$command" set linux 2> "$scratch/output"; then
  fail "a menu that did not reorder fails the switch"
fi
grep -Fq "linux did not become the first boot entry" "$scratch/output" || fail "the failure says the menu was not reordered" "$(<"$scratch/output")"
cmp -s "$OMARCHY_KERNEL_LIMINE_CONF" "$scratch/original-limine" || fail "a skipped build restores the previous boot order" "$(<"$OMARCHY_KERNEL_LIMINE_CONF")"
pass "a skipped boot image build fails and puts the previous boot order back"

reset_fixture
if FAIL_REBUILD=linux as_root "$command" set linux 2> /dev/null; then
  fail "a rebuild that reorders the menu and then fails still fails the switch"
fi
cmp -s "$OMARCHY_KERNEL_LIMINE_CONF" "$scratch/original-limine" || fail "the previous boot order is restored"
grep -Fxq 'limine-mkinitcpio linux-omarchy-bore-o3-exp' "$CALL_LOG" || fail "the previous menu leader is rebuilt" "$(<"$CALL_LOG")"
[[ $(head -n1 "$MENU_FILE") == "linux-omarchy-bore-o3-exp" ]] || fail "the previous kernel leads the boot menu again" "$(<"$MENU_FILE")"
[[ $("$command" get) == "linux-omarchy-bore-o3-exp" ]] || fail "get still reports the previous default after a failed switch"
pass "a rebuild that fails after reordering the menu puts the previous kernel back in front"

reset_fixture
install_kernels linux linux-omarchy-bore linux-omarchy-bore-o3-exp
printf '%s\n' 'BOOT_ORDER="linux-omarchy-*, *"' >> "$OMARCHY_KERNEL_LIMINE_CONF"
cp "$OMARCHY_KERNEL_LIMINE_CONF" "$scratch/original-limine"
printf '%s\n' linux-omarchy-bore linux-omarchy-bore-o3-exp linux > "$MENU_FILE"
if FAIL_REBUILD=linux as_root "$command" set linux 2> /dev/null; then
  fail "a failed switch fails even when the old default came from a wildcard tie"
fi
[[ $(head -n1 "$MENU_FILE") == "linux-omarchy-bore" ]] || fail "the kernel that led the menu is restored, though get could not name it" "$(<"$MENU_FILE")"
pass "rollback restores the previous menu leader even when a wildcard tie hid the default"

reset_fixture
SLOW_REBUILD=linux FAIL_REBUILD=linux as_root "$command" set linux 2> /dev/null &
first=$!
sleep 0.3
as_root "$command" set linux-omarchy
wait "$first" && fail "the slow switch fails"
grep -Fxq 'BOOT_ORDER="linux-omarchy, linux-omarchy-bore-o3-exp, linux-omarchy-*, *, *fallback, Snapshots"' "$OMARCHY_KERNEL_LIMINE_CONF" ||
  fail "a failed switch cannot restore its backup over a later success" "$(<"$OMARCHY_KERNEL_LIMINE_CONF")"
[[ $(head -n1 "$MENU_FILE") == "linux-omarchy" ]] || fail "the later success leads the boot menu" "$(<"$MENU_FILE")"
pass "overlapping switches run one at a time, so the last success wins"

reset_fixture
if FAIL_WRITE=1 as_root "$command" set linux 2> /dev/null; then
  fail "a config that cannot be written fails the switch"
fi
cmp -s "$OMARCHY_KERNEL_LIMINE_CONF" "$scratch/original-limine" || fail "a failed write leaves the boot order in place" "$(<"$OMARCHY_KERNEL_LIMINE_CONF")"
! grep -q '^limine-mkinitcpio linux$' "$CALL_LOG" || fail "nothing is rebuilt after a failed write"
pass "a failed write keeps the previous boot order instead of deleting it"

reset_fixture
if DIRECT_BOOT=1 as_root "$command" set linux 2> /dev/null; then
  fail "root is refused under Direct Boot too"
fi
cmp -s "$OMARCHY_KERNEL_LIMINE_CONF" "$scratch/original-limine" || fail "a refused root switch leaves the boot order alone"
! grep -q '^limine-mkinitcpio' "$CALL_LOG" || fail "a refused root switch rebuilds nothing"
pass "sudo omarchy-kernel set is refused under Direct Boot as well"
