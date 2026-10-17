#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"
cat >"$tmp_dir/bin/omarchy-pkg-drop" <<'SCRIPT'
#!/bin/bash
printf 'drop:%s\n' "$*" >>"$TEST_LOG"
exit "${TEST_DROP_STATUS:-0}"
SCRIPT
chmod +x "$tmp_dir/bin/omarchy-pkg-drop"

export TEST_LOG="$tmp_dir/log"
export PATH="$tmp_dir/bin:$PATH"
export HOME="$tmp_dir/home"

for app in lm-studio lm-studio-bionic; do
  remover="$ROOT/bin/omarchy-remove-ai-$app"
  if [[ $app == "lm-studio" ]]; then
    package="lmstudio-bin"
  else
    package="lmstudio-bionic"
  fi

  for layout in default relocated; do
    rm -rf "$HOME" "$tmp_dir/before" "$tmp_dir/relocated home" "$tmp_dir/relocated-before"
    mkdir -p "$HOME/.config/LM Studio" "$HOME/.config/LM-Studio" "$HOME/.config/Bionic" \
      "$HOME/.cache/LM Studio" "$HOME/.cache/Bionic" "$HOME/.cache/lm-studio" \
      "$HOME/.lmstudio/models" "$HOME/.lmstudio/extensions" \
      "$HOME/.lmstudio/apps/bionic/projects" "$HOME/Documents/my-code"
    touch "$HOME/.config/LM Studio/settings.json" "$HOME/.config/LM-Studio/settings.json" \
      "$HOME/.config/Bionic/settings.json" "$HOME/.cache/LM Studio/cached-data" \
      "$HOME/.cache/Bionic/cached-data" "$HOME/.cache/lm-studio/legacy-data" \
      "$HOME/.lmstudio/models/model.gguf" "$HOME/.lmstudio/extensions/runtime" \
      "$HOME/.lmstudio/apps/bionic/projects/session.json" "$HOME/Documents/my-code/main.py"
    printf '%s' "$HOME/.lmstudio" >"$HOME/.lmstudio-home-pointer"

    if [[ $layout == "relocated" ]]; then
      mv "$HOME/.lmstudio" "$tmp_dir/relocated home"
      printf '%s' "$tmp_dir/relocated home" >"$HOME/.lmstudio-home-pointer"
      cp -R "$tmp_dir/relocated home" "$tmp_dir/relocated-before"
    fi
    cp -R "$HOME" "$tmp_dir/before"

    : >"$TEST_LOG"
    "$remover" >/dev/null
    [[ $(cat "$TEST_LOG") == "drop:$package" ]] || fail "$app removal drops only its own package" "$(cat "$TEST_LOG")"
    pass "$app removal drops only its own package ($layout home)"

    "$remover" >/dev/null
    if TEST_DROP_STATUS=1 "$remover" >/dev/null 2>&1; then
      fail "$app removal reports a failed package removal"
    fi
    pass "$app removal reports a failed package removal ($layout home)"

    diff -r "$tmp_dir/before" "$HOME" || fail "$app removal preserves all user configuration and data"
    if [[ $layout == "relocated" ]]; then
      diff -r "$tmp_dir/relocated-before" "$tmp_dir/relocated home" || fail "$app removal preserves relocated data"
    fi
    pass "$app removal preserves all user data after successful, repeated, and failed removal ($layout home)"
  done

  rm -rf "$HOME"
  mkdir -p "$HOME"
  "$remover" >/dev/null
  pass "$app removal tolerates absent profiles and data"
done

run_node_test <<'JS'
const fs = require('fs')
const menu = requireFromRoot('shell/plugins/menu/MenuModel.js')
const rows = menu.parseMenuJsonc(fs.readFileSync(path.join(root, 'default/omarchy/omarchy-menu.jsonc'), 'utf8'))
for (const [id, app, pkg] of [['lm-studio', 'lm-studio', 'lmstudio-bin'], ['bionic', 'lm-studio-bionic', 'lmstudio-bionic']]) {
  const row = rows.find(row => row.id === `remove.ai.${id}`)
  assertEqual(row.action, `omarchy-launch-floating-terminal-with-presentation omarchy-remove-ai-${app}`, `${app} menu runs its dedicated remover in a terminal`)
  assertEqual(row.when, `omarchy-pkg-present ${pkg}`, `${app} removal is offered only for an installed package`)
}
JS
