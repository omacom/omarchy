#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin" "$tmp_dir/home"
export HOME="$tmp_dir/home"
export TEST_LOG="$tmp_dir/log"
export PATH="$tmp_dir/bin:$PATH"

cat >"$tmp_dir/bin/gum" <<'STUB'
#!/bin/bash
printf 'gum:%s\n' "$*" >>"$TEST_LOG"
exit 0
STUB

cat >"$tmp_dir/bin/omarchy-pkg-add" <<'STUB'
#!/bin/bash
printf 'add:%s\n' "$*" >>"$TEST_LOG"
STUB

cat >"$tmp_dir/bin/omarchy-pkg-present" <<'STUB'
#!/bin/bash
printf 'present:%s\n' "$*" >>"$TEST_LOG"
exit "${TEST_PRESENT_STATUS:-0}"
STUB

cat >"$tmp_dir/bin/omarchy-pkg-drop" <<'STUB'
#!/bin/bash
printf 'drop:%s\n' "$*" >>"$TEST_LOG"
STUB

cat >"$tmp_dir/bin/omarchy-notification-send" <<'STUB'
#!/bin/bash
printf 'notify:%s\n' "$*" >>"$TEST_LOG"
STUB

chmod +x "$tmp_dir/bin/gum" "$tmp_dir/bin/omarchy-pkg-add" \
  "$tmp_dir/bin/omarchy-pkg-present" "$tmp_dir/bin/omarchy-pkg-drop" \
  "$tmp_dir/bin/omarchy-notification-send"

make_app_stub() {
  local app=$1

  cat >"$tmp_dir/bin/$app" <<'STUB'
#!/bin/bash
printf '%s:%s\n' "$(basename "$0")" "$*" >>"$TEST_LOG"
if [[ $* == "setup" && ${TEST_SETUP_STATUS:-0} != 0 ]]; then
  exit "$TEST_SETUP_STATUS"
fi
if [[ $* == "setup check" && ${TEST_CHECK_STATUS:-0} != 0 ]]; then
  exit "$TEST_CHECK_STATUS"
fi
STUB
  chmod +x "$tmp_dir/bin/$app"
}

assert_installer_sequence() {
  local app=$1 package=$2
  local expected

  make_app_stub "$app"
  : >"$TEST_LOG"
  "$ROOT/bin/omarchy-install-ai-$app" >/dev/null

  expected=$(cat <<EOF
gum:confirm Install ${app^}, run guided setup, and enable its user service?
add:$package
$app:setup
$app:setup check
$app:setup systemd
notify:${app^} Ready The $(if [[ $app == omawake ]]; then printf 'wake-word daemon'; else printf 'text-to-speech daemon'; fi) is configured and running.
EOF
)

  [[ $(cat "$TEST_LOG") == "$expected" ]] ||
    fail "$app install configures and validates before enabling its service" "$(cat "$TEST_LOG")"
  pass "$app install configures and validates before enabling its service"

  : >"$TEST_LOG"
  if TEST_CHECK_STATUS=23 "$ROOT/bin/omarchy-install-ai-$app" >/dev/null 2>&1; then
    fail "$app install stops when setup validation fails"
  fi

  grep -qx "$app:setup check" "$TEST_LOG" ||
    fail "$app install runs setup validation before stopping"
  ! grep -qx "$app:setup systemd" "$TEST_LOG" ||
    fail "$app install does not enable a service after failed validation"
  ! grep -q '^notify:' "$TEST_LOG" ||
    fail "$app install does not report readiness after failed validation"
  pass "$app install stops before service enablement when setup validation fails"

  : >"$TEST_LOG"
  if TEST_SETUP_STATUS=19 "$ROOT/bin/omarchy-install-ai-$app" >/dev/null 2>&1; then
    fail "$app install stops when guided setup fails"
  fi

  grep -qx "$app:setup" "$TEST_LOG" ||
    fail "$app install runs guided setup before stopping"
  ! grep -qx "$app:setup check" "$TEST_LOG" ||
    fail "$app install does not validate an incomplete guided setup"
  ! grep -qx "$app:setup systemd" "$TEST_LOG" ||
    fail "$app install does not enable a service after failed guided setup"
  ! grep -q '^notify:' "$TEST_LOG" ||
    fail "$app install does not report readiness after failed guided setup"
  pass "$app install stops before validation and service enablement when guided setup fails"
}

assert_installer_sequence omawake omawake-bin
assert_installer_sequence omaspeak omaspeak-bin

assert_remover_sequence() {
  local app=$1 package=$2 data_description=$3
  local expected

  make_app_stub "$app"
  mkdir -p "$HOME/.cache/$app" "$HOME/.config/$app" "$HOME/.local/share/$app" "$HOME/.local/state/$app"
  : >"$TEST_LOG"
  "$ROOT/bin/omarchy-remove-ai-$app" >/dev/null

  expected=$(cat <<EOF
present:$package
$app:setup systemd --uninstall
drop:$package
notify:${app^} Removed $data_description
EOF
)
  [[ $(cat "$TEST_LOG") == "$expected" ]] ||
    fail "$app removal targets its bin package and stops the service first" "$(cat "$TEST_LOG")"
  for directory in .cache .config .local/share .local/state; do
    [[ ! -e $HOME/$directory/$app ]] ||
      fail "$app removal deletes its application data" "$directory/$app"
  done
  pass "$app removal targets its bin package, stops its service, and deletes its data"

  : >"$TEST_LOG"
  TEST_PRESENT_STATUS=1 "$ROOT/bin/omarchy-remove-ai-$app" >/dev/null
  [[ $(cat "$TEST_LOG") == "present:$package" ]] ||
    fail "$app removal leaves an absent package alone" "$(cat "$TEST_LOG")"
  pass "$app removal leaves an absent package alone"
}

assert_remover_sequence omawake omawake-bin "Omawake and its local data were removed."
assert_remover_sequence omaspeak omaspeak-bin "Omaspeak and its local data were removed."

run_node_test <<'JS'
const fs = require('fs')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const parsed = menu.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
const items = Object.fromEntries(parsed.map(item => [item.id, item]))

for (const [app, packageName] of [['omawake', 'omawake-bin'], ['omaspeak', 'omaspeak-bin']]) {
  const install = items[`install.ai.${app}`]
  const remove = items[`remove.ai.${app}`]
  assert(install, `${app} has an Install > AI menu entry`)
  assert(remove, `${app} has a Remove > AI menu entry`)
  assertEqual(install.disabled, `omarchy-pkg-present ${packageName}`, `${app} install entry uses the bin package guard`)
  assertEqual(install.action, `omarchy-launch-floating-terminal-with-presentation omarchy-install-ai-${app}`, `${app} install entry opens guided setup in a terminal`)
  assertEqual(remove.when, `omarchy-pkg-present ${packageName}`, `${app} remove entry uses the bin package guard`)
  assertEqual(remove.action, `omarchy-launch-floating-terminal-with-presentation omarchy-remove-ai-${app}`, `${app} remove entry opens its remover in a terminal`)
}
JS
