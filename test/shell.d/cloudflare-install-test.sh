#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
export OMARCHY_PATH="$ROOT" CF_TEST_LOG="$scratch/calls"
export PATH="$scratch/bin:$ROOT/bin:$PATH"
cat >"$scratch/bin/omarchy-mise-install" <<'STUB'
#!/bin/bash
[[ $* == "npm:cf cf" ]] || exit 1
mkdir -p "$HOME/.local/bin"
cat >"$HOME/.local/bin/cf" <<'CLI'
#!/bin/bash
printf 'managed-cf %s\n' "$*" >> "$CF_TEST_LOG"
if [[ $* == "auth login" ]]; then exit "${CF_TEST_LOGIN_EXIT:-0}"; fi
if [[ $* == "auth logout" ]]; then exit "${CF_TEST_LOGOUT_EXIT:-0}"; fi
exit 1
CLI
chmod +x "$HOME/.local/bin/cf"
STUB
cat >"$scratch/bin/cf" <<'STUB'
#!/bin/bash
printf 'decoy-cf %s\n' "$*" >> "$CF_TEST_LOG"
if [[ $* == "auth login" ]]; then exit "${CF_TEST_LOGIN_EXIT:-0}"; fi
if [[ $* == "auth logout" ]]; then exit "${CF_TEST_LOGOUT_EXIT:-0}"; fi
exit 1
STUB
cat >"$scratch/bin/curl" <<'STUB'
#!/bin/bash
[[ ${CF_TEST_ICON_FAIL:-0} == 1 ]] && exit 22
while (( $# )); do
  if [[ $1 == "-o" ]]; then
    printf '%s' 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j4ZkAAAAASUVORK5CYII=' | base64 -d > "$2"
    exit 0
  fi
  shift
done
exit 1
STUB
for helper in gtk-update-icon-cache update-desktop-database omarchy-notification-send omarchy-plugin-enable omarchy-plugin-disable; do
  cat >"$scratch/bin/$helper" <<'STUB'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >> "$CF_TEST_LOG"
STUB
done
chmod +x "$scratch/bin/"*

install_service() { bash "$ROOT/bin/omarchy-install-service-cloudflare"; }
remove_service() { bash "$ROOT/bin/omarchy-remove-service-cloudflare"; }
for scenario in ${CF_TEST_CASES:-interrupted webapp-failure logout-failure identity ownership repeated shared-icon legacy}; do
  export HOME="$scratch/$scenario"
  mkdir -p "$HOME/.local/share/applications"
  launcher="$HOME/.local/share/applications/Cloudflare.desktop"
  marker="$HOME/.local/state/omarchy/cloudflare-service"
  : >"$CF_TEST_LOG"
  case $scenario in
    interrupted)
      if CF_TEST_LOGIN_EXIT=130 install_service; then fail "interrupted login aborts setup"; fi
      [[ ! -e $launcher && -f $marker ]] || fail "interrupted login creates no launcher and retains a recovery route"
      ! grep -q 'omarchy-plugin-enable' "$CF_TEST_LOG" || fail "interrupted login enables no widget"
      remove_service
      [[ ! -e $marker ]] || fail "interrupted setup can be removed"
      ;;
    webapp-failure)
      if CF_TEST_ICON_FAIL=1 install_service; then fail "failed icon download aborts setup"; fi
      [[ -f $marker && ! -e $launcher ]] || fail "failed dashboard creation retains Remove without disabling retry"
      ! grep -q 'omarchy-plugin-enable' "$CF_TEST_LOG" || fail "failed dashboard creation enables no widget"
      remove_service
      grep -q '^managed-cf auth logout$' "$CF_TEST_LOG" || fail "failed setup can sign out"
      ;;
    logout-failure)
      install_service
      if CF_TEST_LOGOUT_EXIT=1 remove_service; then fail "failed logout must fail removal"; fi
      [[ -f $launcher && -f $marker ]] || fail "failed logout keeps setup retryable"
      ! grep -q 'omarchy-plugin-disable' "$CF_TEST_LOG" || fail "failed logout keeps widget"
      remove_service
      [[ ! -e $launcher && ! -e $marker ]] || fail "logout retry cleans setup"
      ;;
    identity)
      install_service
      remove_service
      [[ ! -e $HOME/.local/share/icons/hicolor/256x256/apps/cloudflare.png ]] || fail "removal cleans its unused dashboard icon"
      ! grep -q 'decoy-cf' "$CF_TEST_LOG" || fail "PATH collision must not receive authentication commands"
      grep -q '^managed-cf auth login$' "$CF_TEST_LOG" || fail "setup uses the managed Cloudflare CLI"
      grep -q '^managed-cf auth logout$' "$CF_TEST_LOG" || fail "removal uses the managed Cloudflare CLI"
      ;;
    ownership)
      printf '[Desktop Entry]\nExec=other-cloudflare\n' >"$launcher"
      cp "$launcher" "$scratch/foreign.desktop"
      remove_service
      cmp "$launcher" "$scratch/foreign.desktop" || fail "removal preserves an unrelated launcher"
      if install_service; then fail "setup refuses an unrelated launcher"; fi
      cmp "$launcher" "$scratch/foreign.desktop" || fail "setup preserves an unrelated launcher"
      [[ ! -s $CF_TEST_LOG ]] || fail "unrelated launcher causes no auth or widget changes"
      mkdir -p "${marker%/*}"
      touch "$marker"
      remove_service
      cmp "$launcher" "$scratch/foreign.desktop" || fail "removing failed setup preserves a replacement launcher"
      ;;
    repeated)
      install_service
      install_service
      mkdir -p "${launcher%/*}/nested"
      printf '[Desktop Entry]\nExec=omarchy-launch-webapp "https://other.test"\n' >"${launcher%/*}/nested/Cloudflare.desktop"
      remove_service
      remove_service
      [[ ! -e $launcher && ! -e $marker && -f ${launcher%/*}/nested/Cloudflare.desktop ]] || fail "repeated removal targets only the service launcher"
      [[ $(grep -c '^managed-cf auth logout$' "$CF_TEST_LOG") == 1 ]] || fail "repeated removal does not sign out an unrelated later login"
      ;;
    shared-icon)
      install_service
      printf '[Desktop Entry]\nExec=another-app\nIcon=cloudflare\n' >"${launcher%/*}/Other.desktop"
      remove_service
      [[ -f $HOME/.local/share/icons/hicolor/256x256/apps/cloudflare.png ]] || fail "removal preserves an icon used by another launcher"
      ;;
    legacy)
      printf '[Desktop Entry]\nExec=omarchy-launch-webapp https://dash.cloudflare.com\n' >"$launcher"
      remove_service
      [[ ! -e $launcher ]] || fail "legacy owned launcher can be removed without a marker"
      printf '[Desktop Entry]\nExec=omarchy-launch-webapp "https://dash.cloudflare.com"\n' >"$scratch/target.desktop"
      ln -s "$scratch/target.desktop" "$launcher"
      remove_service
      [[ -L $launcher && -f $scratch/target.desktop ]] || fail "removal preserves a launcher symlink"
      if install_service; then fail "setup refuses a launcher symlink"; fi
      ;;
  esac
  pass "Cloudflare service $scenario"
done
