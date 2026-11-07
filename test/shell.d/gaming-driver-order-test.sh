#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
test_home="$test_tmp/home's games"
launcher_dir="$test_home/Games/battlenet/drive_c/Program Files (x86)/Battle.net"
mkdir -p "$stub_bin" "$launcher_dir"
# An existing launcher avoids the download and partial-prefix prompt.
touch "$launcher_dir/Battle.net Launcher.exe"

cat >"$stub_bin/omarchy-install-gaming-gpu-lib32" <<'SH'
#!/bin/bash
printf 'drivers\n' >>"$OMARCHY_TEST_CALLS"
exit "${OMARCHY_TEST_DRIVER_STATUS:-0}"
SH

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'packages %s\n' "$*" >>"$OMARCHY_TEST_CALLS"
SH

# Never change system files, launch a game, or update the host's desktop cache.
for command in sudo setsid update-desktop-database; do
  printf '#!/bin/bash\nexit 0\n' >"$stub_bin/$command"
done
# Unexpected download or prefix-recovery paths must not reach the host.
for command in curl pkill umu-run; do
  printf '#!/bin/bash\nexit 99\n' >"$stub_bin/$command"
done
chmod +x "$stub_bin"/*

run_installer() {
  local installer="$1" driver_status="$2"

  : >"$test_tmp/calls"
  HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" \
    OMARCHY_TEST_CALLS="$test_tmp/calls" OMARCHY_TEST_DRIVER_STATUS="$driver_status" \
    bash "$ROOT/bin/$installer" >"$test_tmp/output" 2>&1
}

for installer in omarchy-install-gaming-lutris omarchy-install-gaming-battlenet; do
  run_installer "$installer" 0 || fail "$installer completes with stubbed dependencies" "$(<"$test_tmp/output")"
  mapfile -t calls <"$test_tmp/calls"
  [[ ${calls[0]:-} == "drivers" && ${calls[1]:-} == "packages "* ]] ||
    fail "$installer installs GPU libraries before umu-launcher dependencies" "$(<"$test_tmp/calls")"
  pass "$installer installs GPU libraries before umu-launcher dependencies"

  if run_installer "$installer" 23; then
    fail "$installer stops when GPU library installation fails"
  else
    status=$?
  fi
  (( status == 23 )) || fail "$installer preserves the GPU library failure status" "$status"
  [[ $(<"$test_tmp/calls") == "drivers" ]] ||
    fail "$installer installs no dependencies after GPU library failure" "$(<"$test_tmp/calls")"
  pass "$installer stops before dependency installation when GPU library installation fails"
done

# A fresh install used to append the wizard log at a fixed /tmp name.
rm -rf "$test_home/Games"
printf '#!/bin/bash\nexit 0\n' >"$stub_bin/curl"
cat >"$stub_bin/setsid" <<'SH'
#!/bin/bash
[[ $1 == "-f" ]] || exit 98
shift
exec "$@"
SH
cat >"$stub_bin/umu-run" <<'SH'
#!/bin/bash
[[ $# == 1 && $1 == "$HOME/.cache/omarchy/Battle.net-Setup.exe" ]] || exit 97
printf 'installer argument preserved\n' >>"$OMARCHY_TEST_CALLS"
SH
chmod +x "$stub_bin/curl" "$stub_bin/setsid" "$stub_bin/umu-run"
env -u XDG_RUNTIME_DIR HOME="$test_home" XDG_STATE_HOME="$test_tmp/state" OMARCHY_PATH="$ROOT" \
  OMARCHY_TEST_CALLS="$test_tmp/calls" PATH="$stub_bin:$PATH" \
  bash "$ROOT/bin/omarchy-install-gaming-battlenet" >"$test_tmp/output"
log="$test_tmp/state/omarchy/omarchy-battlenet-installer.log"
[[ -e $log && ! -L $log ]] || fail "battlenet installer log is kept in the private state dir" "$(<"$test_tmp/output")"
grep -F "Installer log: $log" "$test_tmp/output" >/dev/null ||
  fail "battlenet installer tells the user where the log went"
grep -qx 'installer argument preserved' "$test_tmp/calls" ||
  fail "the installer path with a quote is passed as one unchanged argument"
pass "battlenet installer log stays out of /tmp"
