#!/bin/bash

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

migration="$ROOT/migrations/1789744207.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

test_home="$test_dir/home"
config_dir="$test_home/.config"
mkdir -p "$config_dir"

run_migration() {
  HOME="$test_home" bash -euo pipefail "$migration" >/dev/null
}

printf '%s\n' \
  '--ozone-platform=wayland' \
  '--ozone-platform-hint=wayland' \
  '--password-store=gnome-libsecret' \
  '--enable-features=TouchpadOverscrollHistoryNavigation' \
  '--load-extension=/one,/two' >"$config_dir/chromium-flags.conf"
printf '%s\n' '--ozone-platform=wayland' >"$config_dir/brave-flags.conf"
printf '%s\n' '--enable-features=ExistingFeature' >"$config_dir/brave-origin-flags.conf"
printf '%s\n' '--enable-features=ExistingBetaFeature' >"$config_dir/brave-beta-flags.conf"
printf '%s\n' '--disable-features=SystemNotifications' >"$config_dir/chrome-flags.conf"

run_migration

grep -Fxq -- '--enable-features=TouchpadOverscrollHistoryNavigation,SystemNotifications' "$config_dir/chromium-flags.conf" ||
  fail "migration adds system notifications to Chromium's existing feature list"
grep -Fxq -- '--ozone-platform=wayland' "$config_dir/chromium-flags.conf" ||
  fail "migration leaves flags before Chromium's feature list unchanged"
grep -Fxq -- '--load-extension=/one,/two' "$config_dir/chromium-flags.conf" ||
  fail "migration leaves flags after Chromium's feature list unchanged"
[[ $(grep -o 'SystemNotifications' "$config_dir/chromium-flags.conf" | wc -l) -eq 1 ]] ||
  fail "migration changes only Chromium's feature list"
grep -Fxq -- '--enable-features=SystemNotifications' "$config_dir/brave-flags.conf" ||
  fail "migration adds a feature list when Brave does not have one"
grep -Fxq -- '--enable-features=ExistingFeature,SystemNotifications' "$config_dir/brave-origin-flags.conf" ||
  fail "migration preserves custom Brave Origin features"
grep -Fxq -- '--enable-features=ExistingBetaFeature,SystemNotifications' "$config_dir/brave-beta-flags.conf" ||
  fail "migration enables system notifications for retained Brave Beta flags"
[[ $(<"$config_dir/chrome-flags.conf") == '--disable-features=SystemNotifications' ]] ||
  fail "migration preserves an explicit system-notification opt-out"
pass "migration enables system notifications without discarding browser flag choices"

run_migration

[[ $(grep -o 'SystemNotifications' "$config_dir/chromium-flags.conf" | wc -l) -eq 1 ]] ||
  fail "migration is idempotent for an existing feature list"
[[ $(grep -o 'SystemNotifications' "$config_dir/brave-flags.conf" | wc -l) -eq 1 ]] ||
  fail "migration is idempotent for an added feature list"
grep -Fxq -- '--enable-features=ExistingBetaFeature,SystemNotifications' "$config_dir/brave-beta-flags.conf" ||
  fail "migration is idempotent for Brave Beta flags"
pass "migration does not duplicate the system notification feature"

for ending in newline no-newline empty; do
  flags="$config_dir/microsoft-edge-stable-flags.conf"
  expected="$test_dir/expected"
  case $ending in
    newline) printf '%s\n' '--ozone-platform=wayland' >"$flags" ;;
    no-newline) printf '%s' '--ozone-platform=wayland' >"$flags" ;;
    empty) : >"$flags" ;;
  esac
  if [[ $ending == "empty" ]]; then
    printf '%s\n' '--enable-features=SystemNotifications' >"$expected"
  else
    printf '%s\n' '--ozone-platform=wayland' '--enable-features=SystemNotifications' >"$expected"
  fi

  run_migration
  cmp -s "$expected" "$flags" || fail "migration appends a separate flag with $ending input"
  run_migration
  cmp -s "$expected" "$flags" || fail "migration preserves $ending input on a second run"
  pass "migration preserves flag boundaries and is idempotent with $ending input"
done

managed_dir="$test_home/dotfiles"
mkdir -p "$managed_dir"
managed_flags="$managed_dir/browser-flags.conf"
linked_flags="$config_dir/chromium-flags.conf"
expected="$test_dir/expected"

for state in existing-feature newline no-newline empty opt-out already-enabled; do
  rm -f "$linked_flags"
  case $state in
    existing-feature)
      printf '%s\n' '--ozone-platform=wayland' '--enable-features=ExistingFeature' '--load-extension=/one,/two' >"$managed_flags"
      printf '%s\n' '--ozone-platform=wayland' '--enable-features=ExistingFeature,SystemNotifications' '--load-extension=/one,/two' >"$expected"
      ;;
    newline | no-newline)
      if [[ $state == "newline" ]]; then
        printf '%s\n' '--ozone-platform=wayland' >"$managed_flags"
      else
        printf '%s' '--ozone-platform=wayland' >"$managed_flags"
      fi
      printf '%s\n' '--ozone-platform=wayland' '--enable-features=SystemNotifications' >"$expected"
      ;;
    empty)
      : >"$managed_flags"
      printf '%s\n' '--enable-features=SystemNotifications' >"$expected"
      ;;
    opt-out)
      printf '%s\n' '--enable-features=ExistingFeature' '--disable-features=SystemNotifications' >"$managed_flags"
      cp "$managed_flags" "$expected"
      ;;
    already-enabled)
      printf '%s\n' '--enable-features=ExistingFeature,SystemNotifications' >"$managed_flags"
      cp "$managed_flags" "$expected"
      ;;
  esac
  ln -s '../dotfiles/browser-flags.conf' "$linked_flags"

  for run in first second; do
    run_migration
    [[ -L $linked_flags && $(readlink "$linked_flags") == "../dotfiles/browser-flags.conf" ]] ||
      fail "migration preserves the managed flags symlink with $state input on the $run run"
    cmp -s "$expected" "$managed_flags" ||
      fail "migration updates the managed target correctly with $state input on the $run run"
    cmp -s "$expected" "$linked_flags" ||
      fail "browser sees the managed target through its symlink with $state input on the $run run"
  done
  pass "migration preserves the symlink, target and idempotence with $state input"
done
