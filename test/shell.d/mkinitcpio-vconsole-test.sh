#!/bin/bash
#
# omarchy_hooks.conf leaves a non-Latin keyboard layout out of FILES, so the
# LUKS passphrase stays typeable at the Plymouth prompt (#6229). Since
# 26.134.222-3, Arch's plymouth hook adds vconsole.conf itself (#14246), so
# omarchy_vconsole.conf refuses the file in add_file unless FILES lists it.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# The drop-ins read the machine's own /etc/vconsole.conf; copies read a fixture.
vconsole="$test_tmp/vconsole.conf"
plymouthd="$test_tmp/plymouthd.conf"
: >"$plymouthd"
for conf in omarchy_hooks.conf omarchy_vconsole.conf; do
  sed "s|/etc/vconsole.conf|$vconsole|g" "$ROOT/etc/mkinitcpio.conf.d/$conf" >"$test_tmp/$conf"
done
# An omarchy_hooks.conf from before the package, which pacman keeps over the
# packaged one: it sets HOOKS and never mentions vconsole.conf.
printf 'HOOKS=(base udev plymouth keyboard autodetect modconf kms keymap block encrypt filesystems fsck)\n' >"$test_tmp/stale_hooks.conf"

# Build an image the way mkinitcpio does and print what reached it: source the
# drop-ins with add_file already defined, run plymouth's hook, add FILES, then
# source them again, as parse_config and the systemd hook do, and add a file
# after that. $1 is XKBLAYOUT; with $2 set, mkinitcpio's own add_file copies
# into a real build root; $3 replaces omarchy_hooks.conf.
image_files() {
  local layout=$1 functions=${2:-} hooks_conf=${3:-$test_tmp/omarchy_hooks.conf}
  printf 'KEYMAP=%s\nXKBLAYOUT=%s\n' "${layout%%,*}" "$layout" >"$vconsole"
  rm -rf "$test_tmp/root"
  mkdir -p "$test_tmp/root"
  (
    set +u
    FUNCNEST=50
    MODULES=() BINARIES=() FILES=() HOOKS=()
    BUILDROOT=$test_tmp/root
    if [[ -n $functions ]]; then
      source "$functions"
    else
      add_file() { printf '%s\n' "${2:-$1}" >>"$BUILDROOT/added"; }
    fi
    source "$hooks_conf"
    source "$test_tmp/omarchy_vconsole.conf"
    # What Arch's plymouth hook does since 26.134.222-3, run the way mkinitcpio
    # runs a hook: with FILES local and empty.
    plymouth_build() { local FILES=(); add_file "$vconsole"; }
    plymouth_build
    for file in "${FILES[@]}"; do add_file "$file"; done
    source "$hooks_conf"
    source "$test_tmp/omarchy_vconsole.conf"
    add_file "$plymouthd"
  ) >/dev/null || return 1
  if [[ -n $functions ]]; then
    (cd "$test_tmp/root" && find . -type f -printf '/%P\n')
  else
    cat "$test_tmp/root/added"
  fi | sort -u | paste -sd ' '
}

assert_image() {
  local description=$1 layout=$2 expected=$3 functions=${4:-} hooks_conf=${5:-} actual
  actual=$(image_files "$layout" "$functions" "$hooks_conf") || fail "$description" "the image build failed"
  [[ $actual == "$expected" ]] || fail "$description" "expected: $expected"$'\n'"actual:   $actual"
  pass "$description"
}

latin="$plymouthd $vconsole"
assert_image "a Cyrillic first layout stays out of the image Plymouth builds" ru,us "$plymouthd"
assert_image "a Ukrainian first layout stays out as well" ua,us "$plymouthd"
assert_image "a Hebrew layout stays out as well" il "$plymouthd"
assert_image "a Latin layout still reaches the LUKS prompt" de "$latin"
assert_image "a Latin first layout with a non-Latin second still reaches it" us,ru "$latin"
assert_image "an omarchy_hooks.conf from before the package still keeps it out" ru,us "$plymouthd" "" "$test_tmp/stale_hooks.conf"

# The file is refused wherever a hook copies it from.
printf 'XKBLAYOUT=ru\n' >"$vconsole"
added=$(
  set +u
  FILES=()
  add_file() { printf '%s\n' "${2:-$1}"; }
  source "$test_tmp/omarchy_hooks.conf"
  source "$test_tmp/omarchy_vconsole.conf"
  add_file "$plymouthd" "$vconsole"
  add_file "$plymouthd"
)
[[ $added == "$plymouthd" ]] || fail "a copy written to vconsole.conf's path from elsewhere is refused" "added: $added"
pass "a copy written to vconsole.conf's path from elsewhere is refused"

# FILES still decides, as it did before plymouth copied the file: a
# configuration that lists vconsole.conf itself keeps it, whatever the layout.
added=$(
  set +u
  FILES=("$vconsole")
  add_file() { printf '%s\n' "${2:-$1}"; }
  source "$test_tmp/omarchy_hooks.conf"
  source "$test_tmp/omarchy_vconsole.conf"
  add_file "$vconsole"
)
[[ $added == "$vconsole" ]] || fail "a vconsole.conf the configuration lists in FILES still goes in" "added: $added"
pass "a vconsole.conf the configuration lists in FILES still goes in"

# A drop-in sorting after omarchy_vconsole.conf can list the file too: FILES is
# read when a file is added, and the hook's copy is still refused.
added=$(
  set +u
  FILES=()
  add_file() { printf '%s\n' "${2:-$1}"; }
  source "$test_tmp/omarchy_hooks.conf"
  source "$test_tmp/omarchy_vconsole.conf"
  FILES+=("$vconsole")
  plymouth_build() { local FILES=(); add_file "$vconsole"; }
  plymouth_build
  for file in "${FILES[@]}"; do add_file "$file"; done
)
[[ $added == "$vconsole" ]] || fail "a vconsole.conf a later drop-in lists in FILES goes in once" "added: $added"
pass "a vconsole.conf a later drop-in lists in FILES goes in once"

# The same builds again with mkinitcpio's own add_file, where it is installed.
functions=/usr/lib/initcpio/functions
if [[ -r $functions ]]; then
  assert_image "mkinitcpio's add_file leaves a Cyrillic layout out" ru,us "$plymouthd" "$functions"
  assert_image "mkinitcpio's add_file still copies a Latin layout" de "$latin" "$functions"
else
  skip "mkinitcpio's add_file leaves a Cyrillic layout out (mkinitcpio is not installed)"
fi
