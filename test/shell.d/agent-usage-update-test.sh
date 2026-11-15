#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command jq

TEST_HOME=$(mktemp -d)
FAKE_OMARCHY=$(mktemp -d)
POOL_DIRS=()
cleanup() {
  rm -rf "$TEST_HOME" "$FAKE_OMARCHY" "${POOL_DIRS[@]}"
}
trap cleanup EXIT

mkdir -p "$FAKE_OMARCHY/bin"

cat >"$FAKE_OMARCHY/bin/omarchy-agent-usage-good" <<'EOF'
#!/bin/bash
echo '{"schemaVersion":1,"id":"good","name":"Good Agent","totalPrompts":3}'
EOF

cat >"$FAKE_OMARCHY/bin/omarchy-agent-usage-noisy" <<'EOF'
#!/bin/bash
echo "this is not json"
EOF

cat >"$FAKE_OMARCHY/bin/omarchy-agent-usage-skipped" <<'EOF'
#!/bin/bash
echo '{"id":"skipped"}'
EOF

# The updater itself lives in the same namespace as the collectors it globs.
cat >"$FAKE_OMARCHY/bin/omarchy-agent-usage-update" <<'EOF'
#!/bin/bash
echo '{"id":"update"}'
EOF

chmod +x "$FAKE_OMARCHY/bin/"omarchy-agent-usage-*

usage_dir="$TEST_HOME/.local/state/omarchy/agents/usage"

# This script needs bash 5. Run it with the bash executing the test: a
# shebang of /bin/bash is an older shell on some machines the tests run on.
HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
  bash "$ROOT/bin/omarchy-agent-usage-update" --except skipped 2>/dev/null && fail "update reports a failing collector"
pass "update reports a failing collector"

[[ $(jq -r '.name' "$usage_dir/good.json") == "Good Agent" ]] ||
  fail "update writes each collector's record to the usage directory"
pass "update writes each collector's record to the usage directory"

[[ ! -e $usage_dir/noisy.json ]] ||
  fail "update refuses records that are not valid JSON"
pass "update refuses records that are not valid JSON"

[[ ! -e $usage_dir/skipped.json ]] ||
  fail "update skips agents excluded with --except"
pass "update skips agents excluded with --except"

[[ ! -e $usage_dir/update.json ]] ||
  fail "update does not treat itself as a collector"
pass "update does not treat itself as a collector"

HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
  bash "$ROOT/bin/omarchy-agent-usage-update" skipped 2>/dev/null ||
  fail "update succeeds when the requested collectors all pass"
pass "update succeeds when the requested collectors all pass"

[[ -e $usage_dir/skipped.json && ! -e $usage_dir/noisy.json ]] ||
  fail "update with agent arguments only runs the named collectors"
pass "update with agent arguments only runs the named collectors"

rm -rf "$usage_dir"
if output=$(HOME="$TEST_HOME" OMARCHY_PATH="$FAKE_OMARCHY" XDG_STATE_HOME="" \
  bash "$ROOT/bin/omarchy-agent-usage-update" --except '' 2>&1); then
  fail "update refuses an empty --except"
fi
[[ $output == "--except needs an agent" && ! -e $usage_dir/good.json ]] ||
  fail "update refuses an empty --except before collecting anything" "$output"
pass "update refuses an empty --except before collecting anything"

# Eight collectors. Each notes how many are alive as it starts, holds for
# OMARCHY_TEST_COLLECTOR_HOLD, and exits 1 when its id is in
# OMARCHY_TEST_FAIL_AGENTS. The hold is long enough that an uncapped launch
# overlaps all eight, and a cap of two overlaps exactly two.
install_pool_collectors() {
  local pool_root=$1 id
  mkdir -p "$pool_root/bin"
  for id in c01 c02 c03 c04 c05 c06 c07 c08; do
    cat >"$pool_root/bin/omarchy-agent-usage-$id" <<'EOF'
#!/bin/bash
agent=${0##*/omarchy-agent-usage-}
state=${OMARCHY_TEST_COLLECTOR_STATE:?}
mkdir -p "$state/active" "$state/ran"
while ! mkdir "$state/lock" 2>/dev/null; do
  :
done
touch "$state/active/$agent"
count=$(find "$state/active" -mindepth 1 -maxdepth 1 -print | wc -l | tr -d ' ')
printf '%s\n' "$count" >>"$state/samples"
rmdir "$state/lock"
touch "$state/ran/$agent"
# Stay active until the whole wave is in the sample. A short sleep can end
# before a peer is scheduled, and the default cap would then look like 1.
if [[ -n ${OMARCHY_TEST_OVERLAP:-} ]]; then
  last=0
  stable=0
  started=$SECONDS
  while (( SECONDS - started < 3 )); do
    while ! mkdir "$state/lock" 2>/dev/null; do
      :
    done
    count=$(find "$state/active" -mindepth 1 -maxdepth 1 -print | wc -l | tr -d ' ')
    printf '%s\n' "$count" >>"$state/samples"
    rmdir "$state/lock"
    if (( count == last && count >= OMARCHY_TEST_OVERLAP )); then
      stable=$((stable + 1))
      if (( stable >= 3 )); then
        break
      fi
    else
      stable=0
    fi
    last=$count
    sleep 0.05
  done
fi
case ,${OMARCHY_TEST_FAIL_AGENTS:-}, in
*,"$agent",*)
  rm -f "$state/active/$agent"
  exit 1
  ;;
esac
sleep "${OMARCHY_TEST_COLLECTOR_HOLD:-0.25}"
rm -f "$state/active/$agent"
printf '{"schemaVersion":1,"id":"%s","name":"%s"}\n' "$agent" "$agent"
EOF
    chmod +x "$pool_root/bin/omarchy-agent-usage-$id"
  done
}

# jobs empty means the updater's own default. failing is a comma-separated
# list of ids that exit 1, or empty when every collector succeeds. The
# fourth argument "posix" runs the updater under posix mode, where wait -n
# removes the child and a later wait on its pid is 127. The fifth argument
# is the overlap the collectors hold for, empty when they should not.
run_pool() {
  local jobs=$1 failing=$2 hold=$3 posix=${4:-} overlap=${5:-}
  local home omarchy state
  local runner=(bash)
  [[ $posix == "posix" ]] && runner=(bash --posix)
  home=$(mktemp -d)
  omarchy=$(mktemp -d)
  state=$(mktemp -d)
  POOL_DIRS+=("$home" "$omarchy" "$state")
  install_pool_collectors "$omarchy"
  POOL_USAGE="$home/.local/state/omarchy/agents/usage"
  POOL_STATE=$state
  POOL_CODE=0
  # env, not a shell assignment prefix: an optional VAR=value has to be
  # absent when unset, and a prefix only counts when it is written out.
  env \
    "HOME=$home" \
    "OMARCHY_PATH=$omarchy" \
    "XDG_STATE_HOME=" \
    "OMARCHY_AGENT_USAGE_JOBS=$jobs" \
    "OMARCHY_TEST_COLLECTOR_STATE=$state" \
    "OMARCHY_TEST_FAIL_AGENTS=$failing" \
    "OMARCHY_TEST_COLLECTOR_HOLD=$hold" \
    ${overlap:+"OMARCHY_TEST_OVERLAP=$overlap"} \
    ${POOL_BASH_ENV:+"BASH_ENV=$POOL_BASH_ENV"} \
    "${runner[@]}" "$ROOT/bin/omarchy-agent-usage-update" >/dev/null 2>&1 || POOL_CODE=$?
  POOL_PEAK=$(awk 'BEGIN { peak = 0 } { if ($1 + 0 > peak) peak = $1 + 0 } END { print peak + 0 }' "$state/samples")
  POOL_RAN=$(find "$state/ran" -mindepth 1 -maxdepth 1 -print | wc -l | tr -d ' ')
}

# jobs notifies every collector that has already finished. wait -n with no
# pid then returns 127 even though wait on the pid still has the real status.
# Bash 5.2 does this on its own when a wave exits before the next wait.
notify_finished_children() {
  local env
  env=$(mktemp)
  POOL_DIRS+=("$env")
  cat >"$env" <<'EOF'
if [[ $0 == *omarchy-agent-usage-update ]]; then
  omarchy_test_notify() {
    [[ ${OMARCHY_TEST_IN_TRAP:-} == 1 ]] && return 0
    OMARCHY_TEST_IN_TRAP=1
    jobs >/dev/null
    OMARCHY_TEST_IN_TRAP=0
  }
  trap omarchy_test_notify DEBUG
fi
EOF
  POOL_BASH_ENV=$env
}

# Collectors that print and exit. A heavier collector is often still running
# when the cap first waits, so wait -n receives its real status and the
# notified-127 case never happens.
run_instant_pool() {
  local jobs=$1 failing=$2 posix=${3:-}
  local home omarchy id
  local runner=(bash)
  [[ $posix == "posix" ]] && runner=(bash --posix)
  home=$(mktemp -d)
  omarchy=$(mktemp -d)
  POOL_DIRS+=("$home" "$omarchy")
  mkdir -p "$omarchy/bin"
  for id in c01 c02 c03 c04 c05 c06 c07 c08; do
    if [[ ,$failing, == *,"$id",* ]]; then
      printf '%s\n' '#!/bin/bash' 'exit 1' >"$omarchy/bin/omarchy-agent-usage-$id"
    else
      cat >"$omarchy/bin/omarchy-agent-usage-$id" <<'EOF'
#!/bin/bash
agent=${0##*/omarchy-agent-usage-}
printf '{"schemaVersion":1,"id":"%s","name":"%s"}\n' "$agent" "$agent"
EOF
    fi
    chmod +x "$omarchy/bin/omarchy-agent-usage-$id"
  done
  POOL_USAGE="$home/.local/state/omarchy/agents/usage"
  POOL_CODE=0
  env \
    "HOME=$home" \
    "OMARCHY_PATH=$omarchy" \
    "XDG_STATE_HOME=" \
    "OMARCHY_AGENT_USAGE_JOBS=$jobs" \
    ${POOL_BASH_ENV:+"BASH_ENV=$POOL_BASH_ENV"} \
    "${runner[@]}" "$ROOT/bin/omarchy-agent-usage-update" >/dev/null 2>&1 || POOL_CODE=$?
}

# One failing collector in an early, middle, or late slot of a multi-batch
# run, plus two that fail together before anything is waited for. The rest
# succeed and must still be written. Exit status stays 1.
expect_one_failure_kept() {
  local failing=$1 description=$2 posix=${3:-} id
  run_pool 2 "$failing" 0.15 "$posix"
  (( POOL_CODE == 1 )) || fail "$description" "exit=$POOL_CODE"
  (( POOL_RAN == 8 )) || fail "$description" "ran=$POOL_RAN of 8"
  for id in c01 c02 c03 c04 c05 c06 c07 c08; do
    case ,$failing, in
    *,"$id",*)
      [[ ! -e $POOL_USAGE/$id.json ]] || fail "$description" "$id wrote a record after failing"
      ;;
    *)
      [[ $(jq -r .id "$POOL_USAGE/$id.json") == "$id" ]] ||
        fail "$description" "$id record missing"
      ;;
    esac
  done
  pass "$description"
}

expect_one_failure_kept c01 \
  "update keeps an early collector failure and still writes the rest"
expect_one_failure_kept c04 \
  "update keeps a middle collector failure and still writes the rest"
expect_one_failure_kept c08 \
  "update keeps a late collector failure and still writes the rest"
expect_one_failure_kept c01,c02 \
  "update keeps a failure when the first wave has already exited"
expect_one_failure_kept c01,c02 \
  "update keeps a failure under posix wait -n" \
  posix

run_pool 2 "" 0.25
(( POOL_CODE == 0 )) || fail "capped update succeeds when every collector passes" "exit=$POOL_CODE"
(( POOL_RAN == 8 )) || fail "capped update runs every wanted collector" "ran=$POOL_RAN of 8"
(( POOL_PEAK == 2 )) ||
  fail "update never runs more collectors than the cap" "$(paste -sd, "$POOL_STATE/samples")"
for id in c01 c02 c03 c04 c05 c06 c07 c08; do
  [[ $(jq -r .id "$POOL_USAGE/$id.json") == "$id" ]] ||
    fail "capped update writes every collector record" "$id"
done
pass "update never runs more collectors than the cap"

run_pool 2 "" 0.25 posix
(( POOL_CODE == 0 )) || fail "posix capped update succeeds when every collector passes" "exit=$POOL_CODE"
(( POOL_PEAK == 2 )) ||
  fail "posix update never runs more collectors than the cap" "peak=$POOL_PEAK"
pass "posix update never runs more collectors than the cap"

run_pool "" "" 0 "" 2
(( POOL_CODE == 0 )) || fail "update's default collector cap still succeeds" "exit=$POOL_CODE"
(( POOL_PEAK == 2 )) ||
  fail "update's default collector cap stays at 2" "peak=$POOL_PEAK"
pass "update's default collector cap stays at 2"

# Every collector exits before the next wait. A cap as wide as the pool
# starts them all, and they finish during that launch.
run_pool 8 "" 0
(( POOL_CODE == 0 )) || fail "update succeeds when every collector has already exited" "exit=$POOL_CODE"
(( POOL_RAN == 8 )) || fail "update runs collectors that exit before the wait" "ran=$POOL_RAN of 8"
for id in c01 c02 c03 c04 c05 c06 c07 c08; do
  [[ $(jq -r .id "$POOL_USAGE/$id.json") == "$id" ]] ||
    fail "update writes a record when collectors exit together" "$id"
done
pass "update succeeds when every collector has already exited"

run_pool 8 c05 0
(( POOL_CODE == 1 )) || fail "update keeps a failure when collectors exit together" "exit=$POOL_CODE"
(( POOL_RAN == 8 )) || fail "update runs a mixed wave that exits together" "ran=$POOL_RAN of 8"
[[ ! -e $POOL_USAGE/c05.json ]] || fail "update keeps a failure when collectors exit together" "c05 wrote a record"
for id in c01 c02 c03 c04 c06 c07 c08; do
  [[ $(jq -r .id "$POOL_USAGE/$id.json") == "$id" ]] ||
    fail "update writes the collectors that passed in a wave that exits together" "$id"
done
pass "update keeps a failure when collectors exit together"

# Same wave, but jobs has already notified the finished children, so wait -n
# returns 127. The refresh is still a success.
notify_finished_children
run_instant_pool 2 ""
POOL_BASH_ENV=
(( POOL_CODE == 0 )) || fail "update succeeds when wait -n would return 127" "exit=$POOL_CODE"
for id in c01 c02 c03 c04 c05 c06 c07 c08; do
  [[ $(jq -r .id "$POOL_USAGE/$id.json") == "$id" ]] ||
    fail "update writes every record when wait -n would return 127" "$id"
done
pass "update succeeds when wait -n would return 127"

notify_finished_children
run_instant_pool 2 c04 posix
POOL_BASH_ENV=
(( POOL_CODE == 1 )) || fail "update keeps a notified collector failure" "exit=$POOL_CODE"
[[ ! -e $POOL_USAGE/c04.json ]] || fail "update keeps a notified collector failure" "c04 wrote a record"
for id in c01 c02 c03 c06 c07 c08; do
  [[ $(jq -r .id "$POOL_USAGE/$id.json") == "$id" ]] ||
    fail "update writes the collectors that passed when a notified one failed" "$id"
done
pass "update keeps a notified collector failure"

# Cap 2, one collector stays up until the other three have run. They have to
# start while it is still active: waiting on that pid first would hold the
# slot until it gives up.
refill_home=$(mktemp -d)
refill_omarchy=$(mktemp -d)
refill_state=$(mktemp -d)
POOL_DIRS+=("$refill_home" "$refill_omarchy" "$refill_state")
mkdir -p "$refill_omarchy/bin"
cat >"$refill_omarchy/bin/omarchy-agent-usage-c01" <<'EOF'
#!/bin/bash
agent=${0##*/omarchy-agent-usage-}
state=${OMARCHY_TEST_COLLECTOR_STATE:?}
mkdir -p "$state/active" "$state/ran" "$state/saw"
touch "$state/active/$agent"
started=$SECONDS
while (( SECONDS - started < 3 )); do
  n=$(find "$state/saw" -mindepth 1 -maxdepth 1 -print 2>/dev/null | wc -l | tr -d ' ')
  if (( n >= 3 )); then
    break
  fi
  sleep 0.01
done
rm -f "$state/active/$agent"
touch "$state/ran/$agent"
printf '{"schemaVersion":1,"id":"%s","name":"%s"}\n' "$agent" "$agent"
EOF
for id in c02 c03 c04; do
  cat >"$refill_omarchy/bin/omarchy-agent-usage-$id" <<'EOF'
#!/bin/bash
agent=${0##*/omarchy-agent-usage-}
state=${OMARCHY_TEST_COLLECTOR_STATE:?}
mkdir -p "$state/active" "$state/ran" "$state/saw"
started=$SECONDS
while (( SECONDS - started < 2 )); do
  if [[ -e $state/active/c01 ]]; then
    while ! mkdir "$state/lock" 2>/dev/null; do
      :
    done
    touch "$state/active/$agent"
    count=$(find "$state/active" -mindepth 1 -maxdepth 1 -print | wc -l | tr -d ' ')
    printf '%s\n' "$count" >>"$state/samples"
    rmdir "$state/lock"
    touch "$state/saw/$agent"
    rm -f "$state/active/$agent"
    touch "$state/ran/$agent"
    printf '{"schemaVersion":1,"id":"%s","name":"%s"}\n' "$agent" "$agent"
    exit 0
  fi
  if [[ -e $state/ran/c01 ]]; then
    touch "$state/ran/$agent"
    printf '{"schemaVersion":1,"id":"%s","name":"%s"}\n' "$agent" "$agent"
    exit 0
  fi
  sleep 0.01
done
exit 1
EOF
done
chmod +x "$refill_omarchy/bin/"omarchy-agent-usage-*
refill_usage="$refill_home/.local/state/omarchy/agents/usage"
refill_code=0
HOME="$refill_home" OMARCHY_PATH="$refill_omarchy" XDG_STATE_HOME="" \
  OMARCHY_AGENT_USAGE_JOBS=2 \
  OMARCHY_TEST_COLLECTOR_STATE="$refill_state" \
  bash "$ROOT/bin/omarchy-agent-usage-update" >/dev/null 2>&1 || refill_code=$?
refill_peak=$(awk 'BEGIN { peak = 0 } { if ($1 + 0 > peak) peak = $1 + 0 } END { print peak + 0 }' "$refill_state/samples")
refill_saw=$(find "$refill_state/saw" -mindepth 1 -maxdepth 1 -print 2>/dev/null | wc -l | tr -d ' ')
(( refill_code == 0 )) || fail "update refills a slot while a slow collector is running" "exit=$refill_code"
(( refill_peak == 2 )) || fail "update refills a slot without passing the cap" "peak=$refill_peak"
(( refill_saw == 3 )) || fail "update starts the fast collectors while the slow one is active" "saw=$refill_saw"
for id in c01 c02 c03 c04; do
  [[ $(jq -r .id "$refill_usage/$id.json") == "$id" ]] ||
    fail "update writes every collector in a mixed-speed wave" "$id"
done
pass "update refills a slot while a slow collector is running"

# A capped refresh can outlast the Codex stamp window. Collectors share that
# one scan for the whole run only when they are told which process is still
# running it, not only when it began. The collector's parent is the updater's
# collect subshell; that subshell's parent is the updater.
stamp_home=$(mktemp -d)
stamp_omarchy=$(mktemp -d)
stamp_state=$(mktemp -d)
POOL_DIRS+=("$stamp_home" "$stamp_omarchy" "$stamp_state")
mkdir -p "$stamp_omarchy/bin"
cat >"$stamp_omarchy/bin/omarchy-agent-usage-stamp" <<'EOF'
#!/bin/bash
state=${OMARCHY_TEST_COLLECTOR_STATE:?}
mkdir -p "$state"
grand=$(ps -o ppid= -p "$PPID" | tr -d ' ')
printf '%s\n' "${OMARCHY_AGENT_USAGE_REFRESH_PID:-}" >"$state/pid"
printf '%s\n' "${OMARCHY_AGENT_USAGE_REFRESH_AT:-}" >"$state/at"
printf '%s\n' "$grand" >"$state/grand"
printf '{"schemaVersion":1,"id":"stamp","name":"stamp"}\n'
EOF
chmod +x "$stamp_omarchy/bin/omarchy-agent-usage-stamp"
HOME="$stamp_home" OMARCHY_PATH="$stamp_omarchy" XDG_STATE_HOME="" \
  OMARCHY_TEST_COLLECTOR_STATE="$stamp_state" \
  bash "$ROOT/bin/omarchy-agent-usage-update" >/dev/null 2>&1 ||
  fail "update tells collectors which refresh they belong to"
stamp_pid=$(<"$stamp_state/pid")
stamp_at=$(<"$stamp_state/at")
stamp_grand=$(<"$stamp_state/grand")
[[ $stamp_pid =~ ^[1-9][0-9]*$ ]] ||
  fail "update exports its pid to collectors" "pid=$stamp_pid"
[[ $stamp_pid == "$stamp_grand" ]] ||
  fail "update's exported pid is the process running the refresh" "pid=$stamp_pid grand=$stamp_grand"
now=${EPOCHREALTIME/,/.}
awk -v at="$stamp_at" -v now="$now" 'BEGIN { d = now - at; exit !(d >= -1 && d < 30) }' ||
  fail "update's refresh stamp is when this run began" "at=$stamp_at now=$now"
pass "update tells collectors the pid of the refresh they belong to"
