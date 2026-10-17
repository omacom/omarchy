#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The overlay's model turns fprintd-enroll's output into steps and hints.
run_node_test <<'JS'
const fs = require('fs')
const source = fs.readFileSync(root + '/shell/plugins/fingerprint-enroll/EnrollModel.js', 'utf8')
eval(source.replace('.pragma library', ''))

assertEqual(stepForLine('Enroll result: enroll-stage-passed').kind, 'passed', 'a passed stage is a passed step')
assertEqual(stepForLine('Enroll result: enroll-completed').kind, 'done', 'completion ends the enrollment')
assertEqual(stepForLine('Enroll result: enroll-swipe-too-short').kind, 'retry', 'a short press asks for a retry')
assertEqual(stepForLine('Enroll result: enroll-unknown-error').kind, 'failed', 'an unknown error fails the enrollment')
assertEqual(stepForLine('failed to claim device: busy').kind, 'failed', 'a busy reader fails the enrollment')
assertEqual(stepForLine('Using device /net/reactivated/Fprint/Device/0'), null, 'chatter is ignored')
assertEqual(stepForLine('EnrollStart failed: GDBus.Error:net.reactivated.Fprint.Error.PermissionDenied: Not Authorized: net.reactivated.fprint.device.enroll').kind, 'cancelled', 'a cancelled password prompt is a cancel, not a failure')
assert(!/GDBus/.test(JSON.stringify(stepForLine('EnrollStart failed: GDBus.Error:org.freedesktop.DBus.Error.NoReply').message)), 'D-Bus error strings stay out of the overlay')

assert(!expired({}, Date.now()) && !expired({ expires: 'soon' }, Date.now()), 'a request without a deadline never expires')
assert(!expired({ expires: 2000 }, 1000) && expired({ expires: 2000 }, 3000), 'a request expires once its deadline has passed')

assert(validFinger('right-thumb') && validFinger('left-little-finger') && !validFinger('right-toe'), 'finger names follow fprintd')
assertEqual(fingerId(1, 0), 'right-thumb', 'thumbs have no -finger suffix')
assertEqual(fingerId(0, 4), 'left-little-finger', 'other fingers do')
assertEqual(fingerName('right-index-finger').key, 'fingerprint.finger.rightIndex', 'finger names come from the catalog')
assertEqual(fingerName('right-index-finger').text, 'right index finger', 'with an English fallback that reads in a sentence')

assertDeepEqual(
  enrolledFromList('Fingerprints for user u on Reader (press):\n - #0: right-index-finger\n - #1: left-thumb\n'),
  ['right-index-finger', 'left-thumb'],
  'enrolled fingers are read from fprintd-list'
)

const hints = new Set()
for (let i = 0; i < 9; i++) hints.add(placementFor(i).key)
assertEqual(hints.size, 9, 'the first nine presses each get a different placement')
assertEqual(placementFor(0).key, placementFor(9).key, 'then the spiral repeats')

// Every key the overlay and its model use exists in the English catalog,
// and every finger fprintd knows has a name.
const catalog = JSON.parse(fs.readFileSync(root + '/default/i18n/en/shell.json', 'utf8'))
const qml = fs.readFileSync(root + '/shell/plugins/fingerprint-enroll/Enroll.qml', 'utf8')
const used = [...(source + qml).matchAll(/(?:I18n\.t|[^a-zA-Z_.]t)\("(fingerprint\.[A-Za-z0-9.]+)"/g)].map((m) => m[1])
const missing = used.filter((k) => !(k in catalog))
assert(missing.length === 0, 'every fingerprint key is in the English catalog', JSON.stringify(missing))
for (const h of [0, 1]) for (let f = 0; f < 5; f++) {
  assert(fingerName(fingerId(h, f)).key !== 'fingerprint.finger.unknown', 'every finger has a catalog name: ' + fingerId(h, f))
}
JS

# The wrapper builds the overlay's JSON payload from its argument, so it must
# refuse anything that is not an fprintd finger name before using it.
if "$ROOT/bin/omarchy-fingerprint-enroll" 'right-index-finger","doneFile":"/tmp/x' >/dev/null 2>&1; then
  fail "omarchy-fingerprint-enroll rejects a finger name that is not fprintd's"
fi
pass "omarchy-fingerprint-enroll rejects a finger name that is not fprintd's"

# The wrapper's request handling, against a stubbed shell. OVERLAY decides how
# the stub answers: "ok" writes ok as the result, "vanish" takes the request
# and then disappears without answering, "slow" opens a second after the
# summon, "absent" never loads. The wrapper's wait is cut to two seconds.
wrapper_scratch=$(mktemp -d)
trap 'rm -rf "$wrapper_scratch"' EXIT
mkdir -p "$wrapper_scratch/bin"
cat > "$wrapper_scratch/bin/omarchy-shell" <<'STUB'
#!/bin/bash
state="$WRAPPER_STATE"
case "$2 $3" in
  "ping "*) [[ $OVERLAY != "noshell" ]] && echo ok ;;
  "summon "*)
    echo ok
    echo "$4" > "$state.payload"
    date +%s%3N > "$state.t0"
    done_file=$(sed -n 's/.*"doneFile":"\([^"]*\)".*/\1/p' <<< "$4")
    echo "$done_file" > "$state"
    [[ $OVERLAY == "ok" && -n $done_file ]] && echo ok > "$done_file"
    ;;
  "call omarchy.fingerprint-enroll")
    case "$4 $OVERLAY" in
      "isOpen ok") echo open ;;
      "isOpen slow") (( $(date +%s%3N) - $(cat "$state.t0") >= 1000 )) && echo open || echo closed ;;
      "handles vanish")
        # ours for the first few polls, then gone
        count=$(($(cat "$state.n" 2>/dev/null || echo 0) + 1)); echo "$count" > "$state.n"
        (( count <= 2 )) && echo yes || echo unknown ;;
      *) echo unknown ;;
    esac
    ;;
esac
STUB
cat > "$wrapper_scratch/bin/fprintd-enroll" <<'STUB'
#!/bin/bash
echo fprintd-enroll >> "$WRAPPER_STATE.log"
STUB
chmod +x "$wrapper_scratch/bin/"*

run_wrapper() {
  rm -f "$wrapper_scratch/state"*
  OVERLAY=$1 WRAPPER_STATE="$wrapper_scratch/state" PATH="$wrapper_scratch/bin:$PATH" \
    OMARCHY_FINGERPRINT_ENROLL_WAIT_MS=2000 \
    timeout 60 "$ROOT/bin/omarchy-fingerprint-enroll" "${@:2}" </dev/null >/dev/null 2>&1
}

run_wrapper ok right-thumb || fail "a finger enrolled by the overlay exits 0"
pass "the wrapper reports the overlay's result"

run_wrapper ok || fail "the picker exits 0 once the overlay is open"
pass "the wrapper confirms the picker opened"

started=$SECONDS
if run_wrapper vanish right-thumb; then
  fail "an overlay that goes away without answering is a failure"
fi
(( SECONDS - started < 30 )) || fail "the wrapper notices a vanished overlay within seconds" "$((SECONDS - started))s"
pass "the wrapper stops waiting when the overlay goes away"

run_wrapper slow || fail "a picker that takes a moment to load still counts as open"
pass "the wrapper waits for a slow overlay"

# The overlay refuses a request once its deadline has passed, so the wrapper
# must not give up and fall back any earlier: the two would both run.
gives_up_after_deadline() {
  local expires
  expires=$(sed -n 's/.*"expires":\([0-9]*\).*/\1/p' "$wrapper_scratch/state.payload")
  [[ -n $expires ]] || fail "$1: the request carries a deadline"
  (( $(date +%s%3N) > expires )) || fail "$1: the wrapper gives up only after the deadline"
}

if run_wrapper absent; then
  fail "a picker that never opens is a failure without a terminal"
fi
gives_up_after_deadline "picker"
[[ ! -f $wrapper_scratch/state.log ]] || fail "without a terminal the wrapper does not fall back to fprintd-enroll"
pass "without a terminal the wrapper fails instead of running fprintd-enroll"

if run_wrapper absent right-thumb; then
  fail "a finger request the overlay never takes is a failure"
fi
gives_up_after_deadline "finger"
pass "the wrapper gives up on a request only after its deadline"

if run_wrapper noshell right-thumb; then
  fail "no shell and no terminal is a failure"
fi
pass "no shell and no terminal is a failure"
