#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command python3
test_tmp=$(mktemp -d)
server_pid=""
trap '[[ -z $server_pid ]] || kill "$server_pid"; rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/source"
for command in omarchy-theme-set omarchy-shell; do
  printf '#!/bin/bash\nexit 0\n' >"$test_tmp/bin/$command"
  chmod +x "$test_tmp/bin/$command"
done
cat >"$test_tmp/source/manifest.json" <<'JSON'
{"schemaVersion":1,"id":"acme.clone","name":"Clone test","version":"1.0.0","kinds":["bar-widget"],"entryPoints":{"barWidget":"Widget.qml"},"barWidget":{"displayName":"Clone test","category":"Test","allowMultiple":false}}
JSON
printf 'import QtQuick\nItem {}\n' >"$test_tmp/source/Widget.qml"
git -C "$test_tmp/source" init -q
git -C "$test_tmp/source" add .
git -C "$test_tmp/source" -c user.name=Test -c user.email=test@example.com commit -qm Initial
git -C "$test_tmp/source" -c user.name=Test -c user.email=test@example.com commit --allow-empty -qm Second
git clone -q --bare "$test_tmp/source" "$test_tmp/addon.git"
git -C "$test_tmp/addon.git" update-server-info

python3 - "$test_tmp" >"$test_tmp/http.log" 2>&1 <<'PY' &
import http.server
import pathlib
import sys
root = pathlib.Path(sys.argv[1])
handler = lambda *args, **kwargs: http.server.SimpleHTTPRequestHandler(*args, directory=str(root), **kwargs)
with http.server.HTTPServer(('127.0.0.1', 0), handler) as server:
    (root / 'port').write_text(str(server.server_port))
    server.serve_forever()
PY
server_pid=$!
for (( attempt = 0; attempt < 100; attempt++ )); do
  [[ -s $test_tmp/port ]] && break
  sleep 0.05
done
[[ -s $test_tmp/port ]] || fail "HTTP test server starts"
http_url="http://127.0.0.1:$(cat "$test_tmp/port")/addon.git"

export OMARCHY_PATH="$ROOT" PATH="$test_tmp/bin:$ROOT/bin:$PATH"
for installer in theme plugin; do
  if [[ $installer == "theme" ]]; then
    command=(omarchy-theme-install)
    relative_path="themes/addon"
  else
    command=(omarchy-plugin-add --yes)
    relative_path="plugins/acme.clone"
  fi
  export HOME="$test_tmp/$installer-home"
  target="$HOME/.config/omarchy/$relative_path"
  for mode in unset 0 1; do
    unset OMARCHY_GIT_FULL_CLONE
    [[ $mode == "unset" ]] || export OMARCHY_GIT_FULL_CLONE="$mode"
    rm -rf "$target"
    "${command[@]}" "file://$test_tmp/addon.git" >"$test_tmp/out" 2>&1 || fail "$installer clones with override $mode" "$(cat "$test_tmp/out")"
    if [[ $mode == "1" ]]; then
      [[ $(git -C "$target" rev-list --count HEAD) == "2" ]] || fail "$installer full clone includes history"
      [[ $(git -C "$target" rev-parse --is-shallow-repository) == "false" ]] || fail "$installer full clone is not shallow"
    else
      [[ $(git -C "$target" rev-parse --is-shallow-repository) == "true" ]] || fail "$installer defaults to a shallow clone with override $mode"
    fi
  done
  pass "$installer defaults to shallow clones and supports OMARCHY_GIT_FULL_CLONE=1"

  unset OMARCHY_GIT_FULL_CLONE
  rm -rf "$target"
  if "${command[@]}" "$http_url" >"$test_tmp/out" 2>&1; then
    fail "$installer shallow clone fails against dumb HTTP"
  fi
  grep -qF 'OMARCHY_GIT_FULL_CLONE=1' "$test_tmp/out" || fail "$installer explains the full-clone override" "$(cat "$test_tmp/out")"
  OMARCHY_GIT_FULL_CLONE=1 "${command[@]}" "$http_url" >"$test_tmp/out" 2>&1 || fail "$installer full clone works against dumb HTTP" "$(cat "$test_tmp/out")"
  [[ $(git -C "$target" rev-list --count HEAD) == "2" ]] || fail "$installer dumb HTTP clone includes history"
  pass "$installer can install from dumb HTTP with the override"
done
