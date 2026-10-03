#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

fixture=$(mktemp -d)
trap 'rm -rf "$fixture"' EXIT
export fixture
export OMARCHY_PATH="$ROOT"
mkdir -p "$fixture/bin"
export PATH="$fixture/bin:$HOME/.local/bin:$PATH"

# Redirect system paths in a temporary copy; never run setup against the host.
python3 - "$ROOT/bin/omarchy-hibernation-setup" "$fixture/setup" "$fixture" <<'PY'
import sys
from pathlib import Path
source, target, fixture = sys.argv[1:]
script = Path(source).read_text()
for path in ('/etc/', '/sys/power/', '/swap/', '/usr/lib/systemd/system-sleep/'):
    script = script.replace(path, fixture + path)
script = script.replace('SWAP_SUBVOLUME="/swap"', f'SWAP_SUBVOLUME="{fixture}/swap"')
Path(target).write_text(script)
PY

cat > "$fixture/bin/sudo" <<'STUB'
#!/bin/bash
# The fixture hook does not need root ownership.
if [[ $1 == "/usr/bin/install" ]]; then
  shift
  exec /usr/bin/install -m "$2" -T "${@: -2}"
else
  exec "$@"
fi
STUB
cat > "$fixture/bin/findmnt" <<'STUB'
#!/bin/bash
printf '%s\n' "$DEVICE"
STUB
cat > "$fixture/bin/btrfs" <<'STUB'
#!/bin/bash
if [[ $1 == "inspect-internal" ]]; then
  printf '%s\n' "$OFFSET"
fi
STUB
cat > "$fixture/bin/swapon" <<'STUB'
#!/bin/bash
if [[ $1 == "--show" ]]; then
  printf '%s\n' "$fixture/swap/swapfile"
fi
STUB
cat > "$fixture/bin/limine-mkinitcpio" <<'STUB'
#!/bin/bash
printf 'rebuild\n' >> "$fixture/rebuilds"
STUB
cat > "$fixture/bin/omarchy-cmd-missing" <<'STUB'
#!/bin/bash
exit 1
STUB
cat > "$fixture/bin/swaplabel" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$fixture/bin/"*

drop_in="$fixture/etc/limine-entry-tool.d/resume.conf"
marker="$fixture/etc/mkinitcpio.conf.d/omarchy_resume.conf"
export DEVICE OFFSET

reset_fixture() {
  rm -rf "$fixture/etc" "$fixture/sys" "$fixture/swap" "$fixture/usr" "$fixture/rebuilds"
  mkdir -p "$fixture/etc/limine-entry-tool.d" "$fixture/etc/mkinitcpio.conf.d" \
    "$fixture/sys/power" "$fixture/swap" "$fixture/usr/lib/systemd/system-sleep"
  touch "$fixture/sys/power/image_size" "$fixture/sys/power/mem_sleep" "$fixture/swap/swapfile"
  printf '%s none swap defaults 0 0\n' "$fixture/swap/swapfile" > "$fixture/etc/fstab"
  DEVICE='/dev/nvme0n1p2[/@swap]'
  OFFSET=12345
}

run_setup() {
  bash "$fixture/setup" --force "$@" > "$fixture/stdout" 2> "$fixture/stderr" ||
    fail "setup succeeds" "$(cat "$fixture/stderr")"
}

reset_fixture
DEVICE=''
run_setup --no-rebuild
[[ ! -e $drop_in ]] || fail "empty device prevents drop-in creation"
grep -Fx "Warning: Could not determine resume device for $fixture/swap/swapfile" "$fixture/stderr" >/dev/null ||
  fail "empty device warns on stderr"
grep -Fx 'HOOKS+=(resume)' "$marker" >/dev/null || fail "empty device leaves resume hook marker"
pass "empty device leaves retryable state and warns"

DEVICE='/dev/mapper/crypt@home[/@swap]'
run_setup
expected='KERNEL_CMDLINE[default]+=" resume=/dev/mapper/crypt@home resume_offset=12345"'
[[ $(cat "$drop_in") == "$expected" ]] || fail "retry creates exact resume drop-in"
[[ $(cat "$fixture/rebuilds") == "rebuild" ]] || fail "retry rebuilds once"
run_setup
[[ $(cat "$fixture/rebuilds") == "rebuild" ]] || fail "configured retry does not rebuild again"
pass "retry creates missing drop-in and rebuilds only once"

reset_fixture
DEVICE='/dev/nvme0n1p2[/@swap]'
OFFSET=12345
echo 'HOOKS+=(resume)' > "$marker"
run_setup --no-rebuild
expected='KERNEL_CMDLINE[default]+=" resume=/dev/nvme0n1p2 resume_offset=12345"'
[[ $(cat "$drop_in") == "$expected" ]] || fail "missing drop-in retry creates configuration with --no-rebuild"
[[ ! -e $fixture/rebuilds ]] || fail "missing drop-in retry respects --no-rebuild"
pass "missing drop-in retry respects --no-rebuild"

for incomplete in empty device offset both; do
  for rebuild in enabled disabled; do
    reset_fixture
    echo 'HOOKS+=(resume)' > "$marker"
    case "$incomplete" in
      empty) : > "$drop_in" ;;
      device) printf '# keep this\nKERNEL_CMDLINE[default]+=" quiet resume_offset=6789 splash"' > "$drop_in" ;;
      offset) printf '# keep this\nKERNEL_CMDLINE[default]+=" quiet resume=/dev/existing splash"' > "$drop_in" ;;
      both) printf '# resume=/dev/comment resume_offset=999\nKERNEL_CMDLINE[default]+=" quiet splash"' > "$drop_in" ;;
    esac
    cp "$drop_in" "$fixture/original"
    DEVICE=''
    OFFSET=''
    run_setup
    cmp -s "$drop_in" "$fixture/original" || fail "unavailable values preserve $incomplete drop-in"
    [[ ! -e $fixture/rebuilds ]] || fail "unavailable values do not rebuild $incomplete drop-in"

    DEVICE='/dev/nvme0n1p2[/@swap]'
    OFFSET=12345
    if [[ $rebuild == "enabled" ]]; then
      run_setup
    else
      run_setup --no-rebuild
    fi
    case "$incomplete" in
      empty|both) added=' resume=/dev/nvme0n1p2 resume_offset=12345' ;;
      device) added=' resume=/dev/nvme0n1p2' ;;
      offset) added=' resume_offset=12345' ;;
    esac
    { cat "$fixture/original"; printf '\nKERNEL_CMDLINE[default]+="%s"\n' "$added"; } > "$fixture/expected"
    cmp -s "$drop_in" "$fixture/expected" || fail "retry completes $incomplete drop-in and preserves content"
    if [[ $rebuild == "enabled" ]]; then
      [[ $(cat "$fixture/rebuilds") == "rebuild" ]] || fail "retry rebuilds $incomplete drop-in exactly once"
    else
      [[ ! -e $fixture/rebuilds ]] || fail "retry of $incomplete drop-in respects --no-rebuild"
    fi
    run_setup
    cmp -s "$drop_in" "$fixture/expected" || fail "completed $incomplete drop-in stays unchanged"
    if [[ $rebuild == "enabled" ]]; then
      [[ $(cat "$fixture/rebuilds") == "rebuild" ]] || fail "completed $incomplete drop-in does not rebuild again"
    else
      [[ ! -e $fixture/rebuilds ]] || fail "completed $incomplete drop-in does not rebuild"
    fi
    pass "$incomplete drop-in completes on second run with rebuild $rebuild"
  done
done

for missing in device offset; do
  reset_fixture
  echo 'HOOKS+=(resume)' > "$marker"
  if [[ $missing == "device" ]]; then
    DEVICE=''
  else
    OFFSET=''
  fi
  run_setup
  [[ ! -e $drop_in ]] || fail "unavailable $missing leaves missing drop-in retryable"
  [[ ! -e $fixture/rebuilds ]] || fail "unavailable $missing does not rebuild"
  grep -Fx "Warning: Could not determine resume $missing for $fixture/swap/swapfile" "$fixture/stderr" >/dev/null ||
    fail "unavailable $missing warns on retry"
  pass "missing drop-in retry waits for available $missing"
done

reset_fixture
run_setup --no-rebuild
grep -Fx 'KERNEL_CMDLINE[default]+=" resume=/dev/nvme0n1p2 resume_offset=12345"' "$drop_in" >/dev/null ||
  fail "new drop-in contains device without Btrfs suffix and offset"
pass "new drop-in contains device and offset"

prepare_repair() {
  reset_fixture
  echo 'HOOKS+=(resume)' > "$marker"
  printf '# custom comment\nKERNEL_CMDLINE[default]+=" quiet resume= resume_offset=6789 splash"\n' > "$drop_in"
}

prepare_repair
run_setup
expected=$(printf '# custom comment\nKERNEL_CMDLINE[default]+=" quiet resume=/dev/nvme0n1p2 resume_offset=6789 splash"')
[[ $(cat "$drop_in") == "$expected" ]] || fail "device repair preserves offset and surrounding content"
[[ $(cat "$fixture/rebuilds") == "rebuild" ]] || fail "device repair rebuilds once"
pass "empty device is repaired and rebuilt with surrounding content preserved"

prepare_repair
cp "$drop_in" "$fixture/original"
DEVICE='/dev/mapper/swap\name&part|disk[/@swap]'
run_setup --no-rebuild
cmp -s "$drop_in" "$fixture/original" || fail "device repair rejects sed replacement characters"
[[ ! -e $fixture/rebuilds ]] || fail "rejected device does not rebuild"
pass "device repair rejects sed replacement characters"

prepare_repair
cp "$drop_in" "$fixture/original"
DEVICE=''
run_setup
cmp -s "$drop_in" "$fixture/original" || fail "unavailable device leaves broken drop-in untouched"
[[ ! -e $fixture/rebuilds ]] || fail "unavailable device does not rebuild"
pass "unavailable device leaves broken drop-in untouched"

prepare_repair
printf '# Previously had resume= blank\nKERNEL_CMDLINE[default]+=" resume=/dev/existing resume_offset=6789" # Previously had resume= blank\n' > "$drop_in"
cp "$drop_in" "$fixture/original"
run_setup
cmp -s "$drop_in" "$fixture/original" || fail "valid drop-in stays unchanged"
[[ ! -e $fixture/rebuilds ]] || fail "valid drop-in does not rebuild"
pass "valid drop-in stays unchanged"

prepare_repair
printf '# Previously had resume= blank\nKERNEL_CMDLINE[default]+=" resume= resume_offset=6789" # Previously had resume= blank\n' > "$drop_in"
run_setup
expected=$(printf '# Previously had resume= blank\nKERNEL_CMDLINE[default]+=" resume=/dev/nvme0n1p2 resume_offset=6789" # Previously had resume= blank')
[[ $(cat "$drop_in") == "$expected" ]] || fail "device repair only changes the active argument"
[[ $(cat "$fixture/rebuilds") == "rebuild" ]] || fail "active device repair rebuilds once"
pass "device repair preserves comments containing empty resume text"

prepare_repair
printf 'KERNEL_CMDLINE[default]+=" resume=/dev/existing resume_offset="\n' > "$drop_in"
run_setup
grep -Fx 'KERNEL_CMDLINE[default]+=" resume=/dev/existing resume_offset=12345"' "$drop_in" >/dev/null ||
  fail "existing empty-offset repair still works"
[[ $(cat "$fixture/rebuilds") == "rebuild" ]] || fail "offset repair still rebuilds"
pass "existing empty-offset repair still works"

for rebuild in enabled disabled; do
  prepare_repair
  printf '# custom comment\nKERNEL_CMDLINE[default]+=" quiet resume= resume_offset="\n# keep this too\n' > "$drop_in"
  cp "$drop_in" "$fixture/original"
  DEVICE=''
  OFFSET=''
  run_setup
  cmp -s "$drop_in" "$fixture/original" || fail "unavailable values preserve dual-empty drop-in"
  [[ ! -e $fixture/rebuilds ]] || fail "unavailable values do not rebuild dual-empty drop-in"

  DEVICE='/dev/nvme0n1p2[/@swap]'
  OFFSET=12345
  if [[ $rebuild == "enabled" ]]; then
    run_setup
  else
    run_setup --no-rebuild
  fi
  expected=$(printf '# custom comment\nKERNEL_CMDLINE[default]+=" quiet resume=/dev/nvme0n1p2 resume_offset=12345"\n# keep this too')
  [[ $(cat "$drop_in") == "$expected" ]] || fail "dual repair preserves surrounding configuration and comments"
  if [[ $rebuild == "enabled" ]]; then
    [[ $(cat "$fixture/rebuilds") == "rebuild" ]] || fail "dual repair rebuilds exactly once"
  else
    [[ ! -e $fixture/rebuilds ]] || fail "dual repair respects --no-rebuild"
  fi
  run_setup
  [[ $(cat "$drop_in") == "$expected" ]] || fail "completed dual repair stays unchanged"
  if [[ $rebuild == "enabled" ]]; then
    [[ $(cat "$fixture/rebuilds") == "rebuild" ]] || fail "completed dual repair does not rebuild again"
  else
    [[ ! -e $fixture/rebuilds ]] || fail "completed dual repair does not rebuild"
  fi
  pass "dual repair with rebuild $rebuild preserves comments"
done

for empty_token in device-end offset-middle; do
  for rebuild in enabled disabled; do
    prepare_repair
    case "$empty_token" in
      device-end)
        printf 'KERNEL_CMDLINE[default]+=" resume="\n' > "$drop_in"
        expected=$(printf 'KERNEL_CMDLINE[default]+=" resume=/dev/nvme0n1p2"\n\nKERNEL_CMDLINE[default]+=" resume_offset=12345"')
        ;;
      offset-middle)
        printf '# keep this\nKERNEL_CMDLINE[default]+=" resume=/dev/existing resume_offset= splash" # keep this too\n' > "$drop_in"
        expected=$(printf '# keep this\nKERNEL_CMDLINE[default]+=" resume=/dev/existing resume_offset=12345 splash" # keep this too')
        ;;
    esac
    cp "$drop_in" "$fixture/original"
    DEVICE=''
    OFFSET=''
    run_setup
    cmp -s "$drop_in" "$fixture/original" || fail "unavailable values preserve $empty_token empty token"
    [[ ! -e $fixture/rebuilds ]] || fail "unavailable values do not rebuild $empty_token empty token"

    DEVICE='/dev/nvme0n1p2[/@swap]'
    OFFSET=12345
    if [[ $rebuild == "enabled" ]]; then
      run_setup
    else
      run_setup --no-rebuild
    fi
    [[ $(cat "$drop_in") == "$expected" ]] || fail "retry repairs $empty_token empty token and preserves content"
    if [[ $rebuild == "enabled" ]]; then
      [[ $(cat "$fixture/rebuilds") == "rebuild" ]] || fail "$empty_token repair rebuilds exactly once"
    else
      [[ ! -e $fixture/rebuilds ]] || fail "$empty_token repair respects --no-rebuild"
    fi
    run_setup
    [[ $(cat "$drop_in") == "$expected" ]] || fail "completed $empty_token repair stays unchanged"
    if [[ $rebuild == "enabled" ]]; then
      [[ $(cat "$fixture/rebuilds") == "rebuild" ]] || fail "completed $empty_token repair does not rebuild again"
    else
      [[ ! -e $fixture/rebuilds ]] || fail "completed $empty_token repair does not rebuild"
    fi
    pass "$empty_token empty token repairs with rebuild $rebuild"
  done
done

# Validate each discovered value independently on every write path.
for parameter in device offset; do
  if [[ $parameter == "device" ]]; then
    invalid_values=('' '/tmp/swap' '/dev/' '/dev/swap name' $'/dev/swap\tname' $'/dev/swap\nname' '/dev/swap"name' "/dev/swap'name" '/dev/swap\name' '/dev/swap&name' '/dev/swap|name')
  else
    invalid_values=('' '123abc' '+123' '-123' '12 34' $'12\t34' $'12\n34' '12&34' '12|34' '12\34')
  fi
  for value in "${invalid_values[@]}"; do
    for write_path in creation repair append; do
      reset_fixture
      if [[ $write_path != "creation" ]]; then
        echo 'HOOKS+=(resume)' > "$marker"
        if [[ $parameter == "device" ]]; then
          if [[ $write_path == "repair" ]]; then
            printf '# keep this\nKERNEL_CMDLINE[default]+=" quiet resume= resume_offset=6789"\n' > "$drop_in"
          else
            printf '# keep this\nKERNEL_CMDLINE[default]+=" quiet resume_offset=6789"' > "$drop_in"
          fi
        else
          if [[ $write_path == "repair" ]]; then
            printf '# keep this\nKERNEL_CMDLINE[default]+=" quiet resume=/dev/existing resume_offset="\n' > "$drop_in"
          else
            printf '# keep this\nKERNEL_CMDLINE[default]+=" quiet resume=/dev/existing"' > "$drop_in"
          fi
        fi
        cp "$drop_in" "$fixture/original"
      fi
      if [[ $parameter == "device" ]]; then
        DEVICE=$value
      else
        OFFSET=$value
      fi
      # Initial creation still installs the marker; configured retries never rebuild.
      run_setup --no-rebuild
      run_setup
      if [[ $write_path == "creation" ]]; then
        [[ ! -e $drop_in ]] || fail "invalid $parameter prevents creation"
        grep -Fx "Warning: Could not determine resume $parameter for $fixture/swap/swapfile" "$fixture/stderr" >/dev/null ||
          fail "invalid $parameter warns on creation retry"
      else
        cmp -s "$drop_in" "$fixture/original" || fail "invalid $parameter preserves $write_path drop-in"
      fi
      [[ ! -e $fixture/rebuilds ]] || fail "invalid $parameter does not rebuild on $write_path retry"
    done
  done
  pass "invalid $parameter values are rejected on creation, repair, append, and retry"
done

for device in '/dev/nvme0n1p2[/@swap]' '/dev/mapper/swap_crypt-1' '/dev/mapper/crypt@home' '/dev/mapper/crypt@home[/@swap]'; do
  for offset in 0 12345 00123; do
    for write_path in creation repair append; do
      for rebuild in enabled disabled; do
        reset_fixture
        DEVICE=$device
        OFFSET=$offset
        if [[ $write_path == "repair" ]]; then
          echo 'HOOKS+=(resume)' > "$marker"
          printf '# keep this\nKERNEL_CMDLINE[default]+=" quiet resume= resume_offset="\n' > "$drop_in"
          printf '# keep this\nKERNEL_CMDLINE[default]+=" quiet resume=%s resume_offset=%s"\n' "${DEVICE%%\[*}" "$OFFSET" > "$fixture/expected"
        else
          if [[ $write_path == "append" ]]; then
            echo 'HOOKS+=(resume)' > "$marker"
            printf '# keep this\nKERNEL_CMDLINE[default]+=" quiet"' > "$drop_in"
            cp "$drop_in" "$fixture/expected"
            printf '\n' >> "$fixture/expected"
          else
            : > "$fixture/expected"
          fi
          printf 'KERNEL_CMDLINE[default]+=" resume=%s resume_offset=%s"\n' "${DEVICE%%\[*}" "$OFFSET" >> "$fixture/expected"
        fi
        if [[ $rebuild == "enabled" ]]; then
          run_setup
        else
          run_setup --no-rebuild
        fi
        cmp -s "$drop_in" "$fixture/expected" || fail "valid values produce exact $write_path output"
        run_setup
        cmp -s "$drop_in" "$fixture/expected" || fail "valid $write_path retry is idempotent"
        if [[ $rebuild == "enabled" ]]; then
          [[ $(cat "$fixture/rebuilds") == "rebuild" ]] || fail "valid $write_path rebuilds exactly once"
        else
          [[ ! -e $fixture/rebuilds ]] || fail "valid $write_path respects --no-rebuild on setup and retry"
        fi
      done
    done
  done
  pass "$device accepts zero, digits, and leading zeros on every write path"
done
