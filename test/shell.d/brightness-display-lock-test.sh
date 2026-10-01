#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

run_checks() {
  test_tmp=$(mktemp -d)
  mock_bin="$test_tmp/bin"
  mkdir -p "$mock_bin"
  cat >"$mock_bin/brightnessctl" <<'SCRIPT'
#!/bin/bash
printf '%s\n' "$*" >>"$CALL_LOG"
if [[ $* == *" -m"* ]]; then
  printf 'mock,backlight,40,%s%%\n' "$(<"$BRIGHTNESS_STATE")"
else
  value=${*: -1}
  printf '%s\n' "${value%%%}" >"$BRIGHTNESS_STATE"
fi
SCRIPT
  cat >"$mock_bin/hyprctl" <<'SCRIPT'
#!/bin/bash
printf 'hyprctl %s\n' "$*" >>"$CALL_LOG"
if [[ $1 == "monitors" ]]; then
  printf '[{"name":"eDP-1","disabled":false,"dpmsStatus":false}]\n'
fi
SCRIPT
  cat >"$mock_bin/omarchy-hw-display" <<'SCRIPT'
#!/bin/bash
printf 'mock\n'
SCRIPT
  cat >"$mock_bin/omarchy-hyprland-monitor-focused" <<'SCRIPT'
#!/bin/bash
printf 'eDP-1\n'
SCRIPT
  for name in omarchy-hyprland-monitor-focused-apple omarchy-hyprland-toggle-enabled; do
    printf '#!/bin/bash\nexit 1\n' >"$mock_bin/$name"
  done
  printf '#!/bin/bash\nexit 0\n' >"$mock_bin/omarchy-notification-send"
  chmod +x "$mock_bin"/*

  runtime_mode=unset
  run_command() {
    local command=$1
    shift
    local environment=(env -u XDG_RUNTIME_DIR)
    if [[ $runtime_mode == "empty" ]]; then
      environment=(env XDG_RUNTIME_DIR=)
    fi
    "${environment[@]}" HOME="$active_home" OMARCHY_PATH="$ROOT" \
      BRIGHTNESS_STATE="$active_home/brightness" CALL_LOG="$test_tmp/calls" \
      PATH="$mock_bin:$ROOT/bin:$PATH" "$ROOT/bin/$command" "$@"
  }

  # A foreign user's predictable files must never be consulted or modified.
  # This entire test has a disposable /tmp, including when run on an old head.
  mkdir /tmp/omarchy-brightness-display.lock
  printf '99\n' >/tmp/omarchy-brightness-display.saved
  for mode in unset empty; do
    runtime_mode=$mode
    active_home="$test_tmp/home $mode"
    mkdir -p "$active_home"
    printf '40\n' >"$active_home/brightness"
    run_command omarchy-brightness-display off
    private_dir="$active_home/.local/state/omarchy/brightness-display"
    [[ -f $private_dir/omarchy-brightness-display.lock ]] || fail "$mode runtime uses a private lock"
    [[ $(stat -c %a "$private_dir") == "700" ]] || fail "fallback directory is private"
    [[ $(<"$private_dir/omarchy-brightness-display.saved") == "40" ]] || fail "fallback saves the correct user's level"
    run_command omarchy-hyprland-monitor-internal restore-backlight
    [[ $(<"$active_home/brightness") == "40" && ! -e $private_dir/omarchy-brightness-display.saved ]] || fail "internal helper shares the fallback saved state"
    run_command omarchy-brightness-display off
    run_command omarchy-brightness-display on
    [[ $(<"$active_home/brightness") == "40" ]] || fail "fallback blank and wake restore the level"
  done
  [[ $(</tmp/omarchy-brightness-display.saved) == "99" && -d /tmp/omarchy-brightness-display.lock ]] || fail "legacy shared files remain untouched"
  pass "unset and empty runtime use shared private state despite hostile legacy paths"

  first_home="$active_home"
  run_command omarchy-brightness-display off
  active_home="$test_tmp/second home"
  mkdir -p "$active_home"
  printf '65\n' >"$active_home/brightness"
  run_command omarchy-brightness-display off
  run_command omarchy-brightness-display on
  [[ $(<"$active_home/brightness") == "65" ]] || fail "second user keeps an independent restore level"
  [[ $(<"$first_home/.local/state/omarchy/brightness-display/omarchy-brightness-display.saved") == "40" ]] || fail "second user does not consume first user's state"
  pass "different HOME directories have independent fallback locks and state"

  private_dir="$active_home/.local/state/omarchy/brightness-display"
  private_lock="$private_dir/omarchy-brightness-display.lock"
  for obstruction in directory symlink; do
    rm -f "$private_lock"
    if [[ $obstruction == "directory" ]]; then
      mkdir "$private_lock"
    else
      ln -s "$test_tmp/missing-parent/lock" "$private_lock"
    fi
    for command in omarchy-brightness-display omarchy-hyprland-monitor-internal; do
      : >"$test_tmp/calls"
      if [[ $command == "omarchy-brightness-display" ]]; then
        action=off
      else
        action=restore-backlight
      fi
      if run_command "$command" "$action" 2>/dev/null; then
        fail "$command rejects unavailable $obstruction lock"
      fi
      [[ ! -s $test_tmp/calls ]] || fail "lock-open failure prevents hardware and DPMS actions"
    done
    if [[ $obstruction == "directory" ]]; then
      rmdir "$private_lock"
    else
      rm "$private_lock"
    fi
  done
  pass "both helpers fail before side effects when their private lock cannot open"

  flock "$private_lock" bash -c 'touch "$1"; while [[ ! -f $2 ]]; do sleep 0.02; done' fixture "$test_tmp/held" "$test_tmp/release" &
  holder=$!
  for _ in {1..100}; do
    [[ -f $test_tmp/held ]] && break
    sleep 0.02
  done
  [[ -f $test_tmp/held ]] || fail "fallback lock holder starts"
  : >"$test_tmp/calls"
  run_command omarchy-brightness-display --no-osd 70%
  [[ ! -s $test_tmp/calls ]] || fail "contended adjustment does not run hardware commands"
  run_command omarchy-brightness-display off &
  blanker=$!
  sleep 0.1
  [[ ! -s $test_tmp/calls ]] || fail "blank waits for the shared fallback lock"
  touch "$test_tmp/release"
  wait "$holder"
  wait "$blanker"
  run_command omarchy-brightness-display on
  [[ $(<"$active_home/brightness") == "65" ]] || fail "serialized fallback blank restores the original level"
  pass "fallback locking preserves blocking blank and nonblocking adjustment semantics"
}

if [[ ${1:-} == "--isolated" ]]; then
  run_checks
else
  sandbox=$(mktemp -d)
  trap 'rm -rf "$sandbox"' EXIT
  bwrap --ro-bind / / --dev /dev --tmpfs /tmp --ro-bind "$ROOT" "$ROOT" \
    --bind "$sandbox" /tmp/brightness-lock-test --unshare-pid --proc /proc \
    --die-with-parent --setenv TMPDIR /tmp/brightness-lock-test \
    bash "$ROOT/test/shell.d/brightness-display-lock-test.sh" --isolated
fi
