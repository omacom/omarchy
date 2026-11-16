#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Resume device: the real command, with every system path it writes moved into
# a scratch directory, so these cases run without hibernation on the machine.
rtmp=$(mktemp -d)
trap 'rm -rf "$rtmp"' EXIT
mkdir -p "$rtmp/bin" "$rtmp/sys" "$rtmp/sleep"
sed -e "s|/sys/power/|$rtmp/sys/|g" \
  -e "s|/etc/mkinitcpio.conf.d|$rtmp/mkinitcpio.conf.d|g" \
  -e "s|/etc/limine-entry-tool.d|$rtmp/limine-entry-tool.d|g" \
  -e "s|/etc/fstab|$rtmp/fstab|g" \
  -e "s|/swap/swapfile|$rtmp/swapfile|g" \
  -e "s|/usr/lib/systemd/system-sleep|$rtmp/sleep|g" \
  -e "s|/var/lib/omarchy|$rtmp/var-lib|g" \
  "$ROOT/bin/omarchy-hibernation-setup" >"$rtmp/setup"

for command in omarchy-hw-aarch64-apple omarchy-sleep-disabled omarchy-cmd-missing gum; do
  printf '#!/bin/bash\nexit 1\n' >"$rtmp/bin/$command"
done
printf '#!/bin/bash\nexit 0\n' >"$rtmp/bin/swaplabel"
printf '#!/bin/bash\n[[ $1 == --show ]] && echo "$SWAP_FILE_PATH"\nexit 0\n' >"$rtmp/bin/swapon"
printf '#!/bin/bash\n[[ $1 == inspect-internal ]] && echo 4242\nexit 0\n' >"$rtmp/bin/btrfs"
printf '#!/bin/bash\n[[ $2 == SOURCE ]] && echo "$SWAP_SOURCE"\n[[ $2 == UUID ]] && echo "$SWAP_UUID"\nexit 0\n' >"$rtmp/bin/findmnt"

# Root ownership is not the test's to give.
cat >"$rtmp/bin/sudo" <<'SH'
#!/bin/bash
if [[ $1 == */install ]]; then
  args=()
  while (($#)); do
    case $1 in
      -o | -g) shift 2 ;;
      *) args+=("$1"); shift ;;
    esac
  done
  set -- "${args[@]}"
fi
exec "$@"
SH

# Records the drop-in each build reads. limine-mkinitcpio 1.40 reports a kernel
# whose image failed to build and still exits 0; "interrupt" kills setup in the
# middle of the build, as closing the update terminal does.
cat >"$rtmp/bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
case ${REBUILD_RESULT:-ok} in
  skip) echo "==> ERROR: mkinitcpio failed for kernel 7.2.8-9-omarchy, skipping." >&2 ;;
  interrupt) kill -TERM "$PPID"; exit 0 ;;
esac
cat "$DROP_IN" >>"$REBUILD_LOG"
exit 0
SH
chmod +x "$rtmp/bin/"*

uuid=0f3c5a1e-7d2b-4c8e-9a61-2b7e4d9c1f08
uuid_line="KERNEL_CMDLINE[default]+=\" resume=UUID=$uuid resume_offset=4242\""
drop_in=$rtmp/limine-entry-tool.d/resume.conf

# Fresh state; given a drop-in line, a machine hibernation was set up on before.
machine() {
  rm -rf "$rtmp/limine-entry-tool.d" "$rtmp/mkinitcpio.conf.d" "$rtmp/var-lib"
  : >"$rtmp/sys/image_size"
  : >"$rtmp/swapfile"
  : >"$rtmp/fstab"
  : >"$rtmp/rebuilds"
  if (($#)); then
    mkdir -p "$rtmp/limine-entry-tool.d" "$rtmp/mkinitcpio.conf.d"
    printf 'HOOKS+=(resume)\n' >"$rtmp/mkinitcpio.conf.d/omarchy_resume.conf"
    printf '%s\n' "$1" >"$drop_in"
  fi
}

setup() {
  env PATH="$rtmp/bin:$PATH" SWAP_FILE_PATH="$rtmp/swapfile" SWAP_SOURCE="$SWAP_SOURCE" SWAP_UUID="$uuid" \
    DROP_IN="$drop_in" REBUILD_LOG="$rtmp/rebuilds" REBUILD_RESULT="${REBUILD_RESULT:-ok}" \
    bash "$rtmp/setup" "$@" >"$rtmp/out" 2>&1
}

# A kernel name such as nvme0n1p2 follows probe order, so with two NVMe disks it
# can name the other disk at the next boot. The filesystem UUID does not move,
# and neither does a device-mapper name.
machine
SWAP_SOURCE="/dev/nvme0n1p2[/@]" setup --force --no-rebuild || fail "setup on an unencrypted root" "$(<"$rtmp/out")"
[[ $(<"$drop_in") == "$uuid_line" ]] || fail "setup names an unencrypted root by its filesystem UUID" "$(<"$drop_in")"
machine
SWAP_SOURCE="/dev/mapper/root[/@]" setup --force --no-rebuild || fail "setup on an encrypted root" "$(<"$rtmp/out")"
[[ $(<"$drop_in") == 'KERNEL_CMDLINE[default]+=" resume=/dev/mapper/root resume_offset=4242"' ]] ||
  fail "setup keeps the device-mapper name of an encrypted root" "$(<"$drop_in")"
pass "setup names the resume device by filesystem UUID, or by its device-mapper name"

# A machine set up before: a rerun renames the device and rebuilds from the
# renamed drop-in, once. An empty offset is filled in first.
for line in 'KERNEL_CMDLINE[default]+=" resume=/dev/nvme1n1p2 resume_offset=4242"' \
  'KERNEL_CMDLINE[default]+=" resume=/dev/nvme1n1p2 resume_offset="'; do
  machine "$line"
  SWAP_SOURCE="/dev/nvme0n1p2[/@]" setup || fail "setup reruns on '$line'" "$(<"$rtmp/out")"
  [[ $(<"$drop_in") == "$uuid_line" && $(tail -n1 "$rtmp/rebuilds") == "$uuid_line" ]] ||
    fail "a rerun renames '$line' and rebuilds the boot image from it" "$(<"$rtmp/rebuilds")"
  builds=$(wc -l <"$rtmp/rebuilds")
  SWAP_SOURCE="/dev/nvme0n1p2[/@]" setup || fail "a second rerun succeeds" "$(<"$rtmp/out")"
  (( $(wc -l <"$rtmp/rebuilds") == builds )) || fail "a second rerun leaves a renamed drop-in alone"
done
pass "a rerun renames a kernel-name resume device once"

# If a kernel's image is not rebuilt, or the rebuild is interrupted, the drop-in
# is already renamed; the next run sees the pending rebuild and does it, once.
for result in skip interrupt; do
  machine 'KERNEL_CMDLINE[default]+=" resume=/dev/sda2 resume_offset=4242"'
  # A subshell, so the shell reporting the killed setup does not print to the log.
  if (SWAP_SOURCE="/dev/sda2[/@]" REBUILD_RESULT=$result setup) 2>/dev/null; then
    fail "setup reports a boot image it did not rebuild ($result)"
  fi
  : >"$rtmp/rebuilds"
  SWAP_SOURCE="/dev/sda2[/@]" setup || fail "a rerun after a failed rebuild succeeds ($result)" "$(<"$rtmp/out")"
  SWAP_SOURCE="/dev/sda2[/@]" setup || fail "a third run succeeds ($result)" "$(<"$rtmp/out")"
  [[ $(<"$rtmp/rebuilds") == "$uuid_line" ]] ||
    fail "the next run rebuilds the boot image a $result left behind, and only once" "$(<"$rtmp/rebuilds")"
done
pass "a rebuild that failed or was interrupted is retried on the next run"

# Encrypted installs are stable already, and a drop-in edited by hand belongs to
# whoever edited it.
for line in 'KERNEL_CMDLINE[default]+=" resume=/dev/mapper/root resume_offset=4242"' \
  $'KERNEL_CMDLINE[default]+=" resume=/dev/nvme0n1p2\tresume_offset=4242"'; do
  machine "$line"
  SWAP_SOURCE="/dev/nvme0n1p2[/@]" setup || fail "setup on a drop-in it does not own" "$(<"$rtmp/out")"
  [[ $(<"$drop_in") == "$line" && ! -s $rtmp/rebuilds ]] || fail "setup leaves a drop-in it does not own alone" "$(<"$drop_in")"
done
pass "setup leaves device-mapper and hand-edited drop-ins alone"
rm -rf "$rtmp"

if [[ ! -f /sys/power/image_size ]]; then
  skip "hibernation is unavailable; skipping setup prompt test"
  exit 0
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/bin"

cat >"$tmpdir/bin/omarchy-cmd-missing" <<'EOF'
#!/bin/bash
exit 1
EOF

cat >"$tmpdir/bin/grep" <<'EOF'
#!/bin/bash
exit 1
EOF

cat >"$tmpdir/bin/free" <<'EOF'
#!/bin/bash
if [[ ${LC_ALL:-} == "C" ]]; then
  printf 'Mem: 31Gi 1Gi 30Gi\n'
else
  printf '内存： 31Gi 1Gi 30Gi\n'
fi
EOF

cat >"$tmpdir/bin/gum" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >"$PROMPT_LOG"
exit 1
EOF

chmod +x "$tmpdir/bin/"*

env -u LC_ALL PROMPT_LOG="$tmpdir/prompt" PATH="$tmpdir/bin:$PATH" \
  "$ROOT/bin/omarchy-hibernation-setup"

[[ $(<"$tmpdir/prompt") == "confirm Use 31Gi on boot drive to make hibernation available?" ]] ||
  fail "hibernation setup reads memory size independently of the user's locale"
pass "hibernation setup reads memory size independently of the user's locale"
