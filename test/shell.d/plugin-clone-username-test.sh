#!/bin/bash

set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
require_command jq

case_root=$(mktemp -d)
trap 'rm -rf "$case_root"' EXIT
mkdir -p "$case_root/bin" "$case_root/source"
export TEST_SOURCE="$case_root/source" TEST_CALLS="$case_root/calls"
printf '{"id":"omarchy.fixture","name":"Fixture","kinds":["bar-widget"],"entryPoints":{"barWidget":"Widget.qml"}}\n' >"$TEST_SOURCE/manifest.json"
printf 'Item {}\n' >"$TEST_SOURCE/Widget.qml"
cat >"$case_root/bin/omarchy-plugin-catalog" <<'STUB'
#!/bin/bash
jq -cn --arg source "$TEST_SOURCE" '[{firstParty:true,id:"omarchy.fixture",name:"Fixture",sourceDir:$source,manifestPath:($source+"/manifest.json")}]'
STUB
cat >"$case_root/bin/omarchy-plugin-list" <<'STUB'
#!/bin/bash
manifests=("$HOME/.config/omarchy/plugins/"*/manifest.json)
if [[ -e ${manifests[0]} ]]; then jq -s 'map({id:.id})' "${manifests[@]}"; else printf '[]\n'; fi
STUB
for command in omarchy-shell omarchy-plugin-enable omarchy-notification-send; do
  cat >"$case_root/bin/$command" <<'STUB'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >>"$TEST_CALLS"
STUB
done
chmod +x "$case_root/bin/"*

case_index=0
for username in tester Tester user_1 a-b.c _service 'tester$'; do
  case_index=$((case_index + 1))
  home="$case_root/valid-$case_index"
  : >"$TEST_CALLS"
  HOME="$home" USER="$username" PATH="$case_root/bin:$PATH" bash "$ROOT/bin/omarchy-plugin-clone" omarchy.fixture >"$case_root/output"
  target="$home/.config/omarchy/plugins/$username.fixture"
  [[ -f $target/Widget.qml ]] || fail "valid username clones inside the plugin directory"
  jq -e --arg id "$username.fixture" '.id == $id and .omarchy.clonedFrom == "omarchy.fixture"' "$target/manifest.json" >/dev/null || fail "valid username is retained in the manifest"
  grep -Fxq "omarchy-plugin-enable $username.fixture" "$TEST_CALLS" || fail "valid clone is enabled"
  HOME="$home" PATH="$case_root/bin:$PATH" bash "$ROOT/bin/omarchy-plugin-remove" "$username.fixture" --yes >"$case_root/remove-output"
  [[ ! -e $target ]] || fail "valid username plugin can be removed"
  backups=("$home/.config/omarchy/plugins/.$username.fixture.bak."*)
  [[ -f ${backups[0]}/manifest.json ]] || fail "removal preserves the clone in its backup"
  pass "username $username clones, enables and removes its plugin"
done

# Even the negative-control version of this test keeps every candidate path
# inside its synthetic home. No host config or pre-existing plugin is touched.
for username in '../escaped' '../../escaped' 'nested/name' 'a..b' 'bad$name' $'bad\nname'; do
  home="$case_root/invalid"
  mkdir -p "$home"
  : >"$TEST_CALLS"
  status=0
  HOME="$home" USER="$username" PATH="$case_root/bin:$PATH" bash "$ROOT/bin/omarchy-plugin-clone" omarchy.fixture >"$case_root/output" 2>&1 || status=$?
  (( status != 0 )) || fail "unsafe username is refused"
  grep -Fq 'invalid username for plugin id:' "$case_root/output" || fail "username is rejected by the path guard"
  [[ ! -d $home/.config/omarchy/plugins && ! -s $TEST_CALLS ]] || fail "invalid username has no clone or shell side effects"
done
pass "path and control-character usernames fail before creating files"
