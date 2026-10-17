#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

for command in python3 script; do require_command "$command"; done

test_tmp=$(mktemp -d)
trap 'rm -rf -- "$test_tmp"' EXIT
export OMARCHY_TEST_ROOT="$test_tmp"
export OMARCHY_PATH="$ROOT"
mkdir -p "$test_tmp/bin"

# Exercise the real installer with package, service and app entry points replaced.
# No test installs software or opens the user's Desktop or Docker service.
python3 - "$ROOT" "$test_tmp" <<'PY'
from pathlib import Path
import sys
root, scratch = map(Path, sys.argv[1:])
script = (root / 'bin/omarchy-install-ai-hermes').read_text()
script = script.replace('/usr/bin/hermes-desktop', str(scratch / 'bin/hermes-desktop'))
(scratch / 'installer').write_text(script)
PY

cat >"$test_tmp/bin/omarchy-install-hermes-cli" <<'SH'
#!/bin/bash
printf 'local %s\n' "$*" >>"$OMARCHY_TEST_ROOT/events"
exit "${OMARCHY_TEST_LOCAL_STATUS:-0}"
SH
cat >"$test_tmp/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'package %s\n' "$*" >>"$OMARCHY_TEST_ROOT/events"
exit "${OMARCHY_TEST_PACKAGE_STATUS:-0}"
SH
cat >"$test_tmp/bin/hermes-desktop" <<'SH'
#!/bin/bash
printf 'launch\n' >>"$OMARCHY_TEST_ROOT/events"
SH
cat >"$test_tmp/bin/setsid" <<'SH'
#!/bin/bash
exec "$@"
SH
cat >"$test_tmp/bin/uwsm-app" <<'SH'
#!/bin/bash
[[ $1 == -- ]] || exit 1
shift
exec "$@"
SH
cat >"$test_tmp/bin/gum" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$OMARCHY_TEST_ROOT/choice-args"
[[ $1 == choose && $2 == --header ]] || exit 1
[[ ${OMARCHY_TEST_CHOICE:-local} != cancel ]] || exit 130
if [[ ${OMARCHY_TEST_CHOICE:-local} == remote ]]; then
  printf '%s\n' "$5"
else
  printf '%s\n' "$4"
fi
SH
cat >"$test_tmp/bin/omarchy-i18n" <<'SH'
#!/bin/bash
exec python3 - "$OMARCHY_PATH/default/i18n/en/cli.json" "$1" <<'PY'
import json
import sys
print(json.load(open(sys.argv[1]))[sys.argv[2]])
PY
SH
chmod +x "$test_tmp/bin/"*

new_home() {
  test_home="$test_tmp/$1"
  mkdir -p "$test_home"
  : >"$test_tmp/events"
  rm -f "$test_tmp/choice-args"
}

run_installer() {
  HOME="$test_home" HERMES_HOME="$test_home/.hermes" PATH="$test_tmp/bin:$PATH" \
    bash "$test_tmp/installer" "$@" </dev/null >"$test_tmp/output" 2>&1
}

run_choice() {
  HOME="$test_home" HERMES_HOME="$test_home/.hermes" PATH="$test_tmp/bin:$PATH" \
    script -qec "bash '$test_tmp/installer'; status=\$?; sleep 0.1; exit \$status" /dev/null </dev/null >"$test_tmp/output" 2>&1
}

wait_for_launch() {
  for (( attempt=0; attempt<200; attempt++ )); do
    if grep -qx launch "$test_tmp/events"; then return 0; fi
    sleep 0.01
  done
  fail "Desktop launch completes" "$(cat "$test_tmp/output")"
}

new_home remote
run_installer --remote || fail "explicit remote installation succeeds" "$(cat "$test_tmp/output")"
wait_for_launch
[[ $(cat "$test_tmp/events") == $'package hermes-desktop\nlaunch' ]] || fail "remote installation only installs the package and opens Desktop"
[[ ! -e $test_home/.hermes && ! -e $test_home/.local/bin ]] || fail "remote installation creates no host runtime or CLI wrappers"
grep -q 'Connect to existing Hermes' "$test_tmp/output" || fail "remote installation explains upstream onboarding"
pass "remote installation skips local runtime, CLI handover and theme setup"

new_home existing-local
mkdir -p "$test_home/.hermes/hermes-agent" "$test_home/.local/bin" "$test_home/.config/systemd/user"
printf 'local work\n' >"$test_home/.hermes/hermes-agent/work"
printf 'existing command\n' >"$test_home/.local/bin/hermes"
printf 'existing gateway\n' >"$test_home/.config/systemd/user/hermes-gateway.service"
run_installer --remote || fail "remote installation accepts an existing local installation"
wait_for_launch
[[ $(cat "$test_tmp/events") == $'package hermes-desktop\nlaunch' ]] || fail "remote installation never calls the local installer"
[[ $(cat "$test_home/.hermes/hermes-agent/work") == 'local work' ]] || fail "existing runtime is preserved"
[[ $(cat "$test_home/.local/bin/hermes") == 'existing command' ]] || fail "existing CLI is preserved"
[[ $(cat "$test_home/.config/systemd/user/hermes-gateway.service") == 'existing gateway' ]] || fail "existing gateway unit is preserved"
pass "remote installation leaves existing local runtimes, commands and services alone"

new_home local
run_installer --local || fail "explicit local installation succeeds"
wait_for_launch
[[ $(cat "$test_tmp/events") == $'local --now\nlaunch' ]] || fail "local installation delegates to the unchanged default-agent installer"
pass "explicit local installation preserves the existing runtime setup path"

for choice in local remote; do
  new_home "choose-$choice"
  OMARCHY_TEST_CHOICE="$choice" run_choice || fail "interactive $choice choice succeeds" "$(cat "$test_tmp/output")"
  wait_for_launch
  if [[ $choice == local ]]; then
    expected=$'local --now\nlaunch'
  else
    expected=$'package hermes-desktop\nlaunch'
  fi
  [[ $(cat "$test_tmp/events") == "$expected" ]] || fail "interactive $choice choice dispatches correctly"
  grep -qx 'How do you want to use Hermes Desktop?' "$test_tmp/choice-args" || fail "choice uses the translated header"
  grep -qx 'Connect to existing Hermes' "$test_tmp/choice-args" || fail "choice offers an existing backend"
done
pass "interactive local and existing-backend choices use the English catalog and select the right path"

new_home cancel
OMARCHY_TEST_CHOICE=cancel run_choice || fail "cancelling the picker exits cleanly"
[[ ! -s $test_tmp/events ]] || fail "cancelling installs and launches nothing"
pass "cancelling the choice has no side effects"

new_home invalid
for args in '' '--unknown' '--remote --local'; do
  read -ra argv <<<"$args"
  run_installer "${argv[@]}" && fail "missing noninteractive or invalid mode is rejected"
  [[ ! -s $test_tmp/events ]] || fail "invalid mode has no side effects"
done
pass "noninteractive callers must choose a valid explicit mode"

new_home package-failure
OMARCHY_TEST_PACKAGE_STATUS=7 run_installer --remote && fail "package failure must stop installation"
[[ $(cat "$test_tmp/events") == 'package hermes-desktop' ]] || fail "package failure does not open Desktop"
new_home local-failure
OMARCHY_TEST_LOCAL_STATUS=7 run_installer --local && fail "local setup failure must stop installation"
[[ $(cat "$test_tmp/events") == 'local --now' ]] || fail "local failure does not open Desktop"
pass "failed package or runtime setup stops before launch"

# Check the companion launcher's no-runtime path rather than assuming that
# installing only the package is enough. The Electron binary is a recorder;
# upstream's actual first-run remote form still needs graphical verification.
if find_omarchy_pkgs; then
  new_home packaged-launcher
  mkdir -p "$test_tmp/package"
  cat >"$test_tmp/package/Hermes" <<'SH'
#!/bin/bash
printf 'packaged-app\n' >>"$OMARCHY_TEST_ROOT/events"
printf '%s\n' "$@" >"$OMARCHY_TEST_ROOT/app-args"
SH
  cat >"$test_tmp/bin/unshare" <<'SH'
#!/bin/bash
exit 0
SH
  chmod +x "$test_tmp/package/Hermes" "$test_tmp/bin/unshare"
  python3 - "$OMARCHY_PKGS_ROOT/hermes-desktop/hermes-desktop.sh" "$test_tmp" <<'PY'
from pathlib import Path
import sys
source, scratch = map(Path, sys.argv[1:])
(scratch / 'package-launcher').write_text(source.read_text().replace('/opt/hermes-desktop', str(scratch / 'package')))
PY
  HOME="$test_home" HERMES_HOME="$test_home/.hermes" PATH="$test_tmp/bin:$PATH" \
    bash "$test_tmp/package-launcher" >"$test_tmp/output" 2>&1 || fail "packaged launcher works without a runtime" "$(cat "$test_tmp/output")"
  [[ $(cat "$test_tmp/events") == packaged-app ]] || fail "launcher opens the packaged Electron app"
  [[ ! -e $test_home/.hermes ]] || fail "launcher does not provision a runtime"
  grep -qx -- --disable-setuid-sandbox "$test_tmp/app-args" || fail "launcher keeps the Electron namespace sandbox"
  pass "the actual package launcher opens Electron without a local runtime"
else
  skip "package launcher check needs the companion omarchy-pkgs checkout"
fi
