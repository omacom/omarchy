#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

# Dotfile managers link ~/.config and browser profiles in from elsewhere.
mkdir -p "$tmp_dir/bin" "$tmp_dir/dotfiles/config/1Password" "$tmp_dir/dotfiles/vivaldi/NativeMessagingHosts" "$tmp_dir/home"
ln -s "$tmp_dir/dotfiles/config" "$tmp_dir/home/.config"
ln -s "$tmp_dir/dotfiles/vivaldi" "$tmp_dir/home/.config/vivaldi"
touch "$tmp_dir/dotfiles/vivaldi/Preferences"

for browser_dir in \
  chromium/NativeMessagingHosts \
  "google-chrome/Profile 1/NativeMessagingHosts" \
  BraveSoftware/Brave-Browser/NativeMessagingHosts \
  microsoft-edge/NativeMessagingHosts \
  vivaldi/NativeMessagingHosts; do
  mkdir -p "$tmp_dir/home/.config/$browser_dir"
  touch "$tmp_dir/home/.config/$browser_dir/com.1password.1password.json"
done

mkdir -p "$tmp_dir/home/.mozilla/native-messaging-hosts"
touch "$tmp_dir/home/.mozilla/native-messaging-hosts/com.1password.1password.json"

mkdir -p "$tmp_dir/home/.config/not-a-browser"
touch "$tmp_dir/home/.config/not-a-browser/com.1password.1password.json"
touch "$tmp_dir/home/.config/1Password/settings.json"

cat >"$tmp_dir/bin/sudo" <<'SCRIPT'
#!/bin/bash
if [[ $1 == "rm" ]]; then
  printf '%s\n' "$*" >>"${OMARCHY_TEST_SUDO_LOG:-/dev/null}"
  exit 0
fi
exec "$@"
SCRIPT

cat >"$tmp_dir/bin/omarchy-pkg-drop" <<'SCRIPT'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_LOG"
exit "${OMARCHY_TEST_PKG_DROP_STATUS:-0}"
SCRIPT

chmod +x "$tmp_dir/bin/sudo" "$tmp_dir/bin/omarchy-pkg-drop"

if OMARCHY_TEST_PKG_DROP_STATUS=1 OMARCHY_TEST_SUDO_LOG="$tmp_dir/sudo.log" OMARCHY_TEST_LOG="$tmp_dir/pkg-drop.log" HOME="$tmp_dir/home" PATH="$tmp_dir/bin:$PATH" \
  bash "$ROOT/bin/omarchy-remove-service-1password" >/dev/null; then
  fail "1Password removal reports a failed package removal"
fi
[[ -e "$tmp_dir/home/.config/chromium/NativeMessagingHosts/com.1password.1password.json" ]] ||
  fail "1Password removal keeps the browser integration when the packages stay"
[[ ! -e "$tmp_dir/sudo.log" ]] ||
  fail "1Password removal keeps the browser integration when the packages stay" "$(cat "$tmp_dir/sudo.log")"
pass "1Password removal keeps the browser integration when the packages stay"

OMARCHY_TEST_LOG="$tmp_dir/pkg-drop.log" HOME="$tmp_dir/home" PATH="$tmp_dir/bin:$PATH" \
  bash "$ROOT/bin/omarchy-remove-service-1password"

for browser_dir in \
  chromium/NativeMessagingHosts \
  "google-chrome/Profile 1/NativeMessagingHosts" \
  BraveSoftware/Brave-Browser/NativeMessagingHosts \
  microsoft-edge/NativeMessagingHosts \
  vivaldi/NativeMessagingHosts; do
  [[ ! -e "$tmp_dir/home/.config/$browser_dir/com.1password.1password.json" ]] ||
    fail "1Password removal deletes stale native-messaging manifests" "$browser_dir"
done
[[ ! -e "$tmp_dir/home/.mozilla/native-messaging-hosts/com.1password.1password.json" ]] ||
  fail "1Password removal deletes stale native-messaging manifests" "firefox"
pass "1Password removal deletes stale native-messaging manifests"

[[ -e "$tmp_dir/home/.config/not-a-browser/com.1password.1password.json" ]] ||
  fail "1Password removal leaves unrelated configuration files alone"
[[ -e "$tmp_dir/home/.config/1Password/settings.json" ]] ||
  fail "1Password removal preserves the user's 1Password data"
[[ -e "$tmp_dir/dotfiles/vivaldi/Preferences" ]] ||
  fail "1Password removal leaves a linked browser profile alone"
pass "1Password removal leaves unrelated configuration files alone"

grep -Fxq '1password 1password-cli' "$tmp_dir/pkg-drop.log" ||
  fail "1Password removal drops both packages"
pass "1Password removal drops both packages"
