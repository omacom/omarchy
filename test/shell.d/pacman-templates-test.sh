#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command python3
require_command pacman-conf

# Every platform's repositories are a pacman.conf and mirrorlist per channel,
# copied into place whole on a channel change and at install finalization, as
# x86_64's always were.

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
export OMARCHY_PATH="$ROOT"
source "$ROOT/install/helpers/pacman.sh"

platforms="x86 aarch64 aarch64-apple"
# Apple Silicon has edge alone: its packages and Asahi ALARM are published for
# edge only so far.
channels_for() {
  if [[ $1 == "aarch64-apple" ]]; then echo "edge"; else echo "stable rc edge"; fi
}

# ── the templates ────────────────────────────────────────────────────────────

[[ $(omarchy_pacman_templates x86) == "$ROOT/default/pacman" ]] || fail "x86 keeps its templates where they were"
[[ $(omarchy_pacman_templates aarch64) == "$ROOT/default/pacman/aarch64" ]] || fail "plain aarch64 uses the aarch64 templates"
[[ $(omarchy_pacman_templates aarch64-apple) == "$ROOT/default/pacman/aarch64-apple" ]] || fail "Apple Silicon uses its own templates"
for platform in aarch64-qualcomm aarch64-n1x aarch64-gb10; do
  [[ $(omarchy_pacman_templates "$platform") == "$ROOT/default/pacman/aarch64" ]] || fail "$platform shares the aarch64 templates"
  [[ $(omarchy_pacman_default_channel "$platform") == stable ]] || fail "$platform defaults to stable"
done
! omarchy_pacman_templates riscv 2>/dev/null || fail "an unknown platform has no templates"
pass "each platform's templates sit in a directory of their own, x86_64's where they always were"

for platform in x86 aarch64; do
  [[ $(omarchy_pacman_default_channel "$platform") == stable ]] || fail "$platform defaults to stable"
done
[[ $(omarchy_pacman_default_channel aarch64-apple) == edge ]] || fail "aarch64-apple defaults to edge"
! omarchy_pacman_default_channel riscv 2>/dev/null || fail "an unknown platform has no default channel"
pass "every platform defaults to stable but Apple Silicon, which defaults to edge"

# pacman reads each repository list from the template, with its mirrorlist
# standing in for /etc/pacman.d/mirrorlist.
repos() {
  local templates=$1 channel=$2
  sed "s|/etc/pacman.d/mirrorlist|$templates/mirrorlist-$channel|" "$templates/pacman-$channel.conf" >"$work/pacman.conf"
  pacman-conf --config "$work/pacman.conf" --repo-list | tr '\n' ' '
}
for platform in $platforms; do
  templates=$(omarchy_pacman_templates "$platform")
  for channel in stable rc; do
    [[ $platform == "aarch64-apple" ]] || continue
    [[ ! -e $templates/pacman-$channel.conf && ! -e $templates/mirrorlist-$channel ]] ||
      fail "$platform has no $channel template or mirrorlist"
  done
  for channel in $(channels_for "$platform"); do
    [[ -f $templates/pacman-$channel.conf && -f $templates/mirrorlist-$channel ]] ||
      fail "$platform has a $channel template and mirrorlist"
    list=$(repos "$templates" "$channel") || fail "$platform $channel: pacman reads the template"
    case $platform in
      x86) expected="omarchy core extra multilib " ;;
      aarch64) expected="omarchy core extra alarm " ;;
      aarch64-apple) expected="omarchy asahi-alarm core extra alarm " ;;
    esac
    [[ $list == "$expected" ]] || fail "$platform $channel: repositories in order" "$list"
    # $arch stays literal: pacman fills it in on the machine.
    server=$(sed -n '/^\[omarchy\]/,/^\[/s/^Server = //p' "$templates/pacman-$channel.conf")
    [[ $server == "https://pkgs.omarchy.org/$channel/\$arch" ]] ||
      fail "$platform $channel: Omarchy's $channel repository" "$server"
    # The Arch mirror is the same channel's: x86's at <channel>-mirror, Arch
    # Linux ARM's at arm-<channel>-mirror, edge without the channel.
    case $platform in
      x86) host=mirror.omarchy.org layout='$repo/os/$arch' ;;
      *) host=arm-mirror.omarchy.org layout='$arch/$repo' ;;
    esac
    [[ $channel == "edge" ]] || host=${host/mirror/$channel-mirror}
    mirror=$(sed -n 's/^Server = //p' "$templates/mirrorlist-$channel")
    [[ $mirror == "https://$host/$layout" ]] || fail "$platform $channel: the $channel Arch mirror" "$mirror"
  done
done
pass "x86 and aarch64 have templates for stable, rc and edge and Apple Silicon for edge alone, each with its repositories in order and its channel's mirrors"

# omarchy-version-channel names each template pair's channel: the menu's
# checkmarks and a refresh with no channel go by it.
sed -e "s|/etc/pacman.d/mirrorlist|$work/mirrorlist|g" -e "s|/etc/pacman.conf|$work/pacman.conf|g" \
  "$ROOT/bin/omarchy-version-channel" >"$work/version-channel"
for platform in $platforms; do
  templates=$(omarchy_pacman_templates "$platform")
  for channel in $(channels_for "$platform"); do
    cp "$templates/pacman-$channel.conf" "$work/pacman.conf"
    cp "$templates/mirrorlist-$channel" "$work/mirrorlist"
    said=$(bash "$work/version-channel")
    [[ $said == "$channel" ]] || fail "$platform $channel: omarchy-version-channel names it" "$said"
  done
done
pass "omarchy-version-channel names the channel of every platform's templates"

# ── install finalization ─────────────────────────────────────────────────────

finalize_bin=$work/finalize-bin
mkdir -p "$finalize_bin"
printf '#!/bin/bash\necho "$PLATFORM"\n' >"$finalize_bin/omarchy-hw-platform"
for command in omarchy-pkg-add pacman-key; do
  printf '#!/bin/bash\nexit 0\n' >"$finalize_bin/$command"
done
chmod +x "$finalize_bin"/*
# Finalization restores the templates through omarchy-apply-pacman, whose copy
# here writes into the test's etc rather than the host's.
finalize_root=$work/finalize-root
mkdir -p "$finalize_root/bin" "$finalize_root/install/post-install" "$finalize_root/default"
cp -r "$ROOT/install/helpers" "$finalize_root/install/"
cp -r "$ROOT/default/pacman" "$ROOT/default/regions" "$finalize_root/default/"
cp "$ROOT/install/post-install/pacman.sh" "$work/finalize.sh"
target_etc='etc="${2:-/}/etc"'
grep -Fqx "  $target_etc" "$ROOT/bin/omarchy-apply-pacman" || fail "omarchy-apply-pacman still names its target etc"
sed "s|^  $target_etc\$|  etc=\"\${2:-$work}/etc\"|" "$ROOT/bin/omarchy-apply-pacman" >"$finalize_root/bin/omarchy-apply-pacman"
chmod +x "$finalize_root/bin/omarchy-apply-pacman"
mkdir -p "$work/install/hardware"
: >"$work/install/hardware/pacman.sh"

# Finalization asks the image helper whether this is an image build, which root
# answers from the real /var/lib/omarchy; everyone else from the test's root.
if (( EUID == 0 )); then
  skip "install finalization copies the platform's channel template and mirrorlist (refuses to run as root)"
else
for platform in $platforms; do
  templates=$(omarchy_pacman_templates "$platform")
  # An install built for a channel the platform has no templates for, or for
  # none, gets the platform's default channel.
  for channel in stable rc edge ""; do
    expected=$channel
    [[ -n $expected && -f $templates/pacman-$expected.conf ]] || expected=$(omarchy_pacman_default_channel "$platform")
    rm -rf "$work/etc"
    mkdir -p "$work/etc/pacman.d"
    printf 'offline\n' | tee "$work/etc/pacman.conf" >"$work/etc/pacman.d/mirrorlist"
    OMARCHY_PATH=$finalize_root OMARCHY_IMAGE_ROOT=$work OMARCHY_MIRROR=$channel PLATFORM=$platform OMARCHY_INSTALL="$work/install" PATH="$finalize_bin:$PATH" \
      bash -e -c 'source "$1"' bash "$work/finalize.sh" >/dev/null || fail "$platform finalization on '$channel'"
    cmp -s "$work/etc/pacman.conf" "$templates/pacman-$expected.conf" || fail "$platform '$channel': finalization copies the $expected template"
    cmp -s "$work/etc/pacman.d/mirrorlist" "$templates/mirrorlist-$expected" || fail "$platform '$channel': finalization copies the $expected mirrorlist"
  done
done
pass "install finalization copies the platform's channel template and mirrorlist, or its default channel's when it has none for that channel"
fi

# ── refresh through the command, with every privileged step a stand-in ───────

rm -rf "$work"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-refresh-pacman
copy_boundary_file bin/omarchy-apply-pacman
cat >"$SUDO_TEST_ROOT/bin/omarchy-channel-current" <<'STUB'
#!/bin/bash
[[ ${SUDO_TEST_CHANNEL_FAIL:-0} != "1" ]] || exit 1
echo "${SUDO_TEST_CHANNEL:-unknown}"
STUB
chmod +x "$SUDO_TEST_ROOT/bin/omarchy-channel-current"

refresh() {
  "$SUDO_TEST_ROOT/bin/omarchy-refresh-pacman" "$@" >"$boundary_tmp/output" 2>&1
}
events() {
  grep -vE '^sudo (-h|-k)$' "$SUDO_TEST_LOG" || true
}

for platform in $platforms; do
  case $platform in
    x86) templates=$SUDO_TEST_ROOT/default/pacman ;;
    aarch64) templates=$SUDO_TEST_ROOT/default/pacman/aarch64 ;;
    aarch64-apple) templates=$SUDO_TEST_ROOT/default/pacman/aarch64-apple ;;
  esac
  # No channel named refreshes to the platform's default one.
  for channel in $(channels_for "$platform") ""; do
    reset_boundary
    SUDO_TEST_PLATFORM=$platform refresh $channel || fail "$platform refreshes to '$channel'" "$(cat "$boundary_tmp/output")"
    [[ -n $channel ]] || channel=$(omarchy_pacman_default_channel "$platform")
    python3 - "$SUDO_TEST_LOG" "$templates" "$channel" <<'PY'
import sys
events = [e for e in open(sys.argv[1]).read().splitlines() if e not in ('sudo -h', 'sudo -k')]
templates, channel = sys.argv[2:]
# The caller renders from the platform's templates; root backs up and copies
# the result.
copies = [e for e in events if e.startswith('step:cp ')]
assert len(copies) == 6, events
rendered = copies[0].split()[-1].rsplit('/', 1)[0]
expected = [
  f'step:cp {templates}/pacman-{channel}.conf {rendered}/pacman.conf',
  f'step:cp {templates}/mirrorlist-{channel} {rendered}/mirrorlist',
  'step:cp -f /etc/pacman.conf /etc/pacman.conf.bak',
  'step:cp -f /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak',
  f'step:cp -f {rendered}/pacman.conf /etc/pacman.conf',
  f'step:cp -f {rendered}/mirrorlist /etc/pacman.d/mirrorlist',
]
assert copies == expected, events
hook = events.index('step:omarchy-hook pre-refresh-pacman')
upgrade = 'step:pacman -Syyuu --noconfirm'
if channel in ('stable', 'rc'):
  # The -dev pair is edge's: an old build of it in a stable or rc repository is
  # left to the channel switch's swap.
  upgrade += ' --ignore omarchy-dev,omarchy-settings-dev'
transaction = events.index(upgrade)
assert events.index(expected[-1]) < hook < transaction, events
PY
    assert_boundary_cold "$platform $channel"
  done
done
pass "a refresh renders and copies the named channel, or the platform default when the current channel is unknown, then runs the cold hook and the upgrade"

for channel in stable rc edge dev; do
  reset_boundary
  SUDO_TEST_CHANNEL=$channel refresh || fail "refresh preserves $channel" "$(cat "$boundary_tmp/output")"
  expected=$channel
  [[ $channel != "dev" ]] || expected=edge
  grep -F "step:cp $SUDO_TEST_ROOT/default/pacman/pacman-$expected.conf " "$SUDO_TEST_LOG" >/dev/null ||
    fail "$channel refresh uses $expected repositories" "$(events)"
  grep -F "step:cp $SUDO_TEST_ROOT/default/pacman/mirrorlist-$expected " "$SUDO_TEST_LOG" >/dev/null ||
    fail "$channel refresh uses $expected mirrors" "$(events)"
  assert_boundary_cold "$channel refresh"
done
pass "a refresh with no channel preserves stable, rc and edge, and uses edge for a linked dev checkout"

reset_boundary
SUDO_TEST_CHANNEL=edge SUDO_TEST_CHANNEL_FAIL=1 refresh rc || fail "explicit rc overrides current edge without detecting it"
grep -F "step:cp $SUDO_TEST_ROOT/default/pacman/pacman-rc.conf " "$SUDO_TEST_LOG" >/dev/null ||
  fail "explicit rc overrides current edge" "$(events)"
assert_boundary_cold "explicit override"
pass "an explicit channel overrides the current channel without querying it"

for channel in stable rc; do
  reset_boundary
  if SUDO_TEST_PLATFORM=aarch64-apple SUDO_TEST_CHANNEL=$channel refresh; then fail "aarch64-apple refuses current $channel without templates"; fi
  [[ -z $(events) ]] || fail "unsupported current channel changes nothing" "$(events)"
  assert_boundary_cold "unsupported current channel"
done
for channel in invalid failed; do
  reset_boundary
  if [[ $channel == "failed" ]]; then
    if SUDO_TEST_CHANNEL_FAIL=1 refresh; then fail "failed channel detection is refused"; fi
  else
    if SUDO_TEST_CHANNEL=$channel refresh; then fail "unexpected channel is refused"; fi
  fi
  [[ -z $(events) ]] || fail "failed channel detection changes nothing" "$(events)"
  assert_boundary_cold "failed channel detection"
done
pass "unsupported, unexpected or failed current channel detection changes nothing"

reset_boundary
if refresh invalid; then fail "invalid explicit channel is refused"; fi
[[ -z $(events) ]] || fail "invalid explicit channel changes nothing" "$(events)"
assert_boundary_cold "invalid explicit channel"
pass "an invalid explicit channel changes nothing"

# A channel the platform has no template for (stable or rc on Apple Silicon),
# or a machine whose platform can't be told, stops before anything changes.
for platform in aarch64-apple; do
  for channel in stable rc; do
    reset_boundary
    if SUDO_TEST_PLATFORM=$platform refresh "$channel"; then fail "$platform: $channel is refused"; fi
    [[ -z $(events) ]] || fail "$platform: $channel stops before anything" "$(events)"
    grep -q "Omarchy has no $channel channel for $platform" "$boundary_tmp/output" || fail "the refusal says why" "$(cat "$boundary_tmp/output")"
    assert_boundary_cold "$platform $channel"
  done
done
cat >"$SUDO_TEST_ROOT/bin/omarchy-hw-platform" <<'STUB'
#!/bin/bash
exit 1
STUB
reset_boundary
if refresh stable; then fail "an unknown platform is refused"; fi
[[ -z $(events) ]] || fail "an unknown platform stops before anything" "$(events)"
assert_boundary_cold "unknown platform"
pass "a channel without a template, or a machine whose platform can't be told, changes nothing"
