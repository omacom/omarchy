#!/bin/bash

set -euo pipefail

# Dictation install, removal, and menu guards follow the voxtype command, not
# one package name. Stubs stand in for pacman, sudo, gum, and the compositor.
# Setup > Defaults owns installation now; Remove still has to see every
# package that provides the voxtype command.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_home=$(mktemp -d)
test_bin=$(mktemp -d)
log_file=$(mktemp)

cleanup() {
  rm -rf "$test_home" "$test_bin"
  rm -f "$log_file"
}
trap cleanup EXIT

cat >"$test_bin/gum" <<'EOF'
#!/bin/bash
exit 0
EOF

cat >"$test_bin/omarchy-pkg-add" <<'EOF'
#!/bin/bash
echo "pkg-add:$*" >>"$TEST_LOG"
EOF

cat >"$test_bin/omarchy-pkg-drop" <<'EOF'
#!/bin/bash
echo "pkg-drop:$*" >>"$TEST_LOG"
EOF

cat >"$test_bin/omarchy-cmd-present" <<'EOF'
#!/bin/bash
if [[ $1 == "voxtype" && $VOXTYPE_PRESENT == "yes" ]]; then
  exit 0
fi
exit 1
EOF

cat >"$test_bin/omarchy-cmd-missing" <<'EOF'
#!/bin/bash
if [[ $1 == "voxtype" && $VOXTYPE_PRESENT == "yes" ]]; then
  exit 1
fi
exit 0
EOF

cat >"$test_bin/pacman" <<'EOF'
#!/bin/bash
echo "pacman:$*" >>"$TEST_LOG"
exit 1
EOF

cat >"$test_bin/sudo" <<'EOF'
#!/bin/bash
echo "sudo:$*" >>"$TEST_LOG"
exit 1
EOF

for stub_name in voxtype omarchy-hw-vulkan hyprctl omarchy-restart-shell omarchy-notification-send omarchy-dictation-use systemctl; do
  cat >"$test_bin/$stub_name" <<'EOF'
#!/bin/bash
exit 0
EOF
  chmod +x "$test_bin/$stub_name"
done

chmod +x "$test_bin/gum" "$test_bin/omarchy-pkg-add" "$test_bin/omarchy-pkg-drop" \
  "$test_bin/omarchy-cmd-present" "$test_bin/omarchy-cmd-missing" "$test_bin/pacman" "$test_bin/sudo"

run_voxtype() {
  : >"$log_file"
  run_status=0
  run_output=$(
    HOME="$test_home" \
      XDG_CONFIG_HOME="$test_home/.config" \
      OMARCHY_PATH="$ROOT" \
      PATH="$test_bin:$PATH" \
      TEST_LOG="$log_file" \
      VOXTYPE_PRESENT="$2" \
      bash "$ROOT/bin/$1" </dev/null 2>&1
  ) || run_status=$?
}

assert_logged() {
  local expected=$1
  local description=$2
  local actual

  actual=$(grep "^${expected%%:*}:" "$log_file" || true)
  (( run_status == 0 )) || fail "$description" "$run_output"
  [[ $actual == "$expected" ]] || fail "$description" "$actual"
  pass "$description"
}

assert_not_logged() {
  local prefix=$1
  local description=$2
  local actual

  (( run_status == 0 )) || fail "$description" "$run_output"
  actual=$(grep "^${prefix}:" "$log_file" || true)
  [[ -z $actual ]] || fail "$description" "$actual"
  pass "$description"
}

run_voxtype omarchy-install-dictation-voxtype yes
assert_not_logged "pkg-add" "dictation install leaves an existing voxtype command in place"

run_voxtype omarchy-install-dictation-voxtype no
assert_logged "pkg-add:wtype voxtype-bin" "dictation install adds wtype and voxtype-bin when the voxtype command is absent"

run_voxtype omarchy-remove-dictation-voxtype yes
assert_logged "pkg-drop:voxtype-bin voxtype-bin-rc voxtype" "dictation removal drops every voxtype package"

require_command node

dictation_guards=$(node -e '
  const fs = require("fs")
  const path = require("path")
  const menu = require(path.join(process.env.ROOT, "shell/plugins/menu/MenuModel.js"))
  const items = menu.parseMenuJsonc(fs.readFileSync(path.join(process.env.ROOT, "default/omarchy/omarchy-menu.jsonc"), "utf8"))
  const byId = Object.fromEntries(items.map(item => [item.id, item]))
  process.stdout.write(byId["remove.dictation"].when + "\n" + byId["remove.dictation.voxtype"].when)
')

[[ $dictation_guards == $'omarchy-cmd-present voxtype || omarchy-pkg-present superwhisper-bin\nomarchy-cmd-present voxtype' ]] ||
  fail "dictation menu guards follow the voxtype command" "$dictation_guards"
pass "dictation menu guards follow the voxtype command"
