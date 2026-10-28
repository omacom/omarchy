#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq

run_node_test <<'JS'
const fs = require('fs')
const bounce = requireFromRoot('shell/plugins/screensaver-bounce/BounceModel.js')

const logo = bounce.parseArt(fs.readFileSync(path.join(root, 'logo.txt'), 'utf8'))
assert(logo.blocks, 'the stock logo is read as block pixels')
assertEqual(logo.columns, 162, 'block pixels are half a character wide, trimmed to the ink')
assertEqual(logo.rows, 19, 'block pixels are half a row tall, trimmed to the ink')
const inked = Array.from(fs.readFileSync(path.join(root, 'logo.txt'), 'utf8')).reduce((sum, ch) =>
  sum + ({ '█': 4, '▀': 2, '▄': 2 }[ch] || 0), 0)
assertEqual(logo.runs.reduce((sum, run) => sum + run.width, 0), inked, 'the runs cover every inked pixel once')

assertDeepEqual(bounce.parseArt('\n  ▐▌\n'), {
  blocks: true, text: '▐▌', columns: 2, rows: 2,
  runs: [{ x: 0, y: 0, width: 2 }, { x: 0, y: 1, width: 2 }]
}, 'quarter blocks are read at half-character resolution')

assertDeepEqual(bounce.parseArt('  <o>\n\t |\n'), {
  blocks: false, text: '<o>\n       |', columns: 8, rows: 2, runs: []
}, 'other art is kept as text, its tabs expanded and indent trimmed')

assertDeepEqual(bounce.legs(30, 1, 100, 50), {
  first: { from: 30, to: 100, duration: 1400 },
  out: { from: 100, to: 0, duration: 2000 },
  back: { from: 0, to: 100, duration: 2000 }
}, 'heading out, the logo runs to the far wall, then sweeps back and forth')
assertDeepEqual(bounce.legs(30, -1, 100, 50).first, { from: 30, to: 0, duration: 600 },
  'heading back, the first leg ends at the near wall')
assert(bounce.isCorner(100, 101.5, 2), 'walls met within a couple of frames make a corner')
assert(!bounce.isCorner(100, 130, 2), 'walls met half a second apart do not')

assert(/^#[0-9a-f]{6}$/.test(bounce.colorFor(200)), 'colors are #rrggbb')
for (let hue = 0; hue < 360; hue += 45) {
  const next = bounce.nextHue(hue, 0)
  assert((next - hue + 360) % 360 >= 72, `a wall moves the color well round the wheel from ${hue}`)
}
JS

tmpdir=$(mktemp -d)
cleanup() {
  [[ -f $tmpdir/socat.pid ]] && kill "$(<"$tmpdir/socat.pid")" 2>/dev/null || true
  rm -rf "$tmpdir"
}
trap cleanup EXIT

mkdir -p "$tmpdir/bin" "$tmpdir/home/.config/omarchy/branding"
cat >"$tmpdir/bin/hyprctl" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_DIR/calls"
case "$*" in
  'activewindow -j') printf '{"class":"org.omarchy.screensaver"}\n' ;;
  'monitors -j') printf '[{"name":"DP-1","specialWorkspace":{"name":""}}]\n' ;;
  'clients -j') printf '[]\n' ;;
  *exec_cmd*) printf 'openwindow>>1,1,org.omarchy.screensaver,foot\n' >"$TEST_DIR/events" ;;
esac
SH
cat >"$tmpdir/bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_DIR/shell-calls"
[[ $* == *summon* && -n $SHELL_UP ]] && echo ok
exit 0
SH
cat >"$tmpdir/bin/ttfx" <<'SH'
#!/bin/bash
if [[ $1 == "--help" ]]; then
  printf 'Usage: ttfx [OPTIONS] [COMMAND]\n\nCommands:\n  help  Print help\n\nOptions:\n'
else
  echo ran >"$TEST_DIR/ttfx"
  exec sleep 5
fi
SH
printf '#!/bin/bash\nexit 0\n' >"$tmpdir/bin/pkill"
chmod +x "$tmpdir/bin/"*

# With no other effects to pick from, the screensaver always picks the bounce.
screensaver() {
  : >"$tmpdir/shell-calls"
  rm -f "$tmpdir/ttfx"
  started=$SECONDS
  HOME="$tmpdir/home" PATH="$tmpdir/bin:$PATH" TEST_DIR="$tmpdir" \
    timeout 10 "$ROOT/bin/omarchy-screensaver" DP-1 < <(sleep 1.5; printf q) >/dev/null 2>&1 || true
  elapsed=$((SECONDS - started))
}

SHELL_UP=1 screensaver
grep -qxF 'shell summon omarchy.screensaver-bounce {"monitor":"DP-1","seconds":30}' "$tmpdir/shell-calls" ||
  fail "the screensaver has the shell bounce the logo on its monitor" "$(cat "$tmpdir/shell-calls")"
pass "the screensaver has the shell bounce the logo on its monitor"

(( elapsed < 4 )) && grep -qxF -- '-q shell hide omarchy.screensaver-bounce' "$tmpdir/shell-calls" ||
  fail "a keypress during the bounce ends it" "after ${elapsed}s: $(cat "$tmpdir/shell-calls")"
pass "a keypress during the bounce ends it"

SHELL_UP="" screensaver
[[ -f $tmpdir/ttfx ]] || fail "without the shell the screensaver runs a text effect instead"
pass "without the shell the screensaver runs a text effect instead"

# The launcher tells each screensaver which monitor it is on.
mkfifo "$tmpdir/events"
exec {events}<>"$tmpdir/events"
cat >"$tmpdir/bin/socat" <<'SH'
#!/bin/bash
printf '%s\n' "$$" >"$TEST_DIR/socat.pid"
exec cat "$TEST_DIR/events"
SH
printf '#!/bin/bash\nexit 1\n' >"$tmpdir/bin/pgrep"
printf '#!/bin/bash\necho DP-1\n' >"$tmpdir/bin/omarchy-hyprland-monitor-focused"
printf '#!/bin/bash\necho foot.desktop\n' >"$tmpdir/bin/xdg-terminal-exec"
chmod +x "$tmpdir/bin/"*

: >"$tmpdir/calls"
PATH="$tmpdir/bin:$PATH" TEST_DIR="$tmpdir" XDG_RUNTIME_DIR="$tmpdir" HYPRLAND_INSTANCE_SIGNATURE=test \
  timeout 10 "$ROOT/bin/omarchy-launch-screensaver" force
kill "$(<"$tmpdir/socat.pid")" 2>/dev/null || true
[[ $(grep exec_cmd "$tmpdir/calls") == *"omarchy-screensaver DP-1"* ]] ||
  fail "the launcher tells each screensaver its monitor" "$(grep exec_cmd "$tmpdir/calls")"
pass "the launcher tells each screensaver its monitor"
