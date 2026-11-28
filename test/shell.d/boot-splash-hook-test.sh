#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# etc/initcpio/install/omarchy-splash builds no image for systemd-boot, which
# the splash is untested with: not on a machine that boots it, nor on one
# switching to it, whose omarchy-boot-backend still says limine until the
# switch is promoted while --managed names both.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"
cat >"$test_tmp/bin/omarchy-boot-backend" <<'SH'
#!/bin/bash
if [[ ${1:-} == --managed ]]; then
  cat "$TEST_BACKENDS"
else
  head -n 1 "$TEST_BACKENDS"
fi
SH
chmod +x "$test_tmp/bin/omarchy-boot-backend"

# Runs the hook's build() where omarchy-boot-backend --managed prints the
# arguments, one per line. Its first addition ends the run.
build_hook() {
  printf '%s\n' "$@" >"$test_tmp/backends"
  (
    export PATH="$test_tmp/bin:$PATH" TEST_BACKENDS="$test_tmp/backends"
    HOOKS=(base udev omarchy-splash)
    error() { echo "error: $*"; }
    map() { echo "added: $*"; exit 0; }
    source "$ROOT/etc/initcpio/install/omarchy-splash"
    build
  )
}

for backends in "systemd-boot" "limine systemd-boot"; do
  # shellcheck disable=SC2086 # one backend per word
  if output=$(build_hook $backends); then
    fail "no image for systemd-boot ($backends)" "$output"
  fi
  [[ $output == "error: omarchy-splash does not support systemd-boot yet" ]] ||
    fail "no image for systemd-boot ($backends)" "$output"
done
pass "no image on a machine that boots systemd-boot or is switching to it"

output=$(build_hook limine) || fail "an image for Limine" "$output"
[[ $output == "added: add_binary sway seatd seatd-launch quickshell" ]] || fail "an image for Limine" "$output"
pass "an image for Limine"

# Runs build() end-to-end with stubbed mkinitcpio helpers to verify that
# OMARCHY_SPLASH_NO_KMS=1 adds /usr/lib/omarchy-splash/no-kms via add_file /dev/null
# and leaves it absent by default.
sed "s|source=/usr/share/omarchy/default/splash|source=$ROOT/default/splash|" \
  "$ROOT/etc/initcpio/install/omarchy-splash" >"$test_tmp/omarchy-splash"

build_full_hook() {
  local no_kms=$1
  printf 'limine\n' >"$test_tmp/backends"
  (
    export PATH="$test_tmp/bin:$PATH" TEST_BACKENDS="$test_tmp/backends"
    OMARCHY_SPLASH_NO_KMS=$no_kms
    HOOKS=(base udev omarchy-splash)
    error() { echo "error: $*"; }
    warning() { :; }
    map() { :; }
    add_binary() { :; }
    add_full_dir() { :; }
    add_udev_rule() { :; }
    add_symlink() { :; }
    add_runscript() { :; }
    add_file() {
      local dst=${2:-$1}
      [[ $1 == - ]] && cat >/dev/null
      echo "file: $1 -> $dst (${3:-})"
    }
    source "$test_tmp/omarchy-splash"
    build
  )
}

output=$(build_full_hook 1)
grep -qx "file: /dev/null -> /usr/lib/omarchy-splash/no-kms (644)" <<<"$output" ||
  fail "OMARCHY_SPLASH_NO_KMS=1 must add /usr/lib/omarchy-splash/no-kms directly" "$output"
pass "adds no-kms marker when OMARCHY_SPLASH_NO_KMS=1 is set"

output=$(build_full_hook "")
if grep -Fq "/usr/lib/omarchy-splash/no-kms" <<<"$output"; then
  fail "no-kms marker must be omitted by default" "$output"
fi
pass "omits no-kms marker by default"
