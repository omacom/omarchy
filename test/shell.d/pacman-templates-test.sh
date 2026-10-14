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
# aarch64 has edge alone: stable and rc there would install the release line,
# which has no aarch64 support.
channels_for() {
  if [[ $1 == "x86" ]]; then echo "stable rc edge"; else echo "edge"; fi
}

# ── the templates ────────────────────────────────────────────────────────────

[[ $(omarchy_pacman_templates x86) == "$ROOT/default/pacman" ]] || fail "x86 keeps its templates where they were"
[[ $(omarchy_pacman_templates aarch64) == "$ROOT/default/pacman/aarch64" ]] || fail "plain aarch64 uses the aarch64 templates"
[[ $(omarchy_pacman_templates aarch64-apple) == "$ROOT/default/pacman/aarch64-apple" ]] || fail "Apple Silicon uses its own templates"
! omarchy_pacman_templates riscv 2>/dev/null || fail "an unknown platform has no templates"
pass "each platform's templates sit in a directory of their own, x86_64's where they always were"

[[ $(omarchy_pacman_default_channel x86) == stable ]] || fail "x86 defaults to stable"
for platform in aarch64 aarch64-apple; do
  [[ $(omarchy_pacman_default_channel "$platform") == edge ]] || fail "$platform defaults to edge"
done
! omarchy_pacman_default_channel riscv 2>/dev/null || fail "an unknown platform has no default channel"
pass "x86 defaults to stable and every aarch64 platform to edge"

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
    [[ $platform == "x86" ]] && continue
    [[ ! -e $templates/pacman-$channel.conf && ! -e $templates/mirrorlist-$channel ]] ||
      fail "$platform has no $channel template or mirrorlist"
  done
  for channel in $(channels_for "$platform"); do
    [[ -f $templates/pacman-$channel.conf && -f $templates/mirrorlist-$channel ]] ||
      fail "$platform has a $channel template and mirrorlist"
    list=$(repos "$templates" "$channel") || fail "$platform $channel: pacman reads the template"
    case $platform in
      x86) expected="omarchy core extra multilib " ;;
      aarch64) expected="omarchy core extra alarm aur " ;;
      aarch64-apple) expected="omarchy asahi-alarm core extra alarm aur " ;;
    esac
    [[ $list == "$expected" ]] || fail "$platform $channel: repositories in order" "$list"
    # $arch stays literal: pacman fills it in on the machine.
    server=$(sed -n '/^\[omarchy\]/,/^\[/s/^Server = //p' "$templates/pacman-$channel.conf")
    [[ $server == "https://pkgs.omarchy.org/$channel/\$arch" ]] ||
      fail "$platform $channel: Omarchy's $channel repository" "$server"
  done
done
pass "x86 has templates for stable, rc and edge and aarch64 for edge alone, each with its repositories in order"

# ── install finalization ─────────────────────────────────────────────────────

finalize_bin=$work/finalize-bin
mkdir -p "$finalize_bin"
printf '#!/bin/bash\necho "$PLATFORM"\n' >"$finalize_bin/omarchy-hw-platform"
for command in omarchy-pkg-add pacman-key; do
  printf '#!/bin/bash\nexit 0\n' >"$finalize_bin/$command"
done
chmod +x "$finalize_bin"/*
sed "s|/etc/pacman|$work/etc/pacman|g" "$ROOT/install/post-install/pacman.sh" >"$work/finalize.sh"
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
    OMARCHY_IMAGE_ROOT=$work OMARCHY_MIRROR=$channel PLATFORM=$platform OMARCHY_INSTALL="$work/install" PATH="$finalize_bin:$PATH" \
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
expected = [
  'step:cp -f /etc/pacman.conf /etc/pacman.conf.bak',
  'step:cp -f /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak',
  f'step:cp -f {templates}/pacman-{channel}.conf /etc/pacman.conf',
  f'step:cp -f {templates}/mirrorlist-{channel} /etc/pacman.d/mirrorlist',
]
copies = [e for e in events if e.startswith('step:cp ')]
assert copies == expected, events
hook = events.index('step:omarchy-hook pre-refresh-pacman')
transaction = events.index('step:pacman -Syyuu --noconfirm')
assert events.index(expected[-1]) < hook < transaction, events
PY
    assert_boundary_cold "$platform $channel"
  done
done
pass "a refresh backs up and copies the platform's channel template and mirrorlist, or its default channel's when none is named, then runs the cold hook and the upgrade"

# A channel the platform has no template for (stable or rc on aarch64), or a
# machine whose platform can't be told, stops before anything changes.
for platform in aarch64 aarch64-apple; do
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
