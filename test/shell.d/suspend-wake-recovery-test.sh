#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
command="$ROOT/bin/omarchy-diagnose-suspend-wake"
awk '/^[a-z_]+\(\) \{/ { copying=1 } copying { print } /^}/ { copying=0 }' "$command" >"$scratch/functions"
# Execute the actual entry point and functions, replacing all device/suspend
# access with explicit fixtures. No host /sys, /proc, udev or sleep writes.
cat >"$scratch/driver" <<'EOF'
#!/bin/bash
set -uo pipefail
source "$CASE_DIR/../functions"
STATE_DIR="$CASE_DIR/state"
STATE_FILE="$STATE_DIR/pending"
RULE_FILE="$CASE_DIR/rules"
SECONDS_DEFAULT=10
SETTLE_SECONDS=0
ESSENTIAL_ACPI=LID0
RESTORE_ON_EXIT=0
mkdir -p "$STATE_DIR"
require_root() { :; }
require_rtcwake() { :; }
prepare_state_dir() { exec 9>"$STATE_DIR/lock"; flock -n 9; }
settle() { :; }
udevadm() { [[ ${MODE:-} != reload-failure ]]; }
all_candidates() { printf 'USB1\tusb\tfixture1\nUSB2\tusb\tfixture2\n'; }
describe_candidate() { printf '%s' "$1"; }
suggest_rule() { echo 'generated rule'; }
set_candidate() {
  printf '%s %s\n' "$1" "$4" >>"$CASE_DIR/events"
  [[ ! -f $CASE_DIR/fail-$1 ]]
}
run_test() {
  local n=0
  [[ ! -e $CASE_DIR/count ]] || n=$(cat "$CASE_DIR/count")
  n=$((n+1)); echo "$n" >"$CASE_DIR/count"
  case ${MODE:-}:$n in
    failure:*) echo inconclusive; return 1 ;;
    *:1) echo woke-early ;;
    *:2) echo held ;;
    signal:3) kill -TERM "$$"; echo woke-early ;;
    inconclusive:3) echo inconclusive; return 1 ;;
    *) echo woke-early ;;
  esac
}
EOF
sed -n '/^# --- entry point/,$p' "$command" >>"$scratch/driver"
run_case() {
  local scenario=$1 mode=$2 verb=$3
  CASE_DIR="$scratch/$scenario" MODE="$mode" bash "$scratch/driver" "$verb" 10
}
mkdir -p "$scratch/restore/state"
printf 'USB1\tusb\tfixture1\nUSB2\tusb\tfixture2\n' >"$scratch/restore/state/pending"
touch "$scratch/restore/fail-USB2"
if run_case restore '' restore >"$scratch/restore.log" 2>&1; then fail "partial restore must report failure"; fi
[[ $(cat "$scratch/restore/state/pending") == $'USB2\tusb\tfixture2' ]] || fail "only failed restoration remains pending"
rm "$scratch/restore/fail-USB2"
run_case restore '' restore >>"$scratch/restore.log" 2>&1
[[ ! -e $scratch/restore/state/pending ]] || fail "successful retry clears recovery state"
pass "failed restores retain exactly the unresolved devices for retry"

mkdir -p "$scratch/test"
if run_case test failure test >"$scratch/test.log" 2>&1; then fail "inconclusive sleep reports failure"; fi
pass "failed sleep cannot report a successful test"

for mode in inconclusive signal; do
  mkdir -p "$scratch/$mode"
  if run_case "$mode" "$mode" diagnose <<< $'y\ny' >"$scratch/$mode.log" 2>&1; then fail "$mode diagnosis reports failure"; fi
  [[ ! -e $scratch/$mode/rules ]] || fail "$mode diagnosis never installs rules"
  [[ ! -e $scratch/$mode/state/pending ]] || fail "$mode diagnosis restores original state"
  [[ $(tail -n 2 "$scratch/$mode/events") == $'USB1 enabled\nUSB2 enabled' ]] || fail "$mode diagnosis stops after restoring" "$(cat "$scratch/$mode.log")"
done
pass "inconclusive per-device sleep and TERM restore settings and terminate diagnosis"

mkdir -p "$scratch/rules"
echo custom-rule >"$scratch/rules/rules"
if run_case rules '' diagnose <<< $'y\ny' >"$scratch/rules.log" 2>&1; then fail "an existing rule requires manual reconciliation"; fi
[[ $(cat "$scratch/rules/rules") == custom-rule ]] || fail "existing rule is preserved"
[[ ! -e $scratch/rules/state/pending ]] || fail "rule conflict restores temporary changes"
pass "existing generated rules are preserved and temporary changes restored"

mkdir -p "$scratch/pending/state"
printf 'USB0\tusb\tfixture0\n' >"$scratch/pending/state/pending"
if run_case pending '' diagnose <<< $'y\nn' >"$scratch/pending.log" 2>&1; then fail "prior recovery must be handled first"; fi
[[ ! -e $scratch/pending/events && $(cat "$scratch/pending/state/pending") == $'USB0\tusb\tfixture0' ]] || fail "a new diagnosis cannot overwrite earlier recovery state"
pass "pending recovery prevents a new diagnosis from discarding earlier state"

mkdir -p "$scratch/reload"
if run_case reload reload-failure diagnose <<< $'y\ny' >"$scratch/reload.log" 2>&1; then fail "udev reload failure is reported"; fi
[[ ! -e $scratch/reload/rules && ! -e $scratch/reload/state/pending ]] || fail "reload failure removes its new rule and restores temporary state"
pass "failed rule activation restores temporary state"

mkdir -p "$scratch/decline"
run_case decline '' diagnose <<< $'y\nn' >"$scratch/decline.log" 2>&1
[[ -s $scratch/decline/state/pending && ! -e $scratch/decline/rules ]] || fail "declined rule keeps explicit session recovery state"
run_case decline '' restore >>"$scratch/decline.log" 2>&1
[[ ! -e $scratch/decline/state/pending ]] || fail "session changes remain undoable"
pass "declining a permanent rule retains recovery state until explicit restore"
