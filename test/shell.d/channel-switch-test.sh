#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-channel-set
copy_boundary_file bin/omarchy-refresh-pacman
copy_boundary_file bin/omarchy-apply-pacman
copy_boundary_file bin/omarchy-update
export OMARCHY_UPDATE_LOGGED=1

# Relocate the package root into the fixture, including the explicit handoff
# from the development checkout. All privileged operations remain stand-ins.
python3 - "$SUDO_TEST_ROOT/bin/omarchy-channel-set" "$SUDO_TEST_ROOT" <<'PY'
import sys
from pathlib import Path
p = Path(sys.argv[1])
p.write_text(p.read_text().replace('/usr/share/omarchy', sys.argv[2]))
PY

for command in omarchy-dev-link omarchy-dev-unlink omarchy-state gum git; do
  cat >"$SUDO_TEST_ROOT/bin/$command" <<'STUB'
#!/bin/bash
set -euo pipefail
step=${0##*/}
printf 'step:%s %s\n' "$step" "$*" >>"$SUDO_TEST_LOG"
case "$step" in
  omarchy-dev-link|omarchy-dev-unlink) sudo /usr/bin/true ;;
  git)
    [[ $1 == "clone" ]] || exit 90
    /usr/bin/cp -a "$SUDO_TEST_ROOT" "${@: -1}"
    mkdir -p "${@: -1}/.git" "${@: -1}/shell"
    ;;
esac
STUB
  chmod +x "$SUDO_TEST_ROOT/bin/$command"
done

assert_channel_order() {
  python3 - "$SUDO_TEST_LOG" <<'PY'
import sys
events = open(sys.argv[1]).read().splitlines()
# The refresh hook runs before the transaction; the update it hands off to
# authorizes once up front for its own phases, post-update hook included.
hooks = [i for i, event in enumerate(events) if event.startswith('step:omarchy-hook ')]
assert len(hooks) == 2, events
assert events[hooks[0]] == 'step:omarchy-hook pre-refresh-pacman', events
assert events[hooks[1]] == 'step:omarchy-hook post-update', events
transaction = next(i for i, event in enumerate(events) if event.startswith('step:pacman '))
# The package swap calls pacman itself, so an older release can't strand it.
swap = next(i for i, event in enumerate(events) if event.startswith('sudo env OMARCHY_UPDATE_PACMAN=1 pacman -S --needed --noconfirm --ask 4 '))
auth = events.index('sudo true', swap)
assert hooks[0] < transaction < swap < auth < hooks[1], events
PY
}

run_channel() {
  "$OMARCHY_PATH/bin/omarchy-channel-set" "$@" >"$boundary_tmp/output" 2>&1
}
for channel in stable rc edge dev; do
  reset_boundary
  run_channel "$channel" || fail "$channel failed" "$(<"$boundary_tmp/output")"
  assert_channel_order
  pass "$channel runs the refresh hook before the transaction and hands off to one update authorization"
done

# Every aarch64 platform switches to each channel it has templates for, copying
# its own: Apple Silicon to rc, edge and dev, every other one to all four.
for platform in aarch64 aarch64-apple; do
  case $platform in
    aarch64-apple) templates=default/pacman/aarch64-apple channels="rc edge dev" ;;
    *) templates=default/pacman/aarch64 channels="stable rc edge dev" ;;
  esac
  for channel in $channels; do
    # dev refreshes from the checkout it links, on edge.
    pacman_channel=$channel root=$SUDO_TEST_ROOT
    [[ $channel != "dev" ]] || pacman_channel=edge root=$SUDO_TEST_HOME/omarchy
    reset_boundary
    SUDO_TEST_PLATFORM=$platform run_channel "$channel" || fail "$platform $channel failed" "$(<"$boundary_tmp/output")"
    assert_channel_order
    # The caller renders from the platform's template; root copies the result.
    grep -Eq "^step:cp $root/$templates/pacman-$pacman_channel.conf [^ ]+/pacman.conf\$" "$SUDO_TEST_LOG" ||
      fail "$platform $channel renders its own template" "$(<"$SUDO_TEST_LOG")"
  done
done
pass "aarch64 platforms switch to every channel they have templates for through their own templates"

# Apple Silicon has no stable template yet: it refuses stable before anything
# changes.
for channel in stable; do
  reset_boundary
  if SUDO_TEST_PLATFORM=aarch64-apple run_channel "$channel"; then fail "aarch64-apple accepted $channel"; fi
  if grep -Eq '^step:|^sudo ' "$SUDO_TEST_LOG"; then fail "aarch64-apple $channel was refused before any change" "$(<"$SUDO_TEST_LOG")"; fi
  grep -q "Omarchy has no $channel channel for aarch64-apple" "$boundary_tmp/output" || fail "aarch64-apple $channel: the refusal says why" "$(<"$boundary_tmp/output")"
done
pass "Apple Silicon refuses stable before any change"

# A channel the platform has no template for stops before anything, the dev
# confirmation included.
mv "$SUDO_TEST_ROOT/default/pacman/aarch64-apple/pacman-edge.conf" "$boundary_tmp/saved-template"
for channel in edge dev; do
  reset_boundary
  if SUDO_TEST_PLATFORM=aarch64-apple run_channel "$channel"; then fail "a channel without a template was accepted ($channel)"; fi
  if grep -Eq '^step:|^sudo ' "$SUDO_TEST_LOG"; then fail "$channel was refused before any change" "$(<"$SUDO_TEST_LOG")"; fi
  grep -q "Omarchy has no edge channel for aarch64-apple" "$boundary_tmp/output" || fail "the refusal says why" "$(<"$boundary_tmp/output")"
done
mv "$boundary_tmp/saved-template" "$SUDO_TEST_ROOT/default/pacman/aarch64-apple/pacman-edge.conf"
pass "a channel without a template for the platform is refused before any change"

reset_boundary
required="$SUDO_TEST_HOME/omarchy/bin/omarchy-refresh-pacman"
mv "$required" "$boundary_tmp/saved-required"
if run_channel dev; then fail "an old checkout without its refresh was accepted"; fi
if grep -Eq '^step:omarchy-(dev-link|state)|^sudo ' "$SUDO_TEST_LOG"; then
  fail "an incompatible dev checkout changed the system before rejection"
fi
grep -q 'Update the checkout before switching to dev' "$boundary_tmp/output" || fail "stale checkout rejection lacks recovery guidance"
mv "$boundary_tmp/saved-required" "$required"
pass "a stale dev checkout is rejected before linking or privileged work"

# On aarch64 the checkout's own refresh keeps the machine's repositories only
# once it tells platforms apart: a checkout without that is refused the same way.
checkout="$SUDO_TEST_HOME/omarchy"
for required in bin/omarchy-hw-platform install/helpers/pacman.sh; do
  for platform in aarch64; do
    reset_boundary
    mv "$checkout/$required" "$boundary_tmp/saved-required"
    if SUDO_TEST_PLATFORM=$platform run_channel dev; then fail "$platform: a dev checkout without $required was accepted"; fi
    mv "$boundary_tmp/saved-required" "$checkout/$required"
    if grep -Eq '^step:omarchy-(dev-link|state)|^step:pacman|^sudo ' "$SUDO_TEST_LOG"; then
      fail "$platform: a dev checkout without $required changed the system before rejection" "$(<"$SUDO_TEST_LOG")"
    fi
    grep -q "Update the checkout before switching to dev; on $platform it needs $required" "$boundary_tmp/output" ||
      fail "$platform: the rejection names $required" "$(<"$boundary_tmp/output")"
  done
done
pass "on aarch64 a dev checkout that can't keep the machine's repositories is rejected before linking"

# The checkout's own refresh copies its own templates, so one without them for
# this platform is refused before linking.
template=$checkout/default/pacman/aarch64/mirrorlist-edge
mv "$template" "$boundary_tmp/saved-template"
reset_boundary
if SUDO_TEST_PLATFORM=aarch64 run_channel dev; then fail "a dev checkout without its templates was accepted"; fi
mv "$boundary_tmp/saved-template" "$template"
if grep -Eq '^step:omarchy-(dev-link|state)|^step:pacman|^sudo ' "$SUDO_TEST_LOG"; then
  fail "a dev checkout without its templates changed the system before rejection" "$(<"$SUDO_TEST_LOG")"
fi
grep -q "Update the checkout before switching to dev; it has no edge templates for aarch64" "$boundary_tmp/output" ||
  fail "the rejection names the missing templates" "$(<"$boundary_tmp/output")"
pass "a dev checkout without its templates for the platform is rejected before linking"

reset_boundary
OMARCHY_PATH="$SUDO_TEST_HOME/omarchy" run_channel stable || fail "leaving dev failed" "$(<"$boundary_tmp/output")"
assert_channel_order
grep -Fxq 'step:omarchy-dev-unlink --no-reboot' "$SUDO_TEST_LOG" || fail "leaving dev did not unlink" "$(<"$SUDO_TEST_LOG")"
pass "leaving dev unlinks and hands off to the packaged update"

mkdir "$boundary_tmp/user tools"
cat >"$boundary_tmp/user tools/channel-user-tool" <<'STUB'
#!/bin/bash
printf 'user-tool:%s\n' "$*" >>"$SUDO_TEST_LOG"
STUB
chmod +x "$boundary_tmp/user tools/channel-user-tool"
for command in omarchy-hook omarchy-update-mise; do
  rm "$SUDO_TEST_ROOT/bin/$command"
  cat >"$SUDO_TEST_ROOT/bin/$command" <<'STUB'
#!/bin/bash
# The update's own phases run under its single authorization.
[[ ${1:-} == "pre-refresh-pacman" || -e $SUDO_TEST_CACHE ]] || exit 94
channel-user-tool "${0##*/}" "$@"
STUB
  chmod +x "$SUDO_TEST_ROOT/bin/$command"
done
reset_boundary
PATH="$boundary_tmp/user tools:$PATH" run_channel stable || fail "channel hooks lost the user's PATH" "$(<"$boundary_tmp/output")"
for event in 'omarchy-hook post-update' 'omarchy-update-mise' 'omarchy-hook pre-refresh-pacman'; do
  grep -Fxq "user-tool:$event" "$SUDO_TEST_LOG" || fail "user PATH was not preserved for $event"
done
for command in omarchy-hook omarchy-update-mise; do
  ln -sfn test-step "$SUDO_TEST_ROOT/bin/$command"
done
pass "channel switching preserves user tools for both hooks and mise"

for step in pacman omarchy-update-system-pkgs omarchy-hook; do
  reset_boundary
  if SUDO_TEST_FAIL_STEP="$step" run_channel stable; then fail "$step failure was ignored"; fi
  if grep -q '^step:omarchy-hook post-update$' "$SUDO_TEST_LOG"; then fail "$step failure reached the post-update hook"; fi
  pass "$step failure stops before the post-update hook"
done

# A terminal signals its whole foreground group, so the switch runs in a group
# of its own and the stand-in signals all of it, as Ctrl-C would.
for signal in HUP INT TERM; do
  reset_boundary
  cat >"$SUDO_TEST_ROOT/bin/omarchy-dev-unlink" <<'STUB'
#!/bin/bash
sudo /usr/bin/true || exit 1
kill -s "$SUDO_TEST_CHANNEL_SIGNAL" 0
STUB
  if SUDO_TEST_CHANNEL_SIGNAL="$signal" setsid -w "$OMARCHY_PATH/bin/omarchy-channel-set" stable >"$boundary_tmp/output" 2>&1; then fail "$signal was ignored"; fi
  if grep -q '^step:omarchy-hook post-update$' "$SUDO_TEST_LOG"; then fail "$signal reached the post-update hook"; fi
  pass "$signal stops the channel transition"
done
