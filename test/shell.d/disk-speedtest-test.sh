#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

script=$ROOT/bin/omarchy-disk-speedtest

tmp=$(mktemp -d)
shm_before=$(mktemp)
shm_after=$(mktemp)
test_pids=()

cleanup_test() {
  local pid
  for pid in ${test_pids[@]+"${test_pids[@]}"}; do
    pkill -KILL -P "$pid" 2>/dev/null || true
    kill -KILL "$pid" 2>/dev/null || true
  done
  rm -rf "$tmp" "$shm_before" "$shm_after"
}
trap cleanup_test EXIT

status=0
out=$("$script" "$tmp/does-not-exist" 2>&1) || status=$?
(( status == 2 )) && [[ $out == Usage:* ]] || fail "rejects nonexistent target directory" "status $status: $out"
pass "rejects nonexistent target directory"

block_dev=""
for path in /sys/class/block/*/stat; do
  [[ -r $path ]] || continue
  name=${path#/sys/class/block/}
  block_dev=${name%/stat}
  break
done
if [[ -z $block_dev ]]; then
  skip "disk speedtest cleanup checks require a readable /sys/class/block/*/stat"
  exit 0
fi

mkdir -p "$tmp/bin"

cat > "$tmp/bin/findmnt" <<STUB
#!/bin/bash
echo "/dev/$block_dev"
STUB

cat > "$tmp/bin/df" <<'STUB'
#!/bin/bash
echo "Avail"
echo "${OMARCHY_TEST_AVAIL_MB:-10000}"
STUB

cat > "$tmp/bin/lsblk" <<'STUB'
#!/bin/bash
echo "TestDisk"
STUB

# Stub dd writes real bytes to the destination path/fd (so unlinked /proc/pid/fd
# paths and -s checks are exercised for real) without allocating 1 GiB.
cat > "$tmp/bin/dd" <<'STUB'
#!/bin/bash
in_path=""
out_path=""
has_notrunc=0
for arg in "$@"; do
  case $arg in
    if=*) in_path=${arg#if=} ;;
    of=*) out_path=${arg#of=} ;;
    conv=notrunc) has_notrunc=1 ;;
  esac
done

if [[ $out_path == "/dev/null" ]]; then
  cat "$in_path" > /dev/null 2>/dev/null || exit 1
  sleep 0.2
elif [[ $in_path == "/dev/urandom" ]]; then
  (( has_notrunc == 1 )) || exit 1
  printf '%4096s' "" > "$out_path" || exit 1
else
  (( has_notrunc == 1 )) || exit 1
  cat "$in_path" > "$out_path" 2>/dev/null || exit 1
  sleep 0.2
fi
STUB

chmod +x "$tmp/bin/findmnt" "$tmp/bin/df" "$tmp/bin/lsblk" "$tmp/bin/dd"

list_shm_files() {
  find /dev/shm -maxdepth 1 -type f -name 'omarchy-disk-speedtest-*.src' 2>/dev/null | sort
}

run_and_kill() {
  local sig=$1 expected_status=$2
  local target="$tmp/target-$sig"
  local out="$tmp/out-$sig"
  mkdir -p "$target"

  list_shm_files > "$shm_before"

  PATH="$tmp/bin:$PATH" "$script" "$target" > "$out" 2>&1 &
  local pid=$!
  test_pids+=("$pid")

  # Wait until staging has finished and the read phase is actively running.
  local waited=0
  while (( waited < 50 )); do
    if grep -q '^read ' "$out" 2>/dev/null; then
      break
    fi
    sleep 0.1
    waited=$((waited + 1))
  done
  grep -q '^read ' "$out" 2>/dev/null || fail "disk speedtest entered read phase before SIG$sig" "$(cat "$out")"

  kill "-$sig" "$pid" 2>/dev/null || fail "delivered SIG$sig while disk speedtest was still running" "$(cat "$out")"
  local exit_status=0
  wait "$pid" 2>/dev/null || exit_status=$?
  (( exit_status == expected_status )) || fail "disk speedtest exited $expected_status on SIG$sig" "got $exit_status"
  pass "disk speedtest exited $expected_status on SIG$sig"

  # Wait briefly for any in-flight stub worker pass to finish and exit.
  waited=0
  while (( waited < 20 )); do
    if ! pgrep -f "$tmp/bin/dd|$target" >/dev/null 2>&1; then
      break
    fi
    sleep 0.1
    waited=$((waited + 1))
  done

  list_shm_files > "$shm_after"
  local leaked_disk leaked_shm
  leaked_disk=$(find "$target" -maxdepth 1 -name 'disk-speedtest-*.dat' 2>/dev/null)
  leaked_shm=$(comm -13 "$shm_before" "$shm_after")

  [[ -z $leaked_disk ]] || fail "no disk scratch files left after SIG$sig" "$leaked_disk"
  pass "no disk scratch files left after SIG$sig"

  [[ -z $leaked_shm ]] || fail "no /dev/shm chunk files left after SIG$sig" "$leaked_shm"
  pass "no /dev/shm chunk files left after SIG$sig"

  if pgrep -f "$tmp/bin/dd|$target" >/dev/null 2>&1; then
    fail "no worker processes remain after SIG$sig" "$(pgrep -af "$tmp/bin/dd|$target")"
  else
    pass "no worker processes remain after SIG$sig"
  fi
}

run_and_kill TERM 143
run_and_kill KILL 137

# Low-disk preflight failure must exit 1 without leaving scratch files behind.
mkdir -p "$tmp/low-space"
list_shm_files > "$shm_before"
status=0
out=$(OMARCHY_TEST_AVAIL_MB=100 PATH="$tmp/bin:$PATH" "$script" "$tmp/low-space" 2>&1) || status=$?
list_shm_files > "$shm_after"
(( status == 1 )) && [[ $out == *"Need at least"* ]] || fail "rejects target with insufficient free space" "status $status: $out"
[[ -z $(find "$tmp/low-space" -maxdepth 1 -name 'disk-speedtest-*.dat' 2>/dev/null) ]] || fail "low-space preflight leaves no disk scratch files"
[[ -z $(comm -13 "$shm_before" "$shm_after") ]] || fail "low-space preflight leaves no /dev/shm chunk files"
pass "low-space preflight fails cleanly without creating scratch files"
