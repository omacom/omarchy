#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
export HOME="$test_tmp/home"
mkdir -p "$mock_bin" "$HOME"
export PATH="$mock_bin:$ROOT/bin:$PATH"

applications="$HOME/.local/share/applications"
icons="$HOME/.local/share/icons/hicolor/scalable/apps"
status_file="$test_tmp/status.json"
export OMARCHY_TEST_STATUS_FILE="$status_file"
export OMARCHY_TEST_START_LOG="$test_tmp/start"

# The engine as the commands see it: status is whatever the test wrote, and a
# start marks the model running, or fails with the engine's reason.
cat >"$mock_bin/omarchy-agent-local" <<'SH'
#!/bin/bash
case $1 in
status) cat "$OMARCHY_TEST_STATUS_FILE" ;;
start)
  printf '%s\n' "$2" >>"$OMARCHY_TEST_START_LOG"
  if [[ -n ${OMARCHY_TEST_START_FAILS:-} ]]; then
    echo "Error: Not enough memory to start $2"
    exit 1
  fi
  ;;
esac
SH
printf '#!/bin/bash\n' >"$mock_bin/update-desktop-database"
chmod +x "$mock_bin"/*

model() {
  jq -nc --arg recipe "$1" --arg name "$2" --arg vendor "$3" --arg unit "$4" --arg sub "${5:-dead}" \
    '{($recipe): {recipe: $recipe, name: $name, vendor: $vendor, unit: $unit, sub_state: $sub, expected_load_seconds: 76.0}}'
}

write_status() {
  jq -sc '{last: "qwen-fast", models: add}' <<<"$*" >"$status_file"
}

launchers() {
  (cd "$applications" && printf '%s\n' omarchy-agent-local-*.desktop | sort | paste -sd' ')
}

# Each model that is set up gets a launcher with its name and its vendor's
# logo, which opens an agent on it. One still downloading has nothing to open.
write_status "$(model qwen-fast "Qwen3.8 Flash Next" qwen inactive)" "$(model glm-5.3 "GLM-5.3 Flash" zai active running)" \
  "$(model nemotron "Nemotron 3.5 Bolt" nvidia installing)"
omarchy-agent-local-launchers
[[ $(launchers) == "omarchy-agent-local-glm-5.3.desktop omarchy-agent-local-qwen-fast.desktop" ]] ||
  fail "each model that is set up gets a launcher, and one still installing none" "$(launchers)"
entry=$(<"$applications/omarchy-agent-local-qwen-fast.desktop")
[[ $entry == *$'\nName=Qwen3.8 Flash Next\n'* ]] || fail "the launcher carries the model's name" "$entry"
[[ $entry == *$'\nExec=omarchy-agent --local-model qwen-fast --app-id=org.omarchy.local.qwen-fast\n'* ]] ||
  fail "the launcher opens an agent on its model" "$entry"
[[ $entry == *$'\nIcon=omarchy-agent-local-qwen\n'* && $entry == *$'\nStartupWMClass=org.omarchy.local.qwen-fast\n'* ]] ||
  fail "the launcher has its vendor's icon and a window class of its own" "$entry"
pass "each local model that is set up gets a launcher of its own"

# The icon is the vendor's logo on a tile: the logo's paths, scaled to fit,
# with the fill a logo keeps on its root.
[[ $(<"$icons/omarchy-agent-local-qwen.svg") == *'fill="#6D44E8"'* ]] || fail "the icon holds the vendor's logo"
grep -q '<g transform="translate([0-9. -]*) scale([0-9.]*)" fill="#fff" fill-rule="evenodd">' "$icons/omarchy-agent-local-zai.svg" ||
  fail "a logo filled from its root keeps that fill on the tile" "$(<"$icons/omarchy-agent-local-zai.svg")"
if omarchy-cmd-present xmllint; then
  for icon in "$icons"/omarchy-agent-local-*.svg; do
    xmllint --noout "$icon" || fail "the icon is well-formed: $icon"
  done
fi
pass "the launcher's icon is the model's vendor logo"

# A vendor without a logo gets the local model's, and names that could reach
# a command line or a path are not written anywhere.
write_status "$(model qwen-fast "Qwen3.8 Flash Next" qwen inactive)" "$(model odd "Odd One" ../mystery inactive)" \
  "$(model 'bad; rm -rf ~' "Bad" qwen inactive)"
omarchy-agent-local-launchers
[[ $(launchers) == "omarchy-agent-local-odd.desktop omarchy-agent-local-qwen-fast.desktop" ]] ||
  fail "a recipe that isn't a plain id gets no launcher" "$(launchers)"
grep -q '^Icon=omarchy-agent-local-local$' "$applications/omarchy-agent-local-odd.desktop" ||
  fail "a vendor without a logo gets the local model's icon"
[[ -f $icons/omarchy-agent-local-local.svg ]] || fail "the local model's icon is drawn"
pass "a vendor without a logo gets the local model's icon"

# Removing a model takes its launcher, and an icon no launcher uses, with it.
# Launchers that aren't a local model's are never touched.
touch "$applications/omarchy-agent-claude.desktop" "$icons/omarchy-agent-claude.svg"
write_status "$(model qwen-fast "Qwen3.8 Flash Next" qwen inactive)" "$(model glm-5.3 "GLM-5.3 Flash" zai removing)"
omarchy-agent-local-launchers
[[ $(launchers) == "omarchy-agent-local-qwen-fast.desktop" ]] || fail "a removed model loses its launcher" "$(launchers)"
[[ ! -e $icons/omarchy-agent-local-zai.svg && ! -e $icons/omarchy-agent-local-local.svg && -f $icons/omarchy-agent-local-qwen.svg ]] ||
  fail "an icon no launcher uses goes with it" "$(ls "$icons")"
[[ -f $applications/omarchy-agent-claude.desktop && -f $icons/omarchy-agent-claude.svg ]] ||
  fail "launchers that aren't a local model's are left alone"
echo '{"models":{}}' >"$status_file"
omarchy-agent-local-launchers
[[ $(launchers) == "omarchy-agent-local-*.desktop" ]] || fail "the last model removed leaves no launcher" "$(launchers)"
pass "removing a local model removes its launcher"

# The warm-up starts a stopped model before its agent opens. Without a
# terminal it draws nothing and just waits.
write_status "$(model qwen-fast "Qwen3.8 Flash Next" qwen inactive)"
: >"$OMARCHY_TEST_START_LOG"
omarchy-agent-local-warmup qwen-fast </dev/null >"$test_tmp/warmup-output" 2>&1 ||
  fail "the warm-up starts a stopped model" "$(<"$test_tmp/warmup-output")"
[[ $(<"$OMARCHY_TEST_START_LOG") == "qwen-fast" ]] || fail "the warm-up starts the model it was given"
: >"$OMARCHY_TEST_START_LOG"
omarchy-agent-local-warmup </dev/null >/dev/null 2>&1 || fail "the warm-up starts the model last used when given none"
[[ $(<"$OMARCHY_TEST_START_LOG") == "qwen-fast" ]] || fail "the warm-up defaults to the model last used"
pass "the warm-up starts a stopped model"

write_status "$(model qwen-fast "Qwen3.8 Flash Next" qwen active running)"
: >"$OMARCHY_TEST_START_LOG"
omarchy-agent-local-warmup qwen-fast </dev/null >/dev/null 2>&1 || fail "the warm-up passes a running model"
[[ ! -s $OMARCHY_TEST_START_LOG ]] || fail "a running model is not started again"
pass "the warm-up leaves a running model alone"

write_status "$(model qwen-fast "Qwen3.8 Flash Next" qwen inactive)"
if OMARCHY_TEST_START_FAILS=1 omarchy-agent-local-warmup qwen-fast </dev/null >"$test_tmp/warmup-output" 2>&1; then
  fail "a model that didn't start fails the warm-up"
fi
[[ $(<"$test_tmp/warmup-output") == *"Qwen3.8 Flash Next didn't start."*"Not enough memory to start qwen-fast"* ]] ||
  fail "the warm-up says why the model didn't start" "$(<"$test_tmp/warmup-output")"
if omarchy-agent-local-warmup missing </dev/null >"$test_tmp/warmup-output" 2>&1; then
  fail "a model that isn't set up fails the warm-up"
fi
[[ $(<"$test_tmp/warmup-output") == *"missing is not set up"* ]] || fail "the warm-up says a model isn't set up" "$(<"$test_tmp/warmup-output")"
pass "the warm-up reports a model that didn't start"

# A model someone else is already starting is waited for, not started again:
# the panel's status file says when it is up.
write_status "$(model qwen-fast "Qwen3.8 Flash Next" qwen activating start)"
state_file="$HOME/.local/state/omarchy/agent-local/status.json"
mkdir -p "${state_file%/*}"
cp "$status_file" "$state_file"
: >"$OMARCHY_TEST_START_LOG"
(
  sleep 1.5
  jq -c '.models["qwen-fast"] += {unit: "active", sub_state: "running"}' "$status_file" >"$state_file.tmp"
  mv "$state_file.tmp" "$state_file"
) &
omarchy-agent-local-warmup qwen-fast </dev/null >/dev/null 2>&1 || fail "the warm-up waits for a model that is already loading"
wait
[[ ! -s $OMARCHY_TEST_START_LOG ]] || fail "a model already loading is not started again"
pass "the warm-up waits for a model that is already loading"

# In a terminal the wait is a show: the model's name, how far along it is,
# and the terminal handed back as it was found.
if omarchy-cmd-present script; then
  write_status "$(model qwen-fast "Qwen3.8 Flash Next" qwen inactive)"
  cat >"$mock_bin/omarchy-agent-local" <<'SH'
#!/bin/bash
case $1 in
status) cat "$OMARCHY_TEST_STATUS_FILE" ;;
start) sleep 1 ;;
esac
SH
  script -qec "stty rows 30 cols 100; omarchy-agent-local-warmup qwen-fast" "$test_tmp/show" </dev/null >/dev/null ||
    fail "the warm-up's show ends well once the model is up"
  show=$(sed -E $'s/\e\\[[0-9;?]*[A-Za-z]//g' "$test_tmp/show")
  [[ $show == *"Q W E N 3 . 8   F L A S H   N E X T"* && $show == *"... 1%"* && $show == *"Qwen3.8 Flash Next is ready"* ]] ||
    fail "the show names the model, how far along it is and when it is ready"
  grep -q $'\e\\[?1049h' "$test_tmp/show" && grep -q $'\e\\[?25h\e\\[?1049l' "$test_tmp/show" ||
    fail "the show takes the alternate screen and gives the terminal back"
  pass "the warm-up puts on a show in a terminal"
else
  skip "the warm-up puts on a show in a terminal (no script command)"
fi
