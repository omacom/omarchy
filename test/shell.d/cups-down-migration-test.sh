#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"
export CUPS_TEST_DIR="$test_tmp"

cat >"$test_tmp/bin/lpstat" <<'SH'
#!/bin/bash
if [[ ${CUPS_TEST_RESPONSE:-stopped} == empty ]]; then
  if [[ $LC_MESSAGES == C && $LC_ALL == C && $LANGUAGE == C ]]; then
    echo 'lpstat: No destinations added.' >&2
  else
    echo 'lpstat: Keine Ziele hinzugefügt.' >&2
  fi
else
  [[ $LC_MESSAGES == C && $LC_ALL == C ]] || exit 99
  echo 'lpstat: Scheduler is not running.' >&2
fi
exit 1
SH
cat >"$test_tmp/bin/systemctl" <<'SH'
#!/bin/bash
exit 1
SH
for command in omarchy-pkg-present pacman; do
  printf '#!/bin/bash\nexit 0\n' >"$test_tmp/bin/$command"
done
cat >"$test_tmp/bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
touch "$CUPS_TEST_DIR/dropped"
SH
# A direct user read is denied; only the fake privileged reader can access
# this synthetic root-owned configuration. No host CUPS file is accessed.
cat >"$test_tmp/bin/cat" <<'SH'
#!/bin/bash
if [[ ${1:-} == /etc/cups/printers.conf ]]; then exit 1; fi
exec /bin/cat "$@"
SH
cat >"$test_tmp/bin/sudo" <<'SH'
#!/bin/bash
case "$*" in
  'cat /etc/cups/printers.conf')
    touch "$CUPS_TEST_DIR/privileged-read"
    [[ $CUPS_TEST_MODE == readable ]] || exit 1
    exec /bin/cat "$CUPS_TEST_DIR/printers.conf"
    ;;
  'test ! -e /etc/cups/printers.conf')
    [[ $CUPS_TEST_MODE == missing ]]
    ;;
  'install -Dm644 /dev/null '*)
    touch "$CUPS_TEST_DIR/marker"
    ;;
  *) exit 99 ;;
esac
SH
chmod +x "$test_tmp/bin/"*

run_case() {
  local label=$1 mode=$2 contents=$3 expected=$4
  rm -f "$test_tmp/dropped" "$test_tmp/marker" "$test_tmp/privileged-read"
  printf '%s\n' "$contents" >"$test_tmp/printers.conf"
  local status=0
  CUPS_TEST_MODE="$mode" OMARCHY_CUPS_BROWSED_REMOVAL_MARKER="$test_tmp/marker" \
    PATH="$test_tmp/bin:$PATH" bash -euo pipefail "$ROOT/migrations/1788009111.sh" >"$test_tmp/output" 2>&1 || status=$?
  (( status == expected )) || fail "$label returns the expected status" "$(/bin/cat "$test_tmp/output")"
  [[ -e $test_tmp/privileged-read ]] || fail "$label reads queues with privilege"
  if (( expected == 0 )); then
    [[ -e $test_tmp/dropped && -e $test_tmp/marker ]] || fail "$label completes removal"
  else
    [[ ! -e $test_tmp/dropped && ! -e $test_tmp/marker ]] || fail "$label keeps removal pending"
  fi
  pass "$label"
}

run_case 'saved discovery queue keeps the migration pending' readable 'DeviceURI implicitclass://printer/' 1
grep -Fq 'sudo systemctl start cups.service' "$test_tmp/output" || fail "discovery warning gives a recovery action"
run_case 'indented saved discovery queue stays pending' readable $'  DeviceURI\timplicitclass://printer/' 1
run_case 'direct IPP queue permits removal' readable 'DeviceURI ipp://printer/' 0
run_case 'descriptive mention is not a discovery queue' readable $'Info implicitclass://example\nDeviceURI ipp://printer/' 0
run_case 'unreadable saved queues keep the migration pending' denied 'DeviceURI implicitclass://printer/' 1
run_case 'absent saved configuration permits removal' missing '' 0

# Reproduce CUPS' own message-language selection without requiring a locale
# package on the test host. The stub emits the translated empty-list response
# unless the actual migration pins all three locale inputs for lpstat.
rm -f "$test_tmp/dropped" "$test_tmp/marker" "$test_tmp/privileged-read"
status=0
CUPS_TEST_RESPONSE=empty CUPS_TEST_MODE=denied \
  LC_ALL=C LC_MESSAGES=de_DE.UTF-8 LANGUAGE=de \
  OMARCHY_CUPS_BROWSED_REMOVAL_MARKER="$test_tmp/marker" \
  PATH="$test_tmp/bin:$PATH" bash -euo pipefail "$ROOT/migrations/1788009111.sh" >"$test_tmp/output" 2>&1 || status=$?
(( status == 0 )) || fail "empty queues under a non-English locale permit removal" "$(/bin/cat "$test_tmp/output")"
[[ -e $test_tmp/dropped && -e $test_tmp/marker ]] || fail "empty queues complete removal"
[[ ! -e $test_tmp/privileged-read ]] || fail "healthy empty scheduler does not read saved queues"
pass "empty queues under a non-English locale complete the migration"
