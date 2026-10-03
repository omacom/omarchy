#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Where qt5-base is installed, Chrome needs qt5-wayland so libqt5_shim can find the Wayland
# platform plugin under Omarchy's QT_QPA_PLATFORM=wayland;xcb (issue #10488).

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
home_dir="$test_tmp/home"
pkg_log="$test_tmp/pkg.log"
mkdir -p "$mock_bin" "$home_dir/.config"

cat >"$mock_bin/omarchy-pkg-aur-add" <<'SH'
#!/bin/bash
printf 'aur:%s\n' "$*" >>"$OMARCHY_TEST_PKG_LOG"
SH

cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg:%s\n' "$*" >>"$OMARCHY_TEST_PKG_LOG"
SH

# Installed packages come from OMARCHY_TEST_INSTALLED, a space-separated list.
cat >"$mock_bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
for pkg in "$@"; do
  [[ " ${OMARCHY_TEST_INSTALLED:-} " == *" $pkg "* ]] || exit 1
done
SH

cat >"$mock_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 1
SH

for stub in \
  omarchy-install-chromium-copy-url \
  omarchy-install-chromium-ytdlp \
  omarchy-theme-set-browser; do
  cat >"$mock_bin/$stub" <<'SH'
#!/bin/bash
exit 0
SH
done

# browser-policy helpers need a writable destination; the real helper may call
# sudo, so stub the policy directory setup path via a no-op sourced helper by
# shadowing the install script's sourced file is hard — instead provide a
# minimal browser_policy_setup_dir in a fake OMARCHY_PATH tree.
fake_root="$test_tmp/omarchy"
mkdir -p "$fake_root/install/helpers" "$fake_root/bin" "$fake_root/config"
cp "$ROOT/bin/omarchy-install-browser" "$fake_root/bin/omarchy-install-browser"
cp "$ROOT/config/chromium-flags.conf" "$fake_root/config/chromium-flags.conf"

cat >"$fake_root/install/helpers/browser-policy.sh" <<'SH'
# Policy dirs live under /etc; the install under test only needs the helper to
# succeed so we can assert package selection, not root filesystem writes.
browser_policy_setup_dir() {
  :
}
browser_policy_setup_firefox_distribution() {
  :
}
SH

chmod +x "$mock_bin"/* "$fake_root/bin/omarchy-install-browser"

install_browser() {
  : >"$pkg_log"
  HOME="$home_dir" PATH="$mock_bin:/usr/bin:/bin" OMARCHY_PATH="$fake_root" \
    OMARCHY_TEST_PKG_LOG="$pkg_log" OMARCHY_TEST_INSTALLED="$1" \
    bash "$fake_root/bin/omarchy-install-browser" "$2" >/dev/null
}

run_migration() {
  : >"$pkg_log"
  HOME="$home_dir" PATH="$mock_bin:/usr/bin:/bin" OMARCHY_PATH="$ROOT" \
    OMARCHY_TEST_PKG_LOG="$pkg_log" OMARCHY_TEST_INSTALLED="$1" \
    bash -euo pipefail "$migration" >/dev/null
}

install_browser "qt5-base" chrome
grep -Fx 'aur:google-chrome' "$pkg_log" >/dev/null ||
  fail "chrome install still adds google-chrome" "$(cat "$pkg_log")"
grep -Fx 'pkg:qt5-wayland' "$pkg_log" >/dev/null ||
  fail "chrome install adds qt5-wayland where qt5-base is installed" "$(cat "$pkg_log")"
pass "chrome install adds qt5-wayland where qt5-base is installed"

# Without qt5-base Chrome uses its Qt6 shim, which qt6-wayland already serves.
install_browser "" chrome
grep -Fx 'aur:google-chrome' "$pkg_log" >/dev/null ||
  fail "chrome install still adds google-chrome" "$(cat "$pkg_log")"
! grep -q 'qt5-wayland' "$pkg_log" ||
  fail "chrome install leaves Qt5 off a machine without qt5-base" "$(cat "$pkg_log")"
pass "chrome install leaves Qt5 off a machine without qt5-base"

# Chromium does not ship libqt5_shim and must not pull the Qt5 stack.
install_browser "qt5-base" chromium
grep -Fx 'pkg:chromium' "$pkg_log" >/dev/null ||
  fail "chromium install still adds chromium" "$(cat "$pkg_log")"
! grep -q 'qt5-wayland' "$pkg_log" ||
  fail "chromium install does not pull qt5-wayland" "$(cat "$pkg_log")"
pass "chromium install does not pull qt5-wayland"

migration="$ROOT/migrations/1788743895.sh"
[[ -f $migration ]] || fail "qt5-wayland chrome migration exists"

run_migration "qt5-base"
[[ ! -s $pkg_log ]] || fail "qt5-wayland migration is a no-op without Chrome" "$(cat "$pkg_log")"
pass "qt5-wayland migration is a no-op without Chrome"

run_migration "google-chrome"
[[ ! -s $pkg_log ]] || fail "qt5-wayland migration is a no-op without qt5-base" "$(cat "$pkg_log")"
pass "qt5-wayland migration is a no-op without qt5-base"

run_migration "google-chrome qt5-base"
grep -Fx 'pkg:qt5-wayland' "$pkg_log" >/dev/null ||
  fail "qt5-wayland migration installs when Chrome and qt5-base are present" "$(cat "$pkg_log")"
pass "qt5-wayland migration installs when Chrome and qt5-base are present"
